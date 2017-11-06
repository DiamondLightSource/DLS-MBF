/* Simple parsing support. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>

#include "error.h"

#include "parse.h"


#define MAX_LINE_LENGTH     256


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Simple parsing support. */


bool skip_whitespace(const char **string)
{
    bool seen = false;
    while (isspace((unsigned char) **string))
    {
        *string += 1;
        seen = true;
    }
    return seen;
}


/* Expects whitespace and skips it. */
error__t parse_whitespace(const char **string)
{
    const char *start = *string;
    skip_whitespace(string);
    return TEST_OK_(*string > start, "Whitespace expected");
}


/* Test for valid character in a name.  We allow ASCII letters and underscores,
 * only. */
static bool valid_name_char(char ch)
{
    return isascii(ch)  &&  (isalpha(ch)  ||  ch == '_');
}

/* Allow numbers as well. */
static bool valid_alphanum_char(char ch)
{
    return isascii(ch)  &&  (isalpha(ch)  ||  ch == '_'  ||  isdigit(ch));
}


static error__t parse_filtered_name(
    const char **string, bool (*filter_char)(char),
    char result[], size_t max_length)
{
    size_t ix = 0;
    while (ix < max_length  &&  filter_char(**string))
    {
        result[ix] = *(*string)++;
        ix += 1;
    }
    return
        TEST_OK_(ix > 0, "No name found")  ?:
        TEST_OK_(ix < max_length, "Name too long")  ?:
        DO(result[ix] = '\0');
}


error__t parse_name(const char **string, char result[], size_t max_length)
{
    return parse_filtered_name(string, valid_name_char, result, max_length);
}


error__t parse_alphanum_name(
    const char **string, char result[], size_t max_length)
{
    return
        TEST_OK_(valid_name_char(**string), "No name found")  ?:
        parse_filtered_name(string, valid_alphanum_char, result, max_length);
}


bool read_char(const char **string, char ch)
{
    if (**string == ch)
    {
        *string += 1;
        return true;
    }
    else
        return false;
}


bool read_string(const char **string, const char *expected)
{
    size_t length = strlen(expected);
    if (strncmp(*string, expected, length) == 0)
    {
        *string += length;
        return true;
    }
    else
        return false;
}


error__t parse_char(const char **string, char ch)
{
    return TEST_OK_(read_char(string, ch), "Character '%c' expected", ch);
}


/* Called after a C library conversion function checks that anything was
 * converted and that the conversion was successful.  Relies on errno being zero
 * before conversion started. */
static error__t check_number(const char *start, const char *end)
{
    return
        TEST_OK_(end > start, "Number missing")  ?:
        TEST_IO_(errno == 0, "Error converting number");
}


/* Parsing numbers is rather boilerplate.  This macro encapsulates everything in
 * one common form. */
#define DEFINE_PARSE_NUM(name, type, convert, extra...) \
    error__t name(const char **string, type *result) \
    { \
        errno = 0; \
        const char *start = *string; \
        char *end; \
        *result = (type) convert(start, &end, ##extra); \
        *string = end; \
        return check_number(start, *string); \
    }

DEFINE_PARSE_NUM(parse_int,    int,          strtol, 10)
DEFINE_PARSE_NUM(parse_uint,   unsigned int, strtoul, 10)
DEFINE_PARSE_NUM(parse_uint32, uint32_t,     strtoul, 10)
DEFINE_PARSE_NUM(parse_uint64, uint64_t,     strtoull, 10)
DEFINE_PARSE_NUM(parse_double, double,       strtod)


error__t parse_bit(const char **string, bool *result)
{
    return
        TEST_OK_(**string == '0'  ||  **string == '1', "Invalid bit value")  ?:
        DO(*result = *(*string)++ == '1');
}


error__t parse_to_eos(const char **string, char **result)
{
    *result = strdup(*string);
    *string += strlen(*string);
    return ERROR_OK;
}


error__t parse_eos(const char **string)
{
    return TEST_OK_(**string == '\0', "Unexpected character after input");
}
