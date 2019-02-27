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

#include "common.h"
#include "configs.h"
#include "hardware.h"
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
            PUBLISH_READ_VAR(ulongin, "COUNT", pll->bunch_count);
            pll->enablewf = PUBLISH_WAVEFORM_C_P(
                char, "BUNCHES", system_config.bunches_per_turn,
                write_bunch_enables, pll);

            pll->bunch_set = create_bunch_set();
            PUBLISH_C(bo, "SET_SELECT", enable_selection, pll);
            PUBLISH_C(bo, "RESET_SELECT", disable_selection, pll);

//             PUBLISH_READ_VAR(bi, "OUT_OVF", pll->det_ovf);
        }

        /* Filtered data readbacks. */
        PUBLISH_C(bo, "POLL", read_filtered_readbacks, pll);
        PUBLISH_READ_VAR(ai, "DET:I", pll->filtered_cos);
        PUBLISH_READ_VAR(ai, "DET:Q", pll->filtered_sin);
        PUBLISH_READ_VAR(ai, "DET:MAG", pll->filtered_magnitude);
        PUBLISH_READ_VAR(ai, "PHASE", pll->filtered_phase);
        PUBLISH_READ_VAR(ai, "OFFSET", pll->filtered_freq_offset);
    }
    return ERROR_OK;
}
