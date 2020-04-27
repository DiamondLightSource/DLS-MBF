/* Matlab extension to support fast capture of detector data from the MBF
 * socket server.
 *
 * The function defined here must be called thus:
 *
 *      [d,s,g,t] = mex_mbf_detector_(hostname, port, axis, locking);
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
 *
 * The locking parameter determines behaviour as follows:
 *      locking < 0  => No locking requested
 *      locking == 0 => Immediate lock only requested
 *      locking > 0  => Lock with timeout requested
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
    uint8_t detector_count;
    uint8_t detector_mask;
    uint16_t delay;
    uint32_t samples;
    uint32_t bunches;
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
    size_t samples, unsigned int channels,
    double *reals[], double *imags[])
{
    /* There's no need to optimise this loop beyond the default: it works very
     * nicely. */
    for (size_t i = 0; i < samples; i ++)
    {
        for (unsigned int j = 0; j < channels; j ++)
        {
            /* Take conjugate of captured data here to compensate for capture of
             * "negative" frequencies in detector. */
            *reals[j]++ = ldexp(buffer->i, -31);
            *imags[j]++ = -ldexp(buffer->q, -31);
            buffer += 1;
        }
    }
}


static void read_and_convert_samples(
    mxArray **lhs, int sock, size_t samples, unsigned int channels)
{
    double *reals[4], *imags[4];
    *lhs = create_double_array(samples, channels, &reals[0], &imags[0]);
    for (unsigned int i = 1; i < channels; i ++)
    {
        reals[i] = reals[0] + i * samples;
        imags[i] = imags[0] + i * samples;
    }

    /* Process data in reasonably sized chunks. */
    while (samples > 0)
    {
        size_t sample_size = sizeof(struct detector_result) * channels;
        struct detector_result buffer[BUFFER_SIZE * channels];
        size_t samples_read = fill_buffer(
            sock, buffer, sample_size, BUFFER_SIZE, samples);
        convert_samples(buffer, samples_read, channels, reals, imags);
        samples -= samples_read;
    }
}


static void read_and_convert_frequency(
    mxArray **lhs, int sock, size_t samples, unsigned int bunches)
{
    double *frequency;
    *lhs = create_double_array(samples, 1, &frequency, NULL);
    while (samples > 0)
    {
        uint64_t buffer[BUFFER_SIZE];
        size_t samples_read = fill_buffer(
            sock, buffer, sizeof(uint64_t), BUFFER_SIZE, samples);
        for (size_t i = 0; i < samples_read; i ++)
            *frequency++ = ldexp((double) buffer[i], -48) * bunches;
        samples -= samples_read;
    }
}


static void read_and_convert_timebase(mxArray **lhs, int sock, size_t samples)
{
    double *timebase;
    *lhs = create_double_array(samples, 1, &timebase, NULL);
    while (samples > 0)
    {
        uint32_t buffer[BUFFER_SIZE];
        size_t samples_read = fill_buffer(
            sock, buffer, sizeof(uint32_t), BUFFER_SIZE, samples);
        for (size_t i = 0; i < samples_read; i ++)
            *timebase++ = buffer[i];
        samples -= samples_read;
    }
}


static void send_group_delay(
    mxArray **lhs, int sock, unsigned int bunches, unsigned int delay)
{
    double *group_delay;
    *lhs = create_double_array(1, 1, &group_delay, NULL);
    *group_delay = 2.0 * M_PI * delay / bunches;
}


static void do_send_command(
    int sock, unsigned int axis, bool timebase, double locking)
{
    char command[64];
    char *command_in = command;
    command_in += sprintf(command_in, "D%uFSL", axis);
    if (timebase)
        command_in += sprintf(command_in, "T");

    if (locking >= 0)
        command_in += sprintf(command_in, "L");
    if (locking > 0)
        command_in += sprintf(command_in, "W%d",
            (unsigned int) (locking * 1e3));

    send_command(sock, "%s\n", command);
    check_result(sock);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* We expect a fixed number of arguments. */
    TEST_OK_(nrhs == 4, "args", "Wrong number of arguments");
    /* Can assign up to four results, expect three. */
    TEST_OK_(nlhs >= 3, "result", "Too few results requested");
    TEST_OK_(nlhs <= 4, "result", "Too many results requested");

    /* Read out arguments in precise order. */
    char hostname[256];
    TEST_OK_(mxGetString(*prhs++, hostname, sizeof(hostname)) == 0,
        "hostname", "Error reading hostname");
    int port = (int) mxGetScalar(*prhs++);
    unsigned int axis = (unsigned int) mxGetScalar(*prhs++);
    double locking = mxGetScalar(*prhs++);

    /* Connect to server and send command.  Once we've allocated the socket we
     * have to make sure we close it before calling any error functions! */
    int sock = connect_server(hostname, port);
    do_send_command(sock, axis, nlhs > 3, locking);

    /* Start by reading the frame so we know what data to expect. */
    struct detector_frame frame;
    fill_buffer(sock, &frame, sizeof(frame), 1, 1);

    read_and_convert_samples(
        &plhs[0], sock, frame.samples, frame.detector_count);
    if (nlhs >= 2)
        read_and_convert_frequency(
            &plhs[1], sock, frame.samples, frame.bunches);
    if (nlhs >= 3)
        send_group_delay(&plhs[2], sock, frame.bunches, frame.delay);
    if (nlhs >= 4)
        read_and_convert_timebase(&plhs[3], sock, frame.samples);

    close(sock);
}
