/* DAC readout and control. */

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
    bool mms_after_fir;
    bool dram_after_fir;
    bool overflow;
    unsigned int filter_delay;
    struct dac_events events;
    struct mms_handler *mms;
} dac_context[AXIS_COUNT];


static void write_dac_taps(void *context, float array[], unsigned int *length)
{
    struct dac_context *dac = context;
    *length = hardware_config.dac_taps;

    int taps[hardware_config.dac_taps];
    float_array_to_int(hardware_config.dac_taps, array, taps, 32, 0);

    hw_write_dac_taps(dac->axis, taps);
}


static bool write_dac_delay(void *context, unsigned int *value)
{
    struct dac_context *dac = context;
    hw_write_dac_delay(dac->axis, *value);
    return true;
}


static bool write_dac_output_enable(void *context, bool *value)
{
    struct dac_context *dac = context;
    dac->output_enable = *value;
    hw_write_output_enable(dac->axis, dac->output_enable);
    return true;
}


bool get_dac_output_enable(int axis)
{
    struct dac_context *dac = &dac_context[axis];
    return dac->output_enable;
}


static void update_delays(struct dac_context *dac)
{
    set_mms_offset(dac->mms, dac->mms_after_fir ?
        hardware_delays.MMS_DAC_FIR_DELAY + dac->filter_delay :
        hardware_delays.MMS_DAC_DELAY);
    set_memory_dac_offset(dac->axis, dac->dram_after_fir ?
        hardware_delays.DRAM_DAC_FIR_DELAY + dac->filter_delay :
        hardware_delays.DRAM_DAC_DELAY);
}

static bool write_dac_mms_source(void *context, bool *after_fir)
{
    struct dac_context *dac = context;
    dac->mms_after_fir = *after_fir;
    hw_write_dac_mms_source(dac->axis, *after_fir);
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

static bool write_filter_delay(void *context, unsigned int *delay)
{
    struct dac_context *dac = context;
    dac->filter_delay = *delay;
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
}


error__t initialise_dac(void)
{
    FOR_AXIS_NAMES(axis, "DAC")
    {
        struct dac_context *dac = &dac_context[axis];
        dac->axis = axis;

        PUBLISH_WAVEFORM_C_P(float, "FILTER",
            hardware_config.dac_taps, write_dac_taps, dac);
        PUBLISH_C_P(ulongout, "FILTER:DELAY", write_filter_delay, dac);

        PUBLISH_C_P(ulongout, "DELAY", write_dac_delay, dac);
        PUBLISH_C(bo, "ENABLE",      write_dac_output_enable, dac);
        PUBLISH_C_P(bo, "MMS_SOURCE",  write_dac_mms_source, dac);
        PUBLISH_C_P(bo, "DRAM_SOURCE", write_dac_dram_source, dac);

        PUBLISH_READ_VAR(bi, "BUN_OVF", dac->events.fir_ovf);
        PUBLISH_READ_VAR(bi, "MUX_OVF", dac->events.mux_ovf);
        PUBLISH_READ_VAR(bi, "FIR_OVF", dac->events.out_ovf);
        PUBLISH_READ_VAR(bi, "OVF",     dac->overflow);

        dac->mms = create_mms_handler(axis, hw_read_dac_mms);
    }

    PUBLISH_ACTION("DAC:EVENTS", scan_events);

    return ERROR_OK;
}
