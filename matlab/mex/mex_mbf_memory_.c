/* Matlab extension to support fast capture of fast memory data from the MBF
 * socket server.
 *
 * The function defined here must be called thus:
 *
 *      d = mex_mbf_memory_( ...
 *          hostname, port, bunches, count, offset, channel, locking);
 *
 * Data is captured from hostname:port starting from offset from trigger, and
 * the returned data is in an array of size
 *
 *      size(d) = [bunches * count, 2]
 *
 * If channel is 0 or 1 then only the requested channel of data is returned.
 * The locking parameter determines behaviour as follows:
 *      locking < 0  => No locking requested
 *      locking == 0 => Immediate lock only requested
 *      locking > 0  => Lock with timeout requested
 */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "mex.h"
#include "matrix.h"

#include "socket.h"


/* Convert samples into floats for matlab and transpose so that the layout is
 * appropriate for matlab. */
static void convert_samples(
    int16_t buffer[], size_t samples, float *data0, float *data1,
    unsigned int channel_count)
{
    /* There's no need to optimise this loop beyond the default: it works very
     * nicely. */
    for (size_t i = 0; i < samples; i ++)
    {
        *data0++ = *buffer++;
        if (channel_count > 1)
            *data1++ = *buffer++;
    }
}


/* This is chosen to match the output buffer size in socket_command.c */
#define BUFFER_SIZE     (1 << 14)


static void do_send_command(
    int sock, unsigned int count, int offset, int channel, double locking)
{
    char command[64];
    char *command_in = command;
    command_in += sprintf(command_in, "M%dO%d", count, offset);
    if (channel >= 0)
        command_in += sprintf(command_in, "C%d", channel);

    if (locking >= 0)
        command_in += sprintf(command_in, "L");
    if (locking > 0)
        command_in += sprintf(command_in, "W%u",
            (unsigned int) (locking * 1e3));

    send_command(sock, "%s\n", command);
    check_result(sock);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* We expect five arguments: hostname, port, bunches, count, offset. */
    TEST_OK_(nrhs == 7, "args", "Wrong number of arguments");
    /* We only assign one result. */
    TEST_OK_(nlhs <= 1, "result", "Wrong number of results");

    char hostname[256];
    TEST_OK_(mxGetString(prhs[0], hostname, sizeof(hostname)) == 0,
        "hostname", "Error reading hostname");
    int port    = (int) mxGetScalar(prhs[1]);
    unsigned int bunches = (unsigned int) mxGetScalar(prhs[2]);
    unsigned int count   = (unsigned int) mxGetScalar(prhs[3]);
    int offset  = (int) mxGetScalar(prhs[4]);
    int channel = (int) mxGetScalar(prhs[5]);
    double locking = mxGetScalar(prhs[6]);

    /* Allocate array to receive the result.  Do this before connecting to the
     * server so that matlab can clean up our memory if we fail. */
    unsigned int channel_count = channel >= 0 ? 1 : 2;
    size_t raw_samples = bunches * count;
    float *data0;
    plhs[0] = create_single_array(raw_samples, channel_count, &data0, NULL);
    float *data1 = data0 + raw_samples;

    /* Connect to server and send command.  Once we've allocated the socket we
     * have to make sure we close it before calling any error functions!
     * Fortunately after this point we don't call into Matlab anymore (except to
     * fail), so we're in control. */
    int sock = connect_server(hostname, port);
    do_send_command(sock, count, offset, channel, locking);

    /* Process data in reasonably sized chunks. */
    while (raw_samples > 0)
    {
        int16_t buffer[2 * BUFFER_SIZE];
        size_t samples_read = fill_buffer(
            sock, buffer, channel_count * sizeof(int16_t),
            BUFFER_SIZE, raw_samples);
        convert_samples(buffer, samples_read, data0, data1, channel_count);

        data0 += samples_read;
        data1 += samples_read;
        raw_samples -= samples_read;
    }

    close(sock);
}
