/* Socket server command implementation. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "error.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "parse.h"
#include "buffered_file.h"
#include "memory.h"
#include "detector.h"
#include "sequencer.h"

#include "socket_command.h"


static bool report_error(
    struct buffered_file *file,
    error__t error, const char *command, bool raw_mode)
{
    if (raw_mode)
    {
        ERROR_REPORT(error, "Error parsing \"%s\"", command);
        return false;
    }
    else
    {
        write_formatted_string(file, "%s\n", error_format(error));
        error_discard(error);
        return true;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* MEM capture readout. */

/* The correct read buffer size is slightly delicate.  We want all reads from
 * DRAM0 to complete in a single DMA transfer where possible.  The internal DMA
 * buffer size is 1MB (as defined by the kernel, see DMA_BLOCK_SHIFT in
 * driver/dma_control.c), so we want our buffer to be 1MB ... except, we also
 * need to allow for buffer alignment, both for start and length.  All DMA
 * transfers are in 32-byte chunks, so we subtract 64 bytes from our length. */
#define READ_BUFFER_BYTES       ((1 << 20) - 64)

/* The write buffer size is less difficult.  We want it to be large enough to
 * keep the socket data flowing efficiently, but not so large as to provoke
 * stack overflow for our smaller thread stack. */
#define WRITE_BUFFER_BYTES      (1 << 16)


static void send_converted_memory_data(
    struct buffered_file *file, size_t read_samples,
    unsigned int d0, unsigned int d1, const uint32_t read_buffer[],
    const bool channels[2])

{
    while (read_samples > 0)
    {
        int16_t write_buffer[WRITE_BUFFER_BYTES / sizeof(int16_t)];
        size_t write_samples = MIN(read_samples, ARRAY_SIZE(write_buffer) / 2);
        int16_t *write_buf = write_buffer;
        for (size_t i = 0; i < write_samples; i ++)
        {
            if (channels[0])
                *write_buf++ = (int16_t) read_buffer[i + d0];
            if (channels[1])
                *write_buf++ = (int16_t) (read_buffer[i + d1] >> 16);
        }

        write_block(
            file, write_buffer,
            sizeof(int16_t) * (size_t) (write_buf - write_buffer));

        read_samples -= write_samples;
        read_buffer += write_samples;
    }
}


static void send_memory_data(
    struct buffered_file *file, unsigned int count, int offset_turns,
    const bool channels[2])
{
    /* Convert count and offset into a byte offset from the trigger and a number
     * of samples. */
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    size_t samples = count * bunches_per_turn;
    size_t offset = compute_dram_offset(offset_turns);
    /* Pick up the channel skew factors. */
    unsigned int d0, d1;
    get_memory_channel_delays(&d0, &d1);

    while (samples > 0)
    {
        /* To allow for offset compensation, we need to read one extra turn
         * which we don't include in the sample count. */
        uint32_t read_buffer[READ_BUFFER_BYTES / sizeof(uint32_t)];
        size_t samples_extra = samples + bunches_per_turn;
        size_t read_samples = MIN(samples_extra, ARRAY_SIZE(read_buffer));
        hw_read_dram_memory(offset, read_samples, read_buffer);

        read_samples -= bunches_per_turn;
        send_converted_memory_data(
            file, read_samples, d0, d1, read_buffer, channels);
        samples -= read_samples;
        offset += read_samples * sizeof(uint32_t);
    }
}


/* Supports command of the form:
 *
 *      M [R] count [O offset] [C channel]
 *
 * Returns memory captured into memory with the following options:
 *
 *      R   If set then only raw data is returned and the connection is closed
 *          if a parse error occurs.
 *      count
 *          Number of turns of data to capture.
 *      O offset
 *          Starting offset in turns, default to 0.
 *      C channel
 *          If requested, only the one channel will be transmitted, halving the
 *          data transmitted.
 */
