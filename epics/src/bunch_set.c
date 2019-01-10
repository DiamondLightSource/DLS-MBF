/* Manages a bunch set selection user interface. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "common.h"
#include "parse.h"

#include "bunch_set.h"


struct bunch_set
{
    bool *selection;
    EPICS_STRING status_string;
    struct epics_record *status_pv;
};


void update_record_with_bunch_set(
    struct bunch_set *bunch_set,
    struct epics_record *record, enum waveform_type waveform_type,
    const void *value, size_t value_size)
{
    unsigned int bunches = hardware_config.bunches;
    char wf_value[bunches * value_size];
    _read_record_waveform(waveform_type, record, wf_value, bunches);
    char *wf_update = wf_value;
    for (unsigned int i = 0; i < bunches; i ++)
    {
        if (bunch_set->selection[i])
            memcpy(wf_update, value, value_size);
        wf_update += value_size;
    }
    _write_out_record_waveform(waveform_type, record, wf_value, bunches, true);
}


static bool init_bunch_select(void *context, EPICS_STRING *value)
{
    format_epics_string(value, "0:%d", hardware_config.bunches - 1);
    return true;
}


/* Parses a valid bunch number. */
static error__t parse_bunch_num(const char **parse, unsigned int *bunch)
{
    return
        parse_uint(parse, bunch)  ?:
        TEST_OK_(*bunch < hardware_config.bunches,
            "Bunch number out of range")  ?:
        DO(skip_whitespace(parse));
}


static void set_range(unsigned int start, unsigned int end, bool selection[])
{
    for (unsigned int i = start; i <= end; i ++)
        selection[i] = true;
}


/* A valid parse is a full range or a non-empty list of values and ranges
 *
 *  bunch_set = ":" | ( bunch [ ":" bunch ] )+
 */
static error__t parse_bunch_select(const char **parse, bool selection[])
{
    skip_whitespace(parse);
    if (read_char(parse, ':'))
    {
        /* A single : on its own corresponds to the full range. */
        set_range(0, hardware_config.bunches - 1, selection);
        skip_whitespace(parse);
        return parse_eos(parse);
    }
    else
    {
        memset(selection, 0, sizeof(bool) * hardware_config.bunches);

        /* Otherwise we must start with a number, optionally followed by a range
         * specifier, optionally repeated. */
        error__t error;
        do {
            unsigned int bunch, last_bunch;
            error =
                parse_bunch_num(parse, &bunch)  ?:
                IF_ELSE(read_char(parse, ':'),
                    parse_bunch_num(parse, &last_bunch)  ?:
                    TEST_OK_(bunch <= last_bunch, "Empty range")  ?:
                    DO(set_range(bunch, last_bunch, selection)),
                //else
                    DO(selection[bunch] = true));
        } while (!error  &&  **parse != '\0');

        return error;
    }
}


/* This is called when the user attempts to enter a range of bunches.  If
 * parsing fails then write is rejected and the rejection reason is written to
 * the status PV. */
static bool write_bunch_select(void *context, EPICS_STRING *value)
{
    struct bunch_set *bunch_set = context;

    /* Try to parse the write request into a selection set.  If successful
     * update the selection set, otherwise discard the write. */
    bool selection[hardware_config.bunches];
    const char *parse = value->s;
    error__t error = parse_bunch_select(&parse, selection);
    if (!error)
        memcpy(bunch_set->selection, selection,
            sizeof(bool) * hardware_config.bunches);

    /* Update status string from error. */
    if (error)
    {
        format_epics_string(&bunch_set->status_string, "%s @%zu",
            error_format(error), parse - value->s + 1);
        set_record_severity(bunch_set->status_pv, epics_sev_minor);
    }
    else
    {
        format_epics_string(&bunch_set->status_string, "%s", "Ok");
        set_record_severity(bunch_set->status_pv, epics_sev_none);
    }

    return !error_discard(error);
}


struct bunch_set *create_bunch_set(void)
{
    struct bunch_set *bunch_set = malloc(sizeof(struct bunch_set));
    *bunch_set = (struct bunch_set) {
        .selection = CALLOC(bool, hardware_config.bunches),
        .status_pv = PUBLISH_READ_VAR(
            stringin, "SELECT_STATUS", bunch_set->status_string),
    };

    PUBLISH(stringout, "BUNCH_SELECT", write_bunch_select,
        .context = bunch_set, .init = init_bunch_select);
    return bunch_set;
}
