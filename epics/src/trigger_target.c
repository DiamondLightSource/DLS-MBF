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
    void *context;
};


/* This gathers the state required to manage a set of shared triggers. */
struct shared_triggers {
    bool retrigger_mode;
    bool dont_rearm;
    enum target_state state;
    void (*set_shared_state)(enum target_state state);
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



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target state control. */

/* Helper macros for looping through targets. */
#define _FOR_ALL_TARGETS(i, target) \
    for (unsigned int i = 0; i < TRIGGER_TARGET_COUNT; i ++) \
        for (struct trigger_target *target = &targets[i]; target; target = NULL)
#define FOR_ALL_TARGETS(target) _FOR_ALL_TARGETS(UNIQUE_ID(), target)

#define FOR_SHARED_TARGETS(target) \
    FOR_ALL_TARGETS(target) \
        if (target->mode != MODE_SHARED) ; else


/* Recursive loop between arm_shared_targets() and update_global_state(). */
static void arm_shared_targets(void);


/* Updates state of target and corresponding PV. */
static void set_target_state(
    struct trigger_target *target, enum target_state state)
{
    if (target->state != state)
    {
        target->state = state;
        target->config->set_target_state(target->context, state);
    }
}


/* Arms a single target by performing target specific preparation, recording
 * which target needs a hardware arm, and switch into armed state.  If the
 * arming does not actually occur then false is returned. */
static bool do_arm_target(struct trigger_target *target)
{
    bool armed = false;
    if (target->state == STATE_IDLE  ||  target->state == STATE_LOCKED)
    {
        if (target->lock_count == 0)
        {
            target->dont_rearm = false;
            target->config->prepare_target(target->config->channel);
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
static void do_disarm_target(struct trigger_target *target)
{
    target->dont_rearm = true;
    if (target->state == STATE_ARMED)
    {
        const struct target_config *config = target->config;
        if (config->stop_target)
            config->stop_target(config->channel);
        set_target_state(target, config->disarmed_state);
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
            case STATE_IDLE:                    break;
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
    if (state != shared.state)
    {
        shared.state = state;
        shared.set_shared_state(state);
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
        (new_state == STATE_IDLE  &&
            shared.retrigger_mode  &&  !shared.dont_rearm)  ||
        /* Do a true trigger in locked state if no locks are held. */
        (new_state == STATE_LOCKED  &&  !check_locked_targets());
    if (do_rearm)
        arm_shared_targets();
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger target state control entry points. */

/* Here we manage the state transitions for a single trigger target.  We report
 * three states, Idle, Armed, Busy, as reported by enum target_state.
 * Transitions between states are triggered by arm and disarm commands, and by
 * events received from the interrupt mechanism.
 *
 * All these methods are called with the target trigger_mutex lock held. */


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

/* Called with trigger_mutex locked to arm all shared targets. */
static void arm_shared_targets(void)
{
    shared.dont_rearm = false;

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
    shared.dont_rearm = shared.state != STATE_IDLE;

    bool disarm_mask[TRIGGER_TARGET_COUNT];
    get_shared_mask(disarm_mask);
    hw_write_trigger_disarm(disarm_mask);

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
        {
            bool arm_mask[TRIGGER_TARGET_COUNT];
            get_target_mask(target, arm_mask);
            hw_write_trigger_arm(arm_mask);
        }

        update_global_state();
    }
}


/* Called on transition from target locked for readout to unlocked, performs
 * rearming where possible, updates global state if appropriate. */
static void process_target_unlocked(struct trigger_target *target)
{
    /* When the last lock has gone, if we're in the Locked state and not shared
     * then we can perform the posponed arming of our target. */
    if (target->state == STATE_LOCKED  &&  target->mode != MODE_SHARED)
    {
        target->state = STATE_IDLE;
        arm_target(target);
    }
    update_global_state();
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Single trigger target actions. */

void trigger_target_arm(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
        arm_target(target);
}


void trigger_target_disarm(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
    {
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
    }
}


void trigger_target_trigger(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
    {
        if (target->state == STATE_ARMED)
            set_target_state(target, STATE_BUSY);
        else
            printf("Unexpected trigger %u %u\n",
                target->config->target_id, target->state);
    }
}


void trigger_target_complete(struct trigger_target *target)
{
    WITH_MUTEX(trigger_mutex)
    {
        if (target->state == STATE_BUSY)
        {
            set_target_state(target, STATE_IDLE);
            if (target->mode == MODE_REARM  &&  !target->dont_rearm)
                /* Automatically re-arm where requested and possible. */
                arm_target(target);

            /* On completion let all listening locks know that something may
             * have changed. */
            ASSERT_PTHREAD(pthread_cond_broadcast(&trigger_event));
        }
        else
            printf("Unexpected complete %u %u\n",
                target->config->target_id, target->state);
    }
}


void trigger_target_set_mode(
    struct trigger_target *target, enum target_mode mode)
{
    WITH_MUTEX(trigger_mutex)
    {
        target->mode = mode;

        /* Don't leave the target in locked state if not applicable. */
        if (mode != MODE_SHARED  &&  target->state == STATE_LOCKED  &&
             target->lock_count == 0)
            set_target_state(target, STATE_IDLE);

        update_global_state();
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared trigger target actions. */

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
    return target->state == STATE_IDLE  ||  target->state == STATE_LOCKED;
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

void immediate_memory_capture(void)
{
    struct trigger_target *target = &targets[TRIGGER_DRAM];
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
/* Initialisation. */

struct trigger_target *create_trigger_target(
    const struct target_config *config, void *context)
{
    struct trigger_target *target = &targets[config->target_id];
    *target = (struct trigger_target) {
        .config = config,
        .context = context,
    };
    return target;
}


error__t initialise_trigger_targets(
    void (*set_shared_state)(enum target_state state))
{
    shared = (struct shared_triggers) {
        .dont_rearm = true,
        .set_shared_state = set_shared_state,
    };
    return pwait_initialise(&trigger_event);
}
