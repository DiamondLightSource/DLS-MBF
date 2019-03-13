/* Control interface to Tune PLL functionality. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
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
#include "bunch_fir.h"
#include "bunch_set.h"
#include "tune_pll_fifo.h"

#include "tune_pll.h"


/* CORDIC magnitude correction.  The CORDIC readback is scaled by this value. */
#define CORDIC_SCALING      (1.6467602581210654 / 2)


/* This is a copy of the corresponding options in detector.c. */
enum detector_input_select {
    DET_SELECT_ADC = 0,     // Standard compensated ADC data
    DET_SELECT_FIR = 1,     // Data after bunch by bunch feedback filter
    DET_SELECT_REJECT = 2,  // ADC data after filter and fill pattern rejection
};


static struct pll_context {
    int axis;

    /* Frequency management. */
    struct readout_fifo *offset_fifo;
    struct epics_record *offset_pv;
    double mean_offset;                 // Mean offset from offset FIFO

    /* The stored frequency is updated by three independent events:
     *  1. polled readbacks of offset while running
     *  2. direct writes to NCO:FREQ_S PV
     *  3. when control stops to read final value */
    uint64_t nco_freq_set;              // NCO frequency set from PV
    uint64_t current_nco;               // Current computed NCO frequency
    double nco_freq_out;                // Current frequency readback
    double nco_tune;                    // Tune part if running, NaN otherwise

    /* Target phase and delay to be compensated. */
    unsigned int phase_delay;           // Updated from detector source
    uint32_t target_phase;              // User specified target phase

    /* Live events. */
    struct tune_pll_events events;
    struct tune_pll_status status;
    struct epics_record *update_pv;

    /* Detector configuration. */
    enum detector_input_select input_select;
    unsigned int readout_scale;
    bool *bunch_enables;
    unsigned int bunch_count;
    struct epics_record *enablewf;
    struct bunch_set *bunch_set;

    /* Filtered readbacks. */
    double filtered_cos;
    double filtered_sin;
    bool filtered_cordic;
    double filtered_magnitude;
    double filtered_phase;

    /* Debug readback. */
    struct readout_fifo *debug_fifo;
    unsigned int debug_length;
    float *debug_i;
    float *debug_q;
    float *debug_mag;
    float *debug_angle;
    bool captured_cordic;
    bool compensate_debug;
} pll_context[AXIS_COUNT] = { };


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Feedback setup and control. */


/* Configuration. */

static bool write_ki(void *context, double *value)
{
    struct pll_context *pll = context;
    hw_write_pll_integral_factor(pll->axis, (int32_t) *value << 7);
    return true;
}

static bool write_kp(void *context, double *value)
{
    struct pll_context *pll = context;
    hw_write_pll_proportional_factor(pll->axis, (int32_t) *value << 7);
    return true;
}

static bool write_min_magnitude(void *context, double *value)
{
    struct pll_context *pll = context;
    uint32_t min_mag = (uint32_t) lround(ldexp(*value, 31) * CORDIC_SCALING);
    hw_write_pll_minimum_magnitude(pll->axis, min_mag);
    return true;
}

static bool write_max_offset(void *context, double *value)
{
    struct pll_context *pll = context;
    uint64_t freq = tune_to_freq(*value);
    uint32_t max_offset = (uint32_t) ((freq >> 8) & 0x7FFFFFFF);
    *value = freq_to_tune((uint64_t) max_offset << 8);
    hw_write_pll_maximum_offset(pll->axis, max_offset);
    return true;
}


static void update_target_phase(struct pll_context *pll)
{
    uint32_t phase_delta =
        (uint32_t) ((pll->phase_delay * pll->current_nco) >> 16);
    hw_write_pll_target_phase(pll->axis,
        (int32_t) (pll->target_phase + phase_delta));
}

