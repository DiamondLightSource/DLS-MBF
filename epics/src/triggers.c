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
#include "timespec.h"

#include "triggers.h"


enum target_mode {
    MODE_ONE_SHOT,      // Normal single shot operation
    MODE_REARM,         // Rearm this target after trigger complete
    MODE_SHARED,        // Shared trigger operation
};


enum target_state {
    STATE_IDLE,         // Trigger ready for arming
    STATE_ARMED,        // Waiting for trigger
    STATE_BUSY,         // Trigger received, target processing trigger
    STATE_LOCKED,       // Arm request seen, but trigger locked
};


/* Configuration for a single trigger target. */
struct target_config {
    enum target_mode mode;
    bool dont_rearm;            // Temporary suppression of auto-rearm

    unsigned int state;         // enum target_state
    struct epics_record *state_pv;

    struct epics_record *update_sources;    // Used to read sources[]
    bool sources[TRIGGER_SOURCE_COUNT];     // Interrupt sources seen on trigger

    bool enables[TRIGGER_SOURCE_COUNT];     // Which sources are enabled
    bool blanking[TRIGGER_SOURCE_COUNT];    // Which sources respect blanking

    /* Number of read locks current active. */
    unsigned int lock_count;


    /* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
    /* Fixed target identification and behaviour definitions. */

    /* Target identity. */
    const enum trigger_target_id target;
    const int channel;          // Not valid for DRAM target

    /* Target specific methods and variables. */
    void (*const prepare_target)(struct target_config *target);
    void (*const stop_target)(struct target_config *target);
    const enum target_state disarmed_state;

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

static void prepare_mem_target(struct target_config *target)
{
    prepare_memory();
}

static void stop_mem_target(struct target_config *target)
{
    /* Stop the memory target by actually forcing a trigger! */
    bool fire[TRIGGER_TARGET_COUNT] = { [TRIGGER_DRAM] = true, };
    hw_write_trigger_fire(fire);
}


/* Array of possible targets. */
struct target_config targets[TRIGGER_TARGET_COUNT] = {
    [TRIGGER_SEQ0] = {
        .target = TRIGGER_SEQ0,
        .channel = 0,
        .prepare_target = prepare_seq_target,
        .disarmed_state = STATE_IDLE,
        .trigger_interrupt = { .seq_trigger = 1, },
        .complete_interrupt = { .seq_done = 1, },
    },
    [TRIGGER_SEQ1] = {
        .target = TRIGGER_SEQ1,
        .channel = 1,
        .prepare_target = prepare_seq_target,
        .disarmed_state = STATE_IDLE,
        .trigger_interrupt = { .seq_trigger = 2, },
        .complete_interrupt = { .seq_done = 2, },
    },
    [TRIGGER_DRAM] = {
        .target = TRIGGER_DRAM,
        .channel = -1,          // Not valid for this target
        .prepare_target = prepare_mem_target,
        .stop_target = stop_mem_target,
        .disarmed_state = STATE_ARMED,  // A trigger is on its way!
        .trigger_interrupt = { .dram_trigger = 1, },
        .complete_interrupt = { .dram_done = 1, },
    },
};


struct channel_context {
    int channel;
    struct target_config *target;
    unsigned int turn_clock_offset;
} channel_contexts[CHANNEL_COUNT] = {
    [0] = {
        .channel = 0,
        .target = &targets[TRIGGER_SEQ0],
    },
    [1] = {
        .channel = 1,
        .target = &targets[TRIGGER_SEQ1],
    },
};


/* All trigger management is done under a single shared mutex.  In principle we
 * could have a mutex per target configuration, but then the shared trigger
 * management becomes somewhat painful! */
static pthread_mutex_t trigger_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t trigger_event;

/* Used for monitoring the status of the trigger sources and blanking input. */
static bool sources_in[TRIGGER_SOURCE_COUNT];
static bool blanking_in;

/* Used for shared record aggregate status. */
static bool retrigger_mode = false;
static bool dont_rearm = true;     // One shot suppression of rearm on disarm
static unsigned int trigger_state;
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
        trigger_record(target->state_pv);
    }
}


/* Arms a single target by performing target specific preparation, recording
 * which target needs a hardware arm, and switch into armed state.  If the
 * arming does not actually occur then false is returned. */
