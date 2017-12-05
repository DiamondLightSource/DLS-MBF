/* Helper functions for struct timespec. */

/* Macros for time intervals. */
#define MSECS           1000
#define USECS           1000000
#define NSECS           1000000000


/* Converts time in given units to time as a timespec structure. */
static inline struct timespec interval_to_timespec(int interval, int units)
{
    return (struct timespec) {
        .tv_sec = interval / units,
        .tv_nsec = (interval % units) * (NSECS / units),
    };
}


/* Returns sum of two timespec structures. */
static inline struct timespec add_timespec(struct timespec a, struct timespec b)
{
    struct timespec result = {
        .tv_sec  = a.tv_sec  + b.tv_sec,
        .tv_nsec = a.tv_nsec + b.tv_nsec,
    };
    if (result.tv_nsec >= NSECS)
    {
        result.tv_sec  += 1;
        result.tv_nsec -= NSECS;
    }
    return result;
}


/* Returns difference of two timespec structures. */
static inline struct timespec subtract_timespec(
    struct timespec a, struct timespec b)
{
    struct timespec result = {
        .tv_sec  = a.tv_sec  - b.tv_sec,
        .tv_nsec = a.tv_nsec - b.tv_nsec,
    };
    if (result.tv_nsec < 0)
    {
        result.tv_sec  -= 1;
        result.tv_nsec += NSECS;
    }
    return result;
}


/* Returns sum of timespec and interval in given units. */
static inline struct timespec add_interval(
    struct timespec ts, int interval, int units)
{
    return add_timespec(ts, interval_to_timespec(interval, units));
}


/* Returns true iff a is no later than b. */
static inline bool compare_timespec_le(struct timespec a, struct timespec b)
{
    if (a.tv_sec < b.tv_sec)
        return true;
    else if (a.tv_sec > b.tv_sec)
        return false;
    else
        return a.tv_nsec <= b.tv_nsec;
}


/* Returns true iff a and b are equal. */
static inline bool compare_timespec_eq(struct timespec a, struct timespec b)
{
    return a.tv_sec == b.tv_sec  &&  a.tv_nsec == b.tv_nsec;
}


/* Returns earliest of two timespec structures. */
static inline struct timespec earliest_timespec(
    struct timespec a, struct timespec b)
{
    return compare_timespec_le(a, b) ? a : b;
}


static inline struct timespec get_current_time(void)
{
    struct timespec now;
    ASSERT_IO(clock_gettime(CLOCK_MONOTONIC, &now));
    return now;
}
