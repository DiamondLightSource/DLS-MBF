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
#include "bunch_fir.h"
#include "bunch_set.h"

#include "detector.h"


/* The enumeration values here must match the selections defined in
 * Db/detector.py for DET:SELECT, and must also match the values defined in
 * register_defs.in for DSP.DET.CONFIG.SELECT. */
enum detector_input_select {
    DET_SELECT_ADC = 0,     // Standard compensated ADC data
    DET_SELECT_FIR = 1,     // Data after bunch by bunch feedback filter
    DET_SELECT_REJECT = 2,  // ADC data after filter and fill pattern rejection
};


struct detector_bank {
    int axis;

    struct detector_config config;  // Hardware configuration
    unsigned int bunch_count;       // Number of enabled bunches
    bool enabled;                   // Set if currently enabled in hardware

    bool output_ovf;                // Detector readout overflow

    unsigned int samples;           // Number of valid samples in this bank
    float *wf_i;                    // Detector results
    float *wf_q;
    float *wf_power;
    float *wf_phase;
    double max_power;

    /* Context for editing bunch enable waveform. */
    struct epics_record *enablewf;
    struct bunch_set *bunch_set;
};


static struct detector_context {
    int axis;

    struct epics_interlock *update;
    struct epics_interlock *update_scale;

    struct detector_bank banks[DETECTOR_COUNT];

    /* Shared detector configuration. */
    uint16_t input_select;
    /* Phase delay to be compensated, in bunches. */
    int phase_delay;
    /* Nominal extra FIR delay. */
    double fir_group_delay;

    /* Global detector memory underrun event.  Hope this never happens. */
    bool underrun;

    /* Detector readout support. */
    unsigned int detector_count;        // Number of active detectors
    unsigned int detector_mask;
    struct detector_result *read_buffer;

    /* Scale information for detector readout copied from sequencer. */
    struct scale_info scale_info;

    /* At the moment there is a compatibility issue with the display manager.
     * This code lets us switch between truncated and filled waveforms when the
     * capture length is shorter than buffer length, but in the long term we
     * will want to switch to truncated waveforms. */
    bool fill_waveform;
    unsigned int scale_length;
} detector_context[AXIS_COUNT];


static void gather_buffers(
    struct detector_context *det,
    bool enables[DETECTOR_COUNT],
    float *wf_i[DETECTOR_COUNT], float *wf_q[DETECTOR_COUNT],
    float *wf_power[DETECTOR_COUNT], float *wf_phase[DETECTOR_COUNT])
{
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        struct detector_bank *bank = &det->banks[i];
        enables[i] = (det->detector_mask >> i) & 1;
        wf_i[i] = bank->wf_i;
        wf_q[i] = bank->wf_q;
        wf_power[i] = bank->wf_power;
        wf_phase[i] = bank->wf_phase;
    }
}


void get_detector_info(int axis, struct detector_info *info)
{
    struct detector_context *det = &detector_context[axis];
    *info = (struct detector_info) {
        .detector_mask = det->detector_mask,
        .detector_count = det->detector_count,
        .samples = det->scale_info.samples,
        .delay = det->phase_delay,
    };
}


/* Converts IQ data from raw buffer into delay compensated IQ data, and
 * transposes into individual detectors. */
static void compute_wf_iq(
    struct detector_context *det, unsigned int samples,
    const bool enables[DETECTOR_COUNT],
    float *wf_i[DETECTOR_COUNT], float *wf_q[DETECTOR_COUNT])
{
    struct detector_result *result = det->read_buffer;
    const struct scale_info *info = &det->scale_info;
    const double *scale = info->tune_scale;
    double phase_delay =
        2.0 * M_PI * det->phase_delay / hardware_config.bunches;
    for (unsigned int i = 0; i < samples; i ++)
    {
        double angle = phase_delay * *scale;
        double rotI = cos(angle);
        double rotQ = sin(angle);
        for (int j = 0; j < DETECTOR_COUNT; j ++)
            if (enables[j])
            {
                /* Convert I and Q to +-1 max scale, this is easier to
                 * understand. */
                double ri = ldexp(result->i, -31);
                double rq = ldexp(result->q, -31);
                /* Need complex conjugate of IQ to account for slightly
                 * embarassing fact that the detector computes responses for
                 * *negative* frequencies! */
                wf_i[j][i] = (float) (rotI * ri + rotQ * rq);
                wf_q[j][i] = - (float) (rotI * rq - rotQ * ri);
                result += 1;
            }
        scale += 1;
    }
}


