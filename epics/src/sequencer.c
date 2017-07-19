/* Sequencer sweep and detector control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "common.h"
#include "hardware.h"

#include "sequencer.h"


/* These are the sequencer states for states 1 to 7.  State 0 is special and
 * is not handled in this array. */
struct sequencer_bank {
    /* Much of our state is as written to hardware. */
    struct seq_entry entry;

    /* Some values need conversion from EPICS. */
    double start_freq;
    double delta_freq;

    /* These two records need updating during user editing. */
    struct epics_record *delta_freq_rec;
    struct epics_record *end_freq_rec;
};


struct seq_context {
    int channel;

    /* Sequencer state as currently seen through EPICS. */
    struct sequencer_bank banks[MAX_SEQUENCER_COUNT];
    unsigned int bank0;

    /* Sequencer program counter. */
    unsigned int sequencer_pc;

    /* Super sequencer state. */
    unsigned int super_seq_count;
    uint32_t super_offsets[SUPER_SEQ_STATES];
    bool reset_offsets;

    /* Current state as read from hardware. */
    bool busy;
    unsigned int current_pc;
    unsigned int current_super_pc;

    /* Capture count and duration for user display. */
    unsigned int capture_count;       // Number of IQ points to capture
    unsigned int sequencer_duration;  // Total duration of sequence

