/* Asynchronous events. */

error__t initialise_events(void);

void register_event_handler(
    unsigned int mask, void *context,
    void (*handler)(void *context, unsigned int events));

/* For an orderly shutdown, call this before closing the hardware.  Make sure to
 * call this late, as it calls pthread_cancel(), which can leave locks in an
 * unsafe state. */
void terminate_events(void);

/* Defined hardware events. */

#define EVENT_DRAM0_BUSY        0x00000001
#define EVENT_DRAM0_READY       0x00000002
