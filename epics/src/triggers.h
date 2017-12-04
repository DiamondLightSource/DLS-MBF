/* Trigger handling. */

error__t initialise_triggers(void);

/* Special hook for memory capture: needs to interact with trigger state
 * control, so we do the control internally. */
void immediate_memory_capture(void);


/* The trigger ready lock is used to wait for the trigger to become ready (not
 * armed, not busy).  First the appropriate lock should be captured using one of
 * these two methods. */
struct trigger_ready_lock;
struct trigger_ready_lock *get_memory_trigger_ready_lock(void);
struct trigger_ready_lock *get_detector_trigger_ready_lock(int channel);

/* Call this function to wait for the trigger target state to become ready and
 * lockable.  The timeout is in milliseconds and specifies how long the caller
 * can be blocked waiting for the ready state.  If timeout is zero then this
 * call will not block.
 *   If lock_trigger_ready() is successful then the caller *must* call
 * unlock_trigger_ready() when done.
 *   While waiting for the lock, poll(context) may be called repeatedly, and can
 * return false to abort waiting for the lock. */
error__t lock_trigger_ready(
    struct trigger_ready_lock *lock, unsigned int timeout,
    error__t (*poll)(void *context), void *context);

/* This must be called after a successful lock, and needs to be called in a
 * timely manner to avoid starvation of the system. */
void unlock_trigger_ready(struct trigger_ready_lock *lock);
