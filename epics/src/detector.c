/* Detector control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>

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


struct detector_context {
    int channel;

    struct epics_interlock *update;

    /* Shared detector configuration. */
    bool input_select;
    struct detector_config config[DETECTOR_COUNT];

    /* Detector events. */
    bool output_ovf[DETECTOR_COUNT];
    bool underrun;

    /* Detector waveforms. */
    unsigned int active_channels;       // Updated when preparing detector
    struct detector_result *read_buffer;
    float *wf_i[DETECTOR_COUNT];
    float *wf_q[DETECTOR_COUNT];
    float *wf_power[DETECTOR_COUNT];
} detector_context[CHANNEL_COUNT];


static void read_detector_memory(
    struct detector_context *det, unsigned int samples)
{
    unsigned int detector_length = system_config.detector_length;
    samples = MIN(samples, detector_length);    // Clip to available length
    hw_read_det_memory(
        det->channel, samples * det->active_channels, det->read_buffer);

    /* First zero fill all the target buffers. */
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        memset(det->wf_i[i], 0, detector_length * sizeof(float));
        memset(det->wf_q[i], 0, detector_length * sizeof(float));
        memset(det->wf_power[i], 0, detector_length * sizeof(float));
    }

    /* Transpose the readout into the corresponding output waveforms. */
    struct detector_result *result = det->read_buffer;
    for (unsigned int i = 0; i < samples; i ++)
    {
        for (int j = 0; j < DETECTOR_COUNT; j ++)
            if (det->config[j].enable)
            {
                float iq_i = (float) result->i;
                float iq_q = (float) result->q;
                result += 1;

                det->wf_i[j][i] = iq_i;
                det->wf_q[j][i] = iq_q;
                det->wf_power[j][i] = iq_i * iq_i + iq_q * iq_q;
            }
    }
}


static void detector_readout_event(void *context, struct interrupts interrupts)
{
    struct detector_context *det = context;

    interlock_wait(det->update);

    hw_read_det_events(det->channel, det->output_ovf, &det->underrun);

    const struct scale_info *info = read_detector_scale_info(det->channel);
    read_detector_memory(det, info->samples);

    interlock_signal(det->update, NULL);
}


static void publish_detector(struct detector_context *det, int i)
{
    COMPILE_ASSERT(sizeof(char) == sizeof(bool));   // We assume this!

    unsigned int detector_length = system_config.detector_length;
    char *bunch_enables = calloc(1, system_config.bunches_per_turn);

    det->config[i].bunch_enables = (bool *) bunch_enables;
    det->wf_i[i] = calloc(sizeof(float), detector_length);
    det->wf_q[i] = calloc(sizeof(float), detector_length);
    det->wf_power[i] = calloc(sizeof(float), detector_length);

    char prefix[4];
    sprintf(prefix, "%d", i);
    WITH_NAME_PREFIX(prefix)
    {
        PUBLISH_WRITE_VAR_P(bo, "ENABLE", det->config[i].enable);
        PUBLISH_WRITE_VAR_P(mbbo, "SCALING", det->config[i].scaling);
        PUBLISH_WF_WRITE_VAR_P(
            char, "BUNCHES", system_config.bunches_per_turn, bunch_enables);

        PUBLISH_READ_VAR(bi, "OUT_OVF", det->output_ovf[i]);
        PUBLISH_READ_VAR(bi, "UNDERRUN", det->underrun[i]);

        PUBLISH_WF_READ_VAR(float, "I", detector_length, det->wf_i[i]);
        PUBLISH_WF_READ_VAR(float, "Q", detector_length, det->wf_q[i]);
        PUBLISH_WF_READ_VAR(float, "POWER", detector_length, det->wf_power[i]);
    }
}


/* Called before arming the detector. */
void prepare_detector(int channel)
{
    printf("prepare_detector %d\n", channel);
    struct detector_context *det = &detector_context[channel];
    hw_write_det_config(channel, det->input_select, det->config);
    hw_write_det_start(channel);

    /* Count the number of active channels, needed for readout. */
    det->active_channels = 0;
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        if (det->config[i].enable)
            det->active_channels += 1;
    }
}


error__t initialise_detector(void)
{
    unsigned int detector_length = system_config.detector_length;
    FOR_CHANNEL_NAMES(channel, "DET")
    {
        struct detector_context *det = &detector_context[channel];
        det->channel = channel;

        det->read_buffer = calloc(
            DETECTOR_COUNT * sizeof(struct detector_result), detector_length);

        for (int i = 0; i < DETECTOR_COUNT; i ++)
            publish_detector(det, i);

        PUBLISH_WRITE_VAR_P(bo, "SELECT", det->input_select);

        const struct scale_info *info = read_detector_scale_info(det->channel);
        PUBLISH_WF_READ_VAR(double, "SCALE", detector_length, info->tune_scale);
        PUBLISH_WF_READ_VAR(int, "TIMEBASE", detector_length, info->timebase);
        PUBLISH_READ_VAR(ulongin, "SAMPLES", info->samples);
        PUBLISH_READ_VAR(bi, "UNDERRUN", det->underrun);

        det->update = create_interlock("UPDATE", false);
        register_event_handler(
            INTERRUPT_HANDLER_DETECTOR_0 + channel,
            INTERRUPTS(.seq_done = (1U << channel) & 0x3),
            det, detector_readout_event);
    }

    return ERROR_OK;
}