    /* Detector window. */
    bool reset_window;
    int window[DET_WINDOW_LENGTH];
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
 * part of the persistent state. */


/* This is called when END_FREQ is written, we update STEP_FREQ. */
static bool write_end_freq(void *context, const double *value)
{
    struct sequencer_bank *bank = context;
    bank->delta_freq = (*value - bank->start_freq) / bank->entry.capture_count;
    WRITE_OUT_RECORD(ao, bank->delta_freq_rec, bank->delta_freq, false);
    return true;
}


/* This is called when any of START_FREQ, STEP_FREQ, COUNT have changed.
 * END_FREQ is updated. */
static bool update_end_freq(void *context, const bool *value)
{
    struct sequencer_bank *bank = context;
    double end_freq =
        bank->start_freq + bank->entry.capture_count * bank->delta_freq;
    WRITE_OUT_RECORD(ao, bank->end_freq_rec, end_freq, false);
    return true;
}


static bool write_bank_count(void *context, const unsigned int *value)
{
    struct sequencer_bank *bank = context;
    bank->entry.capture_count = *value;
    return update_end_freq(context, NULL);
}


static void publish_bank(int ix, struct sequencer_bank *bank)
{
    char prefix[4];
    sprintf(prefix, "%d", ix + 1);
    WITH_NAME_PREFIX(prefix)
    {
        PUBLISH_WRITE_VAR_P(ao, "START_FREQ", bank->start_freq);
        PUBLISH_WRITE_VAR_P(ulongout, "DWELL", bank->entry.dwell_time);
        PUBLISH_WRITE_VAR_P(mbbo, "BANK", bank->entry.bunch_bank);
        PUBLISH_WRITE_VAR_P(mbbo, "GAIN", bank->entry.nco_gain);
        PUBLISH_WRITE_VAR_P(bo, "ENABLE", bank->entry.nco_enable);
        PUBLISH_WRITE_VAR_P(bo, "ENWIN", bank->entry.enable_window);
        PUBLISH_WRITE_VAR_P(bo, "CAPTURE", bank->entry.write_enable);
        PUBLISH_WRITE_VAR_P(bo, "BLANK", bank->entry.enable_blanking);
        PUBLISH_WRITE_VAR_P(ulongout, "HOLDOFF", bank->entry.holdoff);

        PUBLISH_C_P(ulongout, "COUNT", write_bank_count, bank);

        bank->delta_freq_rec =
            PUBLISH_WRITE_VAR_P(ao, "STEP_FREQ", bank->delta_freq);
        bank->end_freq_rec = PUBLISH_C(ao, "END_FREQ", write_end_freq, bank);

        PUBLISH_C(bo, "UPDATE_END", update_end_freq, bank);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


static bool set_state0_bunch_bank(void *context, const unsigned int *bank)
{
    struct seq_context *seq = context;
    seq->bank0 = *bank;
    hw_write_seq_entries(seq->channel, seq->bank0, NULL);
    return true;
}


static bool update_capture_count(void *context, const bool *value)
{
    struct seq_context *seq = context;
    seq->capture_count = 0;
    seq->sequencer_duration = 0;
    for (unsigned int i = 0; i < seq->sequencer_pc; i ++)
    {
        struct sequencer_bank *bank = &seq->banks[i];
        if (bank->entry.write_enable)
            seq->capture_count += bank->entry.capture_count;
        seq->sequencer_duration +=
            bank->entry.capture_count *
            (bank->entry.dwell_time + bank->entry.holdoff);
    }
    return true;
}


static bool write_seq_reset(void *context, const bool *value)
{
    struct seq_context *seq = context;
    hw_write_seq_abort(seq->channel);
    return true;
}


static bool write_seq_trig_state(void *context, const unsigned int *value)
{
    struct seq_context *seq = context;
    hw_write_seq_trigger_state(seq->channel, *value);
    return true;
}


static bool read_seq_status(void *context, const bool *value)
{
    struct seq_context *seq = context;
    hw_read_seq_state(
        seq->channel, &seq->busy, &seq->current_pc, &seq->current_super_pc);
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
        seq->super_offsets[i] = tune_to_freq(offsets[i]);
}

static bool reset_super_offsets(void *context, const bool *value)
{
    struct seq_context *seq = context;
    seq->reset_offsets = true;
    return true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/* Prepare a single sequencer bank entry ready for writing to hardware. */
static void prepare_seq_entry(
    const struct sequencer_bank *bank, struct seq_entry *entry)
{
    *entry = bank->entry;
    entry->start_freq = tune_to_freq(bank->start_freq);
    entry->delta_freq = tune_to_freq(bank->delta_freq);
    /* The window_rate calculation is a little tricky.  We want the window to
     * advance from 0 to 2^32 in dwell_time turns ... but it advances one tick
     * (one window_rate value) every two bunches. */
    entry->window_rate = (unsigned int) lround(
        pow(2, 31) / (hardware_config.bunches * bank->entry.dwell_time));
}


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
    float_array_to_int(DET_WINDOW_LENGTH, window, seq->window, 16, 0);
}


static bool reset_detector_window(void *context, const bool *value)
{
    struct seq_context *seq = context;
    seq->reset_window = true;
    return true;
}


void prepare_sequencer(int channel)
{
    struct seq_context *seq = &seq_context[channel];

    struct seq_entry seq_entries[MAX_SEQUENCER_COUNT];
    for (int i = 0; i < MAX_SEQUENCER_COUNT; i ++)
        prepare_seq_entry(&seq->banks[i], &seq_entries[i]);
    hw_write_seq_entries(channel, seq->bank0, seq_entries);
    hw_write_seq_super_entries(
        channel, seq->super_seq_count, seq->super_offsets);
    hw_write_seq_window(channel, seq->window);
    hw_write_seq_super_count(channel, seq->super_seq_count);
    hw_write_seq_count(channel, seq->sequencer_pc);
}


error__t initialise_sequencer(void)
{
    FOR_CHANNEL_NAMES(channel, "SEQ")
    {
        struct seq_context *seq = &seq_context[channel];
        seq->channel = channel;

        PUBLISH_C_P(mbbo, "0:BANK", set_state0_bunch_bank, seq);
        for (int i = 0; i < MAX_SEQUENCER_COUNT; i ++)
            publish_bank(i, &seq->banks[i]);

        PUBLISH_C(bo, "UPDATE_COUNT", update_capture_count, seq);

        PUBLISH_WRITE_VAR_P(ulongout, "PC", seq->sequencer_pc);
        PUBLISH_READ_VAR(ulongin, "PC", seq->current_pc);
        PUBLISH_C(bo, "RESET", write_seq_reset, seq);
        PUBLISH_C_P(ulongout, "TRIGGER", write_seq_trig_state, seq);

        PUBLISH_READ_VAR(ulongin, "LENGTH", seq->capture_count);
        PUBLISH_READ_VAR(ulongin, "DURATION", seq->sequencer_duration);

        /* Super sequencer control and readback. */
        WITH_NAME_PREFIX("SUPER")
        {
            PUBLISH_READ_VAR(ulongin, "COUNT", seq->current_super_pc);
            PUBLISH_WRITE_VAR_P(ulongout, "COUNT", seq->super_seq_count);
            PUBLISH_WAVEFORM_C_P(
                double, "OFFSET", SUPER_SEQ_STATES, write_super_offsets, seq);
            PUBLISH_C(bo, "RESET", reset_super_offsets, seq);
        }

        PUBLISH_READ_VAR(bi, "BUSY", seq->busy);
        PUBLISH_C(bo, "STATUS:READ", read_seq_status, seq);

        seq->reset_window = true;
        PUBLISH_WAVEFORM_C(
            float, "WINDOW", DET_WINDOW_LENGTH, write_detector_window, seq);
        PUBLISH_C(bo, "RESET_WIN", reset_detector_window, seq);
    }

    return ERROR_OK;
}
