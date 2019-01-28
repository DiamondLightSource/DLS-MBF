/* Socket server command implementation. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <math.h>
#include <complex.h>

#include "error.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "parse.h"
#include "buffered_file.h"
#include "memory.h"
#include "detector.h"
#include "sequencer.h"
#include "trigger_target.h"
#include "triggers.h"

#include "socket_command.h"


/* Extends a parse error with an annotation of where the error was detected.
 * The results aren't always all that clear! */
static error__t fixup_parse_error(
    error__t error, const char *parsed, const char *command, bool raw_mode)
{
    /* For the offset take account of the leading command character and any
     * preceding R mark. */
    ssize_t offset = parsed - command + 1 + raw_mode;
    if (error)
        error_extend(error, "Parse error at offset %zu", offset);
    return error;
}


/*****************************************************************************/
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
    struct trigger_target *lock,
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


static void release_lock(struct trigger_target *lock, struct lock_parse args)
{
    if (args.lock)
        unlock_trigger_ready(lock);
}


/*****************************************************************************/
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


/* The precise returned memory format depends on the capture options selected,
 * see below for details. */
enum memory_data_format {
    FORMAT_INT16,           // Default state, D and T not specified
    FORMAT_FLOAT32,         // D specified, T not specified
    FORMAT_COMPLEX64,       // T specified
};

/* This is the information that will be sent at the start of memory read
 * response if requested. */
struct memory_frame {
    uint32_t samples;       // Number of samples that will be sent
    uint16_t channels;      // Number of channels per sample (1 or 2)
    uint16_t format;        // 0 => int16, 1 => float32, 2 => complex
};


/* Supports command of the form:
 *
 *      [R] M count [F] [O offset] [C channel]
 *          [B bunch | [D decimation] [T tune]] [L [W timeout]]
 *
 * Returns memory captured into memory with the following options:
 *
 *      R   If set then only raw data is returned and the connection is closed
 *          if a parse error occurs.
 *      count
 *          Number of turns of data to capture.
 *      O offset
 *          Starting offset in turns, default to 0.
 *      F   Request that number of samples and format be sent at start.
 *      C channel
 *          If requested, only the one channel will be transmitted, halving the
 *          data transmitted.
 *      B bunch
 *          Request that only the one bunch be transmitted.  This option cannot
 *          be combined with D or T options.
 *      D decimation
 *          Data can be reduced by averaging each turn over a number of turns.
 *          If this option is selected the data is returned as single precision
 *          floats, unless T tune is also selected, in which case see below.
 *      T tune
 *          Optionally the data can be frequency shifted by the specifed tune
 *          (specified as a floating point number in revolutions per turn).  If
 *          this option is selected then data is transmitted as single precision
 *          complex numbers.
 *      L   If set then lock readout
 *      W timeout
 *          If locking then optionally wait timeout milliseconds for lock to
 *          succeed.
 */
struct memory_args {
    unsigned int count;             //      Number of turns to send
    bool framed;                    // F
    int offset;                     // O    Start offset
    int channel;                    // C    Channel selection
    int bunch;                      // B    Single bunch selection
    unsigned int decimation;        // D    Data decimation factor
    double tune;                    // T    Selected frequency shift
    struct lock_parse locking;      // L,W  Locking request
    enum memory_data_format format;
};


