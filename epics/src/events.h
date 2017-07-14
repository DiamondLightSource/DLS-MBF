/* Asynchronous events. */

struct interrupts;

error__t initialise_events(void);

void register_event_handler(
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
    return CAST_TO(uint32_t, a) & CAST_TO(uint32_t, b);
}

