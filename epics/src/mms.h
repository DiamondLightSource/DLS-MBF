/* Min/Max/Sum/Std support. */


struct mms_handler;


/* Must be called *after* all MMS handlers have been created. */
error__t start_mms_handlers(void);


/* Creates an MMS handler with associated record support. */
struct mms_handler *create_mms_handler(
    int channel, void (*read_mms)(int, struct mms_result*),
    unsigned int bunch_offset);

/* Dynamically changes the readout offset: needed by DAC as we switch source. */
void set_mms_offset(struct mms_handler *mms, unsigned int bunch_offset);

/* Must be called during shutdown before unmapping hardware registers. */
void stop_mms_handlers(void);
