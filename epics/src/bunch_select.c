/* Bunch selection control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "dac.h"
#include "sequencer.h"
#include "bunch_set.h"

#include "bunch_select.h"


struct bunch_source {
    struct bunch_bank *bank;
    const char *name;

    struct epics_record *enables;
    struct epics_record *gains;
    double gain_select;

    EPICS_STRING status;        // Computed summary string
    float *gains_db;            // Computed gains in dB

    /* Copies of enables and gains as written by PVs. */
    bool *enables_wf;
    int *scaled_gains;

    /* Pointers to hardware configuration waveforms. */
    bool *hw_enables;           // Only non-NULL for FIR
    int *hw_gains;              // References appropriate bunch_config array
};


/* Bunch selection context for a single bank. */
struct bunch_bank {
    int axis;
    uint16_t bank;

    struct bunch_config config;

    EPICS_STRING fir_status;
    EPICS_STRING out_status;

    /* FIR selection waveform control. */
    struct epics_record *firwf;
    struct epics_record *outwf;
    uint16_t fir_select;

    /* Context for editing bunch selection waveforms. */
    struct bunch_set *bunch_set;

    /* Bunch sources control. */
    struct bunch_source fir_source;
    struct bunch_source nco0_source;
    struct bunch_source nco1_source;
    struct bunch_source nco2_source;
    struct bunch_source nco3_source;
};


/* Bunch selection context for a single axis. */
static struct bunch_context {
    int axis;
    uint16_t copy_from;
    uint16_t copy_to;
    struct bunch_bank banks[BUNCH_BANKS];
} bunch_context[AXIS_COUNT];



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Status string computation. */

static unsigned int count_enables(const bool enables[])
{
    if (enables)
    {
        unsigned int count = 0;
        FOR_BUNCHES(i)
            count += enables[i];
        return count;
    }
    else
        return system_config.bunches_per_turn;
}

/* Returns the first enabled index starting from and including the start index.
 * Returns 0 if nothing found, this is an error. */
static unsigned int next_enabled_index(const bool enables[], unsigned int start)
{
    if (enables)
    {
        for (unsigned int i = start; i < hardware_config.bunches; i ++)
            if (enables[i])
                return i;
        /* Caller must not call if nothing enabled! */
        ASSERT_FAIL();
        return 0;
    }
    else
        return 0;
}

/* Helper routine: counts number of instances of given value, not all set,
 * returns index of last non-equal value. */
static unsigned int count_value(
    const int wf[], const bool enables[], int value, unsigned int *diff_ix)
{
    unsigned int count = 0;
    FOR_BUNCHES(i)
    {
        if (!enables  ||  enables[i])
        {
            if (wf[i] == value)
                count += 1;
            else
                *diff_ix = i;
        }
    }
    return count;
}


/* Status computation. */
enum complexity {
    ALL_SAME,       // All the same value
    ALL_BUT_ONE,    // All one value except for one different value
    SINGLE_BUNCH,   // Only one bunch enabled (special case of ALL_SAME)
    COMPLICATED,    // Something else
    ALL_DISABLED    // All values disabled
};

static enum complexity assess_complexity(
    const int wf[], const bool enables[],
    int *value, int *other, unsigned int *other_ix)
{
    unsigned int enable_count = count_enables(enables);
    if (enable_count == 0)
        return ALL_DISABLED;

    unsigned int first_valid = next_enabled_index(enables, 0);
    *value = wf[first_valid];

    unsigned int count = count_value(wf, enables, *value, other_ix);
    if (count == enable_count)
    {
        if (count == 1)
        {
            *other_ix = first_valid;
            return SINGLE_BUNCH;
        }
        else
            return ALL_SAME;
    }
    else if (count == enable_count - 1)
    {
        *other = wf[*other_ix];
        return ALL_BUT_ONE;
    }
    else if (count == 1)
    {
        /* Need to check whether all rest are the same. */
        unsigned int next_valid = next_enabled_index(enables, first_valid + 1);
        *value = wf[next_valid];
        *other = wf[first_valid];
        if (count_value(wf, enables, *value, other_ix) == enable_count - 1)
            return ALL_BUT_ONE;
        else
            return COMPLICATED;
    }
    else
        return COMPLICATED;
}