static void update_samples(struct detector_context *det)
{
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        struct detector_bank *bank = &det->banks[i];
        if (bank->config.enable)
            bank->samples = det->scale_length;
        else
            bank->samples = 0;
    }
}


/* Extends last point to fill entire waveform.  This will be redundant when we
 * switch to always truncating the generated waveforms (see fill_waveform
 * configuration and associated PV). */
static void extend_wf_iq(
    unsigned int samples,
    const bool enables[DETECTOR_COUNT],
    float *wf_i[DETECTOR_COUNT], float *wf_q[DETECTOR_COUNT])
{
    unsigned int detector_length = system_config.detector_length;
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        if (enables[i]  &&  samples > 0)
        {
            float I = wf_i[i][samples - 1];
            float Q = wf_q[i][samples - 1];
            for (unsigned int j = samples; j < detector_length; j ++)
            {
                wf_i[i][j] = I;
                wf_q[i][j] = Q;
            }
        }
        else
        {
            memset(wf_i[i], 0, detector_length * sizeof(float));
            memset(wf_q[i], 0, detector_length * sizeof(float));
        }
    }
}


/* Computes power and phase from IQ and updates maximum power. */
static void compute_power_phase(
    struct detector_context *det,
    float *const wf_i[DETECTOR_COUNT], float *const wf_q[DETECTOR_COUNT],
    float *wf_power[DETECTOR_COUNT], float *wf_phase[DETECTOR_COUNT])
{
    unsigned int detector_length = system_config.detector_length;
    for (int j = 0; j < DETECTOR_COUNT; j ++)
    {
        float max_power = -INFINITY;
        for (unsigned int i = 0; i < detector_length; i ++)
        {
            float I = wf_i[j][i];
            float Q = wf_q[j][i];
            float power = 10 * log10f(SQR(I) + SQR(Q));
            wf_power[j][i] = power;
            wf_phase[j][i] = 180.0F / (float) M_PI * atan2f(Q, I);
            if (power > max_power)
                max_power = power;
        }
        det->banks[j].max_power = max_power;
    }
}


static void read_detector_memory(struct detector_context *det)
{
    const struct scale_info *info = &det->scale_info;
    unsigned int detector_length = system_config.detector_length;
    unsigned int samples = MIN(info->samples, detector_length);
    hw_read_det_memory(
        det->axis, samples * det->detector_count, 0, det->read_buffer);

    /* Gather all the buffers. */
    bool enables[DETECTOR_COUNT];
    float *wf_i[DETECTOR_COUNT];
    float *wf_q[DETECTOR_COUNT];
    float *wf_power[DETECTOR_COUNT];
    float *wf_phase[DETECTOR_COUNT];
    gather_buffers(det, enables, wf_i, wf_q, wf_power, wf_phase);

    /* Transpose the readout into the corresponding output waveforms. */
    compute_wf_iq(det, samples, enables, wf_i, wf_q);

    /* Extend the last data point to fill the buffer if necessary. */
    extend_wf_iq(samples, enables, wf_i, wf_q);

    /* Compute the power waveform. */
    compute_power_phase(det, wf_i, wf_q, wf_power, wf_phase);

    /* Update sample count for each detector. */
    update_samples(det);
}


static void update_detector_scale(struct detector_context *det)
{
    interlock_wait(det->update_scale);

    read_detector_scale_info(
        det->axis, system_config.detector_length, &det->scale_info);
    if (det->fill_waveform)
        det->scale_length = system_config.detector_length;
    else
        det->scale_length =
            MIN(system_config.detector_length, det->scale_info.samples);

    interlock_signal(det->update_scale, NULL);
}

