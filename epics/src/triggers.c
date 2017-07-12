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

#include "triggers.h"


/* Configuration for a single trigger destination. */
struct destination_config {
    enum trigger_destination destination;
    struct epics_record *update_sources;
    struct in_epics_record_mbbi *status;
    bool sources[TRIGGER_SOURCE_COUNT];
    bool enables[TRIGGER_SOURCE_COUNT];
    bool blanking[TRIGGER_SOURCE_COUNT];
};

struct channel_context {
    int channel;
    struct destination_config sequencer;
} channel_contexts[CHANNEL_COUNT] = {
    [0] = {
        .channel = 0,
        .sequencer.destination = TRIGGER_SEQ0,
    },
    [1] = {
        .channel = 1,
        .sequencer.destination = TRIGGER_SEQ1,
    },
};


static bool sources_in[TRIGGER_SOURCE_COUNT];
static bool blanking_in;

static struct destination_config memory = {
    .destination = TRIGGER_DRAM,
};


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

static bool write_trigger_arm_mode(void *context, const unsigned int *value)
{
    struct destination_config *config = context;
    printf("arm mode %p <= %u\n", config, *value);
    return true;
}

static bool arm_destination(void *context, const bool *value)
{
    struct destination_config *config = context;
    printf("arm %p\n", config);
    return true;
}

static bool disarm_destination(void *context, const bool *value)
{
    struct destination_config *config = context;
    printf("disarm %p\n", config);
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
        PUBLISH_C_P(mbbo, "MODE", write_trigger_arm_mode, config);

        PUBLISH_C(bo, "ARM", arm_destination, config);
        PUBLISH_C(bo, "DISARM", disarm_destination, config);

        config->update_sources = PUBLISH_TRIGGER("HIT");
        config->status = PUBLISH_IN_VALUE_I(mbbi, "STATUS");
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
        create_event_set(sources_in, "IN");
        PUBLISH_READ_VAR(bi, "BLNK:IN", blanking_in);
        PUBLISH_ACTION("IN", read_input_events);
        PUBLISH_ACTION("SOFT", hw_write_trigger_soft_trigger);

        create_destination("MEM", &memory);
    }

    FOR_CHANNEL_NAMES(channel, "TRG")
    {
        struct channel_context *chan = &channel_contexts[channel];
        create_destination("SEQ", &chan->sequencer);
        PUBLISH_C_P(ulongout, "BLANKING", write_blanking_window, chan);
    }

    return ERROR_OK;
}
