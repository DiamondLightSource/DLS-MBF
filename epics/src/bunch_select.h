error__t initialise_bunch_select(void);

/* Returns the current configuration of the selected bank. */
const struct bunch_config *get_bunch_config(int axis, unsigned int bank);
