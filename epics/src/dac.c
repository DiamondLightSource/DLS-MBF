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

#include "dac.h"


static struct dac_context {
    int channel;
    struct dac_events events;
    struct mms_handler *mms;
} dac_context[CHANNEL_COUNT];


static void write_dac_taps(void *context, float array[], size_t *length)
{
    struct dac_context *dac = context;
    *length = hardware_config.dac_taps;

    int taps[hardware_config.dac_taps];
    float_array_to_int(hardware_config.dac_taps, array, taps, 32, 0);

    hw_write_dac_taps(dac->channel, taps);
}


static bool write_dac_delay(void *context, const unsigned int *value)
{
    struct dac_context *dac = context;
    hw_write_dac_delay(dac->channel, *value);
    return true;
}


static bool write_dac_fir_enable(void *context, const bool *value)
{
    struct dac_context *dac = context;
    hw_write_dac_fir_enable(dac->channel, *value);
    return true;
}

static bool write_dac_nco1_enable(void *context, const bool *value)
{
    struct dac_context *dac = context;
    hw_write_dac_nco1_enable(dac->channel, *value);
    return true;
}

static bool write_dac_output_enable(void *context, const bool *value)
{
    struct dac_context *dac = context;
    hw_write_output_enable(dac->channel, *value);
    return true;
}


static void scan_events(void)
{
    for (int i = 0; i < CHANNEL_COUNT; i ++)
        hw_read_dac_events(i, &dac_context[i].events);
}


error__t initialise_dac(void)
{
    FOR_CHANNEL_NAMES(channel, "DAC")
    {
        struct dac_context *dac = &dac_context[channel];
        dac->channel = channel;

        PUBLISH_WAVEFORM_C_P(float, "FILTER",
            hardware_config.dac_taps, write_dac_taps, dac);

        PUBLISH_C_P(ulongout, "DELAY", write_dac_delay, dac);
        PUBLISH_C_P(bo, "FIR_ENABLE",  write_dac_fir_enable, dac);
        PUBLISH_C_P(bo, "NCO1_ENABLE", write_dac_nco1_enable, dac);
        PUBLISH_C_P(bo, "ENABLE",      write_dac_output_enable, dac);

        PUBLISH_READ_VAR(bi, "BUN_OVF", dac->events.fir_ovf);
        PUBLISH_READ_VAR(bi, "MUX_OVF", dac->events.mux_ovf);
        PUBLISH_READ_VAR(bi, "FIR_OVF", dac->events.out_ovf);
        PUBLISH_READ_VAR(bi, "MMS_OVF", dac->events.mms_ovf);

        dac->mms = create_mms_handler(
            channel, hw_read_dac_mms, hardware_delays.dac_mms_offset);
    }

    PUBLISH_ACTION("DAC:EVENTS", scan_events);

    return ERROR_OK;
}
