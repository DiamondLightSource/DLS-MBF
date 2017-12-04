/* Socket server command implementation. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/in.h>

#include "error.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "parse.h"
#include "buffered_file.h"
#include "memory.h"
#include "detector.h"
#include "sequencer.h"
#include "triggers.h"

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
/* Locking. */

struct lock_parse {
    bool lock;                      // L    Request locked readout
    unsigned int timeout;           // W    Lock timeout in milliseconds
};

/* Parses [L [W timeout]] fragment of readout request. */
static error__t parse_lock(
    const char **command, struct lock_parse *parse)
{
    parse->lock = read_char(command, 'L');
    parse->timeout = 0;
    return
        IF(parse->lock  &&  read_char(command, 'W'),
            parse_uint(command, &parse->timeout));
}


/* This check_connection call is polled periodically to ensure that the socket
 * client is still connected.  Without this check, it is possible for a client
 * to create numerous stalled threads and possibly exhaust the available
 * threads.
 *
 * Unfortunately, this check is quite tricky to set up and it takes about a
 * minute for a disconnected client to be discovered. */
static error__t check_connection(void *context)
{
    struct buffered_file *file = context;
    int sock = get_socket(file);
    return TEST_IO_(send(sock, NULL, 0, 0), "Client disconnected");
}


static error__t wait_for_lock(
    struct trigger_ready_lock *lock,
    struct buffered_file *file, struct lock_parse args)
{
    if (args.lock)
    {
        int sock = get_socket(file);
        int keepalive = true;
        int keepidle = 1;
        int keepintvl = 1;
        int keepcnt = 5;
        struct timeval sndtimeo = { .tv_sec = 5, .tv_usec = 0 };
        return
            /* The following options are documented in tcp(7).  We need to
             * enable SO_KEEPALIVE with timeout so that we can detect that our
             * client has gone away in a timely manner. */
            TEST_IO(setsockopt(
                sock, SOL_SOCKET, SO_KEEPALIVE, &keepalive, sizeof(int)))  ?:
            TEST_IO(setsockopt(
                sock, SOL_TCP, TCP_KEEPIDLE, &keepidle, sizeof(int)))  ?:
            TEST_IO(setsockopt(
                sock, SOL_TCP, TCP_KEEPINTVL, &keepintvl, sizeof(int)))  ?:
            TEST_IO(setsockopt(
                sock, SOL_TCP, TCP_KEEPCNT, &keepcnt, sizeof(int)))  ?:
            /* Also set the send timeout so that when we do start sending we'll
             * detect failure quickly. */
            TEST_IO(setsockopt(
                sock, SOL_SOCKET, SO_SNDTIMEO, &sndtimeo, sizeof(sndtimeo)))  ?:
            /* Finally go and grab the trigger ready lock, if we can. */
            lock_trigger_ready(lock, args.timeout, check_connection, file);
    }
    else
        return ERROR_OK;
}


static void release_lock(
    struct trigger_ready_lock *lock, struct lock_parse args)
{
    if (args.lock)
        unlock_trigger_ready(lock);
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


/* Supports command of the form:
 *
 *      M [R] count [O offset] [C channel] [L [W timeout]]
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
 *      L   If set then lock readout
 *      W timeout
 *          If locking then optionally wait timeout milliseconds for lock to
 *          succeed.
 */
struct memory_args {
    bool raw_mode;                  // R    Don't send ok header
    unsigned int count;             //      Number of turns to send
    int offset;                     // O    Start offset
    int channel;                    // C    Channel selection
    struct lock_parse locking;      // L,W  Locking request
};


static error__t parse_memory_args(
    const char *command, struct memory_args *args)
{
    const char *command_in = command;
    *args = (struct memory_args) {
        .channel = -1,
    };
    error__t error =
        parse_char(&command, 'M')  ?:
        DO(args->raw_mode = read_char(&command, 'R'))  ?:
        parse_uint(&command, &args->count)  ?:
        IF(read_char(&command, 'O'),
            parse_int(&command, &args->offset))  ?:
        IF(read_char(&command, 'C'),
            parse_int(&command, &args->channel)  ?:
            TEST_OK_(0 <= args->channel  &&  args->channel < CHANNEL_COUNT,
                "Invalid channel number"))  ?:
        parse_lock(&command, &args->locking)  ?:
        parse_eos(&command);

    if (error)
        error_extend(error, "Parse error at offset %zu", command - command_in);
    return error;
}


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


bool process_memory_command(struct buffered_file *file, const char *command)
{
    struct memory_args args;
    struct trigger_ready_lock *lock = get_memory_trigger_ready_lock();
    error__t error =
        parse_memory_args(command, &args)  ?:
        wait_for_lock(lock, file, args.locking);

    if (error)
        return report_error(file, error, command, args.raw_mode);
    else
    {
        if (!args.raw_mode)
            write_char(file, '\0');

        bool channels[2] = { true, true };
        if (args.channel >= 0)
            channels[1 - args.channel] = false;
        send_memory_data(file, args.count, args.offset, channels);

        release_lock(lock, args.locking);
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
 *      D [R] channel [F] [S] [T] [L [W timeout]]
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
 *      L   If set then lock readout
 *      W timeout
 *          If locking then optionally wait timeout milliseconds for lock to
 *          succeed.
 */
struct detector_args {
    bool raw_mode;                  // R    Don't send ok header
    int channel;                    //      Detector channel
    bool framed;                    // F    Send header frame
    bool scale;                     // S    Send frequency scale
    bool timebase;                  // T    Send timebase
    struct lock_parse locking;      // L,W  Locking request
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
        parse_lock(&command, &args->locking)  ?:
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
    struct trigger_ready_lock *lock;
    error__t error =
        parse_detector_args(command, &args)  ?:
        TEST_OK_(0 <= args.channel  &&  args.channel < channel_count,
            "Invalid channel number")  ?:
        DO(lock = get_detector_trigger_ready_lock(args.channel))  ?:
        wait_for_lock(lock, file, args.locking);

    if (error)
        return report_error(file, error, command, args.raw_mode);
    else
    {
        if (!args.raw_mode)
            write_char(file, '\0');

        struct detector_info info;
        get_detector_info(args.channel, &info);
        send_detector_result(file, &args, &info);

        release_lock(lock, args.locking);
        return true;
    }
}
