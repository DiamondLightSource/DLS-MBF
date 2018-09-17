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
#include "triggers.h"
#include "trigger_target.h"
#include "detector.h"
#include "bunch_select.h"

#include "sequencer.h"


/* These are the sequencer states for states 1 to 7.  State 0 is special and
 * is not handled in this array. */
struct sequencer_bank {
    /* Parent state. */
    struct seq_context *seq;

    /* Much of our state is as written to hardware. */
    struct seq_entry *entry;

    /* These two records need updating during user editing. */
    struct epics_record *delta_freq_rec;
    struct epics_record *end_freq_rec;
};


static struct seq_context {
    int axis;

    struct seq_config seq_config;   // Hardware configuration set by EPICS
    struct sequencer_bank banks[MAX_SEQUENCER_COUNT];   // EPICS management
    struct seq_config seq_hw_config;    // Configuration written to hardware

    /* The seq_config_dirty flag is set whenever the seq_config is changed via
     * EPICS.  This flag is copied to seq_hw_config_dirty and reset when arming
     * the sequencer, and is used to determine whether the frequency scale and
     * timebase may have changed. */
    pthread_mutex_t mutex;
    bool seq_config_dirty;
    bool seq_hw_config_dirty;

    struct seq_state seq_state;     // Current state as read from hardware

    unsigned int capture_count;     // Number of IQ points to capture
    unsigned int sequencer_duration; // Total duration of sequence

    bool reset_offsets;             // Reset super sequencer offsets
    bool reset_window;              // Reset detector window
} seq_context[AXIS_COUNT] = {
    [0 ... AXIS_COUNT-1] = {
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .seq_config_dirty = true,
    },
};



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

/* This is called when any of START_FREQ, STEP_FREQ, COUNT have changed.
 * END_FREQ is updated. */
static void update_end_freq(struct sequencer_bank *bank)
{
    struct seq_entry *entry = bank->entry;
    unsigned int end_freq =
        entry->start_freq + entry->capture_count * entry->delta_freq;
    WRITE_OUT_RECORD(ao, bank->end_freq_rec, freq_to_tune(end_freq), false);

    bank->seq->seq_config_dirty = true;
}


static bool write_start_freq(void *context, double *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    entry->start_freq = tune_to_freq(*value);
    *value = freq_to_tune(entry->start_freq);
    update_end_freq(bank);
    return true;
}

static bool write_step_freq(void *context, double *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    entry->delta_freq = tune_to_freq(*value);
    *value = freq_to_tune_signed(entry->delta_freq);
    update_end_freq(bank);
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

    bank->seq->seq_config_dirty = true;
    return true;
}


static bool write_bank_count(void *context, unsigned int *value)
{
    struct sequencer_bank *bank = context;
    struct seq_entry *entry = bank->entry;
    entry->capture_count = *value;
    update_end_freq(bank);
    return true;
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
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


static bool set_state0_bunch_bank(void *context, unsigned int *bank)
{
    struct seq_context *seq = context;
    seq->seq_config.bank0 = *bank;
    hw_write_seq_bank0(seq->axis, *bank);
    return true;
}


unsigned int get_seq_idle_bank(int axis)
{
    return seq_context[axis].seq_config.bank0;
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

    seq->seq_config_dirty = true;
    return true;
}


static bool write_seq_reset(void *context, bool *value)
{
    struct seq_context *seq = context;
    struct trigger_target *target = get_sequencer_trigger_target(seq->axis);
    trigger_target_disarm(target);
    hw_write_seq_abort(seq->axis);
    return true;
}


static bool write_seq_trig_state(void *context, unsigned int *value)
{
    struct seq_context *seq = context;
    hw_write_seq_trigger_state(seq->axis, *value);
    return true;
}


static bool read_seq_status(void *context, bool *value)
{
    struct seq_context *seq = context;
    hw_read_seq_state(seq->axis, &seq->seq_state);
    return true;
}


static void write_super_offsets(
    void *context, double offsets[], unsigned int *length)
{
    struct seq_context *seq = context;
    *length = SUPER_SEQ_STATES;

    if (seq->reset_offsets)
    {
        for (unsigned int i = 0; i < SUPER_SEQ_STATES; i ++)
            offsets[i] = i;
        seq->reset_offsets = false;
    }

    for (int i = 0; i < SUPER_SEQ_STATES; i ++)
    {
        unsigned int freq = tune_to_freq(offsets[i]);
        seq->seq_config.super_offsets[i] = freq;
        offsets[i] = freq_to_tune(freq);
    }

    seq->seq_config_dirty = true;
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
    void *context, float window[], unsigned int *length)
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


/* Helper function for compute_scale_info() below. */
static inline void write_scale_point(
    unsigned int frequency[], unsigned int timebase[],
    unsigned int i, unsigned int f0, unsigned int total_time)
{
    if (frequency) frequency[i] = f0;
    if (timebase)  timebase[i] = total_time;
}

/* Computes frequency and timebase scales from detector configuration. */
unsigned int compute_scale_info(
    int axis, unsigned int frequency[], unsigned int timebase[],
    unsigned int start_offset, unsigned int length)
{
    const struct seq_context *seq = &seq_context[axis];
    const struct seq_config *seq_config = &seq->seq_hw_config;
    unsigned int super_count = seq_config->super_seq_count;
    unsigned int seq_count = seq_config->sequencer_pc;
    unsigned int end_offset = start_offset + length;

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
                    if (start_offset <= ix  &&  ix < end_offset)
                        write_scale_point(
                            frequency, timebase, ix - start_offset,
                            f0, total_time);
                    f0 += entry->delta_freq;
                    total_time += dwell_time;
                    ix += 1;
                }
            }
            else
                gap_time += dwell_time * entry->capture_count;
        }

    /* Fill in the rest of the waveforms. */
    for (unsigned int i = ix; i < end_offset; i ++)
        write_scale_point(
            frequency, timebase, i - start_offset, f0, total_time);

    /* Return total number of samples computed. */
    return ix;
}


