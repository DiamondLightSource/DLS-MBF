/* Asynchronous events. */

struct interrupts;

error__t initialise_events(void);


/* Because the order in which interrupt events are dispatched can matter, we
 * explicitly define the order of interrupt handlers here. */
enum interrupt_handler_index {
    INTERRUPT_HANDLER_MEMORY,
    INTERRUPT_HANDLER_DETECTOR,

    /* The trigger handler must go last!  This is so that any rearming (which
     * does occur in this handler) happens after the complete events have been
     * processed by the concerned components above. */
    INTERRUPT_HANDLER_TRIGGER,
};

/* This must be no less than the number of handlers above. */
#define MAX_EVENT_HANDLERS    4


void register_event_handler(
    enum interrupt_handler_index index,
    struct interrupts interrupts, void *context,
    void (*handler)(void *context, struct interrupts interrupts));

/* For an orderly shutdown, call this before closing the hardware.  Make sure to
 * call this late, as it calls pthread_cancel(), which can leave locks in an
 * unsafe state. */
void terminate_events(void);

/* Defined hardware events. */
#define INTERRUPTS(args...)     (struct interrupts) { args }


/* Some inline handlers for interrupts. */

/* Returns set of interrupts common to both arguments. */
static inline struct interrupts intersect_interrupts(
    struct interrupts a, struct interrupts b)
{
    return CAST_TO(struct interrupts,
        CAST_TO(uint32_t, a) & CAST_TO(uint32_t, b));
}

/* Returns true if any interrupts are set. */
static inline bool test_interrupts(struct interrupts a)
{
    return CAST_TO(uint32_t, a);
}

static inline bool test_intersect(
    struct interrupts a, struct interrupts b)
{
    return test_interrupts(intersect_interrupts(a, b));
}
