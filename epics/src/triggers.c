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

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

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
    unsigned int status;
    struct epics_record *status_pv;

    bool sources[TRIGGER_SOURCE_COUNT];
    bool enables[TRIGGER_SOURCE_COUNT];
    bool blanking[TRIGGER_SOURCE_COUNT];
};


/* Array of possible destinations. */
struct destination_config destinations[TRIGGER_DEST_COUNT] = {
    [TRIGGER_SEQ0] = { .destination = TRIGGER_SEQ0, },
    [TRIGGER_SEQ1] = { .destination = TRIGGER_SEQ1, },
    [TRIGGER_DRAM] = { .destination = TRIGGER_DRAM, },
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


#if 0
static void update_destination_status(
    struct destination_config *config, bool armed, bool busy)
{


}
#endif


static void prepare_seq_destination(int channel)
{
    prepare_sequencer(channel);
    prepare_detector(channel);
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

    /* Now we can arm the selected destinations. */
    hw_write_trigger_arm(arm);
}


static bool arm_destination(void *context, const bool *value)
{
    struct destination_config *config = context;
    if (config->mode == MODE_SHARED)
        /* Reject arming of shared destination. */
        return false;
    else
    {
        bool arm[TRIGGER_DEST_COUNT] = { };
        arm[config->destination] = true;
        arm_destinations(arm);
        return true;
    }
}


static bool disarm_destination(void *context, const bool *value)
{
    struct destination_config *config = context;
    if (config->mode == MODE_SHARED)
        /* Reject arming of shared destination. */
        return false;
    else
    {
        bool disarm[TRIGGER_DEST_COUNT] = { };
        disarm[config->destination] = true;
        hw_write_trigger_disarm(disarm);
        return true;
    }
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
            const char *source = source_names[i];
            char name[20];
#define FORMAT(suffix) \
    ( { sprintf(name, "%s:%s", source, suffix); name; } )
            PUBLISH_READ_VAR(bi, FORMAT("HIT"), config->sources[i]);
            PUBLISH_WRITE_VAR_P(bo, FORMAT("EN"), config->enables[i]);
            PUBLISH_WRITE_VAR_P(bo, FORMAT("BL"), config->blanking[i]);
#undef FORMAT
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


static void poll_events(void)
{
//     printf("poll_events\n");

#if 0
    /* Pick up the bits we're interested in. */
    struct trigger_status status;
    hw_read_trigger_status(&status);
    bool memory_busy = hw_read_dram_active();
    bool seq_busy[CHANNEL_COUNT];
    for (int i = 0; i < CHANNEL_COUNT; i ++)
    {
        unsigned int pc, super_pc;
        hw_read_seq_state(i, &seq_busy[i], &pc, &super_pc);
    }

    /* Compute set of events. */
    bool seq0_armed = status.seq0_armed;
    bool seq1_armed = status.seq1_armed;
    bool dram_armed = status.dram_armed;
#endif
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

        // Temporary hack
        PUBLISH_ACTION("POLL", poll_events);
    }

    FOR_CHANNEL_NAMES(channel, "TRG")
    {
        struct channel_context *chan = &channel_contexts[channel];
        create_destination("SEQ", chan->sequencer);
        PUBLISH_C_P(ulongout, "BLANKING", write_blanking_window, chan);
    }

    return ERROR_OK;
}
