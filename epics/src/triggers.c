/* Trigger handling. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <pthread.h>
#include <time.h>
#include <errno.h>

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
#include "trigger_target.h"

#include "triggers.h"


/* User interface for trigger target. */
struct trigger_target_state {
    struct in_epics_record_mbbi *state_pv;

    struct epics_record *update_sources;    // Used to read sources[]
    bool sources[TRIGGER_SOURCE_COUNT];     // Interrupt sources seen on trigger

    bool enables[TRIGGER_SOURCE_COUNT];     // Which sources are enabled
    bool blanking[TRIGGER_SOURCE_COUNT];    // Which sources respect blanking

    /* Our interrupt sources.  We see two events of interest: trigger to target,
     * and target becomes idle.  The arming event is delivered separately
     * through software. */
    const struct interrupts trigger_interrupt;
    const struct interrupts complete_interrupt;

    struct trigger_target *target;

    const struct target_config config;
};


static struct in_epics_record_mbbi *shared_state_pv;
static struct in_epics_record_stringin *shared_targets_pv;

/* Used for monitoring the status of the trigger sources and blanking input. */
static bool sources_in[TRIGGER_SOURCE_COUNT];
static bool blanking_in;



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target specific configuration and implementation. */


static size_t get_seq_name(int axis, char name[], size_t length)
{
    return (size_t) snprintf(name, length, "%s:SEQ",
        get_axis_name(axis, system_config.lmbf_mode));
}


static void prepare_seq_target(int axis)
{
    prepare_sequencer(axis);
    prepare_detector(axis);
}

static enum target_state stop_seq_target(int axis)
{
    return TARGET_IDLE;
}

static size_t get_mem_name(int axis, char name[], size_t length)
{
    return (size_t) snprintf(name, length, "MEM");
}

static void prepare_mem_target(int axis)
{
    prepare_memory();
}

static enum target_state stop_mem_target(int axis)
{
    /* Stop the memory target by actually forcing a trigger! */
    bool fire[TRIGGER_TARGET_COUNT] = { [TRIGGER_DRAM] = true, };
    hw_write_trigger_fire(fire);
    return TARGET_ARMED;
}


static void set_target_state(void *context, enum target_state state)
{
    struct trigger_target_state *target = context;
    WRITE_IN_RECORD(mbbi, target->state_pv, state);
}


/* Array of possible targets. */
static struct trigger_target_state targets[TRIGGER_TARGET_COUNT] = {
    [TRIGGER_SEQ0] = {
        .config = {
            .target_id = TRIGGER_SEQ0,
            .axis = 0,
            .get_target_name = get_seq_name,
            .prepare_target = prepare_seq_target,
            .stop_target = stop_seq_target,
            .set_target_state = set_target_state,
        },
        .trigger_interrupt = { .seq_trigger = 1, },
        .complete_interrupt = { .seq_done = 1, },
    },
    [TRIGGER_SEQ1] = {
        .config = {
            .target_id = TRIGGER_SEQ1,
            .axis = 1,
            .get_target_name = get_seq_name,
            .prepare_target = prepare_seq_target,
            .stop_target = stop_seq_target,
            .set_target_state = set_target_state,
        },
        .trigger_interrupt = { .seq_trigger = 2, },
        .complete_interrupt = { .seq_done = 2, },
    },
    [TRIGGER_DRAM] = {
        .config = {
            .target_id = TRIGGER_DRAM,
            .axis = -1,          // Not valid for this target
            .get_target_name = get_mem_name,
            .prepare_target = prepare_mem_target,
            .stop_target = stop_mem_target,
            .set_target_state = set_target_state,
        },
        .trigger_interrupt = { .dram_trigger = 1, },
        .complete_interrupt = { .dram_done = 1, },
    },
};


static struct axis_context {
    int axis;
    struct trigger_target_state *target;
} axis_contexts[AXIS_COUNT] = {
    [0] = {
        .axis = 0,
        .target = &targets[TRIGGER_SEQ0],
    },
    [1] = {
        .axis = 1,
        .target = &targets[TRIGGER_SEQ1],
    },
};


/* Helper macros for looping through targets. */
#define _FOR_ALL_TARGETS(i, target) \
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++) \
        for (struct trigger_target_state *target = &targets[i]; \
            target; target = NULL)
#define FOR_ALL_TARGETS(target) _FOR_ALL_TARGETS(UNIQUE_ID(), target)


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/* When a trigger has been processed, update the sources to show where the
 * trigger came from. */
