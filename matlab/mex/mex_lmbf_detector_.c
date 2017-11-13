/* Matlab extension to support fast capture of detector data from the LMBF
 * socket server.
 *
 * The function defined here must be called thus:
 *
 *      d = lmbf_detector_mex(hostname, port, channel);
 *
 * Data is captured from hostname:port and returned in an array of size
 *
 *      size(d) = [samples, channels]
 *
 * where samples is the number of captured sequencer states, and channels is the
 * number of active detectors.
 */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>

#include "mex.h"
#include "matrix.h"

#include "socket.h"


/* Two structures copied from the EPICS driver. */

/* Framing header sent at start of detector readout. */
struct detector_frame {
    uint32_t channels;
    uint32_t samples;
};

/* Single detector sample: (I,Q). */
struct detector_result {
    int32_t i;
    int32_t q;
};


static void create_array(
    mxArray *lhs[], int samples, int channels,
    double **reals, double **imags)
{
    mxArray *array = mxCreateDoubleMatrix(samples, channels, mxCOMPLEX);
    lhs[0] = array;
    *reals = mxGetData(array);
    *imags = mxGetImagData(array);
}


/* Convert samples into doubles for matlab and transpose so that the layout is
 * appropriate for matlab. */
static void convert_samples(
    struct detector_result buffer[],
    unsigned int samples, unsigned int channels,
    double *reals[], double *imags[])
{
    /* There's no need to optimise this loop beyond the default: it works very
     * nicely. */
    for (unsigned int i = 0; i < samples; i ++)
    {
        for (unsigned int j = 0; j < channels; j ++)
        {
            *reals[j]++ = buffer->i;
            *imags[j]++ = buffer->q;
            buffer += 1;
        }
    }
}


#define BUFFER_SIZE     (1 << 13)


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* We expect five arguments: hostname, port, bunches, count, offset. */
    TEST_OK_(nrhs == 3, "args", "Wrong number of arguments");
    /* We only assign one result. */
    TEST_OK_(nlhs <= 1, "result", "Wrong number of results");

    char hostname[256];
    TEST_OK_(mxGetString(prhs[0], hostname, sizeof(hostname)) == 0,
        "hostname", "Error reading hostname");
    int port = (int) mxGetScalar(prhs[1]);
    int channel = (int) mxGetScalar(prhs[2]);

    /* Connect to server and send command.  Once we've allocated the socket we
     * have to make sure we close it before calling any error functions! */
    int sock = connect_server(hostname, port);
    send_command(sock, "D%dF\n", channel);
    check_result(sock);

    /* Start by reading the frame so we know what data to expect. */
    struct detector_frame frame;
    fill_buffer(sock, &frame, sizeof(frame), 1, 1);

    /* Create the data array.  Alas, if this fails due to out of memory we will
     * leak a socket, and we can't fix this without resorting to C++ exception
     * handling. */
    double *reals[4], *imags[4];
    create_array(plhs, frame.samples, frame.channels, &reals[0], &imags[0]);
    for (unsigned int i = 1; i < frame.channels; i ++)
    {
        reals[i] = reals[0] + i * frame.samples;
        imags[i] = imags[0] + i * frame.samples;
    }

    /* Process data in reasonably sized chunks. */
    int samples = frame.samples;
    while (samples > 0)
    {
        int sample_size = sizeof(struct detector_result) * frame.channels;
        struct detector_result buffer[BUFFER_SIZE * frame.channels];
        int samples_read = fill_buffer(
            sock, buffer, sample_size, BUFFER_SIZE, samples);
        convert_samples(buffer, samples_read, frame.channels, reals, imags);
        samples -= samples_read;
    }

    close(sock);
}