/* This is called before arming the sequencer.  We remember a copy of the
 * sequencer state and write this to hardware.  The copy is remembered so that
 * when a subsequent request is made for the scale info we will return a
 * truthful version. */
void prepare_sequencer(int axis)
{
    struct seq_context *seq = &seq_context[axis];
    WITH_MUTEX(seq->mutex)
    {
        seq->seq_hw_config = seq->seq_config;
        seq->seq_hw_config_dirty = seq->seq_config_dirty;
        seq->seq_config_dirty = false;
    }
    hw_write_seq_config(seq->axis, &seq->seq_hw_config);
}


bool detector_scale_changed(int axis)
{
    struct seq_context *seq = &seq_context[axis];
    return seq->seq_hw_config_dirty;
}


/* This is called as part of detector readout, at which point we want to present
 * the user with an accurate view of the detector scaling. */
void read_detector_scale_info(
    int axis, unsigned int length, struct scale_info *scale_info)
{
    /* Need buffer for frequency data so we can covert to tune afterwards. */
    unsigned int frequency[length];
    scale_info->samples = compute_scale_info(
        axis, frequency, (unsigned int *) scale_info->timebase, 0, length);
    for (unsigned int i = 0; i < length; i ++)
        scale_info->tune_scale[i] = freq_to_tune(frequency[i]);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Sequencer mode computation. */


static unsigned int count_bunches_equal_to(bool value, const bool bunches[])
{
    unsigned int count = 0;
    FOR_BUNCHES(i)
        if (bunches[i] == value)
            count += 1;
    return count;
}


static unsigned int count_bunches_equal(const bool b1[], const bool b2[])
{
    unsigned int count = 0;
    FOR_BUNCHES(i)
        if (b1[i] == b2[i])
            count += 1;
    return count;
}


static unsigned int find_first_index(bool value, const bool bunches[])
{
    unsigned int count = 0;
    FOR_BUNCHES(i)
        if (bunches[i] == value)
            return count;
        else
            count += 1;
    ASSERT_FAIL();
}


static bool read_sequencer_mode(void *context, EPICS_STRING *result)
{
    struct seq_context *seq = context;
    struct seq_entry *entry0 = &seq->seq_config.entries[0];
    int axis = seq->axis;
    unsigned int bank = entry0->bunch_bank;

    /* Both the detector and bunch configurations feed into the status. */
    const struct detector_config *det_config = get_detector_config(axis, 0);
    const struct bunch_config *bunch_config = get_bunch_config(axis, bank);

    /* Cound how many bunches we're sweeping and overlap with detector. */
    unsigned int sweeping =
        count_bunches_equal_to(true, bunch_config->nco1_enable);
    unsigned int overlap = count_bunches_equal(
        bunch_config->nco1_enable, det_config->bunch_enables);

    /* Start by evaluating the sequencer.  We expect a single sequencer state
     * with data capture, sequencer enabled, and IQ buffer capture. */
    const char *status = NULL;
    if (!get_sequencer_trigger_active(axis))
        status = "Trigger not enabled";
    else if (seq->seq_config.super_seq_count > 1)
        status = "Super sequencer active";
    else if (seq->seq_config.sequencer_pc > 1)
        status = "Multi-state sequencer";
    else if (!entry0->nco_enable)
        status = "Sequencer NCO off";
    else if (!det_config->enable  ||
             count_bunches_equal_to(true, det_config->bunch_enables) == 0)
        status = "Detector 0 disabled";
    else if (sweeping == 0)
        status = "No tune sweep";
    else if (overlap == 0)
        status = "Not sweeping detector";
    else
    {
        char gain[40];
        sprintf(gain, "%ddB", -6 * (int) entry0->nco_gain);

        if (sweeping == 1)
        {
            unsigned int single_bunch =
                find_first_index(true, bunch_config->nco1_enable);
            format_epics_string(result,
                "Sweep: bunch %u (%s)", single_bunch, gain);
        }
        else if (sweeping == system_config.bunches_per_turn)
            format_epics_string(result, "Sweep: all bunches (%s)", gain);
        else
            format_epics_string(result,
                "Sweep: %u bunches (%s)", sweeping, gain);
        return true;
    }

    format_epics_string(result, "%s", status);
    return true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation. */

error__t initialise_sequencer(void)
{
    /* In LMBF mode we run with just one sequencer axis. */
    FOR_AXIS_NAMES(axis, "SEQ", system_config.lmbf_mode)
    {
        struct seq_context *seq = &seq_context[axis];
        seq->axis = axis;

        /* All PVs which modify the hardware configuration are modified under a
         * mutex to ensure we don't have surprises if settings are changed while
         * rearming. */
        pthread_mutex_t *old_mutex =
            set_default_epics_device_mutex(&seq->mutex);

        PUBLISH_C_P(mbbo, "0:BANK", set_state0_bunch_bank, seq);
        for (int i = 0; i < MAX_SEQUENCER_COUNT; i ++)
        {
            seq->banks[i].seq = seq;
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

        PUBLISH_C(stringin, "MODE", read_sequencer_mode, seq);

        /* Don't forget to restore the default! */
        set_default_epics_device_mutex(old_mutex);
    }

    return ERROR_OK;
}
