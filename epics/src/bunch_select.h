error__t initialise_bunch_select(void);

/* Returns a view of the sequencer enables.  This is used by the sequencer when
 * updating the SEQ:MODE pv. */
void get_bunch_seq_enables(int axis, unsigned int bank, bool enables[]);
