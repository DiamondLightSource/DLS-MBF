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

    if (connect(sock, (struct sockaddr *) &s_in, sizeof(s_in)) != 0)
    {
        close(sock);
        FAIL_("connect", "Unable to connect to server %s:%d", hostname, port);
    }

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


int fill_buffer(
    int sock, void *buffer, int sample_size, int buffer_samples, int samples)
{
    int samples_to_read = samples > buffer_samples ? buffer_samples : samples;
    int bytes_to_read = sample_size * samples_to_read;

    /* Ensure we actually fill the buffer so that we don't have any nasty little
     * bits left over if a packet gets split somewhere along the line. */
    void *read_buffer = buffer;
    while (bytes_to_read > 0)
    {
        ssize_t bytes_read = read(sock, read_buffer, bytes_to_read);
        if (bytes_read <= 0)
        {
            close(sock);
            if (bytes_read == 0)
                FAIL_("read", "Unexpected end of input");
            else
                FAIL();
        }
        read_buffer += bytes_read;
        bytes_to_read -= bytes_read;
    }

    return samples_to_read;
}
