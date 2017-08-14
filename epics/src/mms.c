/* Min/Max/Sum/Std support. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "mms.h"


/* We need four MMS handlers: ADC, DAC, two channels each. */
#define MMS_HANDLER_COUNT   4


/* Accumulator for MMS readouts. */
struct mms_accum {
    /* Raw waveforms accumulated from MMS engine. */
    int16_t *raw_min;
    int16_t *raw_max;
    int64_t *raw_sum;
    uint64_t *raw_sum2;

    /* Raw state from MMS. */
    unsigned int raw_turns;
    bool turns_ovfl;
    bool sum_ovfl;
    bool sum2_ovfl;
};


/* Final results. */
struct mms_epics {
    float *min;
    float *max;
    float *delta;
    float *mean;
    float *std;

    int turns;
    bool turns_ovfl;
    bool sum_ovfl;
    bool sum2_ovfl;
};


struct mms_handler {
    int channel;
    void (*read_mms)(int, struct mms_result*);
    unsigned int bunch_offset;
    pthread_mutex_t mutex;

    struct mms_accum accum;
    struct mms_epics epics;
};


static struct mms_handlers {
    unsigned int count;
    struct mms_handler handlers[MMS_HANDLER_COUNT];
} mms_handlers = {
    .count = 0,
};


/* This is called at a regular interval to ensure that the MMS waveforms are up
 * to date and have not overflowed. */
static void read_raw_mms(struct mms_handler *mms)
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
    mms->read_mms(mms->channel, &result);

    /* Accumulate result into the accumulator. */
    struct mms_accum *accum = &mms->accum;
    FOR_BUNCHES_OFFSET(j, i, mms->bunch_offset)
    {
        accum->raw_min[j] = MIN(accum->raw_min[j], minimum[i]);
        accum->raw_max[j] = MAX(accum->raw_max[j], maximum[i]);
        accum->raw_sum[j] += sum[i];
        accum->raw_sum2[j] += sum2[i];
    }

    /* Accumulate turns and overflow flags. */
    accum->raw_turns += result.turns;
    accum->turns_ovfl |= result.turns_ovfl;
    accum->sum_ovfl |= result.sum_ovfl;
    accum->sum2_ovfl |= result.sum2_ovfl;
}


static void reset_accum(struct mms_handler *mms)
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
    accum->turns_ovfl = false;
    accum->sum_ovfl = false;
    accum->sum2_ovfl = false;
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
    FOR_BUNCHES(i)
    {
        double mean = (double) accum->raw_sum[i] / accum->raw_turns;
        epics->mean[i] = ldexpf((float) mean, -15);
        double mean2 = (double) accum->raw_sum2[i] / accum->raw_turns;
        float var = (float) (mean2 - mean * mean);
        epics->std[i] = ldexpf(sqrtf(var >= 0 ? var : 0), -15);
    }

    epics->turns = (int) accum->raw_turns;
    epics->turns_ovfl = accum->turns_ovfl;
    epics->sum_ovfl = accum->sum_ovfl;
    epics->sum2_ovfl = accum->sum2_ovfl;
}


static bool start_mms_readback(void *context, bool *value)
{
    struct mms_handler *mms = context;

    /* Bring ourself up to date.  It's reasonably harmless if these happen
     * back-to-back, just a trifle wasteful. */

    LOCK(mms->mutex);
    read_raw_mms(mms);
    process_mms_waveforms(mms);
    reset_accum(mms);
    UNLOCK(mms->mutex);
    return true;
}


struct mms_handler *create_mms_handler(
    int channel, void (*read_mms)(int, struct mms_result*))
{
    struct mms_handler *mms = &mms_handlers.handlers[mms_handlers.count];
    mms_handlers.count += 1;

    unsigned int bunches = hardware_config.bunches;
    *mms = (struct mms_handler) {
        .channel = channel,
        .read_mms = read_mms,
        .bunch_offset = 0,          // Will be set separately
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .accum = {
            .raw_min  = calloc(bunches, sizeof(int16_t)),
            .raw_max  = calloc(bunches, sizeof(int16_t)),
            .raw_sum  = calloc(bunches, sizeof(int64_t)),
            .raw_sum2 = calloc(bunches, sizeof(uint64_t)),
        },
        .epics = {
            .min      = calloc(bunches, sizeof(float)),
            .max      = calloc(bunches, sizeof(float)),
            .delta    = calloc(bunches, sizeof(float)),
            .mean     = calloc(bunches, sizeof(float)),
            .std      = calloc(bunches, sizeof(float)),
        },
    };

    WITH_NAME_PREFIX("MMS")
    {
        struct mms_epics *epics = &mms->epics;
        PUBLISH_C(bo, "SCAN", start_mms_readback, mms);
        PUBLISH_WF_READ_VAR(float, "MIN",   bunches, epics->min);
        PUBLISH_WF_READ_VAR(float, "MAX",   bunches, epics->max);
        PUBLISH_WF_READ_VAR(float, "DELTA", bunches, epics->delta);
        PUBLISH_WF_READ_VAR(float, "MEAN",  bunches, epics->mean);
        PUBLISH_WF_READ_VAR(float, "STD",   bunches, epics->std);
        PUBLISH_READ_VAR(longin, "TURNS", epics->turns);
        PUBLISH_READ_VAR(bi, "TURN_OVF", epics->turns_ovfl);
        PUBLISH_READ_VAR(bi, "SUM_OVF", epics->sum_ovfl);
        PUBLISH_READ_VAR(bi, "SUM2_OVF", epics->sum2_ovfl);
    }

    return mms;
}


void set_mms_offset(struct mms_handler *mms, unsigned int bunch_offset)
{
    mms->bunch_offset = bunch_offset;
}


static volatile bool running = true;

static void *read_mms_thread(void *context)
{
    while (running)
    {
        usleep(system_config.mms_poll_interval);
        for (unsigned int i = 0; i < mms_handlers.count; i ++)
        {
            LOCK(mms_handlers.handlers[i].mutex);
            read_raw_mms(&mms_handlers.handlers[i]);
            UNLOCK(mms_handlers.handlers[i].mutex);
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
        printf("Waiting for MMS thread\n");
        running = false;
        pthread_join(mms_thread_id, NULL);
    }
}
