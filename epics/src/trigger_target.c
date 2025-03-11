/* Trigger target handling. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <pthread.h>
#include <time.h>
#include <errno.h>

#include "error.h"

#include "hardware.h"
#include "common.h"
#include "timespec.h"

#include "trigger_target.h"


/* Configuration for a single trigger target. */
struct trigger_target {
    enum target_mode mode;
    bool dont_rearm;                    // Temporary suppression of auto-rearm

    enum target_state state;

    /* Number of read locks current active. */
    unsigned int lock_count;

    /* Fixed target identification and behaviour definitions. */
    const struct target_config *config;
    struct trigger_target_state *context;
};


/* This gathers the state required to manage a set of shared triggers. */
struct shared_triggers {
    bool retrigger_mode;
    bool dont_rearm;
    enum shared_target_state state;
    void (*set_shared_state)(enum shared_target_state state);
    void (*set_shared_targets)(const char *targets);
};


static struct trigger_target targets[TRIGGER_TARGET_COUNT];

static struct shared_triggers shared = {
    .dont_rearm = true,
};


/* All trigger management is done under a single shared mutex.  In principle we
 * could have a mutex per target configuration, but then the shared trigger
 * management becomes somewhat painful! */
static pthread_mutex_t trigger_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t trigger_event;



/* Helper macros for looping through targets. */
#define _FOR_ALL_TARGETS(i, target) \
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++) \
        for (struct trigger_target *target = &targets[i]; target; target = NULL)
#define FOR_ALL_TARGETS(target) _FOR_ALL_TARGETS(UNIQUE_ID(), target)

#define FOR_SHARED_TARGETS(target) \
    FOR_ALL_TARGETS(target) \
        if (target->mode != MODE_SHARED) ; else


/* Wrapper for calling target method.  Automatically passes context as the first
 * argument, passes all other arguments through. */
