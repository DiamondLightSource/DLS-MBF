/* DAC readout and control. */

error__t initialise_dac(void);

/* Reads the output status of the given axis. */
bool get_dac_output_enable(int axis);
