/* Min/Max/Sum/Std support. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <string.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "mms.h"


/* We need four MMS handlers: ADC, and DAC for each axis. */
#define MMS_HANDLER_COUNT   (2 * AXIS_COUNT)


/* Accumulator for MMS readouts. */
struct mms_accum {
    /* Raw waveforms accumulated from MMS engine. */
    int16_t *raw_min;
    int16_t *raw_max;
    int64_t *raw_sum;
    uint64_t *raw_sum2;

    unsigned int variance_sum_count;
    double *variance_sum;
    float *std_min_wf;
    float *std_max_wf;

    /* Raw state from MMS. */
    unsigned int raw_turns;
    unsigned int mms_overflow;
};


/* Final results. */
struct mms_epics {
    float *min;
    float *max;
    float *delta;
    float *mean;
    float *std;
    double mean_mean;
    double std_mean;

    /* These three waveforms are updated by the archive update process. */
    float *std_mean_wf;
    float *std_min_wf;
    float *std_max_wf;

    unsigned int turns;
    unsigned int mms_overflow;
};


struct mms_handler {
    const char *source;
    int axis;
    void (*read_mms)(int, struct mms_result*);
    unsigned int bunch_offset;
    pthread_mutex_t mutex;

    struct epics_interlock *archive;

    struct mms_accum accum;
    struct mms_epics epics;
};


static struct mms_handlers {
    unsigned int count;
    struct mms_handler handlers[MMS_HANDLER_COUNT];
} mms_handlers = {
    .count = 0,
};


void read_mms_mean(struct mms_handler *mms, float mean[])
{
    WITH_MUTEX(mms->mutex)
    {
        unsigned int bunches = hardware_config.bunches;
        memcpy(mean, mms->epics.mean, sizeof(float) * bunches);
    }
}


/* Helper functions for adding with overflow detection.  This is annoyingly a
 * lot more tricky than might be hoped.  In more recent versions of GCC (from
 * version 5) we have __builtin_add_overflow() functions, but this is not
 * supported in GCC 4 which is used for this project.
 *    Unsigned overflow detection isn't too painful: if a+b<a or b then overflow
 * has occurred, and it seems the compiler understands this and generates the
 * right code.  Signed overflow detection is not so great, as it actually
 * triggers undefined behaviour, and so needs to be tested for before actually
 * doing the sum.
 *    We need overflow detection for threee types: unsigned int, uint64_t, and
 * int64_t, the last being the troublemaker.  To make accumulating overflow
 * detection easier we only set the overflow flag. */
static unsigned int add_overflow_uint(
    unsigned int a, unsigned int b, bool *overflow)
{
    unsigned int result = a + b;
    if (result < a)  *overflow = true;
    return result;
}

static uint64_t add_overflow_uint64_t(uint64_t a, uint64_t b, bool *overflow)
{
    uint64_t result = a + b;
    if (result < a)  *overflow = true;
    return result;
}

static int64_t add_overflow_int64_t(int64_t a, int64_t b, bool *overflow)
{
    /* Writing C to work around this problem produces truly nasty code.
     * Fortunately the following assembler is pretty straightforward. */
    int64_t result;
    __asm__(
        "movq    %[a], %[result]" "\n\t"
        "addq    %[b], %[result]" "\n\t"
        "jno     1f" "\n\t"
        "movb    $1, (%[overflow])" "\n"
        "1:"
        : [result] "=&r" (result), "+m" (*overflow)
        : [a] "r" (a), [b] "r" (b), [overflow] "r" (overflow)
        : "cc" );
    return result;
}


static void reset_accum(struct mms_handler *mms, bool reset_overflow)
{
    struct mms_accum *accum = &mms->accum;
    FOR_BUNCHES(i)
    {
        accum->raw_min[i] = 0x7FFF;
        accum->raw_max[i] = (int16_t) 0x8000;
        accum->raw_sum[i] = 0;
        accum->raw_sum2[i] = 0;
    }
    accum->raw_turns = 0;
    if (reset_overflow)
        accum->mms_overflow = 0;
}


static void update_accum(
    struct mms_handler *mms, const struct mms_result *result)
{
    /* Accumulate result into the accumulator. */
    struct mms_accum *accum = &mms->accum;
    bool sum_ovfl = result->sum_ovfl;
    bool sum2_ovfl = result->sum2_ovfl;
    FOR_BUNCHES_OFFSET(j, i, mms->bunch_offset)
    {
        accum->raw_min[j] =
            (int16_t) MIN(accum->raw_min[j], result->minimum[i]);
        accum->raw_max[j] =
            (int16_t) MAX(accum->raw_max[j], result->maximum[i]);
        accum->raw_sum[j] = add_overflow_int64_t(
            accum->raw_sum[j], result->sum[i], &sum_ovfl);
        accum->raw_sum2[j] = add_overflow_uint64_t(
            accum->raw_sum2[j], result->sum2[i], &sum2_ovfl);
    }

