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

#include "tune_pll.h"


static struct pll_context {
    int axis;
    struct epics_record *nco_pv;

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
    double filtered_magnitude;
    double filtered_phase;
    double filtered_freq_offset;

    /* Debug readback. */
    struct readout_fifo *debug_fifo;
} pll_context[AXIS_COUNT] = { };


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

static bool read_nco_frequency(void *context, double *tune)
{
    struct pll_context *pll = context;
    uint64_t frequency = hw_read_pll_nco_frequency(pll->axis);
    *tune = freq_to_tune(frequency);
    return true;
}


static bool read_filtered_readbacks(void *context, bool *value)
{
    struct pll_context *pll = context;
    struct detector_result det;
    int32_t offset;
    hw_read_pll_filtered_readbacks(pll->axis, &det, &offset);

    /* Update each published value. */
    pll->filtered_cos = ldexp(det.i, -31);
    pll->filtered_sin = ldexp(det.q, -31);
    pll->filtered_phase = 180 / M_PI * atan2(det.q, det.i);
    pll->filtered_magnitude =
        sqrt(SQR(pll->filtered_cos) + SQR(pll->filtered_sin));
    /* The frequency offset is a slice out of the middle of the computed
     * frequency, specifically bits 39:8 out of 48 bits.  So we can use
     * freq_to_tune() once we've adjusted the offset. */
    pll->filtered_freq_offset =
        freq_to_tune_signed((uint64_t) ((int64_t) offset << 8));

    return true;
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


static bool enable_selection(void *context, bool *_value)
{
    struct pll_context *pll = context;
    UPDATE_RECORD_BUNCH_SET(char, pll->bunch_set, pll->enablewf, true);
    return true;
}


static bool disable_selection(void *context, bool *_value)
{
    struct pll_context *pll = context;
    UPDATE_RECORD_BUNCH_SET(char, pll->bunch_set, pll->enablewf, false);
    return true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* FIFO readout. */

struct readout_fifo {
    /* Hardware FIFO identification. */
    int axis;                           // Selects which axis
    enum pll_readout_fifo fifo;         // Selects which hardware FIFO to read
    /* EPICS processing handshake. */
    struct epics_interlock *interlock;  // Signal for EPICS processing
    bool epics_busy;                    // Set if EPICS processing is active
    /* Buffer of full FIFO capture ready for EPICS processing. */
    int32_t *buffer;                    // Data captured ready for EPICS output
    unsigned int buffer_size;           // Buffer capacity
    unsigned int buffer_count;          // Current number of samples in buffer
    /* FIFO processing state. */
    bool enabled;
    bool overflow;                      // Hardware FIFO overrun detected
    pthread_mutex_t mutex;              // Needed for managed access
    /* Read buffer for initial data capture. */
    unsigned int read_buffer_count;     // Number of hold-over samples
    int32_t read_buffer[PLL_FIFO_SIZE]; // Buffer of hold-over samples
};


static struct readout_fifo *create_readout_fifo(
    int axis, enum pll_readout_fifo which_fifo, unsigned int buffer_size)
{
    struct readout_fifo *fifo = malloc(sizeof(struct readout_fifo));
    *fifo = (struct readout_fifo) {
        .axis = axis,
        .fifo = which_fifo,
        .interlock = create_interlock("READ", false),
        .buffer_size = buffer_size,
        .buffer = CALLOC(int32_t, buffer_size),
        .mutex = PTHREAD_MUTEX_INITIALIZER,
    };

    PUBLISH_READ_VAR(bi, "FIFO_OVF", fifo->overflow);
    return fifo;
}


/* Performs FIFO data processing, triggered either by data ready interrupt or on
 * disable event (and possibly on timer?).  MUST be called with mutex held.
 *
 * This is called when the FIFO is ready to read.  We read what data is
 * available, update our waveforms and notify EPICS as appropriate, and reenable
 * interrupts for our next call. */
static void process_fifo_content(struct readout_fifo *fifo, bool last_read)
{
    /* Ensure that any EPICS processing has completed. */
    if (fifo->epics_busy)
    {
        interlock_wait(fifo->interlock);
        fifo->epics_busy = false;

        /* Copy any residue from our buffer into the read buffer. */
        memcpy(fifo->buffer, fifo->read_buffer,
            fifo->read_buffer_count * sizeof(int32_t));
        fifo->buffer_count = fifo->read_buffer_count;
        /* Resetting read_buffer_count is optional as we only observe it when
         * epics_busy is set! */
    }

    /* Read what there is to read. */
    unsigned int samples = hw_read_pll_readout_fifo(
        fifo->axis, fifo->fifo, !last_read, &fifo->overflow, fifo->read_buffer);

    /* Update the buffer. */
    unsigned int to_copy =
        MIN(samples, fifo->buffer_size - fifo->buffer_count);
    memcpy(&fifo->buffer[fifo->buffer_count], fifo->read_buffer,
        to_copy * sizeof(int32_t));
    fifo->buffer_count += to_copy;

    /* Emit the buffer if appropriate. */
    if (fifo->buffer_count == fifo->buffer_size  ||
        fifo->overflow  ||  last_read)
    {
        interlock_signal(fifo->interlock, NULL);
        fifo->epics_busy = true;

        /* Hang onto anything we didn't copy. */
        fifo->read_buffer_count = samples - to_copy;
        memmove(fifo->read_buffer, &fifo->read_buffer[to_copy],
            fifo->read_buffer_count * sizeof(int32_t));
    }
}


/* Start the FIFO readout process by clearing and resetting the FIFO and
 * enabling interrupts.  Must be called with mutex held. */
static void start_readout_fifo(struct readout_fifo *fifo)
{
    /* Read and discard FIFO content, resetting if necessary. */
    bool overflow;
    hw_read_pll_readout_fifo(
        fifo->axis, fifo->fifo, true, &overflow, fifo->read_buffer);

    /* First ensure EPICS is not active. */
    if (fifo->epics_busy)
    {
        interlock_wait(fifo->interlock);
        fifo->epics_busy = false;
    }
    /* Reset the FIFO state. */
    fifo->buffer_count = 0;
    fifo->overflow = false;

    fifo->enabled = true;
}


/* Disable the FIFO readout.  Must be called with mutex held. */
static void stop_readout_fifo(struct readout_fifo *fifo)
{
    process_fifo_content(fifo, true);

    fifo->enabled = false;
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* The following are the interface methods to the FIFO above. */


static void enable_readout_fifo(struct readout_fifo *fifo, bool enable)
{
    WITH_MUTEX(fifo->mutex)
    {
        if (enable  &&  !fifo->enabled)
            start_readout_fifo(fifo);
        else if (!enable  &&  fifo->enabled)
            stop_readout_fifo(fifo);
    }
}


static void handle_fifo_ready_event(struct readout_fifo *fifo)
{
    WITH_MUTEX(fifo->mutex)
    {
        if (fifo->enabled)
            process_fifo_content(fifo, false);
    }
}


static bool enable_debug_fifo(void *context, bool *value)
{
    struct pll_context *pll = context;
    enable_readout_fifo(pll->debug_fifo, *value);
    return true;
}


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
/* Implementations specific to each FIFO. */


static void read_debug_wfi(void *context, int *wfi, unsigned int *length)
{
    struct pll_context *pll = context;
    struct readout_fifo *fifo = pll->debug_fifo;
    *length = fifo->buffer_count / 2;
    for (unsigned int i = 0; i < *length; i ++)
        wfi[i] = fifo->buffer[2 * i];
}

static void read_debug_wfq(void *context, int *wfq, unsigned int *length)
{
    struct pll_context *pll = context;
    struct readout_fifo *fifo = pll->debug_fifo;
    *length = fifo->buffer_count / 2;
    for (unsigned int i = 0; i < *length; i ++)
        wfq[i] = fifo->buffer[2 * i + 1];
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Event handling. */


static void handle_fifo_event(struct pll_context *pll, unsigned int event_mask)
{
//     if (event_mask & 0x1)
//         handle_fifo_ready_event(pll->readout_fifo);
    if (event_mask & 0x2)
        handle_fifo_ready_event(pll->debug_fifo);
}


static void dispatch_tune_pll_event(void *context, struct interrupts interrupts)
{
    struct interrupts pll0_ready = INTERRUPTS(.tune_pll0_ready = 3);
    struct interrupts pll1_ready = INTERRUPTS(.tune_pll1_ready = 3);
    if (test_intersect(interrupts, pll0_ready))
        handle_fifo_event(&pll_context[0], interrupts.tune_pll0_ready);
    if (test_intersect(interrupts, pll1_ready))
        handle_fifo_event(&pll_context[1], interrupts.tune_pll1_ready);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation. */

error__t initialise_tune_pll(void)
{
    FOR_AXIS_NAMES(axis, "PLL", system_config.lmbf_mode)
    {
        struct pll_context *pll = &pll_context[axis];
        pll->axis = axis;

        WITH_NAME_PREFIX("NCO")
        {
            PUBLISH_C_P(ao, "FREQ", write_nco_frequency, pll);
            pll->nco_pv = PUBLISH_C(ai, "FREQ",
                read_nco_frequency, pll, .io_intr = true);
            PUBLISH_C_P(mbbo, "GAIN", write_nco_gain, pll);
            PUBLISH_C_P(bo, "ENABLE", write_nco_enable, pll);
        }

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
            PUBLISH_C(bo, "SET_SELECT", enable_selection, pll);
            PUBLISH_C(bo, "RESET_SELECT", disable_selection, pll);

//             PUBLISH_READ_VAR(bi, "OUT_OVF", pll->det_ovf);
        }

        WITH_NAME_PREFIX("DEBUG")
        {
            unsigned int length = system_config.tune_pll_length;
            pll->debug_fifo = create_readout_fifo(
                pll->axis, PLL_FIFO_DEBUG, 2 * length);
            PUBLISH_C(bo, "ENABLE", enable_debug_fifo, pll);
            PUBLISH_WAVEFORM(int, "WFI", length,
                read_debug_wfi, .context = pll);
            PUBLISH_WAVEFORM(int, "WFQ", length,
                read_debug_wfq, .context = pll);
        }

        /* Filtered data readbacks. */
        PUBLISH_C(bo, "POLL", read_filtered_readbacks, pll);
        PUBLISH_READ_VAR(ai, "DET:I", pll->filtered_cos);
        PUBLISH_READ_VAR(ai, "DET:Q", pll->filtered_sin);
        PUBLISH_READ_VAR(ai, "DET:MAG", pll->filtered_magnitude);
        PUBLISH_READ_VAR(ai, "PHASE", pll->filtered_phase);
        PUBLISH_READ_VAR(ai, "OFFSET", pll->filtered_freq_offset);
    }

    struct interrupts ready_interrupts =
        system_config.lmbf_mode ?
            INTERRUPTS(.tune_pll0_ready = 3) :
            INTERRUPTS(.tune_pll0_ready = 3, .tune_pll1_ready = 3);
    register_event_handler(
        INTERRUPT_HANDLER_TUNE_PLL, ready_interrupts,
        NULL, dispatch_tune_pll_event);

    return TEST_OK_(system_config.tune_pll_length > PLL_FIFO_SIZE,
        "tune_pll_length too small");
}
