/* Helper functions and related utilities. */


/* A tricksy macro dance so that we can have a macro with a default argument.
 * Calling GET_DEFAULT(a, b) returns b while GET_DEFAULT(a) returns a. */
#define _ARG2(x, y, extra...)   y
#define GET_DEFAULT(def, arg...)    _ARG2(!, ##arg, def)


/* This macro is a little tricky: it's intended to be used for iterating over
 * the set of axis names together with a prefix thus:
 *
 *  FOR_AXIS_NAME(axis, "ADC") { create pvs ...; }
 *
 * The trickery is in the calling of the exit and enter methods. */
#define FOR_AXIS_NAMES(axis, prefix, mode...) \
    for (int axis = 0; \
         _enter_axis_step(axis, prefix, GET_DEFAULT(false, ##mode)); \
         _exit_axis_step(), axis += 1)

bool _enter_axis_step(int axis, const char *prefix, bool lmbf_mode);
void _exit_axis_step(void);


/* Similar tricksy code to wrap enter and leave functions around a block of
 * code. */
#define _id_WITH_ENTER_LEAVE(loop, enter, leave) \
    for (bool loop = (enter, true); loop; leave, loop = false)
#define _WITH_ENTER_LEAVE(enter, leave) \
    _id_WITH_ENTER_LEAVE(UNIQUE_ID(), enter, leave) \


/* This executes a block of code with the given record name prefix and ensures
 * that the prefix is safely popped when done. */
#define WITH_NAME_PREFIX(prefix) \
    _WITH_ENTER_LEAVE(push_record_name_prefix(prefix), pop_record_name_prefix())



/* This simply loops through the configured bunches. */
#define FOR_BUNCHES(i) \
    for (unsigned int i = 0; i < hardware_config.bunches; i ++)

/* This macro also loops through the configured bunches, but the given offset is
 * applied to j, so that i loops from 0 to bunches-1 and j=(i+offset)%bunches.
 * The given offset *must* be in the range 0 to bunches-1, otherwise j will be
 * computed incorrectly. */
#define FOR_BUNCHES_OFFSET(i, j, offset) \
    for (unsigned int i = 0, j = offset; i < hardware_config.bunches; \
         i += 1, j = j + 1 < hardware_config.bunches ? j + 1 : 0)


/* Returns name of given axis.  If lmbf_mode is set then the common axis name is
 * returned. */
const char *get_axis_name(int axis, bool lmbf_mode);


/* This function converts an array of floats into the corresponding array of
 * integer values by multiplying each value by 2^(bits-high_bits-1).  The
 * floating point values are clipped to the extreme possible values as
 * determined by bits.
 *    The parameter bits determines the total number of bits available, so the
 * output will be in the range [-2^(bits-1)..2^(bits-1)-1].  The parameter
 * high_bits determines the range of valid input values, so the input will be
 * forced into the range [-2^high_bits..2^high_bits).
 *    This function rewrites in[] to correspond to the values written to out[].
 */
void float_array_to_int(
    size_t count, float in[], int out[], int bits, int high_bits);
/* Similar to float_array_to_int, but for a single double argument and producing
 * an unsigned result. */
unsigned int double_to_uint(double *in, int bits, int high_bits);

/* Convert fractional tune in cycles per machine revolution to phase advance per
 * bunch in hardware units. */
unsigned int _pure tune_to_freq(double tune);

/* Reverse computation: hardware units to tune frequency. */
double _pure freq_to_tune(unsigned int freq);

/* As for freq_to_tune, but treats freq as a signed number. */
double _pure freq_to_tune_signed(unsigned int freq);


/* A loop for counting down: surprisingly tricksy for something so simple.
 * Counts i from n-1 downto 0. */
#define _id_FOR_DOWN_FROM(loop, i, n) \
    for (unsigned int i = n; ( { bool loop = i > 0; i --; loop; } ); )
#define FOR_DOWN_FROM(i, n) \
    _id_FOR_DOWN_FROM(UNIQUE_ID(), i, n)


/* Mutex locking is common and doesn't need to be so long winded. */
#define LOCK(mutex)     pthread_mutex_lock(&mutex)
#define UNLOCK(mutex)   pthread_mutex_unlock(&mutex)

#define WITH_MUTEX(mutex)   _WITH_ENTER_LEAVE(LOCK(mutex), UNLOCK(mutex))


/* Generic squaring function. */
#define _id_SQR(temp, x)    ( { typeof(x) temp = (x); temp * temp; } )
#define SQR(x)  _id_SQR(UNIQUE_ID(), x)

/* Type aware calloc. */
#define CALLOC(type, nelm)      (type *) calloc(nelm, sizeof(type))
