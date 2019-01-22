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
    int axis;
    bool mms_after_fir;
    bool dram_after_fir;
    bool overflow;
    struct adc_events events;
    struct mms_handler *mms;
} adc_context[AXIS_COUNT];


static struct phase {
    float *magnitude;
    float *phase;
    double mean_phase;
    double mean_magnitude;
    double threshold;
} phase;


static void write_adc_taps(void *context, float array[], unsigned int *length)
{
    struct adc_context *adc = context;
    *length = hardware_config.adc_taps;

    int taps[hardware_config.adc_taps];
    float_array_to_int(hardware_config.adc_taps, array, taps, 32, 31);

    hw_write_adc_taps(adc->axis, taps);
}


static bool set_adc_overflow_threshold(void *context, double *value)
{
    struct adc_context *adc = context;
    hw_write_adc_overflow_threshold(adc->axis, double_to_uint(value, 13, 13));
    return true;
}


static bool set_adc_delta_threshold(void *context, double *value)
{
    struct adc_context *adc = context;
    hw_write_adc_delta_threshold(adc->axis, double_to_uint(value, 16, 15));
    return true;
}


static bool set_adc_loopback(void *context, bool *value)
{
    struct adc_context *adc = context;
    hw_write_loopback_enable(adc->axis, *value);
    return true;
}


static void update_delays(struct adc_context *adc)
{
    set_mms_offset(adc->mms, adc->mms_after_fir ?
        hardware_delays.MMS_ADC_FIR_DELAY :
        hardware_delays.MMS_ADC_DELAY);
    set_memory_adc_offset(adc->axis, adc->dram_after_fir ?
        hardware_delays.DRAM_ADC_FIR_DELAY :
        hardware_delays.DRAM_ADC_DELAY);
}

static bool write_adc_mms_source(void *context, bool *after_fir)
{
    struct adc_context *adc = context;
    adc->mms_after_fir = *after_fir;
    hw_write_adc_mms_source(adc->axis, *after_fir);
    update_delays(adc);
    return true;
}

static bool write_adc_dram_source(void *context, bool *after_fir)
{
    struct adc_context *adc = context;
    adc->dram_after_fir = *after_fir;
    hw_write_adc_dram_source(adc->axis, *after_fir);
    update_delays(adc);
    return true;
}


static void scan_events(void)
{
    for (int i = 0; i < AXIS_COUNT; i ++)
    {
        struct adc_context *adc = &adc_context[i];
        hw_read_adc_events(i, &adc->events);
        adc->overflow = adc->events.input_ovf | adc->events.fir_ovf;
    }
}


static void compute_phase(void)
{
    unsigned int bunches = hardware_config.bunches;
    float mean_i[bunches], mean_q[bunches];
    read_mms_mean(adc_context[0].mms, mean_i);
    read_mms_mean(adc_context[1].mms, mean_q);

    float max_mag = 0;
    float sum_mag = 0;
    FOR_BUNCHES(i)
    {
        phase.magnitude[i] = sqrtf(SQR(mean_i[i]) + SQR(mean_q[i]));
        max_mag = MAX(max_mag, phase.magnitude[i]);
        sum_mag += phase.magnitude[i];
    }
    phase.mean_magnitude = sum_mag / (float) bunches;

    float threshold = (float) phase.threshold * max_mag;
    float sum_i = 0, sum_q = 0;
    FOR_BUNCHES(i)
    {
        if (phase.magnitude[i] > threshold)
        {
            phase.phase[i] = 180 / (float) M_PI * atan2f(-mean_i[i], mean_q[i]);
            sum_i += mean_i[i];
            sum_q += mean_q[i];
        }
        else
            phase.phase[i] = 0;
    }
    phase.mean_phase = 180 / (float) M_PI * atan2f(-sum_i, sum_q);
}


error__t initialise_adc(void)
{
    FOR_AXIS_NAMES(axis, "ADC")
    {
        struct adc_context *adc = &adc_context[axis];
        adc->axis = axis;

        PUBLISH_WAVEFORM_C_P(float, "FILTER",
            hardware_config.adc_taps, write_adc_taps, adc);

        PUBLISH_C_P(ao, "OVF_LIMIT", set_adc_overflow_threshold, adc);
        PUBLISH_C_P(ao, "EVENT_LIMIT", set_adc_delta_threshold, adc);
        PUBLISH_C(bo, "LOOPBACK", set_adc_loopback, adc);
        PUBLISH_C_P(bo, "MMS_SOURCE",  write_adc_mms_source, adc);
        PUBLISH_C_P(bo, "DRAM_SOURCE", write_adc_dram_source, adc);

        PUBLISH_READ_VAR(bi, "INP_OVF", adc->events.input_ovf);
        PUBLISH_READ_VAR(bi, "FIR_OVF", adc->events.fir_ovf);
        PUBLISH_READ_VAR(bi, "OVF",     adc->overflow);
        PUBLISH_READ_VAR(bi, "EVENT",   adc->events.delta_event);

        adc->mms = create_mms_handler("ADC", axis, hw_read_adc_mms);
    }

    WITH_NAME_PREFIX("ADC")
        PUBLISH_ACTION("EVENTS", scan_events);

    if (system_config.lmbf_mode)
    {
        unsigned int bunches = hardware_config.bunches;
        phase.magnitude = CALLOC(float, bunches);
        phase.phase = CALLOC(float, bunches);
        FOR_AXIS_NAMES(axis, "ADC", system_config.lmbf_mode)
        {
            PUBLISH_ACTION("TRIGGER", compute_phase);
            PUBLISH_WF_READ_VAR(float, "MAGNITUDE", bunches, phase.magnitude);
            PUBLISH_WF_READ_VAR(float, "PHASE", bunches, phase.phase);
            PUBLISH_READ_VAR(ai, "PHASE_MEAN", phase.mean_phase);
            PUBLISH_READ_VAR(ai, "MAGNITUDE_MEAN", phase.mean_magnitude);
            PUBLISH_WRITE_VAR_P(ao, "THRESHOLD", phase.threshold);
        }
    }

    return ERROR_OK;
}
