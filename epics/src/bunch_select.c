/* Bunch selection control. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "bunch_select.h"


struct bunch_bank {
    int channel;
    unsigned int bank;

    struct bunch_config config;

    EPICS_STRING fir_status;
    EPICS_STRING out_status;
    EPICS_STRING gain_status;
};

static struct bunch_context {
    int channel;
    struct bunch_bank banks[BUNCH_BANKS];
} bunch_context[CHANNEL_COUNT];



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Status string computation. */

/* Helper routine: counts number of instances of given value, not all set,
 * returns index of last non-equal value. */
static int count_value(const int wf[], int value, unsigned int *diff_ix)
{
    int count = 0;
    for (unsigned int i = 0; i < BUNCHES_PER_TURN; i ++)
        if (wf[i] == value)
            count += 1;
        else
            *diff_ix = i;
    return count;
}


/* Status computation.  We support three possibilities:
 *  1.  All one value
 *  2.  All one value except for one different value
 *  3.  Something else: "It's complicated" */
enum complexity { ALL_SAME, ALL_BUT_ONE, COMPLICATED };
static enum complexity assess_complexity(
    const int wf[], int *value, int *other, unsigned int *other_ix)
{
    *value = wf[0];
    *other_ix = 0;
    *other = 0;
    switch (count_value(wf, *value, other_ix))
    {
        case BUNCHES_PER_TURN:
            return ALL_SAME;
        case 1:
            /* Need to check whether all rest are the same. */
            *value = wf[1];
            *other = wf[0];
            if (count_value(wf, *value, other_ix) == BUNCHES_PER_TURN-1)
                return ALL_BUT_ONE;
            else
                return COMPLICATED;
        case BUNCHES_PER_TURN-1:
            *other = wf[*other_ix];
            return ALL_BUT_ONE;
        default:
            return COMPLICATED;
    }
}


static void update_status_core(
    const char *name, const int wf[], EPICS_STRING *status,
    void (*render)(int, char[]))
{
    int value, other;
    unsigned int other_ix;
    enum complexity complexity =
        assess_complexity(wf, &value, &other, &other_ix);
    char value_name[20], other_name[20];
    render(value, value_name);
    render(other, other_name);

    switch (complexity)
    {
        case ALL_SAME:
            snprintf(status->s, 40, "%s", value_name);
            break;
        case ALL_BUT_ONE:
            snprintf(status->s, 40, "%s (%s @%u)",
                value_name, other_name, other_ix);
            break;
        case COMPLICATED:
            snprintf(status->s, 40, "Mixed %s", name);
            break;
    }
}


/* Name rendering methods for calls to update_status_core above.  These three
 * functions are invoked in the macro DEFINE_WRITE_WF below. */

static void fir_name(int fir, char result[])
{
    sprintf(result, "#%d", fir);
}

static void out_name(int out, char result[])
{
    const char *out_names[] = {
        "Off",      "FIR",      "NCO",      "NCO+FIR",
        "Sweep",    "Sw+FIR",   "Sw+NCO",   "Sw+N+F" };
    ASSERT_OK(0 <= out  &&  out < (int) ARRAY_SIZE(out_names));
    sprintf(result, "%s", out_names[out]);
}

static void gain_name(int gain, char result[])
{
    sprintf(result, "%.3g", ldexp(gain, -31));
}


/* Quick and dirty helper to convert array of char to array of int. */
#define CHAR_TO_INT(array_out, array_in) \
    int array_out[hardware_config.bunches]; \
    FOR_BUNCHES(i) \
        array_out[i] = array_in[i]

static void update_fir_status(struct bunch_bank *bank, const char fir_select[])
{
    CHAR_TO_INT(fir_wf, fir_select);
    update_status_core("FIR", fir_wf, &bank->fir_status, fir_name);
}