static void update_status_core(
    const char *name, const int wf[], const bool enables[],
    EPICS_STRING *status, void (*render)(int, char[], size_t))
{
    int value = 0, other = 0;
    unsigned int other_ix = 0;
    enum complexity complexity =
        assess_complexity(wf, enables, &value, &other, &other_ix);
    char value_name[40], other_name[40];
    render(value, value_name, sizeof(value_name));
    render(other, other_name, sizeof(other_name));

    switch (complexity)
    {
        case ALL_SAME:
            format_epics_string(status, "%s", value_name);
            break;
        case SINGLE_BUNCH:
            format_epics_string(status, "%s @%u", value_name, other_ix);
            break;
        case ALL_BUT_ONE:
            format_epics_string(status, "%s (%s @%u)",
                value_name, other_name, other_ix);
            break;
        case COMPLICATED:
            format_epics_string(status, "Mixed %s", name);
            break;
        case ALL_DISABLED:
            format_epics_string(status, "Off");
    }
}


static void render_fir(int fir, char result[], size_t length)
{
    snprintf(result, length, "#%d", fir);
}

static void update_fir_status(struct bunch_bank *bank, const char fir_select[])
{
    /* Gather FIR selections into an integer array so that our status checker
     * can work with it. */
    int fir_wf[hardware_config.bunches];
    FOR_BUNCHES(i)
        fir_wf[i] = fir_select[i];
    update_status_core("FIR", fir_wf, NULL, &bank->fir_status, render_fir);
}


static void render_gain(int gain, char result[], size_t length)
{
    const char *extra = gain < 0 ? " -ve" : "";
    snprintf(result, length,
        "Gain %.1f dB%s", 20 * log10(fabs(ldexp(gain, -14))), extra);
}

static void update_gain_status(struct bunch_source *source)
{
    update_status_core(
        source->name, source->scaled_gains, source->enables_wf,
        &source->status, render_gain);
}


static void render_outputs(int outputs, char result[], size_t length)
{
    static const char *names[] = {"FIR", "NCO1", "SEQ", "PLL", "NCO2"};
    if (outputs)
    {
        const char *sep = "";
        result[0] = '\0';
        for (unsigned int i = 0; i < 5; i ++)
            if (outputs >> i & 1)
            {
                strncat(result, sep, length);
                strncat(result, names[i], length);
                sep = "+";
            }
    }
    else
        strncpy(result, "Off", length);
}


/* Returns true if all enabled bunches have the same gain, in which case *gain
 * is set to that value. */
static bool assess_gain(struct bunch_source *source, bool *seen, int *gain)
{
    FOR_BUNCHES(i)
    {
        if (source->enables_wf[i])
        {
            if (*seen)
            {
                if (source->scaled_gains[i] != *gain)
                    return false;
            }
            else
            {
                *seen = true;
                *gain = source->scaled_gains[i];
            }
        }
    }
    /* If we fall through to here then everything we saw had the same value. */
    return true;
}

static void update_out_status(struct bunch_bank *bank)
{
    /* Gather all the output enables into a waveform. */
    unsigned int bunches = hardware_config.bunches;
    int out_wf[bunches];
    bool enable_wf[bunches];
    FOR_BUNCHES(i)
    {
        out_wf[i] =
            bank->fir_source.enables_wf[i]  |
            bank->nco0_source.enables_wf[i] << 1  |
            bank->nco1_source.enables_wf[i] << 2  |
            bank->nco2_source.enables_wf[i] << 3  |
            bank->nco3_source.enables_wf[i] << 4;
        enable_wf[i] = out_wf[i];
    }

    /* First gather the enabled outputs. */
    EPICS_STRING enables;
    update_status_core("outputs", out_wf, enable_wf, &enables, render_outputs);

    /* Now look for gain consensus and assemble result. */
    bool seen = false;
    int gain = 0;
    bool all_same =
        assess_gain(&bank->fir_source,  &seen, &gain)  &&
        assess_gain(&bank->nco0_source, &seen, &gain)  &&
        assess_gain(&bank->nco1_source, &seen, &gain)  &&
        assess_gain(&bank->nco2_source, &seen, &gain)  &&
        assess_gain(&bank->nco3_source, &seen, &gain);
    char gain_status[40];
    if (!seen)
        strcpy(gain_status, "");
    else if (!all_same)
        strcpy(gain_status, "Mixed Gains");
    else
        render_gain(gain, gain_status, sizeof(gain_status));

    format_epics_string(&bank->out_status, "%s %s", enables.s, gain_status);
}


static void update_output_status(struct bunch_source *source)
{
    update_gain_status(source);
    update_out_status(source->bank);
}


