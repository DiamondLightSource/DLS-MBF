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
/* Fixed frequency NCOs. */

static struct nco_context {
    int axis;
    enum fixed_nco nco;
    struct gain_manager *gain;
} nco_context[AXIS_COUNT][2] = {
    [0] = {
        [0] = { .axis = 0, .nco = FIXED_NCO1, },
        [1] = { .axis = 0, .nco = FIXED_NCO2, },
    },
    [1] = {
        [0] = { .axis = 1, .nco = FIXED_NCO1, },
        [1] = { .axis = 1, .nco = FIXED_NCO2, },
    },
};


static bool set_nco_frequency(void *context, double *tune)
{
    struct nco_context *nco = context;
    uint64_t frequency = tune_to_freq(*tune);
    *tune = freq_to_tune(frequency);
    hw_write_nco_frequency(nco->axis, nco->nco, frequency);
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
            PUBLISH_C_P(ao, "FREQ", set_nco_frequency, nco);
            PUBLISH_C_P(bo, "TUNE_PLL", set_nco_tune_pll, nco);
            create_gain_manager(nco, set_nco_gain);
        }
    }
    return ERROR_OK;
}