static void update_detector_result(struct detector_context *det)
{
    interlock_wait(det->update);

    bool output_ovf[DETECTOR_COUNT];
    bool underrun;
    hw_read_det_events(det->axis, output_ovf, &underrun);
    for (int i = 0; i < DETECTOR_COUNT; i ++)
        det->banks[i].output_ovf = output_ovf[i];

    /* The underrun flag gets set and stays set. */
    if (underrun)
        log_message("Unexpected detector readout underrun");
    det->underrun |= underrun;

    read_detector_memory(det);

    interlock_signal(det->update, NULL);
}

static void detector_readout_event(struct detector_context *det)
{
    if (detector_scale_changed(det->axis))
        update_detector_scale(det);
    update_detector_result(det);
}


static void dispatch_detector_event(void *context, struct interrupts interrupts)
{
    for (int i = 0; i < AXIS_COUNT; i ++)
        if (test_intersect(interrupts, INTERRUPTS(.seq_done = (1U << i) & 0x3)))
            detector_readout_event(&detector_context[i]);
}


/* Called when updating the set of bunch enables. */
static void write_bunch_enables(
    void *context, char enables[], unsigned int *length)
{
    struct detector_bank *bank = context;

    /* Update the bunch count and normalise each enable to 0/1. */
    unsigned int bunch_count = 0;
    FOR_BUNCHES(i)
    {
        enables[i] = (bool) enables[i];
        if (enables[i])
            bunch_count += 1;
    }
    bank->bunch_count = bunch_count;

    /* Copy the enables after normalisation. */
    memcpy(bank->config.bunch_enables, enables, system_config.bunches_per_turn);
    *length = system_config.bunches_per_turn;
}


static bool enable_selection(void *context, bool *_value)
{
    struct detector_bank *bank = context;
    UPDATE_RECORD_BUNCH_SET(char, bank->bunch_set, bank->enablewf, true);
    return true;
}

static bool disable_selection(void *context, bool *_value)
{
    struct detector_bank *bank = context;
    UPDATE_RECORD_BUNCH_SET(char, bank->bunch_set, bank->enablewf, false);
    return true;
}


static void publish_detector(
    struct detector_context *context, int i, struct detector_bank *bank)
{
    COMPILE_ASSERT(sizeof(char) == sizeof(bool));   // We assume this!

    bank->axis = context->axis;

    unsigned int detector_length = system_config.detector_length;

    bank->config.bunch_enables = CALLOC(bool, system_config.bunches_per_turn);
    bank->wf_i = CALLOC(float, detector_length);
    bank->wf_q = CALLOC(float, detector_length);
    bank->wf_power = CALLOC(float, detector_length);
    bank->wf_phase = CALLOC(float, detector_length);

    char prefix[4];
    sprintf(prefix, "%d", i);
    WITH_NAME_PREFIX(prefix)
    {
        PUBLISH_WRITE_VAR_P(bo, "ENABLE", bank->config.enable);
        PUBLISH_READ_VAR(bi, "ENABLE", bank->enabled);
        PUBLISH_WRITE_VAR_P(mbbo, "SCALING", bank->config.scaling);

        bank->enablewf = PUBLISH_WAVEFORM_C_P(
            char, "BUNCHES", system_config.bunches_per_turn,
            write_bunch_enables, bank);
        PUBLISH_READ_VAR(ulongin, "COUNT", bank->bunch_count);

        PUBLISH_READ_VAR(bi, "OUT_OVF", bank->output_ovf);

        PUBLISH_WF_READ_VAR_LEN(float, "I",
            detector_length, bank->samples, bank->wf_i);
        PUBLISH_WF_READ_VAR_LEN(float, "Q",
            detector_length, bank->samples, bank->wf_q);
        PUBLISH_WF_READ_VAR_LEN(float, "POWER",
            detector_length, bank->samples, bank->wf_power);
        PUBLISH_WF_READ_VAR_LEN(float, "PHASE",
            detector_length, bank->samples, bank->wf_phase);
        PUBLISH_READ_VAR(ai, "MAX_POWER", bank->max_power);

        bank->bunch_set = create_bunch_set();
        PUBLISH_C(bo, "SET_SELECT", enable_selection, bank);
        PUBLISH_C(bo, "RESET_SELECT", disable_selection, bank);
    }
}


