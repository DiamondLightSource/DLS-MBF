/* EPICS interface to DAC readout and control. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "mms.h"
#include "memory.h"

#include "dac.h"


static struct dac_context {
    int axis;
    bool output_enable;
    enum dac_mms_source mms_source;
    bool dram_after_fir;
    bool overflow;
    struct dac_events events;
    struct mms_handler *mms;
} dac_context[AXIS_COUNT];


static void write_dac_taps(void *context, float array[], unsigned int *length)
{
    struct dac_context *dac = context;
    *length = hardware_config.dac_taps;

    int taps[hardware_config.dac_taps];
    float_array_to_int(hardware_config.dac_taps, array, taps, 32, 31);

    hw_write_dac_taps(dac->axis, taps);
}


static bool set_dac_delta_threshold(void *context, double *value)
{
    struct dac_context *dac = context;
    hw_write_dac_delta_threshold(dac->axis, double_to_uint(value, 16, 15));
    return true;
}


static bool write_dac_delay(void *context, unsigned int *value)
{
    struct dac_context *dac = context;
    *value = MIN(*value, 0x3FFU);
    hw_write_dac_delay(dac->axis, *value);
    return true;
}


/* This counter is used to delay updates to DAC output enable until everything
 * has had time to settle.  We piggy-back on the scan_events event as this is a
 * regular timing event. */
static int output_enable_delay = 2;

/* In combination with write_dac_output_enable() below, ensures that the DAC
 * output enable is left in its default Off state for two update ticks, or
 * around 200ms.  This ensures that all configuration is complete by the time we
 * enable the DAC output. */
static void tick_output_enable_delay(void)
{
    if (output_enable_delay > 0)
    {
        output_enable_delay -= 1;
        if (output_enable_delay == 1)
        {
            for (int i = 0; i < AXIS_COUNT; i ++)
                hw_write_output_enable(i, dac_context[i].output_enable);
        }
    }
}

static bool write_dac_output_enable(void *context, bool *value)
{
    struct dac_context *dac = context;
    dac->output_enable = *value;
    if (output_enable_delay == 0)
        hw_write_output_enable(dac->axis, dac->output_enable);
    return true;
}


bool get_dac_output_enable(int axis)
{
    struct dac_context *dac = &dac_context[axis];
    return dac->output_enable;
}


static unsigned int decode_mms_delay(enum dac_mms_source source)
{
    switch (source)
    {
        case DAC_MMS_BEFORE_PREEMPH:
            return hardware_delays.MMS_DAC_DELAY;
        case DAC_MMS_AFTER_PREEMPH:
            return hardware_delays.MMS_DAC_FIR_DELAY;
        case DAC_MMS_BB_FIR:
            return hardware_delays.MMS_DAC_FEEDBACK_DELAY;
        default:
            ASSERT_FAIL();
    }
}

static void update_delays(struct dac_context *dac)
{
    set_mms_offset(dac->mms, decode_mms_delay(dac->mms_source));
    set_memory_dac_offset(dac->axis, dac->dram_after_fir ?
        hardware_delays.DRAM_DAC_FIR_DELAY :
        hardware_delays.DRAM_DAC_DELAY);
}

static bool write_dac_mms_source(void *context, uint16_t *source)
{
    struct dac_context *dac = context;
    dac->mms_source = *source;
    hw_write_dac_mms_source(dac->axis, *source);
    update_delays(dac);
    return true;
}

static bool write_dac_dram_source(void *context, bool *after_fir)
{
    struct dac_context *dac = context;
    dac->dram_after_fir = *after_fir;
    hw_write_dac_dram_source(dac->axis, *after_fir);
    update_delays(dac);
    return true;
}


static void scan_events(void)
{
    for (int i = 0; i < AXIS_COUNT; i ++)
    {
        struct dac_context *dac = &dac_context[i];
        hw_read_dac_events(i, &dac->events);
        dac->overflow =
            dac->events.fir_ovf | dac->events.mux_ovf | dac->events.out_ovf;
    }
    tick_output_enable_delay();
}


error__t initialise_dac(void)
{
    FOR_AXIS_NAMES(axis, "DAC")
    {
        struct dac_context *dac = &dac_context[axis];
        dac->axis = axis;

        PUBLISH_WAVEFORM_C_P(float, "FILTER",
            hardware_config.dac_taps, write_dac_taps, dac);

        PUBLISH_C_P(ao, "EVENT_LIMIT", set_dac_delta_threshold, dac);
        PUBLISH_C_P(ulongout, "DELAY", write_dac_delay, dac);
        PUBLISH_C_P(bo, "ENABLE",      write_dac_output_enable, dac);
        PUBLISH_C_P(mbbo, "MMS_SOURCE",  write_dac_mms_source, dac);
        PUBLISH_C_P(bo, "DRAM_SOURCE", write_dac_dram_source, dac);

        PUBLISH_READ_VAR(bi, "BUN_OVF", dac->events.fir_ovf);
        PUBLISH_READ_VAR(bi, "MUX_OVF", dac->events.mux_ovf);
        PUBLISH_READ_VAR(bi, "MMS_OVF", dac->events.mms_ovf);
        PUBLISH_READ_VAR(bi, "FIR_OVF", dac->events.out_ovf);
        PUBLISH_READ_VAR(bi, "OVF",     dac->overflow);
        PUBLISH_READ_VAR(bi, "EVENT",   dac->events.delta_event);

        dac->mms = create_mms_handler("DAC", axis, hw_read_dac_mms);
    }

    WITH_NAME_PREFIX("DAC")
        PUBLISH_ACTION("EVENTS", scan_events);

    return ERROR_OK;
}