static bool read_feedback_mode(void *context, EPICS_STRING *result)
{
    struct bunch_context *bunch = context;
    uint16_t idle_bank = get_seq_idle_bank(bunch->axis);
    struct bunch_config *config = &bunch->banks[idle_bank].config;

    /* Evaluate DAC out and FIR waveforms. */
    bool all_off = true;
    bool all_fir = true;
    bool same_fir = true;
    FOR_BUNCHES(i)
    {
        if (config->fir_enable[i])
            all_off = false;
        if (config->nco0_gains[i]  ||  config->nco1_gains[i]  ||
            config->nco2_gains[i]  ||  config->nco3_gains[i])
            all_fir = false;
        if (config->fir_select[i] != config->fir_select[0])
            same_fir = false;
    }

    /* Check whether the output is enabled. */
    bool output_on = system_config.lmbf_mode ?
        get_dac_output_enable(0)  &&  get_dac_output_enable(1) :
        get_dac_output_enable(bunch->axis);

    if (!output_on)
        format_epics_string(result, "Output off");
    else if (all_off)
        format_epics_string(result, "Feedback off");
    else if (!all_fir)
        format_epics_string(result, "Feedback mixed mode");
    else if (same_fir)
        format_epics_string(result,
            "Feedback on, FIR: #%d", config->fir_select[0]);
    else
        format_epics_string(result, "Feedback on, FIR: mixed");
    return true;
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Legacy support for OUTWF */

static void update_out_wf(struct bunch_bank *bank)
{
    unsigned int bunches = hardware_config.bunches;
    char out_wf[bunches];
    FOR_BUNCHES(i)
        out_wf[i] = (char) (
            bank->fir_source.enables_wf[i]  |
            bank->nco0_source.enables_wf[i] << 1  |
            bank->nco1_source.enables_wf[i] << 2  |
            bank->nco2_source.enables_wf[i] << 3  |
            bank->nco3_source.enables_wf[i] << 4);
    /* Refresh value shown by OUTWF, don't trigger process. */
    WRITE_OUT_RECORD_WF(char, bank->outwf, out_wf, bunches, false);
}


static void write_source_enables(
    struct bunch_source *source, const char out_wf[], unsigned int shift)
{
    unsigned int bunches = hardware_config.bunches;
    char enables[bunches];
    FOR_BUNCHES(i)
        enables[i] = (out_wf[i] >> shift) & 1;
    WRITE_OUT_RECORD_WF(char, source->enables, enables, bunches, true);
}

static void write_out_wf(void *context, char out_wf_in[], unsigned int *length)
{
    struct bunch_bank *bank = context;

    /* Take a copy of the waveform, as we're about to trigger updates to the
     * underlying data! */
    unsigned int bunches = hardware_config.bunches;
    *length = bunches;
    char out_wf[bunches];
    memcpy(out_wf, out_wf_in, bunches);

    /* Push the updated waveform to all interested parties. */
    write_source_enables(&bank->fir_source,  out_wf, 0);
    write_source_enables(&bank->nco0_source, out_wf, 1);
    write_source_enables(&bank->nco1_source, out_wf, 2);
    write_source_enables(&bank->nco2_source, out_wf, 3);
    write_source_enables(&bank->nco3_source, out_wf, 4);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Bunch publish and control. */


void get_bunch_seq_enables(int axis, unsigned int bank, bool enables[])
{
    int *nco1_gains = bunch_context[axis].banks[bank].config.nco1_gains;
    FOR_BUNCHES(i)
        enables[i] = nco1_gains[i] != 0;
}


#define COPY_RECORD_WF(type, name, from, to) \
    do { \
        unsigned int bunches = hardware_config.bunches; \
        type buffer[bunches]; \
        READ_RECORD_VALUE_WF(type, (from)->name, buffer, bunches); \
        WRITE_OUT_RECORD_WF(type, (to)->name, buffer, bunches, true); \
    } while (0)

#define COPY_SOURCE(source, from, to) \
    do { \
        COPY_RECORD_WF(char, enables, \
            &from->source##_source, &to->source##_source); \
        COPY_RECORD_WF(float, gains, \
            &from->source##_source, &to->source##_source); \
    } while (0)

static bool copy_bank_from_to(void *context, bool *value)
{
    struct bunch_context *bun = context;
    if (bun->copy_from != bun->copy_to)
    {
        struct bunch_bank *copy_from = &bun->banks[bun->copy_from];
        struct bunch_bank *copy_to = &bun->banks[bun->copy_to];
        COPY_RECORD_WF(char, firwf, copy_from, copy_to);
        COPY_SOURCE(fir, copy_from, copy_to);
        COPY_SOURCE(nco0, copy_from, copy_to);
        COPY_SOURCE(nco1, copy_from, copy_to);
        COPY_SOURCE(nco2, copy_from, copy_to);
        COPY_SOURCE(nco3, copy_from, copy_to);
    }
    return true;
}



static void write_bunch_config(struct bunch_bank *bank)
{
    hw_write_bunch_config(bank->axis, bank->bank, &bank->config);
    if (system_config.lmbf_mode)
        hw_write_bunch_config(1, bank->bank, &bank->config);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Bunch source control. */

/* For simplicity, we update both gains and enables every time any PV changes.
 * This state is then written to hardware. */
static void update_source_gains_enables(struct bunch_source *source)
{
    /* Depending on whether we have hardware enables present we either reset the
     * gains or write to the enable record. */
    bool ignore_enable = source->hw_enables;
    FOR_BUNCHES_OFFSET(i, j, hardware_delays.BUNCH_GAIN_OFFSET)
    {
        source->hw_gains[i] =
            ignore_enable || source->enables_wf[j] ?
                source->scaled_gains[j] : 0;
        if (source->hw_enables)
            source->hw_enables[i] = source->enables_wf[j];
    }
    write_bunch_config(source->bank);
    update_output_status(source);
}


static void write_enables(void *context, char enables[], unsigned int *length)
{
    struct bunch_source *source = context;
    *length = hardware_config.bunches;

    FOR_BUNCHES(i)
    {
        /* Normalise write to boolean values (0 or 1). */
        source->enables_wf[i] = enables[i];
        enables[i] = source->enables_wf[i];
    }

    update_source_gains_enables(source);
    update_out_wf(source->bank);
}


static void write_gains(void *context, float gains[], unsigned int *length)
{
    struct bunch_source *source = context;
    *length = hardware_config.bunches;

    float_array_to_int(
        hardware_config.bunches, gains, source->scaled_gains, 18, 14);
    FOR_BUNCHES(i)
    {
        if (gains[i] == 0)
            /* Don't allow -inf as a waveform value, as some display managers
             * (particularly EDM) can't cope with this. */
            source->gains_db[i] = -85;      // 2^-14 in dB
        else
            source->gains_db[i] = 20 * log10f(fabsf(gains[i]));
    }

    update_source_gains_enables(source);
}


static bool set_enables(void *context, bool *_value)
{
    struct bunch_source *source = context;
    UPDATE_RECORD_BUNCH_SET(char,
        source->bank->bunch_set, source->enables, true);
    return true;
}

static bool reset_enables(void *context, bool *_value)
{
    struct bunch_source *source = context;
    UPDATE_RECORD_BUNCH_SET(char,
        source->bank->bunch_set, source->enables, false);
    return true;
}

static bool set_gains(void *context, bool *_value)
{
    struct bunch_source *source = context;
    UPDATE_RECORD_BUNCH_SET(float,
        source->bank->bunch_set, source->gains, (float) source->gain_select);
    return true;
}


/* Force all gains to 1. */
static void reset_source_gains(struct bunch_source *source)
{
    unsigned int bunches = hardware_config.bunches;
    float gains[bunches];
    FOR_BUNCHES(i)
        gains[i] = 1;
    WRITE_OUT_RECORD_WF(float, source->gains, gains, bunches, true);
}


static void publish_bank_source(
    struct bunch_bank *bank, const char *name,
    struct bunch_source *source, int *hw_gains, bool *hw_enables)
{
    unsigned int bunches = hardware_config.bunches;

    source->bank = bank;
    source->name = name;

    source->enables_wf = CALLOC(bool, bunches);
    source->scaled_gains = CALLOC(int, bunches);
    source->gains_db = CALLOC(float, bunches);

    source->hw_gains = hw_gains;
    source->hw_enables = hw_enables;
    source->gain_select = 1;        // A good default value

    PUBLISH_READ_VAR(stringin, "STATUS", source->status);

    source->enables = PUBLISH_WAVEFORM(char, "ENABLE", bunches,
        write_enables, .context = source, .persist = true);
    PUBLISH_WF_READ_VAR(float, "GAIN_DB", bunches, source->gains_db);
    source->gains = PUBLISH_WAVEFORM(float, "GAIN", bunches,
        write_gains, .context = source, .persist = true);

    PUBLISH_C(bo, "SET_ENABLE", set_enables, source);
    PUBLISH_C(bo, "SET_DISABLE", reset_enables, source);
    PUBLISH_WRITE_VAR(ao, "GAIN_SELECT", source->gain_select);
    PUBLISH_C(bo, "SET_GAIN", set_gains, source);
}

#define PUBLISH_BANK_SOURCE(bank, source, name, enables) \
    do { \
        WITH_NAME_PREFIX(name) \
            publish_bank_source(bank, name, &bank->source##_source, \
                bank->config.source##_gains, enables); \
    } while (0)



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Bank control. */

static void write_fir_wf(void *context, char fir_select[], unsigned int *length)
{
    struct bunch_bank *bank = context;
    *length = hardware_config.bunches;

    update_fir_status(bank, fir_select);

    FOR_BUNCHES_OFFSET(i, j, hardware_delays.BUNCH_FIR_OFFSET)
    {
        fir_select[j] = fir_select[j] & 0x3;
        bank->config.fir_select[i] = fir_select[j];
    }

    write_bunch_config(bank);
}


static bool update_fir_waveform(void *context, bool *_value)
{
    struct bunch_bank *bank = context;
    UPDATE_RECORD_BUNCH_SET(char,
        bank->bunch_set, bank->firwf, (char) bank->fir_select);
    return true;
}


static bool reset_all_source_gains(void *context, bool *_value)
{
    struct bunch_bank *bank = context;
    reset_source_gains(&bank->fir_source);
    reset_source_gains(&bank->nco0_source);
    reset_source_gains(&bank->nco1_source);
    reset_source_gains(&bank->nco2_source);
    reset_source_gains(&bank->nco3_source);
    return true;
}


static void publish_bank(unsigned int ix, struct bunch_bank *bank)
{
    char prefix[4];
    sprintf(prefix, "%d", ix);
    WITH_NAME_PREFIX(prefix)
    {
        unsigned int bunches = hardware_config.bunches;

        PUBLISH_READ_VAR(stringin, "STATUS", bank->out_status);

        PUBLISH_BANK_SOURCE(bank, fir,  "FIR",  bank->config.fir_enable);
        PUBLISH_BANK_SOURCE(bank, nco0, "NCO1", NULL);
        PUBLISH_BANK_SOURCE(bank, nco1, "SEQ",  NULL);
        PUBLISH_BANK_SOURCE(bank, nco2, "PLL",  NULL);
        PUBLISH_BANK_SOURCE(bank, nco3, "NCO2", NULL);

        PUBLISH_READ_VAR(stringin, "FIRWF:STA", bank->fir_status);
        bank->firwf = PUBLISH_WAVEFORM(char, "FIRWF", bunches,
            write_fir_wf, .context = bank, .persist = true);
        PUBLISH_WRITE_VAR(mbbo, "FIR_SELECT", bank->fir_select);
        PUBLISH_C(bo, "FIRWF:SET", update_fir_waveform, bank);

        PUBLISH_C(bo, "RESET_GAINS", reset_all_source_gains, bank);

        bank->outwf = PUBLISH_WAVEFORM(char, "OUTWF", bunches,
            write_out_wf, .context = bank);

        /* Initialise the bunch set and set a sensible default gain. */
        bank->bunch_set = create_bunch_set();
    }
}


static void initialise_bank(
    int axis, uint16_t ix, struct bunch_bank *bank)
{
    bank->axis = axis;
    bank->bank = ix;

    unsigned int bunches = hardware_config.bunches;
    bank->config = (struct bunch_config) {
        .fir_select  = CALLOC(char, bunches),
        .fir_enable  = CALLOC(bool, bunches),
        .fir_gains   = CALLOC(int,  bunches),
        .nco0_gains  = CALLOC(int,  bunches),
        .nco1_gains  = CALLOC(int,  bunches),
        .nco2_gains  = CALLOC(int,  bunches),
        .nco3_gains  = CALLOC(int,  bunches),
    };
}


error__t initialise_bunch_select(void)
{
    /* In LMBF mode we only expose one bunch selection axis, but mirror both
     * axes as we write to hardware. */
    FOR_AXIS_NAMES(axis, "BUN", system_config.lmbf_mode)
    {
        struct bunch_context *bun = &bunch_context[axis];
        bun->axis = axis;

        for (uint16_t i = 0; i < BUNCH_BANKS; i ++)
        {
            initialise_bank(axis, i, &bun->banks[i]);
            publish_bank(i, &bun->banks[i]);
        }

        PUBLISH_C(stringin, "MODE", read_feedback_mode, bun);

        PUBLISH_WRITE_VAR(mbbo, "COPY_FROM", bun->copy_from);
        PUBLISH_WRITE_VAR(mbbo, "COPY_TO", bun->copy_to);
        PUBLISH_C(bo, "COPY_BANK", copy_bank_from_to, bun);
    }
    return ERROR_OK;
}