static void compute_detector_delay_offset(
    struct detector_context *det, int *delay, unsigned int *offset)
{
    switch (det->input_select)
    {
        case DET_SELECT_ADC:
            *offset = hardware_delays.DET_ADC_OFFSET;
            *delay = hardware_delays.DET_ADC_DELAY +
                (int) hardware_config.bunches;
            break;
        case DET_SELECT_FIR:
            *offset = hardware_delays.DET_FIR_OFFSET;
            *delay = hardware_delays.DET_FIR_DELAY +
                (int) lround(det->fir_group_delay *
                    (get_fir_decimation() * hardware_config.bunches));
            break;
        case DET_SELECT_REJECT:
            *offset = hardware_delays.DET_ADC_REJECT_OFFSET;
            *delay = hardware_delays.DET_ADC_REJECT_DELAY +
                (int) hardware_config.bunches;
            break;
        default:
            ASSERT_FAIL();
    }
}


/* Called before arming the detector. */
void prepare_detector(int axis)
{
    struct detector_context *det = &detector_context[axis];

    /* Compute the delay required for phase correction and the offset requred
     * for bunch correction. */
    unsigned int offset;
    compute_detector_delay_offset(det, &det->phase_delay, &offset);

    struct detector_config config[DETECTOR_COUNT];
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        config[i] = det->banks[i].config;
        det->banks[i].enabled = config[i].enable;
    }

    hw_write_det_config(axis, det->input_select, offset, config);
    hw_write_det_start(axis);

    /* Count the number of active axes, needed for readout. */
    det->detector_count = 0;
    det->detector_mask = 0;
    for (int i = 0; i < DETECTOR_COUNT; i ++)
    {
        if (config[i].enable)
        {
            det->detector_count += 1;
            det->detector_mask |= 1U << i;
        }
    }
}


const struct detector_config *get_detector_config(int axis, int detector)
{
    return &detector_context[axis].banks[detector].config;
}


error__t initialise_detector(void)
{
    unsigned int detector_length = system_config.detector_length;

    /* In LMBF mode we run with just one detector axis. */
    FOR_AXIS_NAMES(axis, "DET", system_config.lmbf_mode)
    {
        struct detector_context *det = &detector_context[axis];
        det->axis = axis;

        det->read_buffer =
            CALLOC(struct detector_result, DETECTOR_COUNT * detector_length);

        for (int i = 0; i < DETECTOR_COUNT; i ++)
            publish_detector(det, i, &det->banks[i]);

        PUBLISH_WRITE_VAR_P(mbbo, "SELECT", det->input_select);

        PUBLISH_READ_VAR(bi, "UNDERRUN", det->underrun);

        /* Initialise our own copy of the sequencer scale scale_info. */
        struct scale_info *info = &det->scale_info;
        info->tune_scale = CALLOC(double, detector_length);
        info->timebase = CALLOC(int, detector_length);
        PUBLISH_WF_READ_VAR_LEN(double, "SCALE",
            detector_length, det->scale_length, info->tune_scale);
        PUBLISH_WF_READ_VAR_LEN(int, "TIMEBASE",
            detector_length, det->scale_length, info->timebase);
        PUBLISH_READ_VAR(ulongin, "SAMPLES", info->samples);
        PUBLISH_WRITE_VAR_P(ao, "FIR_DELAY", det->fir_group_delay);

        PUBLISH_WRITE_VAR_P(bo, "FILL_WAVEFORM", det->fill_waveform);

        det->update_scale = create_interlock("UPDATE_SCALE", false);
        det->update = create_interlock("UPDATE", false);
    }

    /* Don't listen to events on the idle sequencer in LMBF mode. */
    unsigned int seq_done = system_config.lmbf_mode ? 1 : 3;
    register_event_handler(
        INTERRUPT_HANDLER_DETECTOR, INTERRUPTS(.seq_done = seq_done & 3),
        NULL, dispatch_detector_event);

    return ERROR_OK;
}