    /* Accumulate turns and overflow flags. */
    bool turns_ovfl = result->turns_ovfl;
    accum->raw_turns =
        add_overflow_uint(accum->raw_turns, result->turns, &turns_ovfl);

    /* Convert individual overflow bits into encoding. */
    accum->mms_overflow |=
        (unsigned int) (turns_ovfl | sum_ovfl << 1 | sum2_ovfl << 2);
}


/* This is called at a regular interval to ensure that the MMS waveforms are up
 * to date and have not overflowed. */
static void read_raw_mms(struct mms_handler *mms, bool initialise)
{
    /* Create somewhere to receive the hardware results.  We put this on the
     * stack to make life simpler. */
    unsigned int bunches = hardware_config.bunches;
    int16_t minimum[bunches];
    int16_t maximum[bunches];
    int32_t sum[bunches];
    uint64_t sum2[bunches];
    struct mms_result result = {
        .minimum = minimum, .maximum = maximum, .sum = sum, .sum2 = sum2 };

    /* Read an update from hardware. */
    mms->read_mms(mms->axis, &result);
    /* If any of the overflow bits are set log an error. */
    if (!initialise  &&
            (result.turns_ovfl || result.sum_ovfl || result.sum2_ovfl))
        log_message("MMS %s:%d overflow: %d %d %d %u",
            mms->source, mms->axis,
            result.turns_ovfl, result.sum_ovfl, result.sum2_ovfl, result.turns);

    if (initialise)
        /* On first call we throw all our data away.  This gives us a clean
         * start in preparation for normal operation. */
        reset_accum(mms, true);
    else
        /* Normally accumulate results until ready for readout. */
        update_accum(mms, &result);
}


static void process_mms_waveforms(struct mms_handler *mms)
{
    struct mms_accum *accum = &mms->accum;
    struct mms_epics *epics = &mms->epics;

    FOR_BUNCHES(i)
        epics->min[i] = ldexpf((float) accum->raw_min[i], -15);
    FOR_BUNCHES(i)
        epics->max[i] = ldexpf((float) accum->raw_max[i], -15);
    FOR_BUNCHES(i)
        epics->delta[i] =
            ldexpf((float) (accum->raw_max[i] - accum->raw_min[i]), -15);
    double mean_mean = 0;
    double std_mean = 0;
    FOR_BUNCHES(i)
    {
        double mean = (double) accum->raw_sum[i] / accum->raw_turns;
        epics->mean[i] = ldexpf((float) mean, -15);
        mean_mean += mean;
        double mean2 = (double) accum->raw_sum2[i] / accum->raw_turns;
        double var = ldexp(mean2 - mean * mean, -30);
        accum->variance_sum[i] += var;
        std_mean += var;
        float std = sqrtf(var >= 0 ? (float) var : 0);
        epics->std[i] = std;
        accum->std_min_wf[i] = MIN(accum->std_min_wf[i], std);
        accum->std_max_wf[i] = MAX(accum->std_max_wf[i], std);
    }
    epics->mean_mean = ldexp(mean_mean / hardware_config.bunches, -15);
    epics->std_mean = sqrt(std_mean / hardware_config.bunches);

    epics->turns = accum->raw_turns;
    epics->mms_overflow = accum->mms_overflow;

    accum->variance_sum_count += 1;
}


static void update_archive_pvs(struct mms_handler *mms)
{
    struct mms_accum *accum = &mms->accum;
    struct mms_epics *epics = &mms->epics;

    interlock_wait(mms->archive);

    unsigned int count = accum->variance_sum_count;
    accum->variance_sum_count = 0;
    FOR_BUNCHES(i)
    {
        epics->std_mean_wf[i] = (float) sqrt(accum->variance_sum[i] / count);
        accum->variance_sum[i] = 0;
        epics->std_min_wf[i] = accum->std_min_wf[i];
        accum->std_min_wf[i] = INFINITY;
        epics->std_max_wf[i] = accum->std_max_wf[i];
        accum->std_max_wf[i] = -INFINITY;
    }

    interlock_signal(mms->archive, NULL);
}


static bool start_mms_readback(void *context, bool *value)
{
    struct mms_handler *mms = context;

    /* Bring ourself up to date.  It's reasonably harmless if these happen
     * back-to-back, just a trifle wasteful. */
    read_raw_mms(mms, false);
    process_mms_waveforms(mms);
    reset_accum(mms, false);
    return true;
}


static bool reset_mms_fault(void *context, bool *value)
{
    struct mms_handler *mms = context;
    mms->accum.mms_overflow = 0;
    return true;
}


