/* Sequencer sweep and detector control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "common.h"
#include "configs.h"
#include "hardware.h"

#include "sequencer.h"


/* These are the sequencer states for states 1 to 7.  State 0 is special and
 * is not handled in this array. */
struct sequencer_bank {
    /* Much of our state is as written to hardware. */
    struct seq_entry *entry;

    /* These two records need updating during user editing. */
    struct epics_record *delta_freq_rec;
    struct epics_record *end_freq_rec;
};


struct seq_context {
    int channel;

    struct seq_config seq_config;   // Hardware configuration set by EPICS
    struct sequencer_bank banks[MAX_SEQUENCER_COUNT];   // EPICS management
    struct seq_config seq_hw_config;    // Configuration written to hardware

    struct seq_state seq_state;     // Current state as read from hardware

    unsigned int capture_count;     // Number of IQ points to capture
    unsigned int sequencer_duration; // Total duration of sequence

    bool reset_offsets;             // Reset super sequencer offsets
    bool reset_window;              // Reset detector window
} seq_context[CHANNEL_COUNT];



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* The management of the sweep interval is tricky.  The interval is defined by
 * four numbers: START_FREQ, STEP_FREQ, END_FREQ, COUNT which are interrelated
 * by the formula:
 *
 *  START_FREQ + STEP_FREQ * COUNT = END_FREQ
 *
 * Note that this defines a "half open" interval, where START_FREQ is in the
 * range of swept frequencies, but END_FREQ is never actually reached.
 *
 * Another tricky detail is how we want this to behave during editing.  The
 * basic usability principle is that the interval length (END-START) should stay
 * fixed when changing START_FREQ or COUNT ... but unfortunately if we have both
 * END_FREQ and STEP_FREQ changed by two inputs we can't choose a consistent set
 * of parameters for a safe reload (we don't have control over the order in
 * which parameter are restored). So, we define the following update
 * dependencies:
 *
 *  when changing       update this
 *  -------------       -----------
 *  START_FREQ          END_FREQ
 *  STEP_FREQ           END_FREQ
 *  COUNT               END_FREQ
 *  END_FREQ            STEP_FREQ
 *
 * With this set of rules we see that END_FREQ is derived and so should not be
 * part of the persistent state.
 *
 * A final tricky detail is that the underlying value for STEP_FREQ is a 32-bit
 * integer, and the formula above defining END_FREQ needs to be calculated as
 * 32-bit numbers -- so both STEP_FREQ and END_FREQ may end up as values
 * different from what the user has written! */

static bool write_start_freq(void *context, double *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    entry->start_freq = tune_to_freq(*value);
    *value = freq_to_tune(entry->start_freq);
    return true;
}

static bool write_step_freq(void *context, double *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    entry->delta_freq = tune_to_freq(*value);
    *value = freq_to_tune_signed(entry->delta_freq);
    return true;
}

static bool write_end_freq(void *context, double *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    double target_delta_freq =
        (*value - freq_to_tune(entry->start_freq)) / entry->capture_count;
    entry->delta_freq = tune_to_freq(target_delta_freq);
    double actual_delta_freq = freq_to_tune_signed(entry->delta_freq);
    WRITE_OUT_RECORD(ao, bank->delta_freq_rec, actual_delta_freq, false);
    return true;
}


/* This is called when any of START_FREQ, STEP_FREQ, COUNT have changed.
 * END_FREQ is updated. */
static bool update_end_freq(void *context, bool *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    unsigned int end_freq =
        entry->start_freq + entry->capture_count * entry->delta_freq;
    WRITE_OUT_RECORD(ao, bank->end_freq_rec, freq_to_tune(end_freq), false);
    return true;
}


static bool write_bank_count(void *context, unsigned int *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    entry->capture_count = *value;
    return update_end_freq(context, NULL);
}


static bool write_dwell_time(void *context, unsigned int *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;

    entry->dwell_time = *value;
    /* The window_rate calculation is a little tricky.  We want the window
     * to advance from 0 to 2^32 in dwell_time turns ... but it advances one
     * tick (one window_rate value) every two bunches. */
    entry->window_rate = (unsigned int) lround(
        ldexp(1, 33) / (hardware_config.bunches * entry->dwell_time));

    return true;
}