#define CALL(method, target, args...) \
    target->config->method(target->context, ## args)


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target state control. */

/* Updates state of target and corresponding PV. */
static void set_target_state(
    struct trigger_target *target, enum target_state state)
{
    if (state != target->state)
    {
        target->state = state;
        CALL(set_target_state, target, state);
    }
}


/* Sets shared target state and updates associated PV. */
static void set_global_state(enum shared_target_state state)
{
    if (state != shared.state)
    {
        shared.state = state;
        shared.set_shared_state(state);
    }
}


static void update_shared_targets(void)
{
    char value[40] = "";
    char *out = value;
    bool first = true;
    FOR_SHARED_TARGETS(target)
    {
        if (!first)
            out += snprintf(out, (size_t) (value + sizeof(value) - out), " ");
        out += CALL(get_target_name,
            target, out, (size_t) (value + sizeof(value) - out));
        first = false;
    }
    shared.set_shared_targets(value);
}


/* We compute the global state based on the following rules across all the
 * shared targets according to the counts of the number of targets in each of
 * the corresponding states:
 *
 *  locked  armed   busy    idle    global_status
 *  >0      >0                      INVALID locked and armed should not occur
 *  >0      =0      >0              INVALID locked and busy should not occur
 *  >0      =0      =0              LOCKED  waiting for read lock to complete
 *  =0      >0      >0              MIXED   a target failed to fire
 *  =0      >0      =0      >0      MIXED   a target failed to fire
 *  =0      >0      =0      =0      ARMED   all targets armed
 *  =0      =0      >0              BUSY    at least one busy, rest idle
 *  =0      =0      =0              IDLE    nothing to do or all idle
 *
 * Note that BUSY and LOCKED are inconsistent.  We should only ever have all
 * targets LOCKED. */
static enum shared_target_state compute_global_state(void)
{
    /* See which of the states are set. */
    bool busy = false;
    bool armed = false;
    bool locked = false;
    bool idle = false;
    FOR_SHARED_TARGETS(target)
    {
        switch (target->state)
        {
            case TARGET_BUSY:   busy = true;    break;
            case TARGET_ARMED:  armed = true;   break;
            case TARGET_LOCKED: locked = true;  break;
            case TARGET_IDLE:   idle = true;    break;
        }
    }

    /* Now compute the new state according to the tabulated rules above. */
    if (locked)
        if (armed  ||  busy)
            return SHARED_INVALID;  // Invalid combination of triggers
        else
            return SHARED_LOCKED;   // At lease one locked, rest idle
    else if (armed)
        if (busy  ||  idle)
            return SHARED_MIXED;    // Somebody failed to trigger
        else
            return SHARED_ARMED;    // Everyone is waiting for trigger
    else if (busy)
        return SHARED_BUSY;         // Waiting for processing to complete
    else
        return SHARED_IDLE;         // All idle
}


/* Returns true if any of the shared targets are currently locked. */
static bool any_locked_targets(void)
{
    bool any_locked = false;
    FOR_SHARED_TARGETS(target)
        if (target->lock_count > 0)
            any_locked = true;
    return any_locked;
}


/* Returns true if there are any shared targets. */
static bool any_shared_targets(void)
{
    bool any_shared = false;
    FOR_SHARED_TARGETS(target)
        any_shared = true;
    return any_shared;
}


static void get_target_mask(struct trigger_target *target, bool mask[])
{
    memset(mask, false, sizeof(bool) * TRIGGER_TARGET_COUNT);
    mask[target->config->target_id] = true;
}


static void get_shared_mask(bool mask[])
{
    memset(mask, false, sizeof(bool) * TRIGGER_TARGET_COUNT);
    FOR_SHARED_TARGETS(target)
        mask[target->config->target_id] = true;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger target state control entry points. */

/* Arms a single target by performing target specific preparation, recording
 * which target needs a hardware arm, and switch into armed state.  If the
 * arming does not actually occur then false is returned. */
static bool do_arm_target(struct trigger_target *target)
{
    bool armed = false;
    if (target->state == TARGET_IDLE  ||  target->state == TARGET_LOCKED)
    {
        if (target->lock_count == 0)
        {
            target->dont_rearm = false;
            CALL(prepare_target, target);
            set_target_state(target, TARGET_ARMED);
            armed = true;
        }
        else
            /* Don't arm now, but maybe later. */
            set_target_state(target, TARGET_LOCKED);
    }
    return armed;
}

static void do_arm_target_hardware(struct trigger_target *target)
{
    bool arm_mask[TRIGGER_TARGET_COUNT];
    get_target_mask(target, arm_mask);
    hw_write_trigger_arm(arm_mask);
}

static void do_arm_shared_hardware(void)
{
    bool arm_mask[TRIGGER_TARGET_COUNT];
    get_shared_mask(arm_mask);
    hw_write_trigger_arm(arm_mask);
}


/* Disarms a single target by performing a target specific stop, recording the
 * disarm flag, and switching into the target specific state. */
static void do_disarm_target(struct trigger_target *target)
{
    target->dont_rearm = true;
    if (target->state == TARGET_ARMED)
        set_target_state(target, CALL(stop_target, target));
    else if (target->state == TARGET_LOCKED)
        set_target_state(target, TARGET_IDLE);
}

static void do_disarm_target_hardware(struct trigger_target *target)
{
    bool disarm_mask[TRIGGER_TARGET_COUNT];
    get_target_mask(target, disarm_mask);
    hw_write_trigger_disarm(disarm_mask);
}

static void do_disarm_shared_hardware(void)
{
    bool disarm_mask[TRIGGER_TARGET_COUNT];
    get_shared_mask(disarm_mask);
    hw_write_trigger_disarm(disarm_mask);
}


/* Here we manage the state transitions for a single trigger target.  We report
 * three states, Idle, Armed, Busy, as reported by enum target_state.
 * Transitions between states are triggered by arm and disarm commands, and by
 * events received from the interrupt mechanism.
 *
 * All these methods are called with the target trigger_mutex lock held. */


/* Called with trigger_mutex locked to arm all shared targets. */
static void arm_shared_targets(void)
{
    shared.dont_rearm = false;

    /* Only permit arming if the shared state is idle. */
    if (shared.state != SHARED_IDLE  &&  shared.state != SHARED_LOCKED)
        log_message("Unable to arm in state %d", shared.state);

    /* Check if any of the targets we want to arm are locked.  If so we'll need
     * to back off and rely on update_global_state() to do this later.  We'll
     * push any locked targets into the delayed arm mode. */
    else if (any_locked_targets())
    {
        /* If any targets are locked then put them all in the locked state.
         * We're guaranteed that one will be in this state. */
        FOR_SHARED_TARGETS(target)
            if (target->lock_count > 0)
                set_target_state(target, TARGET_LOCKED);
        set_global_state(SHARED_LOCKED);
    }
    else if (any_shared_targets())
    {
        /* This is the successful case, all targets are ready to arm. */
        FOR_SHARED_TARGETS(target)
            do_arm_target(target);
        do_arm_shared_hardware();
        set_global_state(SHARED_ARMED);
    }
}


/* Compute the global state each time anything contributing to it changes and
 * trigger any required re-arming. Must be called when the state of a shared
 * target or the set of shared targets changes. */
static void update_global_state(void)
{
    enum shared_target_state new_state = compute_global_state();
    set_global_state(new_state);

    /* We need to rearm the shared targets on entering the idle state, and on
     * completion of locked targets. */
    bool do_rearm =
        /* Retrigger when entering idle state. */
        (new_state == SHARED_IDLE  &&
            shared.retrigger_mode  &&  !shared.dont_rearm)  ||
        /* Do a true trigger in locked state if no locks are held. */
        (new_state == SHARED_LOCKED  &&  !any_locked_targets());
    if (do_rearm)
        arm_shared_targets();
}


/* Called with trigger_mutex locked to disarm all shared targets. */
static void disarm_shared_targets(void)
{
    shared.dont_rearm = true;

    do_disarm_shared_hardware();
    FOR_SHARED_TARGETS(target)
        do_disarm_target(target);
    update_global_state();
}


static void arm_target(struct trigger_target *target)
{
    if (target->mode == MODE_SHARED)
        arm_shared_targets();
    else
    {
        if (do_arm_target(target))
            do_arm_target_hardware(target);
    }
}


static void disarm_target(struct trigger_target *target)
{
    if (target->mode == MODE_SHARED)
        disarm_shared_targets();
    else
    {
        do_disarm_target_hardware(target);
        do_disarm_target(target);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target state change: triggers, completion, unlocking. */

void trigger_target_trigger(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
        if (target->state == TARGET_ARMED)
        {
            set_target_state(target, TARGET_BUSY);
            if (target->mode == MODE_SHARED)
                update_global_state();
        }
        else
            log_message("Unexpected trigger %u %u",
                target->config->target_id, target->state);
}


void trigger_target_complete(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
        if (target->state == TARGET_BUSY)
        {
            set_target_state(target, TARGET_IDLE);

            if (target->mode == MODE_SHARED)
                update_global_state();
            else if (target->mode == MODE_REARM  &&  !target->dont_rearm)
                /* Automatically re-arm where requested and possible. */
                arm_target(target);
            else if (target->mode == MODE_FREE_RUN  &&  !target->dont_rearm)
            {
                /* Automatically re-arm where requested and possible. */
                arm_target(target);
                hw_write_trigger_soft_trigger();
            }

            /* On completion let all listening locks know that something may
             * have changed. */
            ASSERT_PTHREAD(pthread_cond_broadcast(&trigger_event));
        }
        else
            log_message("Unexpected complete %u %u",
                target->config->target_id, target->state);
}


/* Called on transition from target locked for readout to unlocked, performs
 * rearming where possible, updates global state if appropriate. */
static void process_target_unlocked(struct trigger_target *target)
{
    if (target->mode == MODE_SHARED)
        update_global_state();
    else if (target->state == TARGET_LOCKED)
        /* When the last lock has gone, if we're in the Locked state and not
         * shared then we can perform the posponed arming of our target. */
        arm_target(target);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* User actions: arm, disarm, set_mode. */

/* Single trigger. */

void trigger_target_arm(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
        arm_target(target);
}


void trigger_target_disarm(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
        disarm_target(target);
}


void trigger_target_set_mode(
    struct trigger_target *target, enum target_mode mode)
{
    WITH_MUTEX(trigger_mutex)
    {
        target->mode = mode;
        update_global_state();
        update_shared_targets();
    }
}


enum target_state trigger_target_get_state(struct trigger_target *target)
{
    return target->state;
}


/* Shared trigger. */

void shared_trigger_target_arm(void)
{
    WITH_MUTEX(trigger_mutex)
        arm_shared_targets();
}


void shared_trigger_target_disarm(void)
{
    WITH_MUTEX(trigger_mutex)
        disarm_shared_targets();
}


void shared_trigger_set_mode(bool mode)
{
    WITH_MUTEX(trigger_mutex)
        shared.retrigger_mode = mode;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger locking. */

#define POLL_INTERVAL   10          // Seconds


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


/* Returns true if we are now ready to deliver data without interference, ie if
 * the underlying state is idle. */
static bool check_trigger_ready(struct trigger_target *target)
{
    return target->state == TARGET_IDLE  ||  target->state == TARGET_LOCKED;
}


/* This is the complex locking path where we wait with repeated polls for the
 * trigger to become ready. */
static error__t wait_trigger_ready(
    struct trigger_target *target, unsigned int timeout,
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
static void decrement_trigger_lock_count(struct trigger_target *target)
{
    target->lock_count -= 1;
    if (target->lock_count == 0)
        process_target_unlocked(target);
}


error__t lock_trigger_ready(
    struct trigger_target *target, unsigned int timeout,
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


void unlock_trigger_ready(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
        decrement_trigger_lock_count(target);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Special. */

bool immediate_memory_capture(bool ignored)
{
    struct trigger_target *target = &targets[TRIGGER_DRAM];
    bool fire[TRIGGER_TARGET_COUNT] = { [TRIGGER_DRAM] = true, };
    bool ready;
    WITH_MUTEX(trigger_mutex)
    {
        ready = target->lock_count == 0  &&  target->state == TARGET_IDLE;
        if (ready)
        {
            hw_write_dram_capture_command(true, false);
            hw_write_trigger_fire(fire);
            set_target_state(target, TARGET_ARMED);
            target->dont_rearm = true;      // Ensure a one-shot capture!
            if (target->mode == MODE_SHARED)
                update_global_state();
        }
        else
            log_message("Ignoring memory capture while busy");
    }
    return ready;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation. */

struct trigger_target *create_trigger_target(
    const struct target_config *config, struct trigger_target_state *context)
{
    struct trigger_target *target = &targets[config->target_id];
    *target = (struct trigger_target) {
        .config = config,
        .context = context,
    };
    return target;
}


error__t initialise_trigger_targets(
    void (*set_shared_state)(enum shared_target_state state),
    void (*set_shared_targets)(const char *targets))
{
    shared = (struct shared_triggers) {
        .dont_rearm = true,
        .set_shared_state = set_shared_state,
        .set_shared_targets = set_shared_targets,
    };
    return pwait_initialise(&trigger_event);
}