static error__t parse_memory_args(
    const char *command, struct memory_args *args, bool raw_mode)
{
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    const char *command_in = command;
    *args = (struct memory_args) {
        .channel = -1,
        .bunch = -1,
        .decimation = 1,
        .format = FORMAT_INT16,
    };
    error__t error =
        parse_uint(&command, &args->count)  ?:
        DO(args->framed = read_char(&command, 'F'))  ?:
        IF(read_char(&command, 'O'),
            parse_int(&command, &args->offset))  ?:
        IF(read_char(&command, 'C'),
            parse_int(&command, &args->channel)  ?:
            TEST_OK_(0 <= args->channel  &&  args->channel < MEM_CHANNEL_COUNT,
                "Invalid channel number"))  ?:
        IF_ELSE(read_char(&command, 'B'),
            parse_int(&command, &args->bunch)  ?:
            TEST_OK_(0 <= args->bunch  &&  args->bunch < (int) bunches_per_turn,
                "Invalid bunch number"),
        //else (not 'B')
            IF(read_char(&command, 'D'),
                DO(args->format = FORMAT_FLOAT32)  ?:
                parse_uint(&command, &args->decimation)  ?:
                TEST_OK_(args->decimation > 0, "Invalid decimation"))  ?:
            IF(read_char(&command, 'T'),
                DO(args->format = FORMAT_COMPLEX64)  ?:
                parse_double(&command, &args->tune)))  ?:
        parse_lock(&command, &args->locking)  ?:
        parse_eos(&command);

    return fixup_parse_error(error, command, command_in, raw_mode);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Channel extraction and alignment. */

/* Context for channel field extraction. */
struct channels_context {
    unsigned int d0;        // Offset correction for channel 0
    unsigned int d1;        // Offset correction for channel 1
    unsigned int count;     // Number of channels (1 or 2)
    bool channels[2];       // Records which channels are to be captured
};


/* Returns filled in channels_context structure. */
static struct channels_context make_channels_context(int channel)
{
    struct channels_context context = {
        .channels = { true, true },
        .count = channel >= 0 ? 1 : 2,
    };
    if (channel >= 0)
        context.channels[1 - channel] = false;
    get_memory_channel_delays(&context.d0, &context.d1);
    return context;
}


static void extract_channels_one_bunch(
    const uint32_t read_buffer[], const struct channels_context *channels,
    int16_t **write_buf)
{
    if (channels->channels[0])
        *(*write_buf)++ = (int16_t) read_buffer[channels->d0];
    if (channels->channels[1])
        *(*write_buf)++ = (int16_t) (read_buffer[channels->d1] >> 16);
}


/* Extracts selected channels from raw data with bunch offset correction.
 * Returns number of samples extracted. */
static size_t extract_channels(
    const uint32_t read_buffer[], size_t samples,
    const struct channels_context *channels,
    int16_t channel_buffer[])
{
    int16_t *write_buf = channel_buffer;
    for (size_t i = 0; i < samples; i ++)
        extract_channels_one_bunch(&read_buffer[i], channels, &write_buf);
    return (size_t) (write_buf - channel_buffer);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* single bunch format.
 *
 * In this mode we send a single bunch. */

static size_t compute_bunch_turn_data(
    const uint32_t read_buffer[], size_t write_turns, int16_t write_buffer[],
    const struct channels_context *channels)
{
    int16_t *write_buf = write_buffer;
    for (size_t i = 0; i < write_turns; i ++)
    {
        extract_channels_one_bunch(read_buffer, channels, &write_buf);
        read_buffer += system_config.bunches_per_turn;
    }
    return (size_t) (write_buf - write_buffer);
}


/* We assume here that read_samples is an integer multiple of turns. */
static void send_bunch_memory_data(
    struct buffered_file *file, const struct channels_context *channels,
    unsigned int bunch, const uint32_t read_buffer[], size_t read_samples)
{
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    size_t read_turns = read_samples / bunches_per_turn;

    size_t write_buffer_size = WRITE_BUFFER_BYTES / sizeof(int16_t);
    size_t max_samples = write_buffer_size / channels->count;

    while (read_turns > 0)
    {
        size_t write_turns = MIN(read_turns, max_samples);
        int16_t write_buffer[write_buffer_size];

        size_t write_samples = compute_bunch_turn_data(
            &read_buffer[bunch], write_turns, write_buffer, channels);
        write_block(file, write_buffer, sizeof(int16_t) * write_samples);

        read_buffer += write_turns * bunches_per_turn;
        read_turns -= write_turns;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* int16 format.
 *
 * In this mode we send the basic data. */

/* Perform simple channel extraction and send block. */
static void send_int16_memory_data(
    struct buffered_file *file, const struct channels_context *channels,
    const uint32_t read_buffer[], size_t read_samples)
{
    size_t write_buffer_size = WRITE_BUFFER_BYTES / sizeof(int16_t);
    size_t max_samples = write_buffer_size / channels->count;
    while (read_samples > 0)
    {
        int16_t write_buffer[write_buffer_size];
        size_t write_samples = MIN(read_samples, max_samples);
        size_t samples = extract_channels(
            read_buffer, write_samples, channels, write_buffer);

        write_block(file, write_buffer, sizeof(int16_t) * samples);

        read_samples -= write_samples;
        read_buffer += write_samples;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* float32 format.
 *
 * In this mode we average over a specified number of turns and send the
 * resulting averages in floating point format. */

/* Computes a single decimated turn.  The turn buffer must be large enough to
 * accomodate a single turn (one or two channels).  Returns number samples
 * written to turn_buffer[]. */
static size_t compute_float32_turn_data(
    const uint32_t read_buffer[], float turn_buffer[],
    const struct channels_context *channels,
    unsigned int decimation)
{
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    unsigned int sample_count = bunches_per_turn * channels->count;
    memset(turn_buffer, 0, sample_count * sizeof(float));

    /* Accumulate totals over decimation interval from the selected channels. */
    for (unsigned int d = 0; d < decimation; d ++)
    {
        int16_t channel_buffer[sample_count];
        extract_channels(
            read_buffer, bunches_per_turn, channels, channel_buffer);
        read_buffer += bunches_per_turn;

        for (unsigned int i = 0; i < sample_count; i ++)
            turn_buffer[i] += (float) channel_buffer[i];
    }

    /* Convert totals into averages. */
    for (unsigned int i = 0; i < sample_count; i ++)
        turn_buffer[i] /= (float) decimation;
    return sample_count;
}


/* This is called when no tune has been set but decimation has been requested.
 * We have already ensured that read_samples is an integer number of decimated
 * turns in length. */
static void send_float32_memory_data(
    struct buffered_file *file,
    const struct memory_args *args,
    const struct channels_context *channels,
    const uint32_t read_buffer[], size_t read_samples)
{
    /* Figure out how many incoming turns of data we have and the size of each
     * undecimated block of turns.  These are in units of read samples, or
     * blocks of uint32_t. */
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    unsigned int read_turn_samples = bunches_per_turn * args->decimation;
    size_t read_turns = read_samples / read_turn_samples;

    /* Similarly figure out the the write buffer size.  Again, this must be a
     * whole number of complete turns, and we truncate things to fit into the
     * maximum buffer size. */
    size_t samples_per_turn = bunches_per_turn * channels->count;
    size_t turns_per_buffer =
        WRITE_BUFFER_BYTES / sizeof(float) / samples_per_turn;

    while (read_turns > 0)
    {
        float write_buffer[WRITE_BUFFER_BYTES / sizeof(float)];
        size_t write_turns = MIN(read_turns, turns_per_buffer);

        float *write_buf = write_buffer;
        size_t write_samples = 0;
        for (size_t turn = 0; turn < write_turns; turn ++)
        {
            write_samples += compute_float32_turn_data(
                read_buffer, write_buf, channels, args->decimation);
            read_buffer += read_turn_samples;
            write_buf += samples_per_turn;
        }

        write_block(file, write_buffer, sizeof(float) * write_samples);
        read_turns -= write_turns;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* complex64 format.
 *
 * In this mode we average over the specified number of turns after frequency
 * shifting the data by the given tune offset.  The resulting data is sent in IQ
 * format as 64-bit complex numbers (dual 32-bit floats). */


/* Holds the evolving state required to perform tune shifted decimation. */
struct tune_decimate_state {
    /* Copies of relevant parameters. */
    uint64_t tune;          /* Converted into 2^48 revolutions per bunch. */
    unsigned int decimation;

    /* Current rotation angle, in units of rotation per 2^48. */
    uint64_t angle;
    /* Angle advance per turn. */
    uint64_t turn_advance;
    /* Fixup buffer. */
    float complex *turn_fixup;
};


static float complex cisf(float angle)
{
    return cosf(angle) + I * sinf(angle);
}


static float complex angle_to_rotate(uint64_t angle)
{
    /* The angle is in units of rotation per 2^48, so multiply by 2 pi. */
    return cisf((float) (2*M_PI * ldexp((double) angle, -48)));
}


static void prepare_tune_decimate(
    struct tune_decimate_state *state,
    float complex turn_fixup[],
    const struct memory_args *args,
    const struct channels_context *channels)
{
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    uint64_t tune = tune_to_freq(args->tune);
    *state = (struct tune_decimate_state) {
        .tune = tune,
        .decimation = args->decimation,
        .angle = 0,
        .turn_advance = tune * bunches_per_turn,
        .turn_fixup = turn_fixup,
    };

    /* Compute the turn fixup array. */
    uint64_t angle = 0;
    for (unsigned int i = 0; i < bunches_per_turn; i ++)
    {
        float complex rotate = angle_to_rotate(angle);
        for (unsigned int c = 0; c < channels->count; c ++)
            *turn_fixup++ = rotate / (float) args->decimation;
        angle += tune;
    }
}


static size_t compute_complex64_turn_data(
    const uint32_t read_buffer[], float complex turn_buffer[],
    const struct channels_context *channels,
    struct tune_decimate_state *state)
{
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    unsigned int sample_count = bunches_per_turn * channels->count;
    memset(turn_buffer, 0, sample_count * sizeof(float complex));

    /* Accumulate totals over decimation interval from the selected channels. */
    for (unsigned int d = 0; d < state->decimation; d ++)
    {
        int16_t channel_buffer[sample_count];
        extract_channels(
            read_buffer, bunches_per_turn, channels, channel_buffer);
        read_buffer += bunches_per_turn;

        float complex rotate = angle_to_rotate(state->angle);
        for (unsigned int i = 0; i < sample_count; i ++)
            turn_buffer[i] += rotate * (float) channel_buffer[i];
        state->angle += state->turn_advance;
    }

    /* Fix up final result by scaling and rotating as appropriate. */
    for (unsigned int i = 0; i < sample_count; i ++)
        turn_buffer[i] *= state->turn_fixup[i];
    return sample_count;
}


static void send_complex64_memory_data(
    struct buffered_file *file,
    const struct channels_context *channels,
    struct tune_decimate_state *state,
    const uint32_t read_buffer[], size_t read_samples)
{
    /* Same underlying logic as for float32. */
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    unsigned int read_turn_samples = bunches_per_turn * state->decimation;
    size_t read_turns = read_samples / read_turn_samples;
    size_t samples_per_turn = bunches_per_turn * channels->count;
    size_t turns_per_buffer =
        WRITE_BUFFER_BYTES / sizeof(float complex) / samples_per_turn;

    while (read_turns > 0)
    {
        float complex write_buffer[WRITE_BUFFER_BYTES / sizeof(float complex)];
        size_t write_turns = MIN(read_turns, turns_per_buffer);

        float complex *write_buf = write_buffer;
        size_t write_samples = 0;
        for (size_t turn = 0; turn < write_turns; turn ++)
        {
            write_samples += compute_complex64_turn_data(
                read_buffer, write_buf, channels, state);
            read_buffer += read_turn_samples;
            write_buf += samples_per_turn;
        }

        write_block(file, write_buffer, sizeof(float complex) * write_samples);
        read_turns -= write_turns;
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Send memory data. */

static void send_memory_data(
    struct buffered_file *file, size_t read_buffer_size,
    const struct memory_args *args,
    const struct channels_context *channels)
{
    /* Convert count and offset into a byte offset from the trigger and a number
     * of samples. */
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    size_t samples = args->count * bunches_per_turn * args->decimation;
    size_t offset = compute_dram_offset(args->offset);

    struct tune_decimate_state complex_state;
    float complex turn_fixup[bunches_per_turn * channels->count];
    if (args->format == FORMAT_COMPLEX64)
        prepare_tune_decimate(&complex_state, turn_fixup, args, channels);

    while (samples > 0)
    {
        size_t read_samples = MIN(samples, read_buffer_size);

        /* To allow for offset compensation, we need to read one extra turn
         * which we don't include in the sample count. */
        uint32_t read_buffer[read_buffer_size + bunches_per_turn];
        hw_read_dram_memory(
            offset, read_samples + bunches_per_turn, read_buffer);

        if (args->bunch >= 0)
            send_bunch_memory_data(
                file, channels, (unsigned int) args->bunch,
                read_buffer, read_samples);
        else
            switch (args->format)
            {
                case FORMAT_INT16:
                    send_int16_memory_data(
                        file, channels, read_buffer, read_samples);
                    break;
                case FORMAT_FLOAT32:
                    send_float32_memory_data(
                        file, args, channels, read_buffer, read_samples);
                    break;
                case FORMAT_COMPLEX64:
                    send_complex64_memory_data(
                        file, channels, &complex_state,
                        read_buffer, read_samples);
                    break;
            }

        offset += read_samples * sizeof(uint32_t);
        samples -= read_samples;
    }
}


/* Compute size of read buffer (in 32-bit samples) to fit within the maximum
 * read buffer size.  If data reduction is requested then also computes read
 * buffer to be an integer multiple of the decimated sample size.
 *    A second complication is that one extra turn of data needs to be added to
 * the memory read to allow for delay compensation.  This is *not* included in
 * the value returned by this function but is allowed for in the buffer size. */
static error__t compute_read_buffer_size(
    struct memory_args *args, size_t *buffer_size)
{
    size_t bunches_per_turn = system_config.bunches_per_turn;
    *buffer_size = READ_BUFFER_BYTES / sizeof(uint32_t) - bunches_per_turn;
    if (args->bunch >= 0)
    {
        /* Ensure buffer size is an integer number of turns. */
        *buffer_size = (*buffer_size / bunches_per_turn) * bunches_per_turn;
        return ERROR_OK;
    }
    else if (args->format != FORMAT_INT16)
    {
        /* For averaged samples we need to read an integer number of decimated
         * turns at a time to simplify processing. */
        size_t sample_size = bunches_per_turn * args->decimation;
        *buffer_size = (*buffer_size / sample_size) * sample_size;
        return TEST_OK_(*buffer_size > 0, "Decimation too large");
    }
    else
        return ERROR_OK;
}


/* Writes (optional) header containing format information about sent data. */
static void write_memory_info(
    struct buffered_file *file, struct memory_args *args)
{
    struct memory_frame frame = {
        .samples = args->bunch >= 0 ?
            args->count :
            args->count * system_config.bunches_per_turn,
        .channels = args->channel >= 0 ? 1 : 2,
        .format = args->format,
    };
    write_block(file, &frame, sizeof(frame));
}


error__t process_memory_command(
    struct buffered_file *file, bool raw_mode, const char *command)
{
    size_t bunches_per_turn = system_config.bunches_per_turn;
    struct memory_args args;
    size_t read_buffer_size;
    struct trigger_target *lock = get_memory_trigger_target();
    error__t error =
        parse_memory_args(command, &args, raw_mode)  ?:
        TEST_OK_(
            args.count <= DRAM0_LENGTH / sizeof(int32_t) /
                bunches_per_turn / args.decimation,
            "Too many turns requested")  ?:
        compute_read_buffer_size(&args, &read_buffer_size)  ?:

        /* Make sure we always do this one last! */
        wait_for_lock(lock, file, args.locking);

    if (!error)
    {
        if (!raw_mode)
            write_char(file, '\0');
        if (args.framed)
            write_memory_info(file, &args);

        struct channels_context channels = make_channels_context(args.channel);
        send_memory_data(file, read_buffer_size, &args, &channels);

        release_lock(lock, args.locking);
    }
    return error;
}


/*****************************************************************************/
/* DET detector readout. */

/* Information to send at the start of a detector readout.  Is much the same
 * content as detector_info, but with fixed sized words. */
struct detector_frame {
    uint8_t detector_count;
    uint8_t detector_mask;
    uint16_t delay;
    uint32_t samples;
    uint32_t bunches;
};


/* This structure captures the parsed results of a detector request command of
 * the form:
 *
 *      [R] D axis [F] [S [L]] [T] [L [W timeout]]
 *
 * Returns detector readout with the following options:
 *
 *      R   If set then only raw data is returned and the connection is closed
 *          if a parse error occurs.
 *      axis
 *          Specifies which axis is being read.
 *      F   Request that the number of detectors and samples is sent as a header
 *          before sending the raw data.
 *      S   Request that the frequency scale for the detector is transmitted
 *          after sending the axis data.
 *      SL  The frequency scale is sent as 64-bit values.
 *      T   Request that the timebase for the detector is transmitted after the
 *          axis data, and after the frequency scale if requested.
 *      L   If set then lock readout
 *      W timeout
 *          If locking then optionally wait timeout milliseconds for lock to
 *          succeed.
 */
struct detector_args {
    int axis;                       //      Detector axis
    bool framed;                    // F    Send header frame
    bool scale;                     // S    Send frequency scale
    bool long_scale;                // SL       (optionally as 64-bit values)
    bool timebase;                  // T    Send timebase
    struct lock_parse locking;      // L,W  Locking request
};


/* Parses the [F] [S [L]] [T] options. */
static error__t parse_detector_opts(
    const char **command, struct detector_args *args)
{
    args->framed = read_char(command, 'F');
    args->scale = read_char(command, 'S');
    if (args->scale)
        args->long_scale = read_char(command, 'L');
    args->timebase = read_char(command, 'T');
    return ERROR_OK;
}

/* Parsing of detector readout command. */
static error__t parse_detector_args(
    const char *command, struct detector_args *args, bool raw_mode)
{
    const char *command_in = command;
    *args = (struct detector_args) { };
    error__t error =
        parse_int(&command, &args->axis)  ?:
        parse_detector_opts(&command, args)  ?:
        parse_lock(&command, &args->locking)  ?:
        parse_eos(&command);

    return fixup_parse_error(error, command, command_in, raw_mode);
}


static void write_detector_info(
    struct buffered_file *file, struct detector_info *info)
{
    /* Send the axis mask and count corresponding to which samples we're
     * actually sending. */
    struct detector_frame frame = {
        .detector_count = (uint8_t) info->detector_count,
        .detector_mask = (uint8_t) info->detector_mask,
        .delay = (uint16_t) info->delay,
        .samples = (uint32_t) info->samples,
        .bunches = (uint32_t) system_config.bunches_per_turn,
    };
    write_block(file, &frame, sizeof(frame));
}


static void read_detector_samples(
    int axis, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    unsigned int sample_count = (unsigned int) (
        sample_size / sizeof(struct detector_result) * samples);
    hw_read_det_memory(axis, sample_count, sample_size * offset, buffer);
}

static void read_detector_scale(
    int axis, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    uint64_t frequencies[samples];
    compute_scale_info(axis, frequencies, NULL, offset, samples);
    unsigned int *buf_out = buffer;
    for (unsigned int i = 0; i < samples; i ++)
        *buf_out++ = (unsigned int) (frequencies[i] >> 16);
}

static void read_detector_scale_long(
    int axis, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    compute_scale_info(axis, buffer, NULL, offset, samples);
}

static void read_detector_timebase(
    int axis, void *buffer, unsigned int sample_size,
    unsigned int offset, unsigned int samples)
{
    compute_scale_info(axis, NULL, buffer, offset, samples);
}


/* Sends data to destination by repeatedly filling the buffer using the given
 * read_samples() function and then sending. */
static void send_detector_data(
    struct buffered_file *file, int axis, unsigned int samples,
    unsigned int sample_size,
    void (*read_samples)(
        int axis, void *buffer, unsigned int sample_size,
        unsigned int offset, unsigned int samples))
{
    unsigned int offset = 0;
    while (samples > 0)
    {
        unsigned int buffer_samples = READ_BUFFER_BYTES / sample_size;
        char buffer[READ_BUFFER_BYTES];
        unsigned int samples_to_read = MIN(samples, buffer_samples);
        read_samples(axis, buffer, sample_size, offset, samples_to_read);
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
        file, args->axis, info->samples,
        info->detector_count * (unsigned int) sizeof(struct detector_result),
        read_detector_samples);
    if (args->scale)
    {
        if (args->long_scale)
            send_detector_data(
                file, args->axis, info->samples,
                sizeof(uint64_t), read_detector_scale_long);
        else
            send_detector_data(
                file, args->axis, info->samples,
                sizeof(uint32_t), read_detector_scale);
    }
    if (args->timebase)
        send_detector_data(
            file, args->axis, info->samples,
            sizeof(uint32_t), read_detector_timebase);
}


/* Support detector result readout. */
error__t process_detector_command(
    struct buffered_file *file, bool raw_mode, const char *command)
{
    struct detector_args args;
    int axis_count = system_config.lmbf_mode ? 1 : AXIS_COUNT;
    struct trigger_target *lock;
    error__t error =
        parse_detector_args(command, &args, raw_mode)  ?:
        TEST_OK_(0 <= args.axis  &&  args.axis < axis_count,
            "Invalid axis number")  ?:
        DO(lock = get_sequencer_trigger_target(args.axis))  ?:
        wait_for_lock(lock, file, args.locking);

    /* Now we have the lock we are committed to releasing the lock. */
    if (!error)
    {
        struct detector_info info;
        get_detector_info(args.axis, &info);
        error = TEST_OK_(info.detector_count > 0, "No detectors enabled");
        if (!error)
        {
            if (!raw_mode)
                write_char(file, '\0');
            send_detector_result(file, &args, &info);
        }

        release_lock(lock, args.locking);
    }

    return error;
}
