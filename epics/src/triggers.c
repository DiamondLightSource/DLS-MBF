/* Trigger handling. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "register_defs.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "events.h"
#include "memory.h"
#include "sequencer.h"
#include "detector.h"

#include "triggers.h"


enum target_mode {
    MODE_ONE_SHOT,      // Normal single shot operation
    MODE_REARM,         // Rearm this target after trigger complete
    MODE_SHARED,        // Shared trigger operation
};


enum target_status {
    STATUS_IDLE,        // Trigger ready for arming
    STATUS_ARMED,       // Waiting for trigger
    STATUS_BUSY,        // Trigger received, target processing trigger
};



/* Configuration for a single trigger target. */
struct target_config {
    enum trigger_target target;
    enum target_mode mode;
    struct epics_record *update_sources;

    pthread_mutex_t mutex;
    unsigned int status;
    struct epics_record *status_pv;

    /* Our interrupt sources.  We see three events of interest: trigger to
     * target, target becomes busy, target becomes idle.  The arming event is
     * delivered separately through software. */
    struct interrupts trigger_interrupt;
    struct interrupts busy_interrupt;
    struct interrupts done_interrupt;

    bool sources[TRIGGER_SOURCE_COUNT];
    bool enables[TRIGGER_SOURCE_COUNT];
    bool blanking[TRIGGER_SOURCE_COUNT];
};


/* Array of possible targets. */
struct target_config targets[TRIGGER_TARGET_COUNT] = {
    [TRIGGER_SEQ0] = {
        .target = TRIGGER_SEQ0,
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .trigger_interrupt = { .seq_trigger = 1, },
        .busy_interrupt    = { .seq_busy = 1, },
        .done_interrupt    = { .seq_done = 1, },
    },
    [TRIGGER_SEQ1] = {
        .target = TRIGGER_SEQ1,
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .trigger_interrupt = { .seq_trigger = 2, },
        .busy_interrupt    = { .seq_busy = 2, },
        .done_interrupt    = { .seq_done = 2, },
    },
    [TRIGGER_DRAM] = {
        .target = TRIGGER_DRAM,
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .trigger_interrupt = { .dram_trigger = 1, },
        .busy_interrupt    = { .dram_busy = 1, },
        .done_interrupt    = { .dram_done = 1, },
    },
};


struct channel_context {
    int channel;
    struct target_config *sequencer;
} channel_contexts[CHANNEL_COUNT] = {
    [0] = {
        .channel = 0,
        .sequencer = &targets[TRIGGER_SEQ0],
    },
    [1] = {
        .channel = 1,
        .sequencer = &targets[TRIGGER_SEQ1],
    },
};



/* Used for monitoring the status of the trigger sources and blanking input. */
static bool sources_in[TRIGGER_SOURCE_COUNT];
static bool blanking_in;


static const char *source_names[] = {
    "SOFT", "EXT", "PM", "ADC0", "ADC1", "SEQ0", "SEQ1", };


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


static void create_event_set(
    bool sources[TRIGGER_SOURCE_COUNT], const char *suffix)
{
    for (unsigned int i = 0; i < TRIGGER_SOURCE_COUNT; i ++)
    {
        char name[20];
        sprintf(name, "%s:%s", source_names[i], suffix);
        PUBLISH_READ_VAR(bi, name, sources[i]);
    }
}


/* This is polled at 5Hz so that incoming trigger events can be seen. */
static void read_input_events(void)
{
    hw_read_trigger_events(sources_in, &blanking_in);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger state control. */


static void prepare_seq_target(int channel)
{
    prepare_sequencer(channel);
    prepare_detector(channel);
}


static void lock_targets(const bool arm[TRIGGER_TARGET_COUNT])
{
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++)
        if (arm[i])
            LOCK(targets[i].mutex);
}

static void unlock_targets(const bool arm[TRIGGER_TARGET_COUNT])
{
    /* Unlock in reverse order. */
    FOR_DOWN_FROM(i, TRIGGER_TARGET_COUNT)
        if (arm[i])
            UNLOCK(targets[i].mutex);
}


static void update_trigger_sources(struct target_config *dest)
{
    hw_read_trigger_sources(dest->target, dest->sources);
    trigger_record(dest->update_sources);
}


static void arm_targets(const bool arm[TRIGGER_TARGET_COUNT])
{
    /* First prepare the targets, each according to its appropriate
     * processing action. */
    if (arm[TRIGGER_SEQ0])
        prepare_seq_target(0);
    if (arm[TRIGGER_SEQ1])
        prepare_seq_target(1);
    if (arm[TRIGGER_DRAM])
        prepare_memory();

    /* Arming the triggers and updating the status needs to be done
     * synchronously to ensure that hardware events triggered by arming are
     * actually seen afterwards. */
    lock_targets(arm);

    /* Now we can arm the selected targets. */
    hw_write_trigger_arm(arm);

    /* Update the status to indicate that we're armed. */
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++)
        if (arm[i])
        {
            struct target_config *dest = &targets[i];
            dest->status = STATUS_ARMED;
            trigger_record(dest->status_pv);
            update_trigger_sources(dest);
        }

    unlock_targets(arm);
}


