/* Min/Max/Sum/Std support. */


struct mms_handler;


/* Must be called *after* all MMS handlers have been created. */
error__t start_mms_handlers(unsigned int poll_interval);


/* Creates an MMS handler with associated record support. */
struct mms_handler *create_mms_handler(
    int channel, void (*read_mms)(int, struct mms_result*),
    unsigned int bunch_offset);