bool process_memory_command(struct buffered_file *file, const char *command)
{
    const char *command_in = command;
    unsigned int count = 0;
    int offset = 0;
    bool raw_mode = false;
    int channel = -1;
    error__t error =
        parse_char(&command, 'M')  ?:
        DO(raw_mode = read_char(&command, 'R'))  ?:
        parse_uint(&command, &count)  ?:
        IF(read_char(&command, 'O'),
            parse_int(&command, &offset))  ?:
        IF(read_char(&command, 'C'),
            parse_int(&command, &channel)  ?:
            TEST_OK_(0 <= channel  &&  channel < CHANNEL_COUNT,
                "Invalid channel number"))  ?:
        parse_eos(&command);

    if (error)
        error_extend(error, "Parse error at offset %zu", command - command_in);

    if (error)
        return report_error(file, error, command_in, raw_mode);
    else
    {
        bool channels[2] = { true, true };
        if (channel >=0)
            channels[1 - channel] = false;

        if (!raw_mode)
            write_char(file, '\0');
        send_memory_data(file, count, offset, channels);
        return true;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* DET detector readout. */

/* Same content as detector_info, but fixed size words. */
struct detector_frame {
    uint8_t detector_count;
    uint8_t detector_mask;
    uint16_t delay;
    uint32_t samples;
};


/* This structure captures the parsed results of a detector request command of
 * the form:
 *
 *      D [R] channel [F] [S] [T]
 *
 * Returns detector readout with the following options:
 *
 *      R   If set then only raw data is returned and the connection is closed
 *          if a parse error occurs.
 *      channel
 *          Specifies which channel is being read.
 *      F   Request that the number of detectors and samples is sent as a header
 *          before sending the raw data.
 *      S   Request that the frequency scale for the detector is transmitted
 *          after sending the channel data.
 *      T   Request that the timebase for the detector is transmitted after the
 *          channel data, and after the frequency scale if requested.
 */
struct detector_args {
    bool raw_mode;                  // R    Don't send ok header
    int channel;                    //      Detector channel
    bool framed;                    // F    Send header frame
    bool scale;                     // S    Send frequency scale
    bool timebase;                  // T    Send timebase
};


/* Parsing of detector readout command. */
static error__t parse_detector_args(
    const char *command, struct detector_args *args)
{
    const char *command_in = command;
    *args = (struct detector_args) { };
    error__t error =
        parse_char(&command, 'D')  ?:
        DO(args->raw_mode = read_char(&command, 'R'))  ?:
        parse_int(&command, &args->channel)  ?:
        DO(args->framed = read_char(&command, 'F'))  ?:
        DO(args->scale = read_char(&command, 'S'))  ?:
        DO(args->timebase = read_char(&command, 'T'))  ?:
        parse_eos(&command);

    /* If a parse error, extend error with parse position. */
    if (error)
        error_extend(error, "Parse error at offset %zu", command - command_in);
    return error;
}


static void write_detector_info(
    struct buffered_file *file, struct detector_info *info)
{
    /* Send the channel mask and count corresponding to which samples we're
     * actually sending. */
    struct detector_frame frame = {
        .detector_count = (uint8_t) info->detector_count,
        .detector_mask = (uint8_t) info->detector_mask,
        .delay = (uint16_t) info->delay,
        .samples = (uint32_t) info->samples,
    };
    write_block(file, &frame, sizeof(frame));
}


static void read_detector_samples(
    int channel, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    unsigned int sample_count = (unsigned int) (
        sample_size / sizeof(struct detector_result) * samples);
    hw_read_det_memory(channel, sample_count, sample_size * offset, buffer);
}

static void read_detector_scale(
    int channel, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    compute_scale_info(channel, buffer, NULL, offset, samples);
}

static void read_detector_timebase(
    int channel, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    compute_scale_info(channel, NULL, buffer, offset, samples);
}


/* Sends data to destination by repeatedly filling the buffer using the given
 * read_samples() function and then sending. */
static void send_detector_data(
    struct buffered_file *file, int channel, unsigned int samples,
    unsigned int sample_size,
    void (*read_samples)(
        int channel, void *buffer, unsigned int sample_size,
        unsigned int offset, unsigned int samples))
{
    unsigned int offset = 0;
    while (samples > 0)
    {
        unsigned int buffer_samples = READ_BUFFER_BYTES / sample_size;
        char buffer[READ_BUFFER_BYTES];
        unsigned int samples_to_read = MIN(samples, buffer_samples);
        read_samples(channel, buffer, sample_size, offset, samples_to_read);
        write_block(file, buffer, samples_to_read * sample_size);

        samples -= samples_to_read;
        offset += samples_to_read;
    }
}


/* This is called before we have committed to sending a result, but after we
 * have validated arguments. */
static error__t prepare_detector_result(
    struct buffered_file *file, struct detector_args *args,
    struct detector_info *info)
{
    get_detector_info(args->channel, info);
    return ERROR_OK;
}


static void send_detector_result(
    struct buffered_file *file, struct detector_args *args,
    struct detector_info *info)
{
    if (args->framed)
        write_detector_info(file, info);

    send_detector_data(
        file, args->channel, info->samples,
        info->detector_count * (unsigned int) sizeof(struct detector_result),
        read_detector_samples);
    if (args->scale)
        send_detector_data(
            file, args->channel, info->samples,
            sizeof(uint32_t), read_detector_scale);
    if (args->timebase)
        send_detector_data(
            file, args->channel, info->samples,
            sizeof(uint32_t), read_detector_timebase);
}


/* Support detector result readout. */
bool process_detector_command(struct buffered_file *file, const char *command)
{
    struct detector_args args;
    int channel_count = system_config.lmbf_mode ? 1 : CHANNEL_COUNT;
    error__t error =
        parse_detector_args(command, &args)  ?:
        TEST_OK_(0 <= args.channel  &&  args.channel < channel_count,
            "Invalid channel number");

    /* At this point we need to make a start on the send process. */
    struct detector_info info;
    error = error ?:
        prepare_detector_result(file, &args, &info);

    if (error)
        return report_error(file, error, command, args.raw_mode);
    else
    {
        if (!args.raw_mode)
            write_char(file, '\0');
        send_detector_result(file, &args, &info);
        return true;
    }
}
