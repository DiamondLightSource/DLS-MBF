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

#include "mex.h"

#include "socket.h"


mxArray *create_double_array(int rows, int cols, double **reals, double **imags)
{
    mxComplexity type = imags ? mxCOMPLEX : mxREAL;
    mwSize dims[2] = { rows, cols };
    mxArray *array = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, type);
    *reals = mxGetData(array);
    if (imags)
        *imags = mxGetImagData(array);
    return array;
}

mxArray *create_single_array(int rows, int cols, float **reals, float **imags)
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
    memcpy(&s_in.sin_addr.s_addr, hostent->h_addr, hostent->h_length);

    TEST_SOCK_(sock,
        connect(sock, (struct sockaddr *) &s_in, sizeof(s_in)) == 0,
        "connect", "Unable to connect to server %s:%d", hostname, port);
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
static int read_buffer(int sock, void *buffer, int length)
{
    int total = 0;
    while (length > 0)
    {
        ssize_t bytes_read = read(sock, buffer, length);
        TEST_SOCK(sock, bytes_read >= 0);
        if (bytes_read == 0)
            break;
        total += bytes_read;
        buffer += bytes_read;
        length -= bytes_read;
    }
    return total;
}


void check_result(int sock)
{
    char message[256];
    TEST_SOCK(sock, read(sock, message, 1) == 1);
    if (message[0] != '\0')
    {
        /* Whoops, we have an error message to read. */
        int bytes_read = read_buffer(sock, message + 1, sizeof(message) - 1);
        close(sock);

        TEST_OK(message[bytes_read] == '\n');
        message[bytes_read] = '\0';
        FAIL_("server", message);
    }
}


int fill_buffer(
    int sock, void *buffer, int sample_size, int buffer_samples, int samples)
{
    int samples_to_read = samples > buffer_samples ? buffer_samples : samples;
    int bytes_to_read = sample_size * samples_to_read;
    TEST_SOCK_(sock, read_buffer(sock, buffer, bytes_to_read) == bytes_to_read,
        "read", "Unexpected end of input");
    return samples_to_read;
}
