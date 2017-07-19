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
} detector_context[CHANNEL_COUNT];


static void detector_readout_event(void *context, struct interrupts interrupts)
{
    struct detector_context *det = context;
printf("Detector readout %d\n", det->channel);
    hw_read_det_events(
        det->channel, det->output_ovf, det->underrun, det->fir_ovf);
    trigger_record(det->update);
}


static void publish_detector(struct detector_context *det, int i)
{
    COMPILE_ASSERT(sizeof(char) == sizeof(bool));   // We assume this!
    char *bunch_enables = calloc(1, system_config.bunches_per_turn);
    det->bunch_enables[i] = (bool *) bunch_enables;

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
    for (int i = 0; i < DETECTOR_COUNT; i ++)
        hw_write_det_bunch_enable(channel, i, det->bunch_enables[i]);
    hw_write_det_start(channel);
}


error__t initialise_detector(void)
{
    FOR_CHANNEL_NAMES(channel, "DET")
    {
        struct detector_context *det = &detector_context[channel];
        det->channel = channel;

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
