/* Control over fixed frequency NCOs. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "nco.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Gain manager for NCO gains.  Also used by SEQ and PLL NCO control. */

struct gain_manager {
    void *context;
    void (*set_gain)(void *context, unsigned int gain);

    bool enable;
    unsigned int gain;

    struct epics_record *gain_enum;
    struct epics_record *gain_db;
    struct epics_record *gain_scalar;
};


static void refresh_gain_scalar(struct gain_manager *manager)
{
    double gain = ldexp(manager->gain, -18);
    WRITE_OUT_RECORD(ao, manager->gain_scalar, gain, false);
}

static void refresh_gain_db(struct gain_manager *manager)
{
    double gain = ldexp(manager->gain, -18);
    double gain_db = 20 * log10(gain);
    WRITE_OUT_RECORD(ao, manager->gain_db, gain_db, false);
}

static void refresh_gain_enum(struct gain_manager *manager)
{
    /* See if the current gain corresponds to a valid enum value.  We round and
     * will discard the bottom 2 bits while doing this test. */
    unsigned int gain = (manager->gain + 2) >> 2;
    uint16_t gain_enum = 15;        // Fallback "others" case
    if (gain > 1)
    {
        unsigned int bits = 31 - (unsigned int) __builtin_clz(gain);
        if (gain == 1U << bits)
            /* In this case the gain really is a power of 2, select the
             * corresponding enum value. */
            gain_enum = (uint16_t) (16 - bits);
    }
    WRITE_OUT_RECORD(mbbo, manager->gain_enum, gain_enum, false);
}


static void call_set_gain(struct gain_manager *manager)
{
    unsigned int gain = manager->enable ? manager->gain : 0;
    manager->set_gain(manager->context, gain);
}


static bool set_gain_enable(void *context, bool *enable)
{
    struct gain_manager *manager = context;
    manager->enable = *enable;
    call_set_gain(manager);
    return true;
}

static bool set_gain_scalar(void *context, double *scalar)
{
    struct gain_manager *manager = context;
    manager->gain = double_to_uint(scalar, 18, 18);

    refresh_gain_db(manager);
    refresh_gain_enum(manager);
    call_set_gain(manager);
    return true;
}

static bool set_gain_enum(void *context, uint16_t *value)
{
    struct gain_manager *manager = context;
    /* Values in range 0 to 14 correspond to scalar gains of 2^-value (though we
     * have to treat 0 specially).  We disallow the "other" setting. */
    if (*value == 0)
        manager->gain = 0x3FFFF;
    else if (*value < 15)
        manager->gain = 0x40000U >> *value;
    else
        /* This is not a valid direct selection. */
        return false;

    refresh_gain_db(manager);
    refresh_gain_scalar(manager);
    call_set_gain(manager);
    return true;
}

static bool set_gain_db(void *context, double *db)
{
    struct gain_manager *manager = context;
    double gain = pow(10, *db / 20);
    if (!isfinite(gain))
        return false;
    manager->gain = double_to_uint(&gain, 18, 18);
    *db = 20 * log10(gain);

    refresh_gain_enum(manager);
    refresh_gain_scalar(manager);
    call_set_gain(manager);
    return true;
}


