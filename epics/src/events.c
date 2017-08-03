/* Asynchronous events. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <pthread.h>
#include <signal.h>

#include "error.h"

#include "register_defs.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "events.h"



static struct event_handler {
    struct interrupts interrupts;
    void *context;
    void (*handler)(void *context, struct interrupts interrupts);
} event_handlers[MAX_EVENT_HANDLERS];


void register_event_handler(
    enum interrupt_handler_index index,
    struct interrupts interrupts, void *context,
    void (*handler)(void *context, struct interrupts interrupts))
{
    ASSERT_OK(index < MAX_EVENT_HANDLERS);
    /* Check handler not already assigned. */
    ASSERT_OK(!test_interrupts(event_handlers[index].interrupts));

    event_handlers[index] = (struct event_handler) {
        .interrupts = interrupts,
        .context = context,
        .handler = handler,
    };
}


static void *events_thread(void *context)
{
    struct interrupts interrupts;
    error__t error;
    while (error = hw_read_interrupt_events(&interrupts),
           !error)
    {
        for (unsigned int i = 0; i < MAX_EVENT_HANDLERS; i ++)
        {
            struct event_handler *handler = &event_handlers[i];
            if (test_intersect(handler->interrupts, interrupts))
                handler->handler(handler->context,
                    intersect_interrupts(handler->interrupts, interrupts));
        }
    }
    ERROR_REPORT(error, "Error reading events");
    ASSERT_FAIL();                      // We're in trouble!
    return NULL;
}



static pthread_t events_thread_id;

error__t initialise_events(void)
{
    return
        TEST_PTHREAD(
            pthread_create(&events_thread_id, NULL, events_thread, NULL));
}


void terminate_events(void)
{
    if (events_thread_id)
    {
        printf("Waiting for events thread\n");
        pthread_cancel(events_thread_id);
        pthread_join(events_thread_id, NULL);
    }
}
