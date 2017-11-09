/* Matlab extension to support fast capture of fast memory data from the LMBF
 * socket server.
 *
 * The function defined here must be called thus:
 *
 *      d = lmbf_memory_mex(hostname, port, bunches, count, offset);
 *
 * Data is captured from hostname:port starting from offset from trigger, and
 * the returned data is in an array of size
 *
 *      size(d) = [bunches * count, 2]
 */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "mex.h"
#include "matrix.h"


/* Some simple error handling macros.  They all call mexErrMsgIdAndTxt() which
 * does not return, instead either uses longjmp or a C++ exception. */
#define FAIL_(id, error...) \
    mexErrMsgIdAndTxt("lmbf_memory_mex:" id, error)
#define FAIL() \
    FAIL_("unexpected", "Unexpected error")
#define TEST_OK_(test, id, error...) \
    do if (!(test)) \
        FAIL_(id, error); \
    while (0)
#define TEST_IO_(test, id, error...) \
    TEST_OK_((test) != -1, id, error)
#define TEST_IO(test)   TEST_IO_(test, "unexpected", "Unexpected error")


/* Connects to socket server, if possible, returning connected socket if
 * successful.  If this function returns the caller MUST close the returned
 * socket handle before returning control to matlab. */
static int connect_server(const char *hostname, int port)
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


static void send_command(int sock, int count, int offset)
{
    char command[64];
    size_t length = (size_t) sprintf(command, "MR%dO%d\n", count, offset);
    write(sock, command, length);
    shutdown(sock, SHUT_WR);
}


static double *create_array(mxArray *lhs[], int raw_samples)
{
    mxArray *array = mxCreateDoubleMatrix(raw_samples, 2, mxREAL);
    lhs[0] = array;
    return mxGetData(array);
}


/* Fill given buffer from the socket. */
static int fill_buffer(
    int sock, int16_t buffer[][2], int buffer_size, int samples)
{
    int samples_to_read = samples > buffer_size ? buffer_size : samples;
    int bytes_to_read = 4 * samples_to_read;

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


/* Convert samples into doubles for matlab and transpose so that the layout is
 * appropriate for matlab. */
static void convert_samples(
    int16_t buffer[][2], int samples, double *data0, double *data1)
{
    /* There's no need to optimise this loop beyond the default: it works very
     * nicely. */
    for (int i = 0; i < samples; i ++)
    {
        *data0++ = buffer[i][0];
        *data1++ = buffer[i][1];
    }
}


/* This is chosen to match the output buffer size in socket_command.c */
#define BUFFER_SIZE     (1 << 14)


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* We expect five arguments: hostname, port, bunches, count, offset. */
    TEST_OK_(nrhs == 5, "args", "Wrong number of arguments");
    /* We only assign one result. */
    TEST_OK_(nlhs <= 1, "result", "Wrong number of results");

    char hostname[256];
    TEST_OK_(mxGetString(prhs[0], hostname, sizeof(hostname)) == 0,
        "hostname", "Error reading hostname");
    int port = (int) mxGetScalar(prhs[1]);
    int bunches = (int) mxGetScalar(prhs[2]);
    int count = (int) mxGetScalar(prhs[3]);
    int offset = (int) mxGetScalar(prhs[4]);

    /* Allocate array to receive the result.  Do this before connecting to the
     * server so that matlab can clean up our memory if we fail. */
    int raw_samples = bunches * count;
    double *data0 = create_array(plhs, raw_samples);
    double *data1 = data0 + raw_samples;

    /* Connect to server and send command.  Once we've allocated the socket we
     * have to make sure we close it before calling any error functions!
     * Fortunately after this point we don't call into Matlab anymore (except to
     * fail), so we're in control. */
    int sock = connect_server(hostname, port);
    send_command(sock, count, offset);

    /* Process data in reasonably sized chunks. */
    while (raw_samples > 0)
    {
        int16_t buffer[BUFFER_SIZE][2];
        int samples_read = fill_buffer(sock, buffer, BUFFER_SIZE, raw_samples);
        convert_samples(buffer, samples_read, data0, data1);

        data0 += samples_read;
        data1 += samples_read;
        raw_samples -= samples_read;
    }

    close(sock);
}