static bool write_target_phase(void *context, double *value)
{
    struct pll_context *pll = context;
    /* First convert target phase to sensible value for readback. */
    double target_phase = fmod(*value + 180, 360) - 180;
    *value = target_phase;
    /* Convert from degrees to target phase in 2^-32 cycles. */
    pll->target_phase = (uint32_t) lround(ldexp(*value / 360, 32));
    update_target_phase(pll);
    return true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* NCO management. */

static bool write_nco_gain(void *context, unsigned int *gain)
{
    struct pll_context *pll = context;
    hw_write_pll_nco_gain(pll->axis, *gain);
    return true;
}

static bool write_nco_enable(void *context, bool *enable)
{
    struct pll_context *pll = context;
    hw_write_pll_nco_enable(pll->axis, *enable);
    return true;
}


static void read_offset_waveform(
    void *context, float offsets[], unsigned int *length)
{
    struct pll_context *pll = context;
    struct readout_fifo *fifo = pll->offset_fifo;
    const int32_t *buffer;
    *length = read_fifo_buffer(fifo, &buffer);

    /* As well as reading the waveform, update the mean_offset from the same
     * values. */
    double offset_sum = 0;
    for (unsigned int i = 0; i < *length; i ++)
    {
        offsets[i] = (float) freq_to_tune_signed(
            (uint64_t) ((int64_t) buffer[i] << 8));
        offset_sum += offsets[i];
    }
    pll->mean_offset = offset_sum / *length;
}


static bool reset_offset_fifo(void *context, bool *value)
{
    struct pll_context *pll = context;
    reset_readout_fifo(pll->offset_fifo);
    return true;
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Frequency management and readback. */

static bool write_nco_frequency(void *context, double *tune)
{
    struct pll_context *pll = context;

    pll->nco_freq_set = tune_to_freq(*tune);
    *tune = freq_to_tune(pll->nco_freq_set);
    hw_write_pll_nco_frequency(pll->axis, pll->nco_freq_set);

    trigger_record(pll->offset_pv);
    return true;
}


/* This is called during readback update while we're running and once when we
 * receive a stop event. */
static bool update_nco_frequency(void *context, double *value)
{
    struct pll_context *pll = context;

    bool running = pll->status.running;
    uint64_t offset_freq;
    if (running)
    {
        /* During a normal run just read the filtered offset and update the
         * readback frequency accordingly.
         * The frequency offset is a slice out of the middle of the computed
         * frequency, specifically bits 39:8 out of 48 bits. */
        int32_t filtered_offset = hw_read_pll_filtered_offset(pll->axis);
        offset_freq = (uint64_t) ((int64_t) filtered_offset << 8);
        pll->current_nco = pll->nco_freq_set + offset_freq;
    }
    else
    {
        /* During a stop we ignore the filtered offset, which takes a while to
         * settle, and instead compute the offset from the hardware readback
         * frequency. */
        pll->current_nco = hw_read_pll_nco_frequency(pll->axis);
        offset_freq = pll->current_nco - pll->nco_freq_set;
    }

    /* Compute the offset and base frequency readbacks. */
    *value = freq_to_tune_signed(offset_freq);
    pll->nco_freq_out = freq_to_tune(pll->current_nco);
    if (running)
        pll->nco_tune = fmod(pll->nco_freq_out, 1);
    else
        pll->nco_tune = nan("");

    /* Ensure the phase is in step with the target frequency. */
    update_target_phase(pll);

    return true;
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

static void publish_nco(struct pll_context *pll)
{
    WITH_NAME_PREFIX("NCO")
    {
        /* Setting NCO frequency and configuration. */
        PUBLISH_C_P(ao, "FREQ", write_nco_frequency, pll);
        PUBLISH_C_P(mbbo, "GAIN", write_nco_gain, pll);
        PUBLISH_C_P(bo, "ENABLE", write_nco_enable, pll);

        /* Offset readback FIFO. */
        unsigned int length = system_config.tune_pll_length;
        pll->offset_fifo =
            create_readout_fifo(pll->axis, PLL_FIFO_OFFSET, length, NULL, NULL);
        PUBLISH_WAVEFORM(float, "OFFSETWF", length,
            read_offset_waveform, .context = pll);
        PUBLISH_READ_VAR(ai, "MEAN_OFFSET", pll->mean_offset);
        PUBLISH_C(bo, "RESET_FIFO", reset_offset_fifo, pll);

        /* Frequency readback update. */
        pll->offset_pv =
            PUBLISH_C(ai, "OFFSET", update_nco_frequency, pll, .io_intr = true);
        PUBLISH_READ_VAR(ai, "FREQ", pll->nco_freq_out);
        PUBLISH_READ_VAR(ai, "TUNE", pll->nco_tune);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Detector configuration. */

static unsigned int compute_bunch_offset(enum detector_input_select select)
{
    switch (select)
    {
        case DET_SELECT_ADC:
            return hardware_delays.PLL_ADC_OFFSET;
        case DET_SELECT_FIR:
            return hardware_delays.PLL_FIR_OFFSET;
        case DET_SELECT_REJECT:
            return hardware_delays.PLL_ADC_REJECT_OFFSET;
        default:
            ASSERT_FAIL();
    }
}

static int compute_detector_delay(enum detector_input_select select)
{
    switch (select)
    {
        case DET_SELECT_ADC:
            return hardware_delays.PLL_ADC_DELAY +
                (int) hardware_config.bunches;
        case DET_SELECT_FIR:
            return hardware_delays.PLL_FIR_DELAY +
                (int) (get_fir_decimation() * hardware_config.bunches);
        case DET_SELECT_REJECT:
            return hardware_delays.PLL_ADC_REJECT_DELAY +
                (int) hardware_config.bunches;
        default:
            ASSERT_FAIL();
    }
}


static bool write_det_input_select(void *context, unsigned int *select)
{
    struct pll_context *pll = context;
    pll->input_select = *select;
    hw_write_pll_det_config(
        pll->axis, pll->input_select,
        compute_bunch_offset(pll->input_select), pll->bunch_enables);

    /* Update the detector phase delay and keep the target phase aligned. */
    pll->phase_delay = (unsigned int) compute_detector_delay(pll->input_select);
    update_target_phase(pll);
    return true;
}

static bool write_det_output_scale(void *context, unsigned int *scale)
{
    struct pll_context *pll = context;
    pll->readout_scale = *scale;
    hw_write_pll_det_scaling(pll->axis, pll->readout_scale);
    return true;
}

static bool write_det_dwell(void *context, unsigned int *dwell)
{
    struct pll_context *pll = context;
    hw_write_pll_dwell_time(pll->axis, *dwell);
    return true;
}


static void write_bunch_enables(
    void *context, char enables[], unsigned int *length)
{
    struct pll_context *pll = context;

    /* Update the bunch count and normalise each enable to 0/1. */
    unsigned int bunch_count = 0;
    FOR_BUNCHES(i)
    {
        enables[i] = (bool) enables[i];
        if (enables[i])
            bunch_count += 1;
    }
    pll->bunch_count = bunch_count;

    /* Copy the enables after normalisation. */
    memcpy(pll->bunch_enables, enables, system_config.bunches_per_turn);
    *length = system_config.bunches_per_turn;

    /* Write the bunch configuration to hardware. */
    hw_write_pll_det_config(
        pll->axis, pll->input_select,
        compute_bunch_offset(pll->input_select), pll->bunch_enables);
}


static bool enable_bunch_selection(void *context, bool *_value)
{
    struct pll_context *pll = context;
    UPDATE_RECORD_BUNCH_SET(char, pll->bunch_set, pll->enablewf, true);
    return true;
}

static bool disable_bunch_selection(void *context, bool *_value)
{
    struct pll_context *pll = context;
    UPDATE_RECORD_BUNCH_SET(char, pll->bunch_set, pll->enablewf, false);
    return true;
}


static void publish_detector(struct pll_context *pll)
{
    WITH_NAME_PREFIX("DET")
    {
        pll->bunch_enables = CALLOC(bool, system_config.bunches_per_turn);

        PUBLISH_C_P(mbbo, "SELECT", write_det_input_select, pll);
        PUBLISH_C_P(mbbo, "SCALING", write_det_output_scale, pll);
        PUBLISH_C_P(ulongout, "DWELL", write_det_dwell, pll);

        PUBLISH_READ_VAR(ulongin, "COUNT", pll->bunch_count);
        pll->enablewf = PUBLISH_WAVEFORM_C_P(
            char, "BUNCHES", system_config.bunches_per_turn,
            write_bunch_enables, pll);

        pll->bunch_set = create_bunch_set();
        PUBLISH_C(bo, "SET_SELECT", enable_bunch_selection, pll);
        PUBLISH_C(bo, "RESET_SELECT", disable_bunch_selection, pll);
    }
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Feedback event handling. */


/* At present the hardware status readback needs a helping hand to cope with an
 * edge condition... */
static void read_pll_status(int axis, struct tune_pll_status *status)
{
    hw_read_pll_status(axis, status);
    /* If all the bits in the status register are zero then we are still
     * starting (waiting for the first dwell to complete).  It is safe to treat
     * this as a running state. */
    bool stopped =
        status->stopped  ||
        status->overflow  ||
        status->too_small  ||
        status->bad_offset;
    status->running = !stopped;
}


/* This is triggered in response to a feedback status change.  The status is
 * updated. */
static bool process_status_update(void *context, bool *value)
{
    struct pll_context *pll = context;
    read_pll_status(pll->axis, &pll->status);
    return true;
}


static void handle_pll_start(struct pll_context *pll)
{
    trigger_record(pll->update_pv);     // Update reported status
    enable_readout_fifo(pll->offset_fifo, false);
}


static void handle_pll_stop(struct pll_context *pll)
{
    /* It is possible that this stop event has arrived late, in which case we
     * might end up incorrectly halting the readout FIFO.  I think it's safe
     * enough to say that if the hardware thinks we're running then leave things
     * alone; another stop event will be along when we really do stop. */
    struct tune_pll_status status;
    read_pll_status(pll->axis, &status);
    if (!status.running)
    {
        disable_readout_fifo(pll->offset_fifo);
        trigger_record(pll->update_pv);     // Update reported status
        trigger_record(pll->offset_pv);     // Final frequency and offset update
    }
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* Start/Stop command interface. */

static void start_both_axes(void)
{
    hw_write_pll_start(true, true);
    handle_pll_start(&pll_context[0]);
    if (!system_config.lmbf_mode)
        handle_pll_start(&pll_context[1]);
}


static void stop_both_axes(void)
{
    /* For this an unceremonious stop is enough. */
    hw_write_pll_stop(true, true);
}


static bool start_feedback(void *context, bool *value)
{
    struct pll_context *pll = context;
    hw_write_pll_start(pll->axis == 0, pll->axis == 1);
    handle_pll_start(pll);
    return true;
}

static bool stop_feedback(void *context, bool *value)
{
    struct pll_context *pll = context;
    hw_write_pll_stop(pll->axis == 0, pll->axis == 1);
    return true;
}


static void publish_control(struct pll_context *pll)
{
    WITH_NAME_PREFIX("CTRL")
    {
        PUBLISH_C_P(ao, "KI", write_ki, pll);
        PUBLISH_C_P(ao, "KP", write_kp, pll);
        PUBLISH_C_P(ao, "MIN_MAG", write_min_magnitude, pll);
        PUBLISH_C_P(ao, "MAX_OFFSET", write_max_offset, pll);
        PUBLISH_C_P(ao, "TARGET", write_target_phase, pll);

        PUBLISH_C(bo, "START", start_feedback, pll);
        PUBLISH_C(bo, "STOP", stop_feedback, pll);

        pll->update_pv = PUBLISH_C(bi, "UPDATE",
            process_status_update, pll, .io_intr = true);
        PUBLISH_READ_VAR(bi, "STATUS", pll->status.running);
        PUBLISH_READ_VAR(bi, "STOP:STOP", pll->status.stopped);
        PUBLISH_READ_VAR(bi, "STOP:DET_OVF", pll->status.overflow);
        PUBLISH_READ_VAR(bi, "STOP:MAG_ERROR", pll->status.too_small);
        PUBLISH_READ_VAR(bi, "STOP:OFFSET_OVF", pll->status.bad_offset);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Debug readbacks. */

static bool enable_debug_fifo(void *context, bool *value)
{
    struct pll_context *pll = context;
    if (*value)
        enable_readout_fifo(pll->debug_fifo, true);
    else
        disable_readout_fifo(pll->debug_fifo);
    return true;
}


static bool set_captured_debug(void *context, bool *value)
{
    struct pll_context *pll = context;
    pll->captured_cordic = *value;
    hw_write_pll_captured_cordic(pll->axis, *value);
    return true;
}


/* Performs conversion from 32-bit integer IQ or CORDIC readings to compensated
 * IQ and phase and magnitude values. */
static void convert_detector_values(
    struct pll_context *pll,
    bool cordic, bool compensate, unsigned int count,
    const struct detector_result inputs[],
    float wf_i[], float wf_q[], float wf_mag[], float wf_angle[])
{
    /* First compute the phase compensation factor. */
    double phase_offset =
        compensate ?
        /* If compensation enabled then compensation is basically delay to
         * compensate multiplied by the current frequency. */
        pll->phase_delay * 2 * M_PI * ldexp((double) pll->current_nco, -48) :
        /* If we're not compensating then compensating by zero will serve. */
        0.0;
    /* Compensation is by rotation against the introduced group delay. */
    double rotI = cos(phase_offset);
    double rotQ = -sin(phase_offset);

    for (unsigned int i = 0; i < count; i ++)
    {
        /* Extract and convert input values according to cordic setting. */
        double val_i, val_q, mag_out;
        if (cordic)
        {
            double phase = 2 * M_PI * ldexp(inputs[i].i, -32);
            mag_out = ldexp(inputs[i].q, -31) / CORDIC_SCALING;
            val_i = cos(phase) * mag_out;
            val_q = sin(phase) * mag_out;
        }
        else
        {
            val_i = ldexp(inputs[i].i, -31);
            val_q = ldexp(inputs[i].q, -31);
            mag_out = sqrt(SQR(val_i) + SQR(val_q));
        }

        /* Perform phase compensation by rotation. */
        double i_out = rotI * val_i - rotQ * val_q;
        double q_out = rotI * val_q + rotQ * val_i;
        double angle_out = 180 / M_PI * atan2(q_out, i_out);

        /* Here we have one final annoyance: convert results to float. */
        wf_i[i] = (float) i_out;
        wf_q[i] = (float) q_out;
        wf_mag[i] = (float) mag_out;
        wf_angle[i] = (float) angle_out;
    }
}


static void process_debug_fifo(void *context)
{
    struct pll_context *pll = context;
    struct readout_fifo *fifo = pll->debug_fifo;

    const struct detector_result *buffer;
    pll->debug_length = read_fifo_buffer(fifo, (const int32_t **) &buffer) / 2;

    convert_detector_values(
        pll, pll->captured_cordic, pll->compensate_debug, pll->debug_length,
        buffer, pll->debug_i, pll->debug_q, pll->debug_mag, pll->debug_angle);
}


static void publish_debug(struct pll_context *pll)
{
    WITH_NAME_PREFIX("DEBUG")
    {
        unsigned int length = system_config.tune_pll_length;

        pll->debug_i = CALLOC(float, length);
        pll->debug_q = CALLOC(float, length);
        pll->debug_mag = CALLOC(float, length);
        pll->debug_angle = CALLOC(float, length);

        pll->debug_fifo = create_readout_fifo(
            pll->axis, PLL_FIFO_DEBUG, 2 * length, process_debug_fifo, pll);

        PUBLISH_C(bo, "ENABLE", enable_debug_fifo, pll);
        PUBLISH_WF_READ_VAR_LEN(
            float, "WFI", length, pll->debug_length, pll->debug_i);
        PUBLISH_WF_READ_VAR_LEN(
            float, "WFQ", length, pll->debug_length, pll->debug_q);
        PUBLISH_WF_READ_VAR_LEN(
            float, "ANGLE", length, pll->debug_length, pll->debug_angle);
        PUBLISH_WF_READ_VAR_LEN(
            float, "MAG", length, pll->debug_length, pll->debug_mag);

        PUBLISH_C(bo, "SELECT", set_captured_debug, pll);
        PUBLISH_WRITE_VAR_P(bo, "COMPENSATE", pll->compensate_debug);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Miscellaneous readbacks. */

static bool read_filtered_readbacks(void *context, bool *value)
{
    struct pll_context *pll = context;

    hw_read_pll_events(pll->axis, &pll->events);

    /* So long as we're running trigger an update of the offset readback.  We'll
     * carry on compensating with the current frequency which should be close
     * enough. */
    if (pll->status.running)
        trigger_record(pll->offset_pv);

    /* Update each published value. */
    struct detector_result det = hw_read_pll_filtered_detector(pll->axis);
    float f_cos, f_sin, f_mag, f_angle;
    convert_detector_values(
        pll, pll->filtered_cordic, true, 1, &det,
        &f_cos, &f_sin, &f_mag, &f_angle);
    /* Need to convert floats to doubles for display. */
    pll->filtered_cos = f_cos;
    pll->filtered_sin = f_sin;
    pll->filtered_magnitude = f_mag;
    pll->filtered_phase = f_angle;

    return true;
}


static bool set_filtered_debug(void *context, bool *value)
{
    struct pll_context *pll = context;
    pll->filtered_cordic = *value;
    hw_write_pll_filtered_cordic(pll->axis, *value);
    return true;
}


static void publish_readbacks(struct pll_context *pll)
{
    /* Filtered data readbacks. */
    WITH_NAME_PREFIX("FILT")
    {
        PUBLISH_READ_VAR(ai, "I", pll->filtered_cos);
        PUBLISH_READ_VAR(ai, "Q", pll->filtered_sin);
        PUBLISH_READ_VAR(ai, "MAG", pll->filtered_magnitude);
        PUBLISH_READ_VAR(ai, "PHASE", pll->filtered_phase);
        PUBLISH_C(bo, "SELECT", set_filtered_debug, pll);
    }

    /* Live status. */
    WITH_NAME_PREFIX("STA")
    {
        PUBLISH_READ_VAR(bi, "DET_OVF", pll->events.det_overflow);
        PUBLISH_READ_VAR(bi, "MAG_ERROR", pll->events.magnitude_error);
        PUBLISH_READ_VAR(bi, "OFFSET_OVF", pll->events.offset_error);
    }

    PUBLISH_C(bo, "POLL", read_filtered_readbacks, pll);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation and event handling. */


static void handle_fifo_event(struct pll_context *pll, unsigned int event_mask)
{
    if (event_mask & 0x1)
        handle_fifo_ready(pll->offset_fifo);
    if (event_mask & 0x2)
        handle_fifo_ready(pll->debug_fifo);
    if (event_mask & 0x4)
        handle_pll_stop(pll);
}

static void dispatch_tune_pll_event(void *context, struct interrupts interrupts)
{
    handle_fifo_event(&pll_context[0], interrupts.tune_pll0_ready);
    handle_fifo_event(&pll_context[1], interrupts.tune_pll1_ready);
}


error__t initialise_tune_pll(void)
{
    /* Ensure nothing is actually running! */
    stop_both_axes();

    if (!system_config.lmbf_mode)
        WITH_NAME_PREFIX("PLL:CTRL")
        {
            PUBLISH_ACTION("START", start_both_axes);
            PUBLISH_ACTION("STOP", stop_both_axes);
        }

    FOR_AXIS_NAMES(axis, "PLL", system_config.lmbf_mode)
    {
        struct pll_context *pll = &pll_context[axis];
        pll->axis = axis;

        /* NCO management and readback. */
        publish_nco(pll);
        /* Detector configuration. */
        publish_detector(pll);
        /* Feedback configuration and control. */
        publish_control(pll);
        /* Debug readbacks. */
        publish_debug(pll);
        /* Miscellaneous readbacks. */
        publish_readbacks(pll);
    }

    struct interrupts ready_interrupts =
        system_config.lmbf_mode ?
            INTERRUPTS(.tune_pll0_ready = 7) :
            INTERRUPTS(.tune_pll0_ready = 7, .tune_pll1_ready = 7);
    register_event_handler(
        INTERRUPT_HANDLER_TUNE_PLL, ready_interrupts,
        NULL, dispatch_tune_pll_event);

    return TEST_OK_(system_config.tune_pll_length > PLL_FIFO_SIZE,
        "tune_pll_length too small");
}
