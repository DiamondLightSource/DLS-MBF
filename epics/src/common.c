/* Miscellaneous helper functions. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <string.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "configs.h"

#include "common.h"


static const char *const *channel_names[] = {
    &system_config.channel0_name,
    &system_config.channel1_name,
};

static char *iq_channel_name;


bool _enter_channel_step(int channel, const char *prefix, bool lmbf_mode)
{
    /* Ugly first use initialisation. */
    if (!iq_channel_name)
        asprintf(&iq_channel_name, "%s%s",
            system_config.channel0_name, system_config.channel1_name);

    int channel_count = lmbf_mode ? 1 : CHANNEL_COUNT;
    if (channel < channel_count)
    {
        const char *channel_name =
            lmbf_mode ? iq_channel_name : *channel_names[channel];
        push_record_name_prefix(channel_name);
        push_record_name_prefix(prefix);
        return true;
    }
    else
        return false;
}

void _exit_channel_step(void)
{
    pop_record_name_prefix();
    pop_record_name_prefix();
}


void float_array_to_int(
    size_t count, float in[], int out[], int bits, int high_bits)
{
    int fraction_bits = bits - high_bits - 1;
    float top_bit = ldexpf(1, high_bits);
    float min_val = -top_bit;
    /* We have to be a bit careful with max_val.  If bits is larger than can be
     * represented in a float then simply subtracting 2^-fraction_bits will do
     * nothing.  We fudge the issue by subtracting one ULP (Unit of Least
     * Precision) from max_val first to ensure we fit within the necessary
     * limits. */
    float max_val = nextafterf(top_bit, 0) - ldexpf(1, -fraction_bits);

    for (size_t i = 0; i < count; i ++)
    {
        if (in[i] > max_val)
            in[i] = max_val;
        else if (in[i] < min_val)
            in[i] = min_val;
        out[i] = (int) lroundf(ldexpf(in[i], fraction_bits));
        in[i] = ldexpf((float) out[i], -fraction_bits);
    }
}


/* Convert fractional tune in cycles per machine revolution to phase advance per
 * bunch in hardware units. */
unsigned int tune_to_freq(double tune)
{
    /* Convert the incoming tune in cycles per machine revolution into phase
     * advance per bunch by scaling and reducing to the half open interval
     * [0, 1). */
    double integral;
    double fraction = modf(tune / hardware_config.bunches, &integral);
    if (fraction < 0.0)
        fraction += 1.0;
    /* Can now scale up to hardware units. */
    return (unsigned int) round(ldexp(fraction, 32));
}

double freq_to_tune(unsigned int freq)
{
    return ldexp(freq, -32) * hardware_config.bunches;
}

double freq_to_tune_signed(unsigned int freq)
{
    int sfreq = (int) freq;
    return ldexp(sfreq, -32) * hardware_config.bunches;
}