static bool do_arm_target(struct target_config *target)
{
    bool armed = false;
    if (target->state == STATE_IDLE  ||  target->state == STATE_LOCKED)
    {
        if (target->lock_count == 0)
        {
            target->dont_rearm = false;
            target->prepare_target(target);
            set_target_state(target, STATE_ARMED);
            armed = true;
        }
        else
            /* Don't arm now, but maybe later. */
            set_target_state(target, STATE_LOCKED);
    }
    return armed;
}


/* Disarms a single target by performing a target specific stop, recording the
 * disarm flag, and switching into the target specific state. */
static void do_disarm_target(struct target_config *target)
{
    target->dont_rearm = true;
    if (target->state == STATE_ARMED)
    {
        if (target->stop_target)
            target->stop_target(target);
        set_target_state(target, target->disarmed_state);
    }
    else if (target->state == STATE_LOCKED)
        set_target_state(target, STATE_IDLE);
}


/* We compute the global state based on the following rules across all the
 * shared targets:
 *
 *  All targets IDLE => IDLE
 *  Any target BUSY  => BUSY
 *  Any target LOCKED => LOCKED
 *  Any target ARMED, all others IDLE => ARMED
 *
 * Note that BUSY and LOCKED are inconsistent.  We should only ever have all
 * targets LOCKED. */
static enum target_state compute_global_state(void)
{
    int busy = 0;
    int armed = 0;
    int locked = 0;
    FOR_SHARED_TARGETS(target)
    {
        switch (target->state)
        {
            case STATE_BUSY:    busy += 1;      break;
            case STATE_ARMED:   armed += 1;     break;
            case STATE_LOCKED:  locked += 1;    break;
        }
    }

    /* Now compute the new state. */
    enum target_state state = STATE_IDLE;
    if (busy > 0)
        state = STATE_BUSY;
    else if (armed > 0)
        state = STATE_ARMED;
    else if (locked > 0)
        state = STATE_LOCKED;

    return state;
}


/* Returns true if any of the shared targets are currently locked. */
static bool check_locked_targets(void)
{
    bool any_locked = false;
    FOR_SHARED_TARGETS(target)
        if (target->lock_count > 0)
            any_locked = true;
    return any_locked;
}


static void set_global_state(enum target_state state)
{
    if (state != trigger_state)
    {
        trigger_state = state;
        trigger_record(trigger_status_pv);
    }
}


