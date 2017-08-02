/* Trigger handling. */

error__t initialise_triggers(void);

/* Special hook for memory capture: needs to interact with trigger state
 * control, so we do the control internally. */
void immediate_memory_capture(void);