void create_gain_manager(
    void *context, void (*set_gain)(void *context, unsigned int gain))
{
    struct gain_manager *manager = malloc(sizeof(struct gain_manager));
    *manager = (struct gain_manager) {
        .context = context,
        .set_gain = set_gain,
    };

    PUBLISH_C_P(bo, "ENABLE", set_gain_enable, manager);
    manager->gain_scalar =
        PUBLISH_C_P(ao, "GAIN_SCALAR", set_gain_scalar, manager);
    manager->gain_enum = PUBLISH_C(mbbo, "GAIN", set_gain_enum, manager);
    manager->gain_db = PUBLISH_C(ao, "GAIN_DB", set_gain_db, manager);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Swept NCOs. */

static struct nco_context {
    int axis;
    enum swept_nco_id nco;

    struct nco_config nco_config;

    /* These records need updating during user editing. */
    struct epics_record *start_freq_rec;
    struct epics_record *delta_freq_rec;
    struct epics_record *end_freq_rec;
    struct epics_record *dwell_rec;
    struct epics_record *count_rec;
    struct epics_record *repeat_mode_rec;

    /* We store here the value to use when a set_fixed_freq is issued. */
    double fixed_freq_value;

    /* The effect of writting to FREQ is disabled until the initialisation
     * is not finished. */
    bool initialised;
} nco_context[AXIS_COUNT][2] = {
    [0] = {
        [0] = { .axis = 0, .nco = SWEPT_NCO1, .initialised = false },
        [1] = { .axis = 0, .nco = SWEPT_NCO2, .initialised = false },
    },
    [1] = {
        [0] = { .axis = 1, .nco = SWEPT_NCO1, .initialised = false },
        [1] = { .axis = 1, .nco = SWEPT_NCO2, .initialised = false },
    },
};


/* The rules used to calculate the frequency sweep parameters from user inputs
 * are exactly the same as the one used for the sequencer.  Please refer to the
 * note on 'compute_end_freq' in sequencer.c for more details. */
static double compute_end_freq(struct nco_context *nco)
{
    return
        freq_to_tune(nco->nco_config.start_freq) +
        nco->nco_config.point_count *
        freq_to_tune_signed(nco->nco_config.delta_freq);
}


/* This is called when any of START_FREQ, STEP_FREQ, COUNT have changed.
 * END_FREQ is updated. */
static void update_end_freq(struct nco_context *nco)
{
    WRITE_OUT_RECORD(ao, nco->end_freq_rec, compute_end_freq(nco), false);
}


static void write_nco_config(struct nco_context *nco)
{
    // Stops everything in 'Count' mode.
    if (nco->nco_config.repeat_mode == NCO_MODE_COUNT)
        hw_write_nco_abort(nco->axis, nco->nco);

    hw_write_nco_config(nco->axis, nco->nco, &nco->nco_config);

    // Perform a reset with the new configuration in 'Infinite' mode.
    if (nco->nco_config.repeat_mode == NCO_MODE_INFINITE)
        hw_write_nco_abort(nco->axis, nco->nco);
}


static bool write_freq(void *context, double *value)
{
    struct nco_context *nco = context;
    bool repeat_mode;
    bool reset_phase;

    /* This ugly workaround prevents an issue at initialisation.
     * It turns out a zero is written to the 'FREQ' PV at initialisation, even
     * if this PV is not persistant.
     * Writting FREQ changes others NCO PVs, which is not what we want.
     * Therefore we disable the effect of the first call to 'write_freq'. */
    if (!nco->initialised)
    {
        nco->initialised = true;
        return true;
    }

    nco->nco_config.start_freq = tune_to_freq(*value);
    *value = freq_to_tune(nco->nco_config.start_freq);
    WRITE_OUT_RECORD(ao, nco->start_freq_rec, *value, false);

    nco->nco_config.delta_freq = 0;
    WRITE_OUT_RECORD(ao, nco->delta_freq_rec, 0, false);

    nco->nco_config.dwell_time = 1;
    WRITE_OUT_RECORD(ulongout, nco->dwell_rec, 1, false);

    nco->nco_config.point_count = 1;
    WRITE_OUT_RECORD(ulongout, nco->count_rec, 1, false);

    update_end_freq(nco);

    // Write repeat_mode without doing an abort.
    repeat_mode = NCO_MODE_INFINITE;
    nco->nco_config.repeat_mode = repeat_mode;
    WRITE_OUT_RECORD(bo, nco->repeat_mode_rec, repeat_mode, false);
    hw_write_nco_repeat_mode(nco->axis, nco->nco, repeat_mode);

    hw_write_nco_config(nco->axis, nco->nco, &nco->nco_config);

    /* If a phase reset is required, it must be performed using the COMMAND
     * register rather than the FREQ_HIGH register.  A frequency sweep may be
     * in progress, so the sweep must be stopped before resetting the phase.
     * The COMMAND register handles this sequence; writing to FREQ_HIGH alone
     * would not properly stop an ongoing sweep before the phase reset. */
    reset_phase = nco->nco_config.start_freq == 0;
    hw_write_nco_start(nco->axis, nco->nco, reset_phase, true);

    return true;
}

static bool write_set_fixed_freq(void *context, bool *value)
{
    struct nco_context *nco = context;
    return write_freq(context, &nco->fixed_freq_value);
}

static bool write_start_freq(void *context, double *value)
{
    struct nco_context *nco = context;
    nco->nco_config.start_freq = tune_to_freq(*value);
    *value = freq_to_tune(nco->nco_config.start_freq);
    update_end_freq(nco);

    write_nco_config(nco);
    return true;
}

static bool write_step_freq(void *context, double *value)
{
    struct nco_context *nco = context;
    nco->nco_config.delta_freq = tune_to_freq(*value);
    *value = freq_to_tune_signed(nco->nco_config.delta_freq);
    update_end_freq(nco);

    write_nco_config(nco);
    return true;
}

static bool write_end_freq(void *context, double *value)
{
    struct nco_context *nco = context;
    double target_delta_freq =
        (*value - freq_to_tune(nco->nco_config.start_freq)) /
        nco->nco_config.point_count;
    nco->nco_config.delta_freq = tune_to_freq(target_delta_freq);
    double actual_delta_freq = freq_to_tune_signed(nco->nco_config.delta_freq);

    WRITE_OUT_RECORD(ao, nco->delta_freq_rec, actual_delta_freq, false);
    *value = compute_end_freq(nco);

    write_nco_config(nco);
    return true;
}

static bool write_dwell_time(void *context, unsigned int *value)
{
    struct nco_context *nco = context;
    nco->nco_config.dwell_time = *value;

    write_nco_config(nco);
    return true;
}

static bool write_nco_count(void *context, unsigned int *value)
{
    struct nco_context *nco = context;
    nco->nco_config.point_count = *value;
    update_end_freq(nco);

    write_nco_config(nco);
    return true;
}

static bool write_repeat_count(void *context, unsigned int *value)
{
    struct nco_context *nco = context;
    hw_write_nco_repeat_count(nco->axis, nco->nco, *value);
    return true;
}

static bool read_repeat_count(void *context, unsigned int *value)
{
    struct nco_context *nco = context;
    *value = hw_read_nco_repeat_count(nco->axis, nco->nco);
    return true;
}

static bool write_repeat_mode(void *context, bool *value)
{
    struct nco_context *nco = context;
    nco->nco_config.repeat_mode = *value;

    hw_write_nco_repeat_mode(nco->axis, nco->nco, *value);

    // Apply new config.
    hw_write_nco_abort(nco->axis, nco->nco);
    return true;
}

static bool write_repeat_start(void *context, bool *value)
{
    struct nco_context *nco = context;
    bool reset;

    // Perform a reset only in 'Count' mode.
    reset = nco->nco_config.repeat_mode == NCO_MODE_COUNT;

    hw_write_nco_start(nco->axis, nco->nco, false, reset);
    return true;
}

static bool write_repeat_reset(void *context, bool *value)
{
    struct nco_context *nco = context;
    hw_write_nco_abort(nco->axis, nco->nco);
    return true;
}

static bool set_nco_tune_pll(void *context, bool *enable)
{
    struct nco_context *nco = context;
    hw_write_nco_track_pll(nco->axis, nco->nco, *enable);
    return true;
}

static void set_nco_gain(void *context, unsigned int gain)
{
    struct nco_context *nco = context;
    hw_write_nco_gain(nco->axis, nco->nco, gain);
}


error__t initialise_nco(void)
{
    for (unsigned int i = 0; i < ARRAY_SIZE(nco_context); i ++)
    {
        char prefix[8];
        sprintf(prefix, "NCO%d", i + 1);
        FOR_AXIS_NAMES(axis, prefix, system_config.lmbf_mode)
        {
            struct nco_context *nco = &nco_context[axis][i];
            PUBLISH_C(ao, "FREQ", write_freq, nco);
            PUBLISH_WRITE_VAR_P(ao, "FIXED_FREQ", nco->fixed_freq_value);
            PUBLISH_C(bo, "SET_FIXED_FREQ", write_set_fixed_freq, nco);

            nco->start_freq_rec =
                PUBLISH_C_P(ao, "START_FREQ", write_start_freq, nco);
            nco->delta_freq_rec =
                PUBLISH_C_P(ao, "STEP_FREQ", write_step_freq, nco);
            nco->end_freq_rec = PUBLISH_C(ao, "END_FREQ", write_end_freq, nco);

            nco->dwell_rec =
                PUBLISH_C_P(ulongout, "DWELL", write_dwell_time, nco);
            nco->count_rec =
                PUBLISH_C_P(ulongout, "COUNT", write_nco_count, nco);
            PUBLISH_C_P(ulongout, "REPEAT:COUNT", write_repeat_count, nco);
            nco->repeat_mode_rec =
                PUBLISH_C_P(bo, "REPEAT:MODE", write_repeat_mode, nco);
            PUBLISH_C(bo, "REPEAT:START", write_repeat_start, nco);
            PUBLISH_C(bo, "REPEAT:RESET", write_repeat_reset, nco);

            PUBLISH_C(ulongin, "REPEAT:COUNT", read_repeat_count, nco);

            PUBLISH_C_P(bo, "TUNE_PLL", set_nco_tune_pll, nco);
            create_gain_manager(nco, set_nco_gain);
        }
    }
    return ERROR_OK;
}
