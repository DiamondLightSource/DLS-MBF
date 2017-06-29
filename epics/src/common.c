/* Miscellaneous helper functions. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"

#include "common.h"


static const char *channel_names[CHANNEL_COUNT];

void set_channel_names(const char *names[])
{
    for (int i = 0; i < CHANNEL_COUNT; i ++)
        channel_names[i] = names[i];
}


void _enter_channel_step(int channel, const char *prefix)
{
    push_record_name_prefix(channel_names[channel]);
    push_record_name_prefix(prefix);
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
