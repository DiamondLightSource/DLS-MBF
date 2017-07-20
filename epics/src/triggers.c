/* Trigger handling. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "register_defs.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "events.h"
#include "memory.h"
#include "sequencer.h"
#include "detector.h"

#include "triggers.h"


enum destination_mode {
    MODE_ONE_SHOT,      // Normal single shot operation
    MODE_REARM,         // Rearm this destination after trigger complete
    MODE_SHARED,        // Shared trigger operation
};


enum destination_status {
    STATUS_IDLE,        // Trigger ready for arming
    STATUS_ARMED,       // Waiting for trigger
    STATUS_BUSY,        // Trigger received, destination processing trigger
};



/* Configuration for a single trigger destination. */
struct destination_config {
    enum trigger_destination destination;
    enum destination_mode mode;
    struct epics_record *update_sources;

    pthread_mutex_t mutex;
    unsigned int status;
    struct epics_record *status_pv;

    /* Our interrupt sources.  We see three events of interest: trigger to
     * destination, destination becomes busy, destination becomes idle.  The
     * arming event is delivered separately through software. */
    struct interrupts trigger_interrupt;
    struct interrupts busy_interrupt;
    struct interrupts done_interrupt;

    bool sources[TRIGGER_SOURCE_COUNT];
    bool enables[TRIGGER_SOURCE_COUNT];
    bool blanking[TRIGGER_SOURCE_COUNT];
};


/* Array of possible destinations. */
struct destination_config destinations[TRIGGER_DEST_COUNT] = {
    [TRIGGER_SEQ0] = {
        .destination = TRIGGER_SEQ0,
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .trigger_interrupt = { .seq_trigger = 1, },
        .busy_interrupt    = { .seq_busy = 1, },
        .done_interrupt    = { .seq_done = 1, },
    },
    [TRIGGER_SEQ1] = {
        .destination = TRIGGER_SEQ1,
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .trigger_interrupt = { .seq_trigger = 2, },
        .busy_interrupt    = { .seq_busy = 2, },
        .done_interrupt    = { .seq_done = 2, },
    },
    [TRIGGER_DRAM] = {
        .destination = TRIGGER_DRAM,
        .mutex = PTHREAD_MUTEX_INITIALIZER,
        .trigger_interrupt = { .dram_trigger = 1, },
        .busy_interrupt    = { .dram_busy = 1, },
        .done_interrupt    = { .dram_done = 1, },
    },
};


struct channel_context {
    int channel;
    struct destination_config *sequencer;
} channel_contexts[CHANNEL_COUNT] = {
    [0] = {
        .channel = 0,
        .sequencer = &destinations[TRIGGER_SEQ0],
    },
    [1] = {
        .channel = 1,
        .sequencer = &destinations[TRIGGER_SEQ1],
    },
};



/* Used for monitoring the status of the trigger sources and blanking input. */
static bool sources_in[TRIGGER_SOURCE_COUNT];
static bool blanking_in;


static const char *source_names[] = {
    "SOFT", "EXT", "PM", "ADC0", "ADC1", "SEQ0", "SEQ1", };


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


static void create_event_set(
    bool sources[TRIGGER_SOURCE_COUNT], const char *suffix)
{
    for (unsigned int i = 0; i < TRIGGER_SOURCE_COUNT; i ++)
    {
        char name[20];
        sprintf(name, "%s:%s", source_names[i], suffix);
        PUBLISH_READ_VAR(bi, name, sources[i]);
    }
}


