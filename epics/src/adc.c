/* EPICS interface to ADC readout and control. */

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
#include "mms.h"

#include "adc.h"


static struct adc_context {
    int channel;
    struct adc_events events;
    struct mms_handler *mms;
} adc_context[CHANNEL_COUNT];


static void write_adc_taps(void *context, float array[], size_t *length)
{
    struct adc_context *adc = context;

    *length = hardware_config.adc_taps;
    int taps[hardware_config.adc_taps];
    float_array_to_int(hardware_config.adc_taps, array, taps, 32, 0);

    hw_write_adc_taps(adc->channel, taps);
}


static bool set_adc_overflow_threshold(void *context, const double *value)
{
    struct adc_context *adc = context;
    hw_write_adc_overflow_threshold(
        adc->channel, (unsigned int) ldexp(*value, 13));
    return true;
}


static bool set_adc_delta_threshold(void *context, const double *value)
{
    struct adc_context *adc = context;
    hw_write_adc_delta_threshold(
        adc->channel, (unsigned int) ldexp(*value, 15));
    return true;
}


static bool arm_adc_min_max(void *context, const bool *value)
{
    struct adc_context *adc = context;
    hw_write_adc_arm_delta(adc->channel);
    return true;
}


static void scan_events(void)
{
    for (int i = 0; i < CHANNEL_COUNT; i ++)
        hw_read_adc_events(i, &adc_context[i].events);
}


error__t initialise_adc(void)
{
    unsigned int adc_mms_offset = 0;    // To be read from h/w config

    FOR_CHANNEL_NAMES(channel, "ADC")
    {
        struct adc_context *adc = &adc_context[channel];
        adc->channel = channel;

        PUBLISH_WAVEFORM(float, "FILTER",
            hardware_config.adc_taps, write_adc_taps,
            .context = adc, .persist = true);

        PUBLISH(ao, "OVF_LIMIT", set_adc_overflow_threshold,
            .context = adc, .persist = true);
        PUBLISH(ao, "EVENT_LIMIT", set_adc_delta_threshold,
            .context = adc, .persist = true);
        PUBLISH(bo, "ARM", arm_adc_min_max, .context = adc);

        PUBLISH_READ_VAR(bi, "INPUT_OVF", adc->events.input_ovf);
        PUBLISH_READ_VAR(bi, "FIR_OVF",   adc->events.fir_ovf);
        PUBLISH_READ_VAR(bi, "MMS_OVF",   adc->events.mms_ovf);
        PUBLISH_READ_VAR(bi, "EVENT",     adc->events.delta_event);

        adc->mms = create_mms_handler(channel, hw_read_adc_mms, adc_mms_offset);
    }

    PUBLISH_ACTION("ADC:EVENTS", scan_events);

    return ERROR_OK;
}
