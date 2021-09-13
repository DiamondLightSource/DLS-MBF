/* Configuration file parsing code.  Needs to be merged with persistence.c at
 * some point. */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <ctype.h>

#include "error.h"

#include "parse.h"
#include "config_file.h"


#define NAME_LENGTH 40
#define LINE_SIZE   200


static error__t lookup_name(
    const char *name,
    const struct config_entry config_table[], size_t config_size, size_t *ix)
{
    for (size_t i = 0; i < config_size; i ++)
        if (strcmp(name, config_table[i].name) == 0)
        {
            *ix = i;
            return ERROR_OK;
        }
    return FAIL_("Identifier %s not known", name);
}


/* This dispatches the requested parse to the appropriate parser. */
static error__t parse_value(
    const char **string, const struct config_entry *config_table)
{
    switch (config_table->entry_type)
    {
        case CONFIG_int:
            return parse_int(string, config_table->address);
        case CONFIG_uint:
            return parse_uint(string, config_table->address);
        case CONFIG_string:
            return parse_to_eos(string, config_table->address);
        case CONFIG_double:
            return parse_double(string, config_table->address);
        case CONFIG_bool:
            return parse_bit(string, config_table->address);
        default:
            return FAIL_("Invalid config entry");
    }
}


static error__t do_parse_line(
    const char *file_name, int line_number, const char *line_buffer,
    const struct config_entry config_table[], size_t config_size, bool *seen,
    bool ignore_unknown)
{
    const char *string = line_buffer;
    skip_whitespace(&string);
    if (*string == '\0'  ||  *string == '#')
        /* Empty line or comment, can just ignore. */
        return ERROR_OK;

    /* A valid definition is
     *
     *  name<opt-whitespace>=<opt-whitespace><parse><opt-whitespace>
     *
     * The optional whitespace which our parser doesn't support makes the parse
     * a lot more long winded than it otherwise ought to be. */
    char name[NAME_LENGTH];
    error__t error =
        parse_alphanum_name(&string, name, NAME_LENGTH)  ?:
        DO(skip_whitespace(&string))  ?:
        parse_char(&string, '=')  ?:
        DO(skip_whitespace(&string));

    /* We need to treat name lookup specially.  If this fails but we're ignoring
     * unknown keys then we need bail out but return success! */
    size_t ix = 0;
    if (!error)
    {
        error = lookup_name(name, config_table, config_size, &ix);
        if (ignore_unknown  &&  error_discard(error))
            return ERROR_OK;
    }

    error = error  ?:
        parse_value(&string, &config_table[ix])  ?:
        DO(skip_whitespace(&string))  ?:
        parse_eos(&string);

    return
        /* Report parse error. */
        error_extend(error, "Error parsing %s, line %d, offset %zd",
            file_name, line_number, string - line_buffer)  ?:
        /* Perform post parse validation. */
        TEST_OK_(!seen[ix],
            "Parameter %s repeated on line %d", name, line_number)  ?:
        DO(seen[ix] = true);
}


/* Wraps the slightly annoying behaviour of fgets.  Returns error status and eof
 * separately, returns length of line read, and removes trailing newline
 * character.  Also returns an error if the buffer is filled. */
static error__t read_one_line(
    FILE *input, char *line_buffer, size_t line_length,
    int line_number, size_t *length_read, bool *eof)
{
    errno = 0;
    *eof = fgets(line_buffer, (int) line_length, input) == NULL;
    if (*eof)
    {
        *length_read = 0;
        line_buffer[0] = '\0';
        return TEST_OK_(errno == 0,
            "Error reading file on line %d", line_number);
    }
    else
    {
        *length_read = strlen(line_buffer);
        ASSERT_OK(*length_read > 0);
        if (line_buffer[*length_read - 1] == '\n')
        {
            *length_read -= 1;
            line_buffer[*length_read] = '\0';
            return ERROR_OK;
        }
        else
            return TEST_OK_(*length_read + 1 < line_length,
                "Read buffer overflow on line %d", line_number);
    }
}


/* Reads a single line after joining lines with trailing \ characters.  Fails if
 * line buffer overflows or fgets fails, sets *eof on end of file. */
static error__t read_line(
    FILE *input, char *line_buffer, size_t line_length,
    int *line_number, bool *eof)
{
    error__t error = ERROR_OK;
    bool want_line = true;
    while (!error  &&  !*eof  &&  want_line)
    {
        size_t length_read = 0;
        *line_number += 1;
        error = read_one_line(
            input, line_buffer, line_length, *line_number, &length_read, eof);
        want_line = !error  &&  !*eof  &&
            length_read > 0  &&  line_buffer[length_read - 1] == '\\';
        if (want_line)
        {
            line_buffer += length_read - 1;
            line_length -= length_read - 1;
            error = TEST_OK_(line_length > 2,
                "Run out of read buffer on line %d", *line_number);
        }
    }
    return error;
}


error__t load_config_file(
    const char *file_name,
    const struct config_entry config_table[], size_t config_size,
    bool ignore_unknown)
{
    FILE *input = fopen(file_name, "r");
    error__t error =
        TEST_OK_(input, "Unable to open config file \"%s\"", file_name);
    if (error)
        return error;

    /* Array of seen flags for each configuration entry, used to ensure that
     * every needed configuration setting is set. */
    bool seen[config_size];
    memset(seen, 0, sizeof(seen));

    /* Process each line in the file. */
    bool eof = false;
    int line_number = 0;
    while (!error  &&  !eof)
    {
        char line_buffer[LINE_SIZE];
        error =
            read_line(
                input, line_buffer, sizeof(line_buffer), &line_number, &eof)  ?:
            do_parse_line(
                file_name, line_number, line_buffer,
                config_table, config_size, seen, ignore_unknown);
    }
    fclose(input);

    /* Check that all required entries were present. */
    errno = 0;      // Can linger over into error reporting
    for (size_t i = 0; !error  &&  i < config_size; i ++)
        error = TEST_OK_(seen[i],
            "No value specified for parameter: %s", config_table[i].name);

    return error;
}
