/* Detector control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "register_defs.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "events.h"
#include "sequencer.h"

#include "detector.h"


struct detector_bank {
    int channel;

    struct detector_config config;  // Hardware configuration
    unsigned int bunch_count;       // Number of enabled bunches

    bool output_ovf;                // Detector readout overflow

    float *wf_i;                    // Detector results
    float *wf_q;
    float *wf_power;
    double max_power;
};


struct detector_context {
    int channel;

    struct epics_interlock *update;

    struct detector_bank banks[DETECTOR_COUNT];

    /* Shared detector configuration. */
    bool input_select;

    /* Global detector memory underrun event.  Hope this never happens. */
    bool underrun;

    /* Detector readout support. */
    unsigned int active_channels;       // Updated when preparing detector
    struct detector_result *read_buffer;

    /* Scale information for detector readout copied from sequencer. */
    struct scale_info scale_info;
} detector_context[CHANNEL_COUNT];


static void gather_buffers(
    struct detector_context *context,
    bool enables[DETECTOR_COUNT],
    float *wf_i[DETECTOR_COUNT], float *wf_q[DETECTOR_COUNT],
    float *wf_power[DETECTOR_COUNT])
{
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        struct detector_bank *bank = &context->banks[i];
        enables[i] = bank->config.enable;
        wf_i[i] = bank->wf_i;
        wf_q[i] = bank->wf_q;
        wf_power[i] = bank->wf_power;
    }
}


void get_detector_samples(
    int channel, unsigned int *channels, unsigned int *samples)
{
    struct detector_context *det = &detector_context[channel];
    *channels = det->active_channels;
    *samples = det->scale_info.samples;
}


static void read_detector_memory(
    struct detector_context *det, unsigned int samples)
{
    unsigned int detector_length = system_config.detector_length;
    samples = MIN(samples, detector_length);    // Clip to available length
    hw_read_det_memory(
        det->channel, samples * det->active_channels, 0, det->read_buffer);

    /* Gather all the buffers. */
    bool enables[DETECTOR_COUNT];
    float *wf_i[DETECTOR_COUNT];
    float *wf_q[DETECTOR_COUNT];
    float *wf_power[DETECTOR_COUNT];
    gather_buffers(det, enables, wf_i, wf_q, wf_power);

    /* First zero fill the target buffers. */
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        memset(wf_i[i], 0, detector_length * sizeof(float));
        memset(wf_q[i], 0, detector_length * sizeof(float));
        memset(wf_power[i], 0, detector_length * sizeof(float));
    }

    /* Transpose the readout into the corresponding output waveforms. */
    struct detector_result *result = det->read_buffer;
    for (unsigned int i = 0; i < samples; i ++)
    {
        for (int j = 0; j < DETECTOR_COUNT; j ++)
            if (enables[j])
            {
                wf_i[j][i] = (float) result->i;
                wf_q[j][i] = (float) result->q;
                result += 1;
            }
    }

    /* Compute the power waveform. */
    for (int j = 0; j < DETECTOR_COUNT; j ++)
    {
        float max_power = 0;
        if (enables[j])
            for (unsigned int i = 0; i < samples; i ++)
            {
                float power = SQR(wf_i[j][i]) + SQR(wf_q[j][i]);
                wf_power[j][i] = power;
                if (power > max_power)
                    max_power = power;
            }
        det->banks[j].max_power = 10 * log10(max_power / ldexp(1, 2*31));
    }
}


static void detector_readout_event(struct detector_context *det)
{
    interlock_wait(det->update);

    bool output_ovf[DETECTOR_COUNT];
    bool underrun;
    hw_read_det_events(det->channel, output_ovf, &underrun);
    for (int i = 0; i < DETECTOR_COUNT; i ++)
        det->banks[i].output_ovf = output_ovf[i];

    /* The underrun flag gets set and stays set. */
    if (underrun)
        printf("Unexpected detector readout underrun\n");
    det->underrun |= underrun;

    read_detector_scale_info(
        det->channel, system_config.detector_length, &det->scale_info);

    read_detector_memory(det, det->scale_info.samples);

    interlock_signal(det->update, NULL);
}


static void dispatch_detector_event(void *context, struct interrupts interrupts)
{
    for (int i = 0; i < CHANNEL_COUNT; i ++)
        if (test_intersect(interrupts, INTERRUPTS(.seq_done = (1U << i) & 0x3)))
            detector_readout_event(&detector_context[i]);
}


