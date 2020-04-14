/* Control over fixed frequency NCOs. */

error__t initialise_nco(void);

/* This creates a gain manager using the current name prefix and publishes all
 * the associated PVs.  The given set_gain() method will be called each time the
 * gain is changed. */
void create_gain_manager(
    void *context, void (*set_gain)(void *context, unsigned int gain));