/* This is polled at 5Hz so that incoming trigger events can be seen. */
static void read_input_events(void)
{
    hw_read_trigger_events(sources_in, &blanking_in);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger state control. */


static void prepare_seq_destination(int channel)
{
    prepare_sequencer(channel);
    prepare_detector(channel);
}


static void lock_destinations(const bool arm[TRIGGER_DEST_COUNT])
{
    for (unsigned int i = 0; i < TRIGGER_DEST_COUNT; i ++)
        if (arm[i])
            LOCK(destinations[i].mutex);
}

static void unlock_destinations(const bool arm[TRIGGER_DEST_COUNT])
{
    /* Unlock in reverse order. */
    FOR_DOWN_FROM(i, TRIGGER_DEST_COUNT)
        if (arm[i])
            UNLOCK(destinations[i].mutex);
}


static void update_trigger_sources(struct destination_config *dest)
{
    hw_read_trigger_sources(dest->destination, dest->sources);
    trigger_record(dest->update_sources);
}


static void arm_destinations(const bool arm[TRIGGER_DEST_COUNT])
{
    /* First prepare the destinations, each according to its appropriate
     * processing action. */
    if (arm[TRIGGER_SEQ0])
        prepare_seq_destination(0);
    if (arm[TRIGGER_SEQ1])
        prepare_seq_destination(1);
    if (arm[TRIGGER_DRAM])
        prepare_memory();

    /* Arming the triggers and updating the status needs to be done
     * synchronously to ensure that hardware events triggered by arming are
     * actually seen afterwards. */
    lock_destinations(arm);

    /* Now we can arm the selected destinations. */
    hw_write_trigger_arm(arm);

    /* Update the status to indicate that we're armed. */
    for (unsigned int i = 0; i < TRIGGER_DEST_COUNT; i ++)
        if (arm[i])
        {
            struct destination_config *dest = &destinations[i];
            dest->status = STATUS_ARMED;
            trigger_record(dest->status_pv);
            update_trigger_sources(dest);
        }

    unlock_destinations(arm);
}


static bool arm_destination(void *context, const bool *value)
{
    struct destination_config *config = context;
    bool arm[TRIGGER_DEST_COUNT] = { };
    arm[config->destination] = true;
    arm_destinations(arm);
    return true;
}


static bool disarm_destination(void *context, const bool *value)
{
    struct destination_config *config = context;
    bool disarm[TRIGGER_DEST_COUNT] = { };
    disarm[config->destination] = true;
    hw_write_trigger_disarm(disarm);
    return true;
}


static void read_shared_destinations(bool shared[TRIGGER_DEST_COUNT])
{
    for (unsigned int i = 0; i < TRIGGER_DEST_COUNT; i ++)
        shared[i] = destinations[i].mode == MODE_SHARED;
}


static void arm_shared_destinations(void)
{
    bool arm[TRIGGER_DEST_COUNT];
    read_shared_destinations(arm);
    arm_destinations(arm);
}


static void disarm_shared_destinations(void)
{
    bool disarm[TRIGGER_DEST_COUNT];
    read_shared_destinations(disarm);
    hw_write_trigger_disarm(disarm);
}


static void process_destination_events(
    struct destination_config *dest, bool trigger, bool busy, bool done)
{
    LOCK(dest->mutex);
    unsigned int old_status = dest->status;
    if (trigger)
    {
        dest->status = STATUS_BUSY;
        update_trigger_sources(dest);
    }
    if (done)
        dest->status = STATUS_IDLE;
    if (old_status != dest->status)
        trigger_record(dest->status_pv);
    UNLOCK(dest->mutex);
}


static void dispatch_destination_events(
    void *context, struct interrupts interrupts)
{
    for (unsigned int i = 0; i < TRIGGER_DEST_COUNT; i ++)
    {
        struct destination_config *dest = &destinations[i];
        bool trigger = test_intersect(interrupts, dest->trigger_interrupt);
        bool busy    = test_intersect(interrupts, dest->busy_interrupt);
        bool done    = test_intersect(interrupts, dest->done_interrupt);
        process_destination_events(dest, trigger, busy, done);
    }
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Trigger destinations */


static bool write_enables(void *context, const bool *value)
{
    struct destination_config *config = context;
    hw_write_trigger_enable_mask(config->destination, config->enables);
    return true;
}


static bool write_blanking(void *context, const bool *value)
{
    struct destination_config *config = context;
    hw_write_trigger_blanking_mask(config->destination, config->blanking);
    return true;
}


static bool write_trigger_delay(void *context, const unsigned int *value)
{
    struct destination_config *config = context;
    hw_write_trigger_delay(config->destination, *value);
    return true;
}


static void create_destination(
    const char *prefix, struct destination_config *config)
{
    WITH_NAME_PREFIX(prefix)
    {
        for (unsigned int i = 0; i < TRIGGER_SOURCE_COUNT; i ++)
        {
            WITH_NAME_PREFIX(source_names[i])
            {
                PUBLISH_READ_VAR(bi, "HIT", config->sources[i]);
                PUBLISH_WRITE_VAR_P(bo, "EN", config->enables[i]);
                PUBLISH_WRITE_VAR_P(bo, "BL", config->blanking[i]);
            }
        }

        PUBLISH_C(bo, "EN", write_enables, config);
        PUBLISH_C(bo, "BL", write_blanking, config);

        PUBLISH_C_P(ulongout, "DELAY", write_trigger_delay, config);
        PUBLISH_WRITE_VAR_P(mbbo, "MODE", config->mode);

        PUBLISH_C(bo, "ARM", arm_destination, config);
        PUBLISH_C(bo, "DISARM", disarm_destination, config);

        config->update_sources = PUBLISH_TRIGGER("HIT");
        config->status_pv = PUBLISH_READ_VAR_I(mbbi, "STATUS", config->status);
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static bool write_blanking_window(void *context, const unsigned int *value)
{
    struct channel_context *chan = context;
    hw_write_trigger_blanking_duration(chan->channel, *value);
    return true;
}


error__t initialise_triggers(void)
{
    WITH_NAME_PREFIX("TRG")
    {
        create_destination("MEM", &destinations[TRIGGER_DRAM]);

        create_event_set(sources_in, "IN");
        PUBLISH_READ_VAR(bi, "BLNK:IN", blanking_in);
        PUBLISH_ACTION("IN", read_input_events);
        PUBLISH_ACTION("SOFT", hw_write_trigger_soft_trigger);

        PUBLISH_ACTION("ARM", arm_shared_destinations);
        PUBLISH_ACTION("DISARM", disarm_shared_destinations);
    }

    FOR_CHANNEL_NAMES(channel, "TRG")
    {
        struct channel_context *chan = &channel_contexts[channel];
        create_destination("SEQ", chan->sequencer);
        PUBLISH_C_P(ulongout, "BLANKING", write_blanking_window, chan);
    }

    register_event_handler(
        INTERRUPT_HANDLER_TRIGGER,
        INTERRUPTS(
            .dram_busy = 1, .dram_done = 1, .dram_trigger = 1,
            .seq_trigger = 3, .seq_busy = 3, .seq_done = 3),
        NULL, dispatch_destination_events);

    return ERROR_OK;
}
