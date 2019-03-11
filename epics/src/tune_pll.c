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
#include "bunch_set.h"
#include "tune_pll_fifo.h"

#include "tune_pll.h"


/* CORDIC magnitude correction.  The CORDIC readback is scaled by this value. */
#define CORDIC_SCALING      (1.6467602581210654 / 2)


static struct pll_context {
    int axis;

    /* Frequency management. */
    struct readout_fifo *offset_fifo;
    double mean_offset;                 // Updated when reading waveform
    struct epics_record *offset_pv;
    int32_t filtered_offset;

    /* Live events. */
    struct tune_pll_events events;
    struct tune_pll_status status;
    struct epics_record *update_pv;

    /* Feedback control. */

    /* Detector configuration. */
    unsigned int input_select;
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
    double filtered_freq_offset;

    /* Debug readback. */
    struct readout_fifo *debug_fifo;
    bool captured_cordic;
} pll_context[AXIS_COUNT] = { };


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* NCO management. */

static bool write_nco_frequency(void *context, double *tune)
{
    struct pll_context *pll = context;
    uint64_t frequency = tune_to_freq(*tune);
    *tune = freq_to_tune(frequency);
    hw_write_pll_nco_frequency(pll->axis, frequency);
    return true;
}

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


static bool read_nco_frequency(void *context, double *value)
{
    struct pll_context *pll = context;
    uint64_t nco_freq = hw_read_pll_nco_frequency(pll->axis);
    *value = freq_to_tune(nco_freq);
    return true;
}


/* This is called periodically.  Trigger an update of our offset_pv if we are
 * running, otherwise do nothing. */
static void freq_offset_updated(struct pll_context *pll)
{
    if (pll->status.running)
        trigger_record(pll->offset_pv);
}


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
            create_readout_fifo(pll->axis, PLL_FIFO_OFFSET, length);
        PUBLISH_WAVEFORM(float, "OFFSETWF", length,
            read_offset_waveform, .context = pll);
        PUBLISH_READ_VAR(ai, "MEAN_OFFSET", pll->mean_offset);
        PUBLISH_C(bo, "RESET_FIFO", reset_offset_fifo, pll);

        /* Frequency readback update. */
        pll->offset_pv =
            PUBLISH_READ_VAR_I(ai, "OFFSET", pll->filtered_freq_offset);
        PUBLISH_C(ai, "FREQ", read_nco_frequency, pll);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Detector configuration. */

/* This is a copy of the corresponding options in detector.c. */
enum detector_input_select {
    DET_SELECT_ADC = 0,     // Standard compensated ADC data
    DET_SELECT_FIR = 1,     // Data after bunch by bunch feedback filter
    DET_SELECT_REJECT = 2,  // ADC data after filter and fill pattern rejection
};


static unsigned int compute_bunch_offset(unsigned int select)
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


