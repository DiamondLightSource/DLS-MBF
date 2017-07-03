/* Helper functions and related utilities. */

/* Must be called during initialisation before FOR_CHANNEL_NAMES can be used. */
void set_channel_names(const char *names[]);


/* This macro is a little tricky: it's intended to be used for iterating over
 * the set of channel names together with a prefix thus:
 *
 *  FOR_CHANNEL_NAME(channel, "ADC") { create pvs ...; }
 *
 * The trickery is in the calling of the exit and enter methods. */
#define FOR_CHANNEL_NAMES(channel, prefix) \
    for (int channel = 0; channel < CHANNEL_COUNT; \
         _exit_channel_step(), channel += 1) \
    if (_enter_channel_step(channel, prefix), 1)

void _enter_channel_step(int channel, const char *prefix);
void _exit_channel_step(void);


/* This executes a block of code with the given record name prefix and ensures
 * that the prefix is safely popped when done. */
#define _id_WITH_NAME_PREFIX(loop, prefix) \
    for (bool loop = (push_record_name_prefix(prefix), true); loop; \
         pop_record_name_prefix(), loop = false)
#define WITH_NAME_PREFIX(prefix) \
    _id_WITH_NAME_PREFIX(UNIQUE_ID(), prefix)


/* This function converts an array of floats into the corresponding array of
 * integer values by multiplying each value by 2^(bits-high_bits-1).  The
 * floating point values are clipped to the extreme possible values as
 * determined by bits.
 *    The parameter bits determines the total number of bits available, so the
 * output will be in the range [-2^(bits-1)..2^(bits-1)-1].  The parameter
 * high_bits determines the range of valid input values, so the input should be
 * in the range [-2^high_bits..2^high_bits). */
void float_array_to_int(
    size_t count, float in[], int out[], int bits, int high_bits);

/* Convert fractional tune in cycles per machine revolution to phase advance per
 * bunch in hardware units. */
unsigned int tune_to_freq(double tune);


/* Mutex locking is common and doesn't need to be so long winded. */
#define LOCK(mutex)     pthread_mutex_lock(&mutex)
#define UNLOCK(mutex)   pthread_mutex_unlock(&mutex)