/* Called when updating the set of bunch enables. */
static void write_bunch_enables(void *context, char enables[], size_t *length)
{
    struct detector_bank *bank = context;

    memcpy(bank->config.bunch_enables, enables, system_config.bunches_per_turn);
    *length = system_config.bunches_per_turn;

    /* Update the bunch count. */
    unsigned int bunch_count = 0;
    for (unsigned int i = 0; i < system_config.bunches_per_turn; i ++)
        if (enables[i])
            bunch_count += 1;
    bank->bunch_count = bunch_count;
}


static void publish_detector(
    struct detector_context *context, int i, struct detector_bank *bank)
{
    COMPILE_ASSERT(sizeof(char) == sizeof(bool));   // We assume this!

    bank->channel = context->channel;

    unsigned int detector_length = system_config.detector_length;
    char *bunch_enables = CALLOC(char, system_config.bunches_per_turn);

    bank->config.bunch_enables = (bool *) bunch_enables;
    bank->wf_i = CALLOC(float, detector_length);
    bank->wf_q = CALLOC(float, detector_length);
    bank->wf_power = CALLOC(float, detector_length);

    char prefix[4];
    sprintf(prefix, "%d", i);
    WITH_NAME_PREFIX(prefix)
    {
        PUBLISH_WRITE_VAR_P(bo, "ENABLE", bank->config.enable);
        PUBLISH_WRITE_VAR_P(mbbo, "SCALING", bank->config.scaling);

        PUBLISH_WAVEFORM_C_P(
            char, "BUNCHES", system_config.bunches_per_turn,
            write_bunch_enables, bank);
        PUBLISH_READ_VAR(ulongin, "COUNT", bank->bunch_count);

        PUBLISH_READ_VAR(bi, "OUT_OVF", bank->output_ovf);

        PUBLISH_WF_READ_VAR(float, "I", detector_length, bank->wf_i);
        PUBLISH_WF_READ_VAR(float, "Q", detector_length, bank->wf_q);
        PUBLISH_WF_READ_VAR(float, "POWER", detector_length, bank->wf_power);
        PUBLISH_READ_VAR(ai, "MAX_POWER", bank->max_power);
    }
}


/* Called before arming the detector. */
void prepare_detector(int channel)
{
    struct detector_context *det = &detector_context[channel];

    struct detector_config config[DETECTOR_COUNT];
    for (int i = 0; i < DETECTOR_COUNT; i ++)
        config[i] = det->banks[i].config;
    unsigned int delay = det->input_select ?
        hardware_delays.DET_FIR_OFFSET :
        hardware_delays.DET_ADC_OFFSET;
    hw_write_det_config(channel, det->input_select, delay, config);
    hw_write_det_start(channel);

    /* Count the number of active channels, needed for readout. */
    det->active_channels = 0;
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        if (config[i].enable)
            det->active_channels += 1;
    }
}


error__t initialise_detector(void)
{
    unsigned int detector_length = system_config.detector_length;

    /* In LMBF mode we run with just one detector channel. */
    FOR_CHANNEL_NAMES(channel, "DET", system_config.lmbf_mode)
    {
        struct detector_context *det = &detector_context[channel];
        det->channel = channel;

        det->read_buffer =
            CALLOC(struct detector_result, DETECTOR_COUNT * detector_length);

        for (int i = 0; i < DETECTOR_COUNT; i ++)
            publish_detector(det, i, &det->banks[i]);

        PUBLISH_WRITE_VAR_P(bo, "SELECT", det->input_select);

        PUBLISH_READ_VAR(bi, "UNDERRUN", det->underrun);

        /* Initialise our own copy of the sequencer scale scale_info. */
        struct scale_info *info = &det->scale_info;
        info->tune_scale = CALLOC(double, detector_length);
        info->timebase = CALLOC(int, detector_length);
        PUBLISH_WF_READ_VAR(double, "SCALE", detector_length, info->tune_scale);
        PUBLISH_WF_READ_VAR(int, "TIMEBASE", detector_length, info->timebase);
        PUBLISH_READ_VAR(ulongin, "SAMPLES", info->samples);

        det->update = create_interlock("UPDATE", false);
    }

    /* Don't listen to events on the idle sequencer in LMBF mode. */
    unsigned int seq_done = system_config.lmbf_mode ? 1 : 3;
    register_event_handler(
        INTERRUPT_HANDLER_DETECTOR, INTERRUPTS(.seq_done = seq_done & 3),
        NULL, dispatch_detector_event);

    return ERROR_OK;
}
