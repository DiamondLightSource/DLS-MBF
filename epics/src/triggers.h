/* Trigger handling. */

error__t initialise_triggers(void);

/* The trigger ready lock is used to wait for the trigger to become ready (not
 * armed, not busy).  First the appropriate lock should be captured using one of
 * these two methods. */
struct trigger_target *get_memory_trigger_ready_lock(void);
struct trigger_target *get_detector_trigger_ready_lock(int channel);
