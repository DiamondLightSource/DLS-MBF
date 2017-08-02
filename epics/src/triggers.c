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


enum target_state {
    STATE_IDLE,        // Trigger ready for arming
    STATE_ARMED,       // Waiting for trigger
    STATE_BUSY,        // Trigger received, target processing trigger
};


/* Configuration for a single trigger target. */
struct target_config {
    enum trigger_target target;
    enum target_mode mode;
    struct epics_record *update_sources;

    unsigned int state;
    struct epics_record *status_pv;

    bool sources[TRIGGER_SOURCE_COUNT];
    bool enables[TRIGGER_SOURCE_COUNT];
    bool blanking[TRIGGER_SOURCE_COUNT];


    /* Target specific methods and variables. */
    void (*const prepare_target)(struct target_config *target);
    void (*const stop_target)(struct target_config *target);
    const enum target_state disarmed_state;
    const int channel;

    /* Our interrupt sources.  We see two events of interest: trigger to target,
     * and target becomes idle.  The arming event is delivered separately
     * through software. */
    const struct interrupts trigger_interrupt;
    const struct interrupts complete_interrupt;
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target specific configuration and implementation. */


static void prepare_seq_target(struct target_config *target)
{
    prepare_sequencer(target->channel);
    prepare_detector(target->channel);
}

static void stop_seq_target(struct target_config *target)
{
    hw_write_seq_abort(target->channel);
}


static void prepare_mem_target(struct target_config *target)
{
    prepare_memory();
}

static void stop_mem_target(struct target_config *target)
{
    hw_write_dram_capture_command(false, true);
}


/* Array of possible targets. */
struct target_config targets[TRIGGER_TARGET_COUNT] = {
    [TRIGGER_SEQ0] = {
        .target = TRIGGER_SEQ0,
        .prepare_target = prepare_seq_target,
        .stop_target = stop_seq_target,
        .disarmed_state = STATE_IDLE,
        .channel = 0,
        .trigger_interrupt = { .seq_trigger = 1, },
        .complete_interrupt    = { .seq_done = 1, },
    },
    [TRIGGER_SEQ1] = {
        .target = TRIGGER_SEQ1,
        .prepare_target = prepare_seq_target,
        .stop_target = stop_seq_target,
        .disarmed_state = STATE_IDLE,
        .channel = 1,
        .trigger_interrupt = { .seq_trigger = 2, },
        .complete_interrupt    = { .seq_done = 2, },
    },
    [TRIGGER_DRAM] = {
        .target = TRIGGER_DRAM,
        .prepare_target = prepare_mem_target,
        .stop_target = stop_mem_target,
        .disarmed_state = STATE_BUSY,
        .channel = -1,          // Not valid for this target
        .trigger_interrupt = { .dram_trigger = 1, },
        .complete_interrupt    = { .dram_done = 1, },
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


/* All trigger management is done under a single shared mutex.  In principle we
 * could have a mutex per target configuration, but then the shared trigger
 * management becomes somewhat painful! */
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

/* Used for monitoring the status of the trigger sources and blanking input. */
static bool sources_in[TRIGGER_SOURCE_COUNT];
static bool blanking_in;

/* Used for shared record aggregate status. */
static bool retrigger_mode;
static unsigned int trigger_status;
static struct epics_record *trigger_status_pv;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target state control. */

/* Helper macros for looping through targets. */
#define _FOR_ALL_TARGETS(i, target) \
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++) \
        for (struct target_config *target = &targets[i]; target; target = NULL)
#define FOR_ALL_TARGETS(target) _FOR_ALL_TARGETS(UNIQUE_ID(), target)

#define FOR_SHARED_TARGETS(target) \
    FOR_ALL_TARGETS(target) \
        if (target->mode != MODE_SHARED) ; else

/* Recursive loop between arm_shared_targets() and update_global_state(). */
static void arm_shared_targets(void);


/* Updates state of target and corresponding PV. */
static void set_target_state(
    struct target_config *target, enum target_state state)
{
    if (target->state != state)
    {
        target->state = state;
        trigger_record(target->status_pv);
    }
}


/* Arms a single target by performing target specific preparation, recording
 * which target needs a hardware arm, and switch into armed state. */
static void do_arm_target(struct target_config *target, bool arm_mask[])
{
    if (target->state == STATE_IDLE)
    {
        arm_mask[target->target] = true;
        target->prepare_target(target);
        set_target_state(target, STATE_ARMED);
    }
}


/* Disarms a single target by performing a target specific stop, recording the
 * disarm flag, and switching into the target specific state. */
static void do_disarm_target(struct target_config *target, bool disarm_mask[])
{
    if (target->state == STATE_ARMED)
    {
        disarm_mask[target->target] = true;
        target->stop_target(target);
        set_target_state(target, target->disarmed_state);
    }
}


/* Compute the global state each time anything contributing to it changes. */
static void update_global_state(void)
{
    /* Compute corresponding global state: if any target is busy, report busy,
     * otherwise report armed if any target armed, otherwise all targets are
     * idle. */
    enum target_state new_state = STATE_IDLE;
    FOR_SHARED_TARGETS(target)
        if (target->state == STATE_BUSY)
            new_state = STATE_BUSY;
        else if (target->state == STATE_ARMED  &&  new_state == STATE_IDLE)
            new_state = STATE_ARMED;

    /* Update the new state. */
    if (new_state != trigger_status)
    {
        trigger_status = new_state;
        trigger_record(trigger_status_pv);

        /* On entering idle state force a retrigger if this mode is requested;
         * in this case we'll need to recompute the trigger status! */
        if (new_state == STATE_IDLE  &&  retrigger_mode)
            arm_shared_targets();
    }
}


static void update_trigger_sources(struct target_config *target)
{
    hw_read_trigger_sources(target->target, target->sources);
    trigger_record(target->update_sources);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger target state control entry points. */

/* Here we manage the state transitions for a single trigger target.  We report
 * three states, Idle, Armed, Busy, as reported by enum target_state.
 * Transitions between states are triggered by arm and disarm commands, and by
 * events received from the interrupt mechanism.
 *
 * All these methods are called with the target mutex lock held. */


/* This is called with mutex locked to arm the target. */
static bool arm_target(void *context, bool *value)
{
    bool arm_mask[TRIGGER_TARGET_COUNT] = { };
    do_arm_target(context, arm_mask);
    hw_write_trigger_arm(arm_mask);
    update_global_state();
    return true;
}


/* This is called with mutex locked to disarm the target.  Only valid when
 * target is in Armed state. */
static bool disarm_target(void *context, bool *value)
{
    bool disarm_mask[TRIGGER_TARGET_COUNT] = { };
    do_disarm_target(context, disarm_mask);
    hw_write_trigger_disarm(disarm_mask);
    update_global_state();
    return true;
}


/* Called with mutex locked to arm all shared targets. */
static void arm_shared_targets(void)
{
    bool arm_mask[TRIGGER_TARGET_COUNT] = { };
    FOR_SHARED_TARGETS(target)
        do_arm_target(target, arm_mask);
    hw_write_trigger_arm(arm_mask);
    update_global_state();
}


/* Called with mutex locked to disarm all shared targets. */
static void disarm_shared_targets(void)
{
    bool disarm_mask[TRIGGER_TARGET_COUNT] = { };
    FOR_SHARED_TARGETS(target)
        do_disarm_target(target, disarm_mask);
    hw_write_trigger_disarm(disarm_mask);
    update_global_state();
}


/* This is called with mutex locked to process trigger event. */
static void process_target_trigger(struct target_config *target)
{
    if (target->state == STATE_ARMED)
        set_target_state(target, STATE_BUSY);
    else if (target->state == STATE_IDLE)
        /* Normally the trigger takes us straight from Armed to Busy, but if we
         * see a trigger in Idle mode it's possible that the disarm was too
         * late.  In this case forcibly stop the target. */
        target->stop_target(target);
    else
        printf("Unexpected trigger %u %u\n", target->target, target->state);

    update_trigger_sources(target);
}


/* This is called with mutex locked to process target complete event. */
static void process_target_complete(struct target_config *target)
{
    if (target->state == STATE_BUSY)
    {
        set_target_state(target, STATE_IDLE);
        if (target->mode == MODE_REARM)
            /* Automatically re-arm where requested. */
            arm_target(target, NULL);
    }
    else
        printf("Unexpected complete %u %u\n", target->target, target->state);
}


void immediate_memory_capture(void)
{
    struct target_config *target = &targets[TRIGGER_DRAM];
    LOCK(mutex);
    hw_write_dram_capture_command(true, true);
    set_target_state(target, STATE_BUSY);
    update_global_state();
    UNLOCK(mutex);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger target specific configuration */


static const char *source_names[] = {
    "SOFT", "EXT", "PM", "ADC0", "ADC1", "SEQ0", "SEQ1", };


static bool write_target_mode(void *context, unsigned int *mode)
{
    struct target_config *target = context;
    target->mode = *mode;
    update_global_state();
    return true;
}


static bool write_enables(void *context, bool *value)
{
    struct target_config *target = context;
    hw_write_trigger_enable_mask(target->target, target->enables);
    return true;
}


static bool write_blanking(void *context, bool *value)
{
    struct target_config *target = context;
    hw_write_trigger_blanking_mask(target->target, target->blanking);
    return true;
}


static bool write_trigger_delay(void *context, unsigned int *value)
{
    struct target_config *target = context;
    hw_write_trigger_delay(target->target, *value);
    return true;
}


static void create_target(const char *prefix, struct target_config *target)
{
    WITH_NAME_PREFIX(prefix)
    {
        /* Create configuration control and event readbacks for the possible
         * trigger sources. */
        for (unsigned int i = 0; i < TRIGGER_SOURCE_COUNT; i ++)
        {
            WITH_NAME_PREFIX(source_names[i])
            {
                PUBLISH_READ_VAR(bi, "HIT", target->sources[i]);
                PUBLISH_WRITE_VAR_P(bo, "EN", target->enables[i]);
                PUBLISH_WRITE_VAR_P(bo, "BL", target->blanking[i]);
            }
        }

        /* These two PVs are processed whenever any of the corresponding
         * settings have been changed. */
        PUBLISH_C(bo, "EN", write_enables, target);
        PUBLISH_C(bo, "BL", write_blanking, target);

        /* Delay from trigger event to delivery to trigger target, in turns. */
        PUBLISH_C_P(ulongout, "DELAY", write_trigger_delay, target);

        /* Trigger mode control, all managed under trigger mutex. */
        PUBLISH_C_P(mbbo, "MODE", write_target_mode, target, .mutex = &mutex);
        PUBLISH_C(bo, "ARM", arm_target, target, .mutex = &mutex);
        PUBLISH_C(bo, "DISARM", disarm_target, target, .mutex = &mutex);

        target->update_sources = PUBLISH_TRIGGER("HIT");
        target->status_pv = PUBLISH_READ_VAR_I(mbbi, "STATUS", target->state);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared configuration. */


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


static bool write_blanking_window(void *context, unsigned int *value)
{
    struct channel_context *chan = context;
    hw_write_trigger_blanking_duration(chan->channel, *value);
    return true;
}


/* Called in response to hardware interrupt events signalling trigger and target
 * complete events. */
static void dispatch_target_events(void *context, struct interrupts interrupts)
{
    LOCK(mutex);
    FOR_ALL_TARGETS(target)
    {
        /* If we get both trigger and complete simultaneously we can process
         * them in sequence. */
        if (test_intersect(interrupts, target->trigger_interrupt))
            process_target_trigger(target);
        if (test_intersect(interrupts, target->complete_interrupt))
            process_target_complete(target);
    }
    update_global_state();
    UNLOCK(mutex);
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

        PUBLISH_ACTION("ARM", arm_shared_targets, .mutex = &mutex);
        PUBLISH_ACTION("DISARM", disarm_shared_targets, .mutex = &mutex);

        PUBLISH_WRITE_VAR_P(bo, "MODE", retrigger_mode, .mutex = &mutex);
        trigger_status_pv = PUBLISH_READ_VAR_I(mbbi, "STATUS", trigger_status);
    }

    FOR_CHANNEL_NAMES(channel, "TRG")
    {
        struct channel_context *chan = &channel_contexts[channel];
        create_target("SEQ", chan->sequencer);
        PUBLISH_C_P(ulongout, "BLANKING", write_blanking_window, chan);
    }

    /* We're interested in the trigger and complete events for each trigger
     * target, these are dispatched to the appropriate target. */
    register_event_handler(
        INTERRUPT_HANDLER_TRIGGER,
        INTERRUPTS(
            .dram_trigger = 1, .dram_done = 1,
            .seq_trigger  = 3, .seq_done  = 3),
        NULL, dispatch_target_events);

    return ERROR_OK;
}