static bool write_det_input_select(void *context, unsigned int *select)
{
    struct pll_context *pll = context;
    pll->input_select = *select;
    hw_write_pll_det_config(
        pll->axis, pll->input_select,
        compute_bunch_offset(pll->input_select), pll->bunch_enables);
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

static bool write_target_phase(void *context, double *value)
{
    struct pll_context *pll = context;
    int32_t phase = (int32_t) (lround(ldexp(*value / 360, 32)) & 0xFFFFC000);
    *value = 360 * ldexp(phase, -32);
    hw_write_pll_target_phase(pll->axis, phase);
    return true;
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


static void read_debug_wfi(void *context, float *wfi, unsigned int *length)
{
    struct pll_context *pll = context;
    if (pll->captured_cordic)
        *length = 0;
    else
    {
        struct readout_fifo *fifo = pll->debug_fifo;
        const int32_t *buffer;
        *length = read_fifo_buffer(fifo, &buffer) / 2;
        for (unsigned int i = 0; i < *length; i ++)
            wfi[i] = ldexpf((float) buffer[2 * i], -31);
    }
}

static void read_debug_wfq(void *context, float *wfq, unsigned int *length)
{
    struct pll_context *pll = context;
    if (pll->captured_cordic)
        *length = 0;
    else
    {
        struct readout_fifo *fifo = pll->debug_fifo;
        const int32_t *buffer;
        *length = read_fifo_buffer(fifo, &buffer) / 2;
        for (unsigned int i = 0; i < *length; i ++)
            wfq[i] = ldexpf((float) buffer[2 * i + 1], -31);
    }
}

static void read_debug_angle(void *context, float *angle, unsigned int *length)
{
    struct pll_context *pll = context;
    struct readout_fifo *fifo = pll->debug_fifo;
    const int32_t *buffer;
    *length = read_fifo_buffer(fifo, &buffer) / 2;
    if (pll->captured_cordic)
        /* In this case the captured waveform is the angle readback. */
        for (unsigned int i = 0; i < *length; i ++)
            angle[i] = 360 * ldexpf((float) buffer[2 * i], -32);
    else
        /* Otherwise compute the angle from IQ. */
        for (unsigned int i = 0; i < *length; i ++)
        {
            float det_i = (float) buffer[2 * i];
            float det_q = (float) buffer[2 * i + 1];
            angle[i] = 180 / (float) M_PI * atan2f(det_q, det_i);
        }
}

static void read_debug_magnitude(
    void *context, float *magnitude, unsigned int *length)
{
    struct pll_context *pll = context;
    struct readout_fifo *fifo = pll->debug_fifo;
    const int32_t *buffer;
    *length = read_fifo_buffer(fifo, &buffer) / 2;
    if (pll->captured_cordic)
        /* In this case the captured waveform is the magnitude readback. */
        for (unsigned int i = 0; i < *length; i ++)
            magnitude[i] =
                ldexpf((float) (uint32_t) buffer[2 * i + 1], -31) /
                (float) CORDIC_SCALING;
    else
        /* Otherwise compute the magnitude from IQ. */
        for (unsigned int i = 0; i < *length; i ++)
        {
            float det_i = ldexpf((float) buffer[2 * i], -31);
            float det_q = ldexpf((float) buffer[2 * i + 1], -31);
            magnitude[i] = sqrtf(SQR(det_i) + SQR(det_q));
        }
}


static bool set_captured_debug(void *context, bool *value)
{
    struct pll_context *pll = context;
    pll->captured_cordic = *value;
    hw_write_pll_captured_cordic(pll->axis, *value);
    return true;
}


static void publish_debug(struct pll_context *pll)
{
    WITH_NAME_PREFIX("DEBUG")
    {
        unsigned int length = system_config.tune_pll_length;
        pll->debug_fifo = create_readout_fifo(
            pll->axis, PLL_FIFO_DEBUG, 2 * length);
        PUBLISH_C(bo, "ENABLE", enable_debug_fifo, pll);
        PUBLISH_WAVEFORM(float, "WFI", length,
            read_debug_wfi, .context = pll);
        PUBLISH_WAVEFORM(float, "WFQ", length,
            read_debug_wfq, .context = pll);
        PUBLISH_WAVEFORM(float, "ANGLE", length,
            read_debug_angle, .context = pll);
        PUBLISH_WAVEFORM(float, "MAG", length,
            read_debug_magnitude, .context = pll);

        PUBLISH_C(bo, "SELECT", set_captured_debug, pll);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Miscellaneous readbacks. */

static bool read_filtered_readbacks(void *context, bool *value)
{
    struct pll_context *pll = context;

    hw_read_pll_events(pll->axis, &pll->events);

    struct detector_result det;
    hw_read_pll_filtered_readbacks(pll->axis, &det, &pll->filtered_offset);

    /* Update each published value. */
    if (pll->filtered_cordic)
    {
        /* Special debug mode, the filtered values are from CORDIC. */
        pll->filtered_cos = nan("");
        pll->filtered_sin = nan("");
        pll->filtered_phase = 360 * ldexp(det.i, -32);
        pll->filtered_magnitude = ldexp(det.q, -31) / CORDIC_SCALING;
    }
    else
    {
        /* Normal readbacks, compute phase and magnitude from IQ. */
        pll->filtered_cos = ldexp(det.i, -31);
        pll->filtered_sin = ldexp(det.q, -31);
        pll->filtered_phase = 180 / M_PI * atan2(det.q, det.i);
        pll->filtered_magnitude =
            sqrt(SQR(pll->filtered_cos) + SQR(pll->filtered_sin));
    }

    /* The frequency offset is a slice out of the middle of the computed
     * frequency, specifically bits 39:8 out of 48 bits.  So we can use
     * freq_to_tune() once we've adjusted the offset. */
    pll->filtered_freq_offset =
        freq_to_tune_signed((uint64_t) ((int64_t) pll->filtered_offset << 8));
    freq_offset_updated(pll);

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
