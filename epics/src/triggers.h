/* Trigger handling. */

error__t initialise_triggers(void);

/* The trigger ready lock is used to wait for the trigger to become ready (not
 * armed, not busy).  First the appropriate lock should be captured using one of
 * these two methods. */
struct trigger_target *get_memory_trigger_target(void);
struct trigger_target *get_sequencer_trigger_target(int axis);

/* Returns whether the trigger for the sequencer is active. */
bool get_sequencer_trigger_active(int axis);