static void update_trigger_sources(struct trigger_target_state *target)
{
    hw_read_trigger_sources(target->config.target_id, target->sources);
    trigger_record(target->update_sources);
}


/* Called in response to hardware interrupt events signalling trigger and target
 * complete events. */
static void dispatch_target_events(void *context, struct interrupts interrupts)
{
    FOR_ALL_TARGETS(target)
    {
        /* If we get both trigger and complete simultaneously we can process
         * them in sequence. */
        if (test_intersect(interrupts, target->trigger_interrupt))
        {
            update_trigger_sources(target);
            trigger_target_trigger(target->target);
        }
        if (test_intersect(interrupts, target->complete_interrupt))
            trigger_target_complete(target->target);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger target specific configuration */


static const char *source_names[] = {
    "SOFT", "EXT", "PM", "ADC0", "ADC1", "SEQ0", "SEQ1", };


static bool write_enables(void *context, bool *value)
{
    struct trigger_target_state *target = context;
    hw_write_trigger_enable_mask(target->config.target_id, target->enables);
    return true;
}


static bool write_blanking(void *context, bool *value)
{
    struct trigger_target_state *target = context;
    hw_write_trigger_blanking_mask(target->config.target_id, target->blanking);
    return true;
}


static bool write_trigger_delay(void *context, unsigned int *value)
{
    struct trigger_target_state *target = context;
    hw_write_trigger_delay(target->config.target_id, *value);
    return true;
}


static bool write_target_mode(void *context, unsigned int *value)
{
    trigger_target_set_mode(context, *value);
    return true;
}

static bool arm_target(void *context, bool *value)
{
    trigger_target_arm(context);
    return true;
}

static bool disarm_target(void *context, bool *value)
{
    trigger_target_disarm(context);
    return true;
}


static void create_target(
    const char *prefix, struct trigger_target_state *target)
{
    WITH_NAME_PREFIX(prefix)
    {
        target->target = create_trigger_target(&target->config, target);

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

        /* Trigger mode control, all delegated to trigger_target. */
        PUBLISH_C_P(mbbo, "MODE", write_target_mode, target->target);
        PUBLISH_C(bo, "ARM", arm_target, target->target);
        PUBLISH_C(bo, "DISARM", disarm_target, target->target);

        target->update_sources = PUBLISH_TRIGGER("HIT");
        target->state_pv = PUBLISH_IN_VALUE_I(mbbi, "STATUS");
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared configuration. */


struct trigger_target *get_memory_trigger_ready_lock(void)
{
    return targets[TRIGGER_DRAM].target;
}

struct trigger_target *get_detector_trigger_ready_lock(int axis)
{
    return axis_contexts[axis].target->target;
}


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


static void set_shared_state(enum shared_target_state state)
{
    WRITE_IN_RECORD(mbbi, shared_state_pv, state);
}

static void set_shared_targets(const char *value)
{
    EPICS_STRING s;
    snprintf(s.s, sizeof(s.s), "%s", value);
    WRITE_IN_RECORD(stringin, shared_targets_pv, s);
}


bool get_sequencer_trigger_active(int axis)
{
    struct trigger_target *target = axis_contexts[axis].target->target;
    enum target_state state = trigger_target_get_state(target);
    return state != TARGET_IDLE;
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

        PUBLISH_WRITER_P(bo, "MODE", shared_trigger_set_mode);
        PUBLISH_ACTION("ARM", shared_trigger_target_arm);
        PUBLISH_ACTION("DISARM", shared_trigger_target_disarm);

        shared_state_pv = PUBLISH_IN_VALUE_I(mbbi, "STATUS");
        shared_targets_pv = PUBLISH_IN_VALUE_I(stringin, "SHARED");

        PUBLISH_WRITER_P(ulongout, "BLANKING",
            hw_write_trigger_blanking_duration);
    }

    FOR_AXIS_NAMES(axis, "TRG", system_config.lmbf_mode)
        create_target("SEQ", axis_contexts[axis].target);

    /* We're interested in the trigger and complete events for each trigger
     * target, these are dispatched to the appropriate target. */
    unsigned int seq_mask = system_config.lmbf_mode ? 1 : 3;
    register_event_handler(
        INTERRUPT_HANDLER_TRIGGER,
        INTERRUPTS(
            .dram_trigger = 1, .dram_done = 1,
            .seq_trigger = seq_mask & 3, .seq_done = seq_mask & 3),
        NULL, dispatch_target_events);

    /* Initialise the condition. */
    return initialise_trigger_targets(set_shared_state, set_shared_targets);
}
