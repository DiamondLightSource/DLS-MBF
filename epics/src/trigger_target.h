/* Support for a single trigger target and for shared trigger target control. */

/* Abstract interface to a single trigger target. */
struct trigger_target;


/* Target arming control. */
enum target_mode {
    MODE_ONE_SHOT,      // Normal single shot operation
    MODE_REARM,         // Rearm this target after trigger complete
    MODE_SHARED,        // Shared trigger operation
};


/* State of a trigger target. */
enum target_state {
    TARGET_IDLE,        // Trigger ready for arming
    TARGET_ARMED,       // Waiting for trigger
    TARGET_BUSY,        // Trigger received, target processing trigger
    TARGET_LOCKED,      // Arm request seen, but trigger locked
};


/* State of shared target control. */
enum shared_target_state {
    SHARED_IDLE,        // All triggers ready for arming
    SHARED_ARMED,       // All triggers waiting for trigger
    SHARED_LOCKED,      // Arm request seen, but at least one trigger locked
    SHARED_BUSY,        // Trigger received, target processing trigger
    SHARED_MIXED,       // Some targets triggered, some not triggered
    SHARED_INVALID,     // Inconsistent shared state
};


/* Definition of behaviour of a single trigger target. */
struct target_config {
    /* Target identity. */
    enum trigger_target_id target_id;   // Hardware identification
    int axis;                        // Not valid for DRAM target
    size_t (*get_target_name)(int axis, char name[], size_t length);

    /* Target specific methods and variables. */
    void (*prepare_target)(int axis);
    enum target_state (*stop_target)(int axis);

    /* State change notification. */
    void (*set_target_state)(void *context, enum target_state state);
};


/* Initialises shared target management by setting state callback. */
error__t initialise_trigger_targets(
    void (*set_shared_state)(enum shared_target_state state),
    void (*set_shared_targets)(const char *targets));

/* Create and initialise a single trigger target.  The context is used for the
 * .set_target_state() callback. */
struct trigger_target *create_trigger_target(
    const struct target_config *config, void *context);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Single trigger target actions. */

/* Software request to arm specified trigger target. */
void trigger_target_arm(struct trigger_target *target);

/* Software request to disarm specified trigger target. */
void trigger_target_disarm(struct trigger_target *target);

/* Handle trigger event seen by target. */
void trigger_target_trigger(struct trigger_target *target);

/* Handle trigger completion for target.  Called after all other target
 * processing has completed. */
void trigger_target_complete(struct trigger_target *target);

/* Sets the arming control mode. */
void trigger_target_set_mode(
    struct trigger_target *target, enum target_mode mode);

/* Returns current arm state of the target. */
enum target_state trigger_target_get_state(struct trigger_target *target);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared trigger target actions. */

/* Arms all shared triggers. */
void shared_trigger_target_arm(void);

/* Disarms all shared triggers. */
void shared_trigger_target_disarm(void);

/* Configure rearming behaviour of shared triggers. */
void shared_trigger_set_mode(bool auto_rearm);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Target locking. */

/* Call this function to wait for the trigger target state to become ready and
 * lockable.  The timeout is in milliseconds and specifies how long the caller
 * can be blocked waiting for the ready state.  If timeout is zero then this
 * call will not block.
 *   If lock_trigger_ready() is successful then the caller *must* call
 * unlock_trigger_ready() when done.
 *   While waiting for the lock, poll(context) may be called repeatedly, and can
 * return an error code to abort waiting for the lock. */
error__t lock_trigger_ready(
    struct trigger_target *lock, unsigned int timeout,
    error__t (*poll)(void *context), void *context);

/* This must be called after a successful lock, and needs to be called in a
 * timely manner to avoid starvation of the system. */
void unlock_trigger_ready(struct trigger_target *lock);


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Specials */


/* Special hook for memory capture: needs to interact with trigger state
 * control, so we do the control internally. */
void immediate_memory_capture(void);