static void update_out_status(struct bunch_bank *bank, const char out_enable[])
{
    CHAR_TO_INT(out_wf, out_enable);
    update_status_core("outputs", out_wf, &bank->out_status, out_name);
}

static void update_gain_status(struct bunch_bank *bank, const int gain[])
{
    update_status_core("gains", gain, &bank->gain_status, gain_name);
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Bunch publish and control. */


static void write_fir_wf(void *context, char fir_select[], size_t *length)
{
    struct bunch_bank *bank = context;
    *length = hardware_config.bunches;

    update_fir_status(bank, fir_select);

    FOR_BUNCHES_OFFSET(i, j, hardware_delays.bunch_fir_offset)
        bank->config.fir_select[i] = fir_select[j];

    hw_write_bunch_config(bank->channel, bank->bank, &bank->config);
}


static void write_out_wf(void *context, char out_enable[], size_t *length)
{
    struct bunch_bank *bank = context;
    *length = hardware_config.bunches;

    update_out_status(bank, out_enable);

    FOR_BUNCHES_OFFSET(i, j, hardware_delays.bunch_out_offset)
    {
        bank->config.fir_enable[i] = out_enable[j] & 1;
        bank->config.nco0_enable[i] = (out_enable[j] >> 1) & 1;
        bank->config.nco1_enable[i] = (out_enable[j] >> 2) & 1;
    }
    hw_write_bunch_config(bank->channel, bank->bank, &bank->config);
}


static void write_gain_wf(void *context, float gain[], size_t *length)
{
    struct bunch_bank *bank = context;
    *length = hardware_config.bunches;

    int scaled_gain[hardware_config.bunches];
    float_array_to_int(
        hardware_config.bunches, gain, scaled_gain, 32, 0);
    update_gain_status(bank, scaled_gain);

    FOR_BUNCHES_OFFSET(i, j, hardware_delays.bunch_gain_offset)
        bank->config.gain[i] = scaled_gain[j];

    hw_write_bunch_config(bank->channel, bank->bank, &bank->config);
}


static void initialise_bank(
    int channel, unsigned int ix, struct bunch_bank *bank)
{
    bank->channel = channel;
    bank->bank = ix;

    unsigned int bunches = hardware_config.bunches;
    bank->config = (struct bunch_config) {
        .fir_select  = malloc(bunches * sizeof(char)),
        .gain        = malloc(bunches * sizeof(int)),
        .fir_enable  = malloc(bunches * sizeof(char)),
        .nco0_enable = malloc(bunches * sizeof(char)),
        .nco1_enable = malloc(bunches * sizeof(char)),
    };
}


static void publish_bank(unsigned int ix, struct bunch_bank *bank)
{
    char prefix[4];
    sprintf(prefix, "%d", ix);
    WITH_NAME_PREFIX(prefix)
    {
        unsigned int bunches = hardware_config.bunches;
        PUBLISH_WAVEFORM(char, "FIRWF", bunches, write_fir_wf,
            .context = bank, .persist = true);
        PUBLISH_WAVEFORM(char, "OUTWF", bunches, write_out_wf,
            .context = bank, .persist = true);
        PUBLISH_WAVEFORM(float, "GAINWF", bunches, write_gain_wf,
            .context = bank, .persist = true);

        PUBLISH_READ_VAR(stringin, "FIRWF:STA", bank->fir_status);
        PUBLISH_READ_VAR(stringin, "OUTWF:STA", bank->out_status);
        PUBLISH_READ_VAR(stringin, "GAINWF:STA", bank->gain_status);
    }
}


error__t initialise_bunch_select(void)
{
    FOR_CHANNEL_NAMES(channel, "BUN")
    {
        struct bunch_context *bun = &bunch_context[channel];
        bun->channel = channel;

        for (unsigned int i = 0; i < BUNCH_BANKS; i ++)
        {
            initialise_bank(channel, i, &bun->banks[i]);
            publish_bank(i, &bun->banks[i]);
        }
    }
    return ERROR_OK;
}
