/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Simple parsing support. */

/* Skips string past any spaces, returns true if whitespace was seen. */
bool skip_whitespace(const char **string);

/* Advances *string past whitespace, fails with error if no whitespace found.
 * Use skip_whitespace() if space was optional. */
error__t parse_whitespace(const char **string);

/* This parses out a sequence of letters and underscores into the result array.
 * The given max_length includes the trailing null character. */
error__t parse_name(const char **string, char result[], size_t max_length);

/* As for parse_name, but also accepts numbers after the leading character. */
error__t parse_alphanum_name(
    const char **string, char result[], size_t max_length);

/* Tests whether the next character in *string is ch and if so consumes it and
 * returns true, otherwise returns false. */
bool read_char(const char **string, char ch);

/* Tests whether input string matches given comparison string, if so consumes it
 * and returns true, otherwise returns false. */
bool read_string(const char **string, const char *expected);

/* Expects next character to be ch, fails if not. */
error__t parse_char(const char **string, char ch);

/* Parses an unsigned integer from *string. */
error__t parse_uint(const char **string, unsigned int *result);

/* Parses a 32-bit unsigned integer from *string. */
error__t parse_uint32(const char **string, uint32_t *result);

/* Parses a 64-bit unsigned integer from *string. */
error__t parse_uint64(const char **string, uint64_t *result);

/* Parses a signed integer from *string. */
error__t parse_int(const char **string, int *result);

/* Parses a double from *string. */
error__t parse_double(const char **string, double *result);

/* Parses bit from *string. */
error__t parse_bit(const char **string, bool *result);

/* Treats rest of line to end of *string as a single value, assigns copy to
 * *result, advances to end of string. */
error__t parse_to_eos(const char **string, char **result);

/* Checks for end of input string. */
error__t parse_eos(const char **string);
