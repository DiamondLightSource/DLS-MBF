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


static error__t set_range(
    unsigned int start, unsigned int skip, unsigned int end, bool selection[])
{
    return
        TEST_OK_(start <= end, "Empty range")  ?:
        TEST_OK_(skip > 0, "Invalid skip interval")  ?:
        DO( for (unsigned int i = start; i <= end; i += skip)
                selection[i] = true );
}


/* A valid parse is a full range or a non-empty list of values and ranges
 *
 *  bunch_set = ":" | ( bunch [ ":" bunch [ ":" bunch ]] )+
 */
static error__t parse_bunch_select(const char **parse, bool selection[])
{
    skip_whitespace(parse);
    if (read_char(parse, ':'))
    {
        /* A single : on its own corresponds to the full range. */
        skip_whitespace(parse);
        return
            parse_eos(parse)  ?:
            set_range(0, 1, hardware_config.bunches - 1, selection);
    }
    else
    {
        memset(selection, 0, sizeof(bool) * hardware_config.bunches);

        /* Otherwise we must start with a number, optionally followed by a range
         * specifier, optionally repeated. */
        error__t error;
        do {
            unsigned int bunch, bunch2, bunch3;
            error =
                parse_bunch_num(parse, &bunch)  ?:
                IF_ELSE(read_char(parse, ':'),
                    parse_bunch_num(parse, &bunch2)  ?:
                    IF_ELSE(read_char(parse, ':'),
                        /* Must be start:skip:end. */
                        parse_bunch_num(parse, &bunch3)  ?:
                        set_range(bunch, bunch2, bunch3, selection),
                    //else
                        /* Must be start:end. */
                        set_range(bunch, 1, bunch2, selection)),
                //else
                    /* Single number. */
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
