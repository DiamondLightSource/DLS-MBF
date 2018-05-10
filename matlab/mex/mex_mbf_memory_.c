/* Matlab extension to support fast capture of fast memory data from the MBF
 * socket server.
 *
 * The function defined here must be called thus:
 *
 *      d = mex_mbf_memory_( ...
 *          hostname, port, bunches, count, offset, channel, locking, tune,
 *          decimate);
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
#include <stdint.h>
#include <math.h>
#include <complex.h>

#include "mex.h"
#include "matrix.h"

#include "socket.h"


/* This is chosen to match the output buffer size in socket_command.c */
#define BUFFER_SIZE     (1 << 14)


/* These two definitions are copied from epics/src/socket_command.c */
struct memory_frame {
    uint32_t samples;       // Number of samples that will be sent
    uint16_t channels;      // Number of channels per sample (1 or 2)
    uint16_t format;        // 0 => int16, 1 => float32, 2 => complex
};

enum memory_data_format {
    FORMAT_INT16,
    FORMAT_FLOAT32,
    FORMAT_COMPLEX64,
};


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Read and convert. */

/* Convert samples into floats for matlab and transpose so that the layout is
 * appropriate for Matlab.  Note that the time taken to do the transpose here,
 * rather than afterwards in Matlab, does actually pay off. */

static void convert_int16_samples(
    int16_t buffer[], size_t samples, float *data0, float *data1,
    unsigned int channels)
{
    for (size_t i = 0; i < samples; i ++)
    {
        *data0++ = *buffer++;
        if (channels > 1)
            *data1++ = *buffer++;
    }
}


static void read_and_convert_int16(
    mxArray **lhs, int sock, size_t samples, unsigned int channels)
{
    /* Create array of floats for result. */
    float *data0;
    *lhs = create_single_array(samples, channels, &data0, NULL);
    float *data1 = data0 + samples;

    /* Read and convert samples. */
    /* Process data in reasonably sized chunks. */
    while (samples > 0)
    {
        int16_t buffer[2 * BUFFER_SIZE];
        size_t samples_read = fill_buffer(
            sock, buffer, channels * sizeof(int16_t), BUFFER_SIZE, samples);
        convert_int16_samples(buffer, samples_read, data0, data1, channels);

        data0 += samples_read;
        data1 += samples_read;
        samples -= samples_read;
    }
}


static void convert_float32_samples(
    float buffer[], size_t samples, float *data0, float *data1,
    unsigned int channels)
{
    for (size_t i = 0; i < samples; i ++)
    {
        *data0++ = *buffer++;
        if (channels > 1)
            *data1++ = *buffer++;
    }
}


static void read_and_convert_float32(
    mxArray **lhs, int sock, size_t samples, unsigned int channels)
{
    /* Create array of floats for result. */
    float *data0;
    *lhs = create_single_array(samples, channels, &data0, NULL);
    float *data1 = data0 + samples;

    /* Read and convert samples. */
    /* Process data in reasonably sized chunks. */
    while (samples > 0)
    {
        float buffer[2 * BUFFER_SIZE];
        size_t samples_read = fill_buffer(
            sock, buffer, channels * sizeof(float), BUFFER_SIZE, samples);
        convert_float32_samples(buffer, samples_read, data0, data1, channels);

        data0 += samples_read;
        data1 += samples_read;
        samples -= samples_read;
    }
}


static void convert_complex64_samples(
    float complex buffer[], size_t samples,
    float *real0, float *real1, float *imag0, float *imag1,
    unsigned int channels)
{
    for (size_t i = 0; i < samples; i ++)
    {
        *real0++ = crealf(*buffer);
        *imag0++ = cimagf(*buffer);
        buffer += 1;
        if (channels > 1)
        {
            *real1++ = crealf(*buffer);
            *imag1++ = cimagf(*buffer);
            buffer += 1;
        }
    }
}


static void read_and_convert_complex64(
    mxArray **lhs, int sock, size_t samples, unsigned int channels)
{
    /* Create array of floats for result. */
    float *real0, *imag0;
    *lhs = create_single_array(samples, channels, &real0, &imag0);
    float *real1 = real0 + samples;
    float *imag1 = imag0 + samples;

    /* Read and convert samples. */
    /* Process data in reasonably sized chunks. */
    while (samples > 0)
    {
        float complex buffer[2 * BUFFER_SIZE];
        size_t samples_read = fill_buffer(
            sock, buffer, channels * sizeof(float complex),
            BUFFER_SIZE, samples);
        convert_complex64_samples(
            buffer, samples_read, real0, real1, imag0, imag1, channels);

        real0 += samples_read;
        real1 += samples_read;
        imag0 += samples_read;
        imag1 += samples_read;
        samples -= samples_read;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* Convert fractional tune in cycles per machine revolution to phase advance per
 * bunch in hardware units.
 *
 * This code is lifted from epics/src/common.c. */
unsigned int tune_to_freq(unsigned int bunches, double tune)
{
    /* Convert the incoming tune in cycles per machine revolution into phase
     * advance per bunch by scaling and reducing to the half open interval
     * [0, 1). */
    double integral;
    double fraction = modf(tune / bunches, &integral);
    if (fraction < 0.0)
        fraction += 1.0;
    /* Can now scale up to hardware units. */
    return (unsigned int) round(ldexp(fraction, 32));
}


static void do_send_command(
    int sock, unsigned int count, int offset, int channel, double locking,
    unsigned int bunches, double tune, unsigned int decimate)
{
    char command[64];
    char *command_in = command;
    command_in += sprintf(command_in, "M%dFO%d", count, offset);
    if (channel >= 0)
        command_in += sprintf(command_in, "C%d", channel);

    if (decimate > 1)
        command_in += sprintf(command_in, "D%u", decimate);
    if (tune != 0)
        command_in += sprintf(command_in, "T%u", tune_to_freq(bunches, tune));

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
    TEST_OK_(nrhs == 9, "args", "Wrong number of arguments");
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
    double tune = mxGetScalar(prhs[7]);
    unsigned int decimate = (unsigned int) mxGetScalar(prhs[8]);

    TEST_OK_(decimate > 0, "decimate", "Invalid decimation");

    /* Connect to server and send command.  Once we've allocated the socket we
     * have to make sure we close it before calling any error functions!
     * Fortunately after this point we don't call into Matlab anymore (except to
     * fail), so we're in control. */
    int sock = connect_server(hostname, port);
    do_send_command(
        sock, count, offset, channel, locking, bunches, tune, decimate);

    struct memory_frame frame;
    fill_buffer(sock, &frame, sizeof(frame), 1, 1);

    switch (frame.format)
    {
        case FORMAT_INT16:
            read_and_convert_int16(
                &plhs[0], sock, frame.samples, frame.channels);
            break;
        case FORMAT_FLOAT32:
            read_and_convert_float32(
                &plhs[0], sock, frame.samples, frame.channels);
            break;
        case FORMAT_COMPLEX64:
            read_and_convert_complex64(
                &plhs[0], sock, frame.samples, frame.channels);
            break;
        default:
            FAIL();     // Really should not happen!
    }

    close(sock);
}
