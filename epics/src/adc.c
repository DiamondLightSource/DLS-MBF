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
#include "configs.h"
#include "mms.h"
#include "memory.h"

#include "adc.h"


static struct adc_context {
    int channel;
    bool mms_after_fir;
    bool dram_after_fir;
    unsigned int filter_delay;
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


static bool set_adc_overflow_threshold(void *context, double *value)
{
    struct adc_context *adc = context;
    hw_write_adc_overflow_threshold(
        adc->channel, (unsigned int) ldexp(*value, 13));
    return true;
}


static bool set_adc_delta_threshold(void *context, double *value)
{
    struct adc_context *adc = context;
    hw_write_adc_delta_threshold(
        adc->channel, (unsigned int) ldexp(*value, 15));
    return true;
}


static bool set_adc_loopback(void *context, bool *value)
{
    struct adc_context *adc = context;
    hw_write_loopback_enable(adc->channel, *value);
    return true;
}


static void update_delays(struct adc_context *adc)
{
    set_mms_offset(adc->mms, adc->mms_after_fir ?
        hardware_delays.MMS_ADC_FIR_DELAY :
        hardware_delays.MMS_ADC_DELAY - adc->filter_delay);
    set_memory_adc_offset(adc->channel, adc->dram_after_fir ?
        hardware_delays.DRAM_ADC_FIR_DELAY :
        hardware_delays.DRAM_ADC_DELAY - adc->filter_delay);
}

static bool write_adc_mms_source(void *context, bool *after_fir)
{
    struct adc_context *adc = context;
    adc->mms_after_fir = *after_fir;
    hw_write_adc_mms_source(adc->channel, *after_fir);
    update_delays(adc);
    return true;
}

static bool write_adc_dram_source(void *context, bool *after_fir)
{
    struct adc_context *adc = context;
    adc->dram_after_fir = *after_fir;
    hw_write_adc_dram_source(adc->channel, *after_fir);
    update_delays(adc);
    return true;
}

static bool write_filter_delay(void *context, unsigned int *delay)
{
    struct adc_context *adc = context;
    adc->filter_delay = *delay;
    update_delays(adc);
    return true;
}



static void scan_events(void)
{
    for (int i = 0; i < CHANNEL_COUNT; i ++)
        hw_read_adc_events(i, &adc_context[i].events);
}


error__t initialise_adc(void)
{
    FOR_CHANNEL_NAMES(channel, "ADC")
    {
        struct adc_context *adc = &adc_context[channel];
        adc->channel = channel;

        PUBLISH_WAVEFORM_C_P(float, "FILTER",
            hardware_config.adc_taps, write_adc_taps, adc);
        PUBLISH_C_P(ulongout, "FILTER:DELAY", write_filter_delay, adc);

        PUBLISH_C_P(ao, "OVF_LIMIT", set_adc_overflow_threshold, adc);
        PUBLISH_C_P(ao, "EVENT_LIMIT", set_adc_delta_threshold, adc);
        PUBLISH_C(bo, "LOOPBACK", set_adc_loopback, adc);
        PUBLISH_C_P(bo, "MMS_SOURCE",  write_adc_mms_source, adc);
        PUBLISH_C_P(bo, "DRAM_SOURCE", write_adc_dram_source, adc);

        PUBLISH_READ_VAR(bi, "INPUT_OVF", adc->events.input_ovf);
        PUBLISH_READ_VAR(bi, "FIR_OVF",   adc->events.fir_ovf);
        PUBLISH_READ_VAR(bi, "MMS_OVF",   adc->events.mms_ovf);
        PUBLISH_READ_VAR(bi, "EVENT",     adc->events.delta_event);

        adc->mms = create_mms_handler(channel, hw_read_adc_mms);
    }

    PUBLISH_ACTION("ADC:EVENTS", scan_events);

    return ERROR_OK;
}
