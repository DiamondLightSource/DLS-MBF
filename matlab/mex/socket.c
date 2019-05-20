/* Socket support for Matlab C extensions. */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdarg.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <errno.h>

#include "mex.h"

#include "socket.h"

/* This function is an undocumented Matlab API: calling this returns true if a
 * Ctrl-C interrupt has been signalled.  As well as this declaration, it is also
 * necessary to add -lut to the link step.
 *    Documentation of this can be found at the following links:
 *      http://www.caam.rice.edu/~wy1/links/mex_ctrl_c_trick/
 *      http://undocumentedmatlab.com/blog/mex-ctrl-c-interrupt
 */
extern bool utIsInterruptPending(void);


mxArray *create_double_array(
    size_t rows, size_t cols, double **reals, double **imags)
{
    mxComplexity type = imags ? mxCOMPLEX : mxREAL;
    mwSize dims[2] = { rows, cols };
    mxArray *array = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, type);
    *reals = mxGetData(array);
    if (imags)
        *imags = mxGetImagData(array);
    return array;
}

mxArray *create_single_array(
    size_t rows, size_t cols, float **reals, float **imags)
{
    mxComplexity type = imags ? mxCOMPLEX : mxREAL;
    mwSize dims[2] = { rows, cols };
    mxArray *array = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, type);
    *reals = mxGetData(array);
    if (imags)
        *imags = mxGetImagData(array);
    return array;
}


int connect_server(const char *hostname, int port)
{
    struct hostent *hostent = gethostbyname(hostname);
    TEST_OK_(hostent, "resolve", "Unable to resolve server \"%s\"", hostname);

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    TEST_IO(sock);
    /* Past this point we must take care to ensure that sock is closed before
     * generating any kind of error message! */

    struct sockaddr_in s_in = {
        .sin_family = AF_INET,
        .sin_port = htons(port),
    };
    memcpy(&s_in.sin_addr.s_addr, hostent->h_addr, (size_t) hostent->h_length);

    TEST_SOCK_(sock,
        connect(sock, (struct sockaddr *) &s_in, sizeof(s_in)) == 0,
        "connect", "Unable to connect to server %s:%d", hostname, port);

    /* Set timeout so we can catch interruption while waiting for the lock. */
    struct timeval timeval = { .tv_sec = 1, .tv_usec = 0 };
    TEST_SOCK(sock,
        setsockopt(
            sock, SOL_SOCKET, SO_RCVTIMEO, &timeval, sizeof(timeval)) == 0);

    return sock;
}


void send_command(int sock, const char *format, ...)
{
    char command[64];
    va_list args;
    va_start(args, format);
    size_t length = (size_t) vsnprintf(command, sizeof(command), format, args);
    va_end(args);

    write(sock, command, length);
    shutdown(sock, SHUT_WR);
}


/* Reads bytes until buffer is full or EOF, returns bytes read. */
static size_t read_buffer(int sock, void *buffer, size_t length)
{
    size_t total = 0;
    while (length > 0)
    {
        ssize_t bytes_read = read(sock, buffer, length);
        /* Check for timeout, retry if no interrupt. */
        if (bytes_read == -1  &&  errno == EAGAIN)
            TEST_SOCK_(sock,
                !utIsInterruptPending(), "interrupt", "Interrupted");
        else
        {
            TEST_SOCK(sock, bytes_read >= 0);
            if (bytes_read == 0)
                break;
            TEST_SOCK_(sock,
                !utIsInterruptPending(), "interrupt", "Interrupted");
            total  += (size_t) bytes_read;
            buffer += (size_t) bytes_read;
            length -= (size_t) bytes_read;
        }
    }
    return total;
}


void check_result(int sock)
{
    char message[256];
    TEST_SOCK(sock, read_buffer(sock, message, 1) == 1);
    if (message[0] != '\0')
    {
        /* Whoops, we have an error message to read. */
        size_t bytes_read = read_buffer(sock, message + 1, sizeof(message) - 1);
        IGNORE(close(sock));

        TEST_OK(message[bytes_read] == '\n');
        message[bytes_read] = '\0';
        FAIL_("server", message);
    }
}


size_t fill_buffer(
    int sock, void *buffer, size_t sample_size,
    size_t buffer_samples, size_t samples)
{
    size_t samples_to_read =
        samples > buffer_samples ? buffer_samples : samples;
    size_t bytes_to_read = sample_size * samples_to_read;
    TEST_SOCK_(sock, read_buffer(sock, buffer, bytes_to_read) == bytes_to_read,
        "read", "Unexpected end of input");
    return samples_to_read;
}