static void publish_bank(int ix, struct sequencer_bank *bank)
{
    char prefix[4];
    sprintf(prefix, "%d", ix + 1);
    WITH_NAME_PREFIX(prefix)
    {
        struct seq_entry *entry = bank->entry;
        PUBLISH_WRITE_VAR_P(mbbo, "BANK", entry->bunch_bank);
        PUBLISH_WRITE_VAR_P(mbbo, "GAIN", entry->nco_gain);
        PUBLISH_WRITE_VAR_P(bo, "ENABLE", entry->nco_enable);
        PUBLISH_WRITE_VAR_P(bo, "ENWIN", entry->enable_window);
        PUBLISH_WRITE_VAR_P(bo, "CAPTURE", entry->write_enable);
        PUBLISH_WRITE_VAR_P(bo, "BLANK", entry->enable_blanking);
        PUBLISH_WRITE_VAR_P(ulongout, "HOLDOFF", entry->holdoff);

        PUBLISH_C_P(ulongout, "DWELL", write_dwell_time, bank);

        PUBLISH_C_P(ulongout, "COUNT", write_bank_count, bank);

        PUBLISH_C_P(ao, "START_FREQ", write_start_freq, bank);
        bank->delta_freq_rec =
            PUBLISH_C_P(ao, "STEP_FREQ", write_step_freq, bank);
        bank->end_freq_rec = PUBLISH_C(ao, "END_FREQ", write_end_freq, bank);

        PUBLISH_C(bo, "UPDATE_END", update_end_freq, bank);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


static bool set_state0_bunch_bank(void *context, unsigned int *bank)
{
    struct seq_context *seq = context;
    seq->seq_config.bank0 = *bank;
    hw_write_seq_bank0(seq->channel, *bank);
    return true;
}


static bool update_capture_count(void *context, bool *value)
{
    struct seq_context *seq = context;
    seq->capture_count = 0;
    seq->sequencer_duration = 0;
    for (unsigned int i = 0; i < seq->seq_config.sequencer_pc; i ++)
    {
        struct sequencer_bank *bank = &seq->banks[i];
        if (bank->entry->write_enable)
            seq->capture_count += bank->entry->capture_count;
        seq->sequencer_duration +=
            bank->entry->capture_count *
            (bank->entry->dwell_time + bank->entry->holdoff);
    }
    return true;
}


static bool write_seq_reset(void *context, bool *value)
{
    struct seq_context *seq = context;
    hw_write_seq_abort(seq->channel);
    return true;
}


static bool write_seq_trig_state(void *context, unsigned int *value)
{
    struct seq_context *seq = context;
    hw_write_seq_trigger_state(seq->channel, *value);
    return true;
}


static bool read_seq_status(void *context, bool *value)
{
    struct seq_context *seq = context;
    hw_read_seq_state(seq->channel, &seq->seq_state);
    return true;
}


static void write_super_offsets(void *context, double offsets[], size_t *length)
{
    struct seq_context *seq = context;
    *length = SUPER_SEQ_STATES;

    if (seq->reset_offsets)
    {
        for (unsigned int i = 0; i < SUPER_SEQ_STATES; i ++)
            if (i < hardware_config.bunches)
                offsets[i] = i;
            else
                offsets[i] = 0;
        seq->reset_offsets = false;
    }

    for (int i = 0; i < SUPER_SEQ_STATES; i ++)
        seq->seq_config.super_offsets[i] = tune_to_freq(offsets[i]);
}

static bool reset_super_offsets(void *context, bool *value)
{
    struct seq_context *seq = context;
    seq->reset_offsets = true;
    return true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


static void compute_default_window(float window[])
{
    /* Compute a Hamming window as our default window. */
    float a = 0.54F;
    float b = 1 - a;
    float f = 2 * (float) M_PI / (DET_WINDOW_LENGTH - 1);
    for (int i = 0; i < DET_WINDOW_LENGTH; i ++)
        window[i] = a - b * cosf(f * (float) i);
}


static void write_detector_window(
    void *context, float window[], size_t *length)
{
    struct seq_context *seq = context;
    if (seq->reset_window)
    {
        compute_default_window(window);
        seq->reset_window = false;
    }

    *length = DET_WINDOW_LENGTH;
    float_array_to_int(
        DET_WINDOW_LENGTH, window, seq->seq_config.window, 16, 0);
}


static bool reset_detector_window(void *context, bool *value)
{
    struct seq_context *seq = context;
    seq->reset_window = true;
    return true;
}


/* Computes frequency and timebase scales from detector configuration. */
static void update_scale_info(
    const struct seq_config *seq_config, unsigned int length,
    struct scale_info *scale_info)
{
    unsigned int super_count = seq_config->super_seq_count;
    unsigned int seq_count = seq_config->sequencer_pc;

    /* Iterate through super sequencer. */
    unsigned int ix = 0;            // Index into generated vectors
    unsigned int total_time = 0;    // Accumulates time base
    unsigned int gap_time = 0;      // For non-captured states
    unsigned int f0 = 0;            // Accumulates current frequency
    for (unsigned int super = 0; super < super_count; super ++)
        for (unsigned int state = seq_count; state > 0; state --)
        {
            const struct seq_entry *entry = &seq_config->entries[state - 1];
            unsigned int dwell_time = entry->dwell_time + entry->holdoff;
            if (entry->write_enable)
            {
                f0 = entry->start_freq + seq_config->super_offsets[super];
                total_time += gap_time;
                gap_time = 0;
                for (unsigned int i = 0; i < entry->capture_count; i ++)
                {
                    if (ix < length)
                    {
                        scale_info->tune_scale[ix] = freq_to_tune(f0);
                        scale_info->timebase[ix] = (int) total_time;
                    }
                    f0 += entry->delta_freq;
                    total_time += dwell_time;
                    ix += 1;
                }
            }
            else
                gap_time += dwell_time * entry->capture_count;
        }

    /* Fill in the rest of the waveforms. */
    double final_f = freq_to_tune(f0);
    for (unsigned int i = ix; i < length; i ++)
    {
        scale_info->tune_scale[i] = final_f;
        scale_info->timebase[i] = (int) total_time;
    }
    scale_info->samples = ix;
}


/* This is called before arming the sequencer.  We remember a copy of the
 * sequencer state and write this to hardware.  The copy is remembered so that
 * when a subsequent request is made for the scale info we will return a
 * truthful version. */
void prepare_sequencer(int channel)
{
    struct seq_context *seq = &seq_context[channel];
    seq->seq_hw_config = seq->seq_config;
    hw_write_seq_config(seq->channel, &seq->seq_hw_config);
}


/* This is called as part of detector readout, at which point we want to present
 * the user with an accurate view of the detector scaling. */
void read_detector_scale_info(
    int channel, unsigned int length, struct scale_info *info)
{
    const struct seq_context *seq = &seq_context[channel];
    update_scale_info(&seq->seq_hw_config, length, info);
}


error__t initialise_sequencer(void)
{
    FOR_CHANNEL_NAMES(channel, "SEQ")
    {
        struct seq_context *seq = &seq_context[channel];
        seq->channel = channel;

        PUBLISH_C_P(mbbo, "0:BANK", set_state0_bunch_bank, seq);
        for (int i = 0; i < MAX_SEQUENCER_COUNT; i ++)
        {
            seq->banks[i].entry = &seq->seq_config.entries[i];
            publish_bank(i, &seq->banks[i]);
        }

        PUBLISH_C(bo, "UPDATE_COUNT", update_capture_count, seq);

        PUBLISH_WRITE_VAR_P(ulongout, "PC", seq->seq_config.sequencer_pc);
        PUBLISH_READ_VAR(ulongin, "PC", seq->seq_state.pc);
        PUBLISH_C(bo, "RESET", write_seq_reset, seq);
        PUBLISH_C_P(ulongout, "TRIGGER", write_seq_trig_state, seq);

        PUBLISH_READ_VAR(ulongin, "LENGTH", seq->capture_count);
        PUBLISH_READ_VAR(ulongin, "DURATION", seq->sequencer_duration);

        /* Super sequencer control and readback. */
        WITH_NAME_PREFIX("SUPER")
        {
            PUBLISH_READ_VAR(ulongin, "COUNT", seq->seq_state.super_pc);
            PUBLISH_WRITE_VAR_P(
                ulongout, "COUNT", seq->seq_config.super_seq_count);
            PUBLISH_WAVEFORM_C_P(
                double, "OFFSET", SUPER_SEQ_STATES, write_super_offsets, seq);
            PUBLISH_C(bo, "RESET", reset_super_offsets, seq);
        }

        PUBLISH_READ_VAR(bi, "BUSY", seq->seq_state.busy);
        PUBLISH_C(bo, "STATUS:READ", read_seq_status, seq);

        seq->reset_window = true;
        PUBLISH_WAVEFORM_C(
            float, "WINDOW", DET_WINDOW_LENGTH, write_detector_window, seq);
        PUBLISH_C(bo, "RESET_WIN", reset_detector_window, seq);
    }

    return ERROR_OK;
}
