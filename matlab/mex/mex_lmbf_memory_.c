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

#include "mex.h"
#include "matrix.h"

#include "socket.h"


static double *create_array(mxArray *lhs[], int raw_samples)
{
    mxArray *array = mxCreateDoubleMatrix(raw_samples, 2, mxREAL);
    lhs[0] = array;
    return mxGetData(array);
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
    send_command(sock, "M%dO%d\n", count, offset);
    check_result(sock);

    /* Process data in reasonably sized chunks. */
    while (raw_samples > 0)
    {
        int16_t buffer[BUFFER_SIZE][2];
        int samples_read = fill_buffer(
            sock, buffer, 2 * sizeof(int16_t), BUFFER_SIZE, raw_samples);
        convert_samples(buffer, samples_read, data0, data1);

        data0 += samples_read;
        data1 += samples_read;
        raw_samples -= samples_read;
    }

    close(sock);
}
