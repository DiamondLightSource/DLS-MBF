/* Control of FIR. */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "bunch_fir.h"


#define MAX_FIR_GAIN     15

/* Represents the internal state of a single FIR bank. */
struct fir_bank {
    int axis;
    unsigned int index;
    unsigned int cycles;
    unsigned int length;
    double phase;
    int *current_taps;
    int *set_taps;
    struct epics_record *taps_waveform;
    bool use_waveform;
    bool waveform_set;
};

static struct fir_context {
    int axis;
    bool overflow;
    struct epics_record *fir_gain;
    struct fir_bank banks[FIR_BANKS];
} fir_context[AXIS_COUNT];


static unsigned int fir_decimation = 1;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Tap computation and update. */


/* Given a ratio cycles:length and a phase compute the appropriate filter. */
static void compute_fir_taps(struct fir_bank *bank)
{
    double tune = (double) bank->cycles / bank->length;

    /* Calculate FIR coeffs and the mean value. */
    int *taps = bank->current_taps;
    for (unsigned int i = 0; i < bank->length; i++)
    {
        double tap = sin(2*M_PI * (tune * (i+0.5) + bank->phase / 360.0));
        taps[i] = (int) lround(INT32_MAX * tap);
    }
    /* Pad end of filter with zeros. */
    for (size_t i = bank->length; i < hardware_config.bunch_taps; i++)
        taps[i] = 0;
}


/* After any update to current_taps ensures that the hardware and readback
 * record are in step. */
static void update_taps(struct fir_bank *bank)
{
    hw_write_bunch_fir_taps(bank->axis, bank->index, bank->current_taps);
    trigger_record(bank->taps_waveform);
}


