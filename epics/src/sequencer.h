/* Sequencer sweep and detector control. */

error__t initialise_sequencer(void);

/* Called before arming the sequencer: now is the time to configure the hardware
 * for operation. */
void prepare_sequencer(int channel);