/* Compute the global state each time anything contributing to it changes. */
static void update_global_state(void)
{
    enum target_state new_state = compute_global_state();
    set_global_state(new_state);

    /* We need to rearm the shared targets on entering the idle state, and on
     * completion of locked targets. */
    bool do_rearm =
        /* Retrigger when entering idle state. */
        (new_state == STATE_IDLE  &&  retrigger_mode  &&  !dont_rearm)  ||
        /* Do a true trigger in locked state if no locks are held. */
        (new_state == STATE_LOCKED  &&  !check_locked_targets());
    if (do_rearm)
        arm_shared_targets();
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
 * All these methods are called with the target trigger_mutex lock held. */


static void get_target_mask(struct target_config *target, bool mask[])
{
    memset(mask, false, sizeof(bool) * TRIGGER_TARGET_COUNT);
    mask[target->target] = true;
}

static void get_shared_mask(bool mask[])
{
    memset(mask, false, sizeof(bool) * TRIGGER_TARGET_COUNT);
    FOR_SHARED_TARGETS(target)
        mask[target->target] = true;
}

/* Called with trigger_mutex locked to arm all shared targets. */
static void arm_shared_targets(void)
{
    dont_rearm = false;

    /* Check if any of the targets we want to arm are locked.  If so we'll need
     * to back off and rely on update_global_state() to do this later.  We'll
     * push any locked targets into the delayed arm mode. */
    bool any_locked = check_locked_targets();

    if (any_locked)
    {
        /* If any targets are locked then put them all in the locked state. */
        FOR_SHARED_TARGETS(target)
            set_target_state(target, STATE_LOCKED);
        set_global_state(STATE_LOCKED);
    }
    else
    {
        /* This is the successful case, all targets are ready to arm. */
        FOR_SHARED_TARGETS(target)
            do_arm_target(target);

        bool arm_mask[TRIGGER_TARGET_COUNT];
        get_shared_mask(arm_mask);
        hw_write_trigger_arm(arm_mask);

        set_global_state(STATE_ARMED);
    }
}


/* Called with trigger_mutex locked to disarm all shared targets. */
static void disarm_shared_targets(void)
{
    dont_rearm = trigger_state != STATE_IDLE;

    bool disarm_mask[TRIGGER_TARGET_COUNT];
    get_shared_mask(disarm_mask);
    hw_write_trigger_disarm(disarm_mask);

    FOR_SHARED_TARGETS(target)
        do_disarm_target(target);
    update_global_state();
}


/* This is called with trigger_mutex locked to arm the target. */
static bool arm_target(void *context, bool *value)
{
    struct target_config *target = context;
    if (target->mode == MODE_SHARED)
        arm_shared_targets();
    else
    {
        if (do_arm_target(target))
        {
            bool arm_mask[TRIGGER_TARGET_COUNT];
            get_target_mask(target, arm_mask);
            hw_write_trigger_arm(arm_mask);
        }

        update_global_state();
    }
    return true;
}


/* This is called with trigger_mutex locked to disarm the target.  Only valid
 * when target is in Armed state. */
static bool disarm_target(void *context, bool *value)
{
    struct target_config *target = context;
    if (target->mode == MODE_SHARED)
        disarm_shared_targets();
    else
    {
        bool disarm_mask[TRIGGER_TARGET_COUNT];
        get_target_mask(target, disarm_mask);
        hw_write_trigger_disarm(disarm_mask);

        do_disarm_target(target);

        update_global_state();
    }
    return true;
}


/* Called on transition from target locked for readout to unlocked, performs
 * rearming where possible, updates global state if appropriate. */
static void process_target_unlocked(struct target_config *target)
{
    /* When the last lock has gone, if we're in the Locked state and not shared
     * then we can perform the posponed arming of our target. */
    if (target->state == STATE_LOCKED  &&  target->mode != MODE_SHARED)
    {
        target->state = STATE_IDLE;
        arm_target(target, NULL);
    }
    update_global_state();
}


/* Controls target rearming mode and refresh global state as appropriate. */
static bool write_target_mode(void *context, unsigned int *mode)
{
    struct target_config *target = context;
    target->mode = *mode;

    /* Don't leave the target in locked state if not applicable. */
    if (target->mode != MODE_SHARED  &&  target->state == STATE_LOCKED  &&
         target->lock_count == 0)
        set_target_state(target, STATE_IDLE);

    update_global_state();
    return true;
}


/* This is called with trigger_mutex locked to process trigger event. */
static void process_target_trigger(struct target_config *target)
{
    if (target->state == STATE_ARMED)
        set_target_state(target, STATE_BUSY);
    else
        printf("Unexpected trigger %u %u\n", target->target, target->state);

    update_trigger_sources(target);
}


/* This is called with trigger_mutex locked to process target complete event. */
static void process_target_complete(struct target_config *target)
{
    if (target->state == STATE_BUSY)
    {
        set_target_state(target, STATE_IDLE);
        if (target->mode == MODE_REARM  &&  !target->dont_rearm)
            /* Automatically re-arm where requested and possible. */
            arm_target(target, NULL);

        /* On completion let all listening locks know that something may have
         * changed. */
        ASSERT_PTHREAD(pthread_cond_broadcast(&trigger_event));
    }
    else
        printf("Unexpected complete %u %u\n", target->target, target->state);
}


/* Called in response to hardware interrupt events signalling trigger and target
 * complete events. */
static void dispatch_target_events(void *context, struct interrupts interrupts)
{
    WITH_MUTEX(trigger_mutex)
    {
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
    }
}


void immediate_memory_capture(void)
{
    struct target_config *target = &targets[TRIGGER_DRAM];
    bool fire[TRIGGER_TARGET_COUNT] = { [TRIGGER_DRAM] = true, };
    WITH_MUTEX(trigger_mutex)
    {
        if (target->lock_count == 0  &&  target->state == STATE_IDLE)
        {
            hw_write_dram_capture_command(true, false);
            hw_write_trigger_fire(fire);
            set_target_state(target, STATE_ARMED);
            target->dont_rearm = true;      // Ensure a one-shot capture!
            update_global_state();
        }
        else
            log_message("Ignoring memory capture while busy");
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger locking. */

#define POLL_INTERVAL   10          // Seconds


struct target_config *get_memory_trigger_ready_lock(void)
{
    return &targets[TRIGGER_DRAM];
}

struct target_config *get_detector_trigger_ready_lock(int channel)
{
    return channel_contexts[channel].target;
}


/* Returns true if we are now ready to deliver data without interference, ie if
 * the underlying state is idle. */
static bool check_trigger_ready(struct target_config *target)
{
    return target->state == STATE_IDLE  ||  target->state == STATE_LOCKED;
}


/* Waits for event or deadline, returns true if deadline reached. */
static bool pwait_deadline(
    pthread_mutex_t *mutex, pthread_cond_t *signal,
    const struct timespec *deadline)
{
    int rc = pthread_cond_timedwait(signal, mutex, deadline);
    if (rc == ETIMEDOUT)
        return true;
    else
    {
        ASSERT_PTHREAD(rc);
        return false;
    }
}


/* This is the complex locking path where we wait with repeated polls for the
 * trigger to become ready. */
static error__t wait_trigger_ready(
    struct target_config *target, unsigned int timeout,
    error__t (*poll)(void *context), void *context)
{
    /* The main complication here is that we need to wait with repeated wakeups
     * so that we can ensure that poll() is called, this is required so that we
     * don't just hang forever. */
    struct timespec now = get_current_time();
    struct timespec final_deadline =
        add_timespec(now, interval_to_timespec((int) timeout, MSECS));
    struct timespec delta = interval_to_timespec(POLL_INTERVAL, 1);

    error__t error = ERROR_OK;
    struct timespec next_tick = now;
    do {
        /* Compute the deadline for the next wait. */
        next_tick = earliest_timespec(
            add_timespec(next_tick, delta), final_deadline);
        bool last_tick = compare_timespec_eq(next_tick, final_deadline);

        /* Wait to reach the current deadline. */
        bool timed_out, ready;
        do {
            timed_out = pwait_deadline(
                &trigger_mutex, &trigger_event, &next_tick);
            ready = check_trigger_ready(target);
        } while (!ready  &&  !timed_out);

        /* If we're ready we're done, if we run out of ticks we've timed out,
         * otherwise poll for client disconnect and go round and wait again. */
        if (ready)
            break;
        else if (last_tick)
            error = FAIL_("Timed out waiting for trigger");
        else
            error = poll(context);
    } while (!error);
    return error;
}


/* Must be called under lock.  If the lock count reaches zero and there's a
 * pending arm request then it is honoured. */
static void decrement_trigger_lock_count(struct target_config *target)
{
    target->lock_count -= 1;
    if (target->lock_count == 0)
        process_target_unlocked(target);
}


error__t lock_trigger_ready(
    struct target_config *target, unsigned int timeout,
    error__t (*poll)(void *context), void *context)
{
    error__t error;
    WITH_MUTEX(trigger_mutex)
    {
        if (check_trigger_ready(target))
        {
            target->lock_count += 1;
            error = ERROR_OK;
        }
        else if (timeout == 0)
            error = FAIL_("Trigger not ready");
        else
        {
            /* Add to the lock count while we wait.  This ensures that when we
             * do become ready the trigger will remain locked. */
            target->lock_count += 1;
            error = wait_trigger_ready(target, timeout, poll, context);
            if (error)
                decrement_trigger_lock_count(target);
        }
    }
    return error;
}


void unlock_trigger_ready(struct target_config *target)
{
    WITH_MUTEX(trigger_mutex)
        decrement_trigger_lock_count(target);
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger target specific configuration */


static const char *source_names[] = {
    "SOFT", "EXT", "PM", "ADC0", "ADC1", "SEQ0", "SEQ1", };


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

        /* Trigger mode control, all managed under trigger trigger_mutex. */
        PUBLISH_C_P(mbbo, "MODE", write_target_mode, target,
            .mutex = &trigger_mutex);
        PUBLISH_C(bo, "ARM", arm_target, target, .mutex = &trigger_mutex);
        PUBLISH_C(bo, "DISARM", disarm_target, target, .mutex = &trigger_mutex);

        target->update_sources = PUBLISH_TRIGGER("HIT");
        target->state_pv = PUBLISH_READ_VAR_I(mbbi, "STATUS", target->state);
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


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Turn clock control. */

static pthread_mutex_t turn_clock_mutex = PTHREAD_MUTEX_INITIALIZER;

enum turn_clock_status {
    TURN_CLOCK_UNSYNC,
    TURN_CLOCK_ARMED,
    TURN_CLOCK_SYNCED
};
static unsigned int turn_clock_status = TURN_CLOCK_UNSYNC;
static unsigned int turn_clock_turns;
static unsigned int turn_clock_errors;

static void start_turn_sync(void)
{
    hw_write_turn_clock_sync();
    turn_clock_status = TURN_CLOCK_ARMED;
}

static void poll_turn_state(void)
{
    hw_read_turn_clock_counts(&turn_clock_turns, &turn_clock_errors);
    struct trigger_status status;
    hw_read_trigger_status(&status);
    if (turn_clock_status == TURN_CLOCK_ARMED  &&  !status.sync_busy)
        turn_clock_status = TURN_CLOCK_SYNCED;
}


static bool write_turn_offset(void *context, unsigned int *offset)
{
    if (*offset < system_config.bunches_per_turn)
    {
        struct channel_context *chan = context;
        struct channel_context *other_chan =
            system_config.lmbf_mode ? &channel_contexts[1] : NULL;

        chan->turn_clock_offset = *offset;
        hw_write_turn_clock_offset(chan->channel, *offset);
        if (other_chan)
        {
            other_chan->turn_clock_offset = *offset;
            hw_write_turn_clock_offset(other_chan->channel, *offset);
        }

        unsigned int offsets[CHANNEL_COUNT] = {
            [0] = channel_contexts[0].turn_clock_offset,
            [1] = channel_contexts[1].turn_clock_offset,
        };
        set_memory_turn_clock_offsets(offsets);
        return true;
    }
    else
        /* Can't do this.  Actually, *really* can't do this, we'll freeze the
         * system if we try! */
        return false;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* Initialise the condition attribute to use the monotonic clock.  This means we
 * shouldn't have problems if the real time clock starts dancing about. */
static error__t pwait_initialise(pthread_cond_t *signal)
{
    pthread_condattr_t attr;
    return
        TEST_PTHREAD(pthread_condattr_init(&attr))  ?:
        TEST_PTHREAD(pthread_condattr_setclock(&attr, CLOCK_MONOTONIC))  ?:
        TEST_PTHREAD(pthread_cond_init(signal, &attr));
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

        PUBLISH_WRITE_VAR_P(bo, "MODE", retrigger_mode,
            .mutex = &trigger_mutex);
        PUBLISH_ACTION("ARM", arm_shared_targets, .mutex = &trigger_mutex);
        PUBLISH_ACTION("DISARM", disarm_shared_targets,
            .mutex = &trigger_mutex);

        trigger_status_pv = PUBLISH_READ_VAR_I(mbbi, "STATUS", trigger_state);

        WITH_NAME_PREFIX("TURN")
        {
            PUBLISH_ACTION("SYNC", start_turn_sync, .mutex = &turn_clock_mutex);
            PUBLISH_ACTION("POLL", poll_turn_state, .mutex = &turn_clock_mutex);
            PUBLISH_WRITER_P(ulongout, "DELAY", hw_write_turn_clock_idelay);
            PUBLISH_READ_VAR(mbbi, "STATUS", turn_clock_status);
            PUBLISH_READ_VAR(ulongin, "TURNS", turn_clock_turns);
            PUBLISH_READ_VAR(ulongin, "ERRORS", turn_clock_errors);
        }
    }

    FOR_CHANNEL_NAMES(channel, "TRG", system_config.lmbf_mode)
    {
        struct channel_context *chan = &channel_contexts[channel];
        create_target("SEQ", chan->target);
        PUBLISH_C_P(ulongout, "BLANKING", write_blanking_window, chan);
        PUBLISH_C_P(ulongout, "TURN:OFFSET", write_turn_offset, chan);
    }

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
    return pwait_initialise(&trigger_event);
}
