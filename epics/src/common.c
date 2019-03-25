/* Miscellaneous helper functions. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdarg.h>
#include <math.h>
#include <string.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "configs.h"

#include "common.h"


static const char *const *axis_names[] = {
    &system_config.axis0_name,
    &system_config.axis1_name,
};

const char *get_axis_name(int axis, bool lmbf_mode)
{
    static char *iq_axis_name = NULL;

    if (lmbf_mode)
    {
        /* Ugly first use initialisation. */
        if (!iq_axis_name)
            asprintf(&iq_axis_name, "%s%s",
                system_config.axis0_name, system_config.axis1_name);
        return iq_axis_name;
    }
    else
        return *axis_names[axis];
}


bool _enter_axis_step(int axis, const char *prefix, bool lmbf_mode)
{
    int axis_count = lmbf_mode ? 1 : AXIS_COUNT;
    if (axis < axis_count)
    {
        push_record_name_prefix(get_axis_name(axis, lmbf_mode));
        push_record_name_prefix(prefix);
        return true;
    }
    else
        return false;
}

void _exit_axis_step(void)
{
    pop_record_name_prefix();
    pop_record_name_prefix();
}


void float_array_to_int(
    size_t count, float in[], int out[], int bits, int fraction_bits)
{
    float top_bit = ldexpf(1, bits - fraction_bits - 1);
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

/* Much as above, but double, unsigned, one result. */
unsigned int double_to_uint(double *in, int bits, int fraction_bits)
{
    double top_bit = ldexp(1, bits - fraction_bits);
    double min_val = 0;
    double max_val = nextafter(top_bit, 0) - ldexp(1, -fraction_bits);

    if (*in > max_val)
        *in = max_val;
    else if (*in < min_val)
        *in = min_val;
    unsigned int out = (unsigned int) lround(ldexp(*in, fraction_bits));
    *in = ldexp((double) out, -fraction_bits);
    return out;
}


/* Convert fractional tune in cycles per machine revolution to phase advance per
 * bunch in hardware units. */
uint64_t tune_to_freq(double tune)
{
    /* Convert the incoming tune in cycles per machine revolution into phase
     * advance per bunch by scaling and reducing to the half open interval
     * [0, 1). */
    double integral;
    double fraction = modf(tune / hardware_config.bunches, &integral);
    if (fraction < 0.0)
        fraction += 1.0;
    /* Can now scale up to hardware units. */
    return (uint64_t) llround(ldexp(fraction, 48));
}

double freq_to_tune(uint64_t freq)
{
    return ldexp((double) (freq << 16), -64) * hardware_config.bunches;
}

double freq_to_tune_signed(uint64_t freq)
{
    int64_t sfreq = (int64_t) freq;
    return ldexp((double) (sfreq << 16), -64) * hardware_config.bunches;
}


bool format_epics_string(EPICS_STRING *s, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    int length = vsnprintf(s->s, sizeof(s->s), format, args);
    va_end(args);
    return (size_t) length < sizeof(s->s);
}
