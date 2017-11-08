/* Buffered file handling for sockets.
 *
 * Works, unlike using fdopen(3) on a socket, and a bit more appropriate to our
 * use than dup(2)ing the socket and using fdopen anyway. */

struct buffered_file;

/* Reads one newline terminated line from file.  Returns false if EOF is
 * encountered, or if the line buffer overruns.  If flush is requested then any
 * pending output is written. */
bool read_line(
    struct buffered_file *file, char line[], size_t line_size, bool flush);

/* Reads fixed size block of data, returns false if EOF or error encountered
 * before block filled. */
bool read_block(struct buffered_file *file, char data[], size_t length);

/* Writes given character array to output. */
bool write_string(
    struct buffered_file *file, const char string[], size_t length);

/* Writes formatted string to output. */
bool __attribute__((format(printf, 2, 3))) write_formatted_string(
    struct buffered_file *file, const char *format, ...);


/* Writes buffer to output.  The output buffer is bypassed, after first being
 * flushed if necessary. */
bool write_block(struct buffered_file *file, const void *buffer, size_t length);

/* Writes a single character to output. */
bool write_char(struct buffered_file *file, char ch);

/* Ensures output buffer is flushed to socket.  Returns false if unable to write
 * for any reason. */
bool flush_out_buf(struct buffered_file *file);


/* Creates buffered file.  Is not expected to fail. */
struct buffered_file *create_buffered_file(
    int sock, size_t in_buf_size, size_t out_buf_size);

/* Destroys buffered file, returns final error status. */
error__t destroy_buffered_file(struct buffered_file *file);

/* Returns the error status of the buffered file.  If false is returned then an
 * error condition has been detected. */
bool check_buffered_file(struct buffered_file *file);
