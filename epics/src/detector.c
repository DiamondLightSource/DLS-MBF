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

#include "detector.h"


struct detector_context {
    int channel;

    struct epics_record *update;

    /* Shared detector configuration. */
    bool fir_gain;
    bool input_select;

    /* Detector specific configuration. */
    bool capture_enable[DETECTOR_COUNT];
    unsigned int scaling[DETECTOR_COUNT];
    bool *bunch_enables[DETECTOR_COUNT];

    /* Detector events. */
    bool output_ovf[DETECTOR_COUNT];
    bool underrun[DETECTOR_COUNT];
    bool fir_ovf[DETECTOR_COUNT];

    /* Detector waveforms. */
    unsigned int active_channels;       // Updated when preparing detector
    struct detector_result *read_buffer;
    float *wf_i[DETECTOR_COUNT];
    float *wf_q[DETECTOR_COUNT];
    float *wf_power[DETECTOR_COUNT];
} detector_context[CHANNEL_COUNT];


static void read_detector_memory(struct detector_context *det)
{
    unsigned int readout_length = system_config.detector_length;
    hw_read_det_memory(
        det->channel, readout_length * det->active_channels, det->read_buffer);

    /* Transpose the readout into the corresponding output waveforms. */
    struct detector_result *result = det->read_buffer;
    for (unsigned int i = 0; i < readout_length; i ++)
    {
        for (int j = 0; j < DETECTOR_COUNT; j ++)
            if (det->capture_enable[j])
            {
                float iq_i = (float) result->i;
                float iq_q = (float) result->q;
                det->wf_i[j][i] = iq_i;
                det->wf_q[j][i] = iq_q;
                det->wf_power[j][i] = iq_i * iq_i + iq_q * iq_q;
                result += 1;
            }
            else
            {
                det->wf_i[j][i] = 0.0;
                det->wf_q[j][i] = 0.0;
                det->wf_power[j][i] = 0.0;
            }
    }
}


static void detector_readout_event(void *context, struct interrupts interrupts)
{
    struct detector_context *det = context;
printf("Detector readout %d\n", det->channel);
    hw_read_det_events(
        det->channel, det->output_ovf, det->underrun, det->fir_ovf);

    read_detector_memory(det);

    trigger_record(det->update);
}


static void publish_detector(struct detector_context *det, int i)
{
    COMPILE_ASSERT(sizeof(char) == sizeof(bool));   // We assume this!

    unsigned int detector_length = system_config.detector_length;
    char *bunch_enables = calloc(1, system_config.bunches_per_turn);

    det->bunch_enables[i] = (bool *) bunch_enables;
    det->wf_i[i] = calloc(sizeof(float), detector_length);
    det->wf_q[i] = calloc(sizeof(float), detector_length);
    det->wf_power[i] = calloc(sizeof(float), detector_length);

    char prefix[4];
    sprintf(prefix, "%d", i);
    WITH_NAME_PREFIX(prefix)
    {
        PUBLISH_WRITE_VAR_P(bo, "ENABLE", det->capture_enable[i]);
        PUBLISH_WRITE_VAR_P(mbbo, "SCALING", det->scaling[i]);
        PUBLISH_WF_WRITE_VAR_P(
            char, "BUNCHES", system_config.bunches_per_turn, bunch_enables);

        PUBLISH_READ_VAR(bi, "FIR_OVF", det->fir_ovf[i]);
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
    hw_write_det_config(channel,
        det->fir_gain, det->input_select,
        det->capture_enable, det->scaling);
    det->active_channels = 0;
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        hw_write_det_bunch_enable(channel, i, det->bunch_enables[i]);
        if (det->capture_enable[i])
            det->active_channels += 1;
    }
    hw_write_det_start(channel);
}


error__t initialise_detector(void)
{
    FOR_CHANNEL_NAMES(channel, "DET")
    {
        struct detector_context *det = &detector_context[channel];
        det->channel = channel;

        det->read_buffer = calloc(
            DETECTOR_COUNT * sizeof(struct detector_result),
            system_config.detector_length);

        for (int i = 0; i < DETECTOR_COUNT; i ++)
            publish_detector(det, i);

        PUBLISH_WRITE_VAR_P(bo, "FIR_GAIN", det->fir_gain);
        PUBLISH_WRITE_VAR_P(bo, "SELECT", det->input_select);

        det->update = PUBLISH_TRIGGER("UPDATE");
        register_event_handler(
            INTERRUPTS(.seq_done = (1U << channel) & 0x3),
            det, detector_readout_event);
    }

    return ERROR_OK;
}