static bool arm_target(void *context, bool *value)
{
    struct target_config *config = context;
    bool arm[TRIGGER_TARGET_COUNT] = { };
    arm[config->target] = true;
    arm_targets(arm);
    return true;
}


static bool disarm_target(void *context, bool *value)
{
    struct target_config *config = context;
    bool disarm[TRIGGER_TARGET_COUNT] = { };
    disarm[config->target] = true;
    hw_write_trigger_disarm(disarm);
    return true;
}


static void read_shared_targets(bool shared[TRIGGER_TARGET_COUNT])
{
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++)
        shared[i] = targets[i].mode == MODE_SHARED;
}


static void arm_shared_targets(void)
{
    bool arm[TRIGGER_TARGET_COUNT];
    read_shared_targets(arm);
    arm_targets(arm);
}


static void disarm_shared_targets(void)
{
    bool disarm[TRIGGER_TARGET_COUNT];
    read_shared_targets(disarm);
    hw_write_trigger_disarm(disarm);
}


static void process_target_events(
    struct target_config *dest, bool trigger, bool busy, bool done)
{
    LOCK(dest->mutex);
    unsigned int old_status = dest->status;
    if (trigger)
    {
        dest->status = STATUS_BUSY;
        update_trigger_sources(dest);
    }
    if (done)
        dest->status = STATUS_IDLE;
    if (old_status != dest->status)
        trigger_record(dest->status_pv);
    UNLOCK(dest->mutex);
}


static void dispatch_target_events(void *context, struct interrupts interrupts)
{
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++)
    {
        struct target_config *dest = &targets[i];
        bool trigger = test_intersect(interrupts, dest->trigger_interrupt);
        bool busy    = test_intersect(interrupts, dest->busy_interrupt);
        bool done    = test_intersect(interrupts, dest->done_interrupt);
        process_target_events(dest, trigger, busy, done);
    }
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger targets */


static bool write_enables(void *context, bool *value)
{
    struct target_config *config = context;
    hw_write_trigger_enable_mask(config->target, config->enables);
    return true;
}


static bool write_blanking(void *context, bool *value)
{
    struct target_config *config = context;
    hw_write_trigger_blanking_mask(config->target, config->blanking);
    return true;
}


static bool write_trigger_delay(void *context, unsigned int *value)
{
    struct target_config *config = context;
    hw_write_trigger_delay(config->target, *value);
    return true;
}


static void create_target(const char *prefix, struct target_config *config)
{
    WITH_NAME_PREFIX(prefix)
    {
        for (unsigned int i = 0; i < TRIGGER_SOURCE_COUNT; i ++)
        {
            WITH_NAME_PREFIX(source_names[i])
            {
                PUBLISH_READ_VAR(bi, "HIT", config->sources[i]);
                PUBLISH_WRITE_VAR_P(bo, "EN", config->enables[i]);
                PUBLISH_WRITE_VAR_P(bo, "BL", config->blanking[i]);
            }
        }

        PUBLISH_C(bo, "EN", write_enables, config);
        PUBLISH_C(bo, "BL", write_blanking, config);

        PUBLISH_C_P(ulongout, "DELAY", write_trigger_delay, config);
        PUBLISH_WRITE_VAR_P(mbbo, "MODE", config->mode);

        PUBLISH_C(bo, "ARM", arm_target, config);
        PUBLISH_C(bo, "DISARM", disarm_target, config);

        config->update_sources = PUBLISH_TRIGGER("HIT");
        config->status_pv = PUBLISH_READ_VAR_I(mbbi, "STATUS", config->status);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static bool write_blanking_window(void *context, unsigned int *value)
{
    struct channel_context *chan = context;
    hw_write_trigger_blanking_duration(chan->channel, *value);
    return true;
}


error__t initialise_triggers(void)
{
    WITH_NAME_PREFIX("TRG")
    {
        create_target("MEM", &targets[TRIGGER_DRAM]);

        create_event_set(sources_in, "IN");
        PUBLISH_READ_VAR(bi, "BLNK:IN", blanking_in);
        PUBLISH_ACTION("IN", read_input_events);
        PUBLISH_ACTION("SOFT", hw_write_trigger_soft_trigger);

        PUBLISH_ACTION("ARM", arm_shared_targets);
        PUBLISH_ACTION("DISARM", disarm_shared_targets);
    }

    FOR_CHANNEL_NAMES(channel, "TRG")
    {
        struct channel_context *chan = &channel_contexts[channel];
        create_target("SEQ", chan->sequencer);
        PUBLISH_C_P(ulongout, "BLANKING", write_blanking_window, chan);
    }

    register_event_handler(
        INTERRUPT_HANDLER_TRIGGER,
        INTERRUPTS(
            .dram_busy = 1, .dram_done = 1, .dram_trigger = 1,
            .seq_trigger = 3, .seq_busy = 3, .seq_done = 3),
        NULL, dispatch_target_events);

    return ERROR_OK;
}