static void update_bank_taps(struct fir_bank *bank)
{
    if (bank->use_waveform)
        memcpy(bank->current_taps, bank->set_taps,
            hardware_config.bunch_taps * sizeof(int));
    else
        compute_fir_taps(bank);
    update_taps(bank);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/* This is called any time any of the FIR control parameters have changed.
 * Recompute and reload the FIR taps as appropriate.  No effect if not in
 * use_waveform mode. */
static bool reload_fir(void *context, bool *value)
{
    struct fir_bank *bank = context;
    struct fir_bank *other_bank =
        system_config.lmbf_mode ? &fir_context[1].banks[bank->index] : NULL;

    /* In LMBF mode copy all relevant bank settings to the other axis. */
    if (other_bank)
    {
        other_bank->length = bank->length;
        other_bank->cycles = bank->cycles;

        other_bank->phase = bank->phase + system_config.lmbf_fir_offset;
    }

    if (!bank->use_waveform)
    {
        update_bank_taps(bank);

        if (other_bank)
            update_bank_taps(other_bank);
    }
    return true;
}


/* Called to switch between waveform and settings mode. */
static bool set_use_waveform(void *context, bool *use_waveform)
{
    struct fir_bank *bank = context;
    struct fir_bank *other_bank =
        system_config.lmbf_mode ? &fir_context[1].banks[bank->index] : NULL;

    if (*use_waveform != bank->use_waveform)
    {
        bank->use_waveform = *use_waveform;
        update_bank_taps(bank);
        if (other_bank)
        {
            other_bank->use_waveform = *use_waveform;
            update_bank_taps(other_bank);
        }
    }
    return true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/* This is called when the waveform TAPS_S is updated.  If we're using the
 * waveform settings then the given waveform is written to hardware, otherwise
 * we just hang onto it. */
static void set_fir_taps(void *context, float *taps, unsigned int *length)
{
    struct fir_bank *bank = context;
    *length = hardware_config.bunch_taps;

    float_array_to_int(*length, taps, bank->set_taps, 32, 0);
    if (bank->use_waveform)
        update_bank_taps(bank);
}


static void get_fir_taps(void *context, float *taps, unsigned int *length)
{
    struct fir_bank *bank = context;
    *length = hardware_config.bunch_taps;

    for (unsigned int i = 0; i < *length; i ++)
        taps[i] = (float) ldexp(bank->current_taps[i], -31);
}


static void publish_bank_waveforms(
    int axis, unsigned int ix, struct fir_bank *bank)
{
    bank->axis = axis;
    bank->index = ix;
    bank->current_taps = CALLOC(int, hardware_config.bunch_taps);
    bank->set_taps     = CALLOC(int, hardware_config.bunch_taps);

    char prefix[4];
    sprintf(prefix, "%d", ix);
    WITH_NAME_PREFIX(prefix)
    {
        PUBLISH_WAVEFORM_C_P(
            float, "TAPS_S", hardware_config.bunch_taps, set_fir_taps, bank);
        bank->taps_waveform = PUBLISH_WAVEFORM_C(
            float, "TAPS", hardware_config.bunch_taps, get_fir_taps, bank,
            .io_intr = true);
    }
}


static void publish_bank(unsigned int ix, struct fir_bank *bank)
{
    char prefix[4];
    sprintf(prefix, "%d", ix);
    WITH_NAME_PREFIX(prefix)
    {
        /* This is triggered when any coefficient is changed. */
        PUBLISH_C(bo, "RELOAD", reload_fir, bank);

        /* Selects whether to use waveform or parameters for FIR taps. */
        PUBLISH_C_P(bo, "USEWF", set_use_waveform, bank);

        /* These writes all forward link to reload_fir above. */
        PUBLISH_WRITE_VAR_P(ulongout, "LENGTH", bank->length);
        PUBLISH_WRITE_VAR_P(ulongout, "CYCLES", bank->cycles);
        PUBLISH_WRITE_VAR_P(ao, "PHASE", bank->phase);
    }
}


static void publish_banks(struct fir_context *fir)
{
    for (unsigned int i = 0; i < FIR_BANKS; i ++)
        publish_bank(i, &fir->banks[i]);
}


static bool write_fir_gain(void *context, unsigned int *value)
{
    struct fir_context *fir = context;
    hw_write_dac_fir_gain(fir->axis, *value);
    if (system_config.lmbf_mode)
        hw_write_dac_fir_gain(1, *value);
    return true;
}


static bool increment_fir_gain(void *context, bool *value)
{
    struct fir_context *fir = context;
    unsigned int new_gain = READ_RECORD_VALUE(mbbo, fir->fir_gain) - 1;
    if (new_gain <= MAX_FIR_GAIN)
        WRITE_OUT_RECORD(mbbo, fir->fir_gain, new_gain, true);
    return true;
}


static bool decrement_fir_gain(void *context, bool *value)
{
    struct fir_context *fir = context;
    unsigned int new_gain = READ_RECORD_VALUE(mbbo, fir->fir_gain) + 1;
    if (new_gain <= MAX_FIR_GAIN)
        WRITE_OUT_RECORD(mbbo, fir->fir_gain, new_gain, true);
    return true;
}


static void write_fir_decimation(unsigned int value)
{
    fir_decimation = value;
    for (int i = 0; i < AXIS_COUNT; i ++)
        hw_write_bunch_decimation(i, fir_decimation);
}


unsigned int get_fir_decimation(void)
{
    return fir_decimation;
}


static void scan_events(void)
{
    for (int i = 0; i < AXIS_COUNT; i ++)
    {
        struct fir_context *fir = &fir_context[i];
        fir->overflow = hw_read_bunch_overflow(i);
    }
}


error__t initialise_bunch_fir(void)
{
    /* Initialise the common functionality: both axes publish individual
     * banks for the waveform PVs. */
    FOR_AXIS_NAMES(axis, "FIR")
    {
        struct fir_context *fir = &fir_context[axis];
        fir->axis = axis;

        for (unsigned int i = 0; i < FIR_BANKS; i ++)
            publish_bank_waveforms(axis, i, &fir->banks[i]);

        PUBLISH_READ_VAR(bi, "OVF", fir->overflow);
    }

    /* In TMBF mode the two axes operate independently, in LMBF mode most of
     * our PVs act on both axes together. */
    FOR_AXIS_NAMES(axis, "FIR", system_config.lmbf_mode)
    {
        struct fir_context *fir = &fir_context[axis];
        publish_banks(fir);
        fir->fir_gain = PUBLISH_C_P(mbbo, "GAIN", write_fir_gain, fir);
        PUBLISH_C(bo, "GAIN:UP", increment_fir_gain, fir);
        PUBLISH_C(bo, "GAIN:DN", decrement_fir_gain, fir);

        if (system_config.lmbf_mode)
            PUBLISH_WRITER_P(ulongout, "DECIMATION", write_fir_decimation);
    }

    PUBLISH_ACTION("FIR:EVENTS", scan_events);

    if (!system_config.lmbf_mode)
        /* Disable decimation in TMBF mode. */
        write_fir_decimation(1);

    return ERROR_OK;
}
