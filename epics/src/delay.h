/* Fine control over clock delays. */

error__t initialise_delay(void);

/* Returns true if the PLL is operating in passthrough mode. */
bool read_clock_passthrough(void);
