#include <stdbool.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "error.h"

#include "buffered_file.h"


/*****************************************************************************/
/* Buffered file handling.
 *
 * You'd think the obvious solution was to use fdopen() to wrap the socket in a
 * stream and then lean on the easy to use stream functions.  Alas, it would
 * seem that this doesn't work terribly well with a socket interface.  The most
 * obvious problem is that if multiple commands are sent in one block they're
 * not all received!
 *
 * So we write our own buffered file handling.  Ho hum.  At least we can tweak
 * the API to suit.
 *
 * Actually, there is an alternative: apparently if we dup(2) the socket handle
 * and call fdopen twice we then get two streams which can each be treated as a
 * unidirectional stream. */

/* The input and output buffers are managed somewhat differently: we always
 * flush the entire output buffer, but the input buffer is read and filled
 * piecemeal. */
struct buffered_file {
    int sock;                   // Socket handle to read
    bool eof;                   // Set once end of input encountered
    error__t error;             // Any error blocks all further IO processing
    size_t in_length;           // Length of data currently in in_buf
    size_t read_ptr;            // Start of readout data from in_buf
    size_t out_length;          // Length of data in out_buf
    size_t in_buf_size;         // Length of input buffer
    size_t out_buf_size;        // Length of output buffer
    char *in_buf;               // Input buffer
    char *out_buf;              // Output buffer
};


/* Does what is necessary to send the entire given buffer to the socket. */
static void send_entire_buffer(
    struct buffered_file *file, const void *buffer, size_t length)
{
    while (!file->error  &&  length > 0)
    {
        ssize_t written;
        file->error =
            TEST_IO_(written = write(file->sock, buffer, length),
                "Error writing to socket")  ?:
            DO( length -= (size_t) written;
                buffer += (size_t) written);
    }
}


/* Writes out the entire output buffer, retrying as necessary to ensure it's all
 * gone. */
bool flush_out_buf(struct buffered_file *file)
{
    send_entire_buffer(file, file->out_buf, file->out_length);
    file->out_length = 0;
    return !file->error;
}


/* Reads what data is available into the input buffer. */
static void fill_in_buf(struct buffered_file *file)
{
    if (!file->eof  &&  !file->error)
    {
        ssize_t seen;
        file->error = TEST_IO_(
            seen = read(file->sock, file->in_buf, file->in_buf_size),
            "Error reading from socket");
        file->eof = seen == 0;
        file->read_ptr = 0;
        file->in_length = (size_t) seen;
    }
}


/* Fills the buffer as necessary to return a line.  False is returned if eof or
 * an error was encountered first.  We also flush the out buffer if the buffer
 * needs filling so that the other side of the conversation has a chance to keep
 * up. */
bool read_line(
    struct buffered_file *file, char line[], size_t line_size, bool flush)
{
    while (!file->eof  &&  !file->error)
    {
        /* See if we've got a line in the buffer. */
        size_t data_avail = file->in_length - file->read_ptr;
        char *data_start = file->in_buf + file->read_ptr;
        char *newline = memchr(data_start, '\n', data_avail);
        if (newline)
        {
            size_t line_length = (size_t) (newline - data_start);
            file->error = TEST_OK_(line_length + 1 < line_size, "Line overrun");
            if (file->error)
                return false;
            else
            {
                memcpy(line, data_start, line_length);
                file->read_ptr += line_length + 1;
                line[line_length] = '\0';
                return true;
            }
        }

        /* Not enough data.  Empty what we have into the line, refill the
         * buffer, and try again. */
        file->error = TEST_OK_(data_avail + 1 < line_size, "Line overrun");
        if (file->error)
            return false;

        memcpy(line, data_start, data_avail);
        line += data_avail;
        line_size -= data_avail;

        if (flush)
            flush_out_buf(file);
        flush = false;
        fill_in_buf(file);
    }
    return false;
}


/* This reads a fixed size block of data, returns false if the entire block
 * cannot be read for any reason. */
bool read_block(struct buffered_file *file, char data[], size_t length)
{
    while (!file->eof  &&  !file->error  &&  length > 0)
    {
        /* Copy what we've got to the destination. */
        size_t to_copy = MIN(file->in_length - file->read_ptr, length);
        memcpy(data, file->in_buf + file->read_ptr, to_copy);
        data += to_copy;
        length -= to_copy;
        file->read_ptr += to_copy;

        if (length > 0)
            fill_in_buf(file);
    }
    return !file->eof  &&  !file->error  &&  length == 0;
}


/* Writes a character array to the output buffer, flushing it to make room if
 * needed. */
bool write_string(
    struct buffered_file *file, const char string[], size_t length)
{
    while (!file->error  &&  length > 0)
    {
        /* Put as much of the string as possible into out_buf. */
        size_t to_write = MIN(file->out_buf_size - file->out_length, length);
        memcpy(file->out_buf + file->out_length, string, to_write);
        string += to_write;
        length -= to_write;
        file->out_length += to_write;

        /* If out_buf is full, send it. */
        if (file->out_length >= file->out_buf_size)  // Only == is possible!
            flush_out_buf(file);
    }
    return !file->error;
}


bool write_formatted_string(
    struct buffered_file *file, const char *format, ...)
{
    if (file->error)
        return false;

    va_list args;

    /* First try writing into the buffer as is. */
    size_t length = file->out_buf_size - file->out_length;
    va_start(args, format);
    size_t written = (size_t) vsnprintf(
        file->out_buf + file->out_length, length, format, args);
    va_end(args);

    if (written < length)
        /* Good, job done. */
        file->out_length += (size_t) written;
    else
    {
        /* Not enough room.  Flush the buffer and try again. */
        if (flush_out_buf(file))
        {
            va_start(args, format);
            file->out_length = (size_t) vsnprintf(
                file->out_buf, file->out_buf_size, format, args);
            va_end(args);

            file->error =
                TEST_OK_(file->out_length < file->out_buf_size,
                    "Formatted string too long for buffered output");
        }
    }

    return !file->error;
}


bool write_block(struct buffered_file *file, const void *buffer, size_t length)
{
    flush_out_buf(file);
    send_entire_buffer(file, buffer, length);
    return !file->error;
}


/* As we guarantee that there's always room for one character in the output
 * buffer (we always flush when full) this function can be quite simple. */
bool write_char(struct buffered_file *file, char ch)
{
    if (!file->error)
    {
        file->out_buf[file->out_length++] = ch;
        if (file->out_length >= file->out_buf_size)
            flush_out_buf(file);
    }
    return !file->error;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


struct buffered_file *create_buffered_file(
    int sock, size_t in_buf_size, size_t out_buf_size)
{
    struct buffered_file *file = malloc(sizeof(struct buffered_file));
    *file = (struct buffered_file) {
        .sock = sock,
        .in_buf_size = in_buf_size,
        .out_buf_size = out_buf_size,
        .in_buf = malloc(in_buf_size),
        .out_buf = malloc(out_buf_size),
    };
    return file;
}

error__t destroy_buffered_file(struct buffered_file *file)
{
    error__t error = file->error;
    free(file->in_buf);
    free(file->out_buf);
    free(file);
    return error;
}

bool check_buffered_file(struct buffered_file *file)
{
    return !file->error;
}
