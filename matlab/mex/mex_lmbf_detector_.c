/* Matlab extension to support fast capture of detector data from the LMBF
 * socket server.
 *
 * The function defined here must be called thus:
 *
 *      [d,s,g,t] = mex_lmbf_detector_(hostname, port, bunches, channel);
 *
 * Data is captured from hostname:port and returned in an array of size
 *
 *      size(d) = [samples, detectors]
 *
 * where samples is the number of captured sequencer states, and detectors is
 * the number of active detectors.  The remaining results are optional and are:
 *
 *      s   Frequency scale in turns (of length samples) for detector values
 *      g   Group delay in radians per turn of captured data
 *      t   Timebase in turns (of length samples) of detector value
 */

#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <math.h>

#include "mex.h"
#include "matrix.h"

#include "socket.h"


#define BUFFER_SIZE     (1 << 13)


/* Two structures copied from the EPICS driver. */

/* Framing header sent at start of detector readout. */
struct detector_frame {
    uint8_t channel_count;
    uint8_t channel_mask;
    uint16_t delay;
    uint32_t samples;
};

/* Single detector sample: (I,Q). */
struct detector_result {
    int32_t i;
    int32_t q;
};



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


static void read_and_convert_samples(
    mxArray **lhs, int sock, int samples, int channels)
{
    double *reals[4], *imags[4];
    *lhs = create_array(samples, channels, &reals[0], &imags[0]);
    for (int i = 1; i < channels; i ++)
    {
        reals[i] = reals[0] + i * samples;
        imags[i] = imags[0] + i * samples;
    }

    /* Process data in reasonably sized chunks. */
    while (samples > 0)
    {
        int sample_size = sizeof(struct detector_result) * channels;
        struct detector_result buffer[BUFFER_SIZE * channels];
        int samples_read = fill_buffer(
            sock, buffer, sample_size, BUFFER_SIZE, samples);
        convert_samples(buffer, samples_read, channels, reals, imags);
        samples -= samples_read;
    }
}


static void read_and_convert_frequency(
    mxArray **lhs, int sock, int samples, int bunches)
{
    double *frequency;
    *lhs = create_array(samples, 1, &frequency, NULL);
    while (samples > 0)
    {
        uint32_t buffer[BUFFER_SIZE];
        int samples_read = fill_buffer(
            sock, buffer, sizeof(uint32_t), BUFFER_SIZE, samples);
        for (int i = 0; i < samples_read; i ++)
            *frequency++ = ldexp(buffer[i], -32) * bunches;
        samples -= samples_read;
    }
}


static void read_and_convert_timebase(mxArray **lhs, int sock, int samples)
{
    double *timebase;
    *lhs = create_array(samples, 1, &timebase, NULL);
    while (samples > 0)
    {
        uint32_t buffer[BUFFER_SIZE];
        int samples_read = fill_buffer(
            sock, buffer, sizeof(uint32_t), BUFFER_SIZE, samples);
        for (int i = 0; i < samples_read; i ++)
            *timebase++ = buffer[i];
        samples -= samples_read;
    }
}


static void send_group_delay(mxArray **lhs, int sock, int bunches, int delay)
{
    double *group_delay;
    *lhs = create_array(1, 1, &group_delay, NULL);
    *group_delay = 2.0 * M_PI * delay / bunches;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* We expect four arguments: hostname, port, bunches, channel. */
    TEST_OK_(nrhs == 4, "args", "Wrong number of arguments");
    /* Can assign up to three results. */
    TEST_OK_(nlhs <= 4, "result", "Too many results requested");

    char hostname[256];
    TEST_OK_(mxGetString(prhs[0], hostname, sizeof(hostname)) == 0,
        "hostname", "Error reading hostname");
    int port = (int) mxGetScalar(prhs[1]);
    int bunches = (int) mxGetScalar(prhs[2]);
    int channel = (int) mxGetScalar(prhs[3]);

    /* Connect to server and send command.  Once we've allocated the socket we
     * have to make sure we close it before calling any error functions! */
    int sock = connect_server(hostname, port);
    send_command(sock, "D%dF%s%s\n",
        channel, nlhs >= 2 ? "S" : "", nlhs >= 3 ? "T" : "");
    check_result(sock);

    /* Start by reading the frame so we know what data to expect. */
    struct detector_frame frame;
    fill_buffer(sock, &frame, sizeof(frame), 1, 1);

    read_and_convert_samples(
        &plhs[0], sock, frame.samples, frame.channel_count);
    if (nlhs >= 2)
        read_and_convert_frequency(&plhs[1], sock, frame.samples, bunches);
    if (nlhs >= 3)
        send_group_delay(&plhs[2], sock, bunches, frame.delay);
    if (nlhs >= 4)
        read_and_convert_timebase(&plhs[3], sock, frame.samples);

    close(sock);
}