struct mms_handler *create_mms_handler(
    const char *source, int axis, void (*read_mms)(int, struct mms_result*))
{
    struct mms_handler *mms = &mms_handlers.handlers[mms_handlers.count];
    mms_handlers.count += 1;

    unsigned int bunches = hardware_config.bunches;
    *mms = (struct mms_handler) {
        .source = source,
        .axis = axis,
        .read_mms = read_mms,
        .bunch_offset = 0,          // Will be set separately
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .accum = {
            .raw_min  = CALLOC(int16_t, bunches),
            .raw_max  = CALLOC(int16_t, bunches),
            .raw_sum  = CALLOC(int64_t, bunches),
            .raw_sum2 = CALLOC(uint64_t, bunches),
            .variance_sum = CALLOC(double, bunches),
            .std_min_wf = CALLOC(float, bunches),
            .std_max_wf = CALLOC(float, bunches),
        },
        .epics = {
            .min      = CALLOC(float, bunches),
            .max      = CALLOC(float, bunches),
            .delta    = CALLOC(float, bunches),
            .mean     = CALLOC(float, bunches),
            .std      = CALLOC(float, bunches),
            .std_mean_wf = CALLOC(float, bunches),
            .std_min_wf = CALLOC(float, bunches),
            .std_max_wf = CALLOC(float, bunches),
        },
    };

    WITH_NAME_PREFIX("MMS")
    {
        struct mms_epics *epics = &mms->epics;
        PUBLISH_C(bo, "SCAN", start_mms_readback, mms, .mutex = &mms->mutex);
        PUBLISH_WF_READ_VAR(float, "MIN",   bunches, epics->min);
        PUBLISH_WF_READ_VAR(float, "MAX",   bunches, epics->max);
        PUBLISH_WF_READ_VAR(float, "DELTA", bunches, epics->delta);
        PUBLISH_WF_READ_VAR(float, "MEAN",  bunches, epics->mean);
        PUBLISH_WF_READ_VAR(float, "STD",   bunches, epics->std);
        PUBLISH_READ_VAR(ai, "MEAN_MEAN", epics->mean_mean);
        PUBLISH_READ_VAR(ai, "STD_MEAN", epics->std_mean);
        PUBLISH_READ_VAR(ulongin, "TURNS", epics->turns);
        PUBLISH_READ_VAR(mbbi, "OVERFLOW", epics->mms_overflow);

        PUBLISH_WF_READ_VAR(float, "STD_MEAN_WF", bunches, epics->std_mean_wf);
        PUBLISH_WF_READ_VAR(float, "STD_MIN_WF", bunches, epics->std_min_wf);
        PUBLISH_WF_READ_VAR(float, "STD_MAX_WF", bunches, epics->std_max_wf);
        mms->archive = create_interlock("ARCHIVE", false);

        PUBLISH_C(bo, "RESET_FAULT", reset_mms_fault, mms,
            .mutex = &mms->mutex);
    }

    return mms;
}


void set_mms_offset(struct mms_handler *mms, unsigned int bunch_offset)
{
    mms->bunch_offset = bunch_offset;
}


static volatile bool running = true;

static void read_mms_handlers(bool initialise)
{
    for (unsigned int i = 0; i < mms_handlers.count; i ++)
    {
        struct mms_handler *mms = &mms_handlers.handlers[i];
        WITH_MUTEX(mms->mutex)
            read_raw_mms(mms, initialise);
    }
}

static void update_all_archive_pvs(void)
{
    for (unsigned int i = 0; i < mms_handlers.count; i ++)
    {
        struct mms_handler *mms = &mms_handlers.handlers[i];
        WITH_MUTEX(mms->mutex)
            update_archive_pvs(mms);
    }
}

static void *read_mms_thread(void *context)
{
    wait_for_epics_start();

    /* Work out when we're going to start, make sure that all our archive
     * updates are on an integer multiple of the archive interval. */
    int interval = system_config.archive_interval;
    struct timespec now;
    ASSERT_IO(clock_gettime(CLOCK_REALTIME, &now));
    time_t next = interval * (1 + now.tv_sec / interval);

    /* Treat first readout of MMS as a reset; we do this after EPICS is up and
     * running and everything has settled down. */
    read_mms_handlers(true);

    while (running)
    {
        usleep(system_config.mms_poll_interval);
        read_mms_handlers(false);

        /* Check for archive output. */
        ASSERT_IO(clock_gettime(CLOCK_REALTIME, &now));
        if (now.tv_sec >= next)
        {
            update_all_archive_pvs();
            next += interval;
        }
    }
    return NULL;
}


static pthread_t mms_thread_id;

error__t start_mms_handlers(void)
{
    return TEST_PTHREAD(
        pthread_create(&mms_thread_id, NULL, read_mms_thread, NULL));
}


void stop_mms_handlers(void)
{
    if (mms_thread_id)
    {
        log_message("Waiting for MMS thread");
        running = false;
        pthread_join(mms_thread_id, NULL);
    }
}
