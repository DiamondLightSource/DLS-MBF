/* Socket server command implementation. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "error.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "memory.h"
#include "buffered_file.h"
#include "parse.h"

#include "socket_command.h"


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
    unsigned int d0, unsigned int d1, const uint32_t read_buffer[])

{
    while (read_samples > 0)
    {
        int16_t write_buffer[WRITE_BUFFER_BYTES / sizeof(int16_t)];
        size_t write_samples = MIN(read_samples, ARRAY_SIZE(write_buffer) / 2);
        int16_t *write_buf = write_buffer;
        for (size_t i = 0; i < write_samples; i ++)
        {
            *write_buf++ = (int16_t) read_buffer[i + d0];
            *write_buf++ = (int16_t) (read_buffer[i + d1] >> 16);
        }

        write_block(file, write_buffer, sizeof(uint32_t) * write_samples);

        read_samples -= write_samples;
        read_buffer += write_samples;
    }
}


static void send_memory_data(
    struct buffered_file *file, unsigned int count, int offset_turns)
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
        send_converted_memory_data(file, read_samples, d0, d1, read_buffer);
        samples -= read_samples;
        offset += read_samples * sizeof(uint32_t);
    }
}


/* Supports command of the form:
 *
 *      M [R] count [O offset] [C]
 *
 * Returns count turns starting at offset turns from trigger point. */
bool process_memory_command(struct buffered_file *file, const char *command)
{
    const char *command_in = command;
    unsigned int count = 0;
    int offset = 0;
    bool raw_mode = false;
    bool auto_close = false;
    error__t error =
        parse_char(&command, 'M')  ?:
        IF(read_char(&command, 'R'),
            DO(raw_mode = true))  ?:
        parse_uint(&command, &count)  ?:
        IF(read_char(&command, 'O'),
            parse_int(&command, &offset))  ?:
        IF(read_char(&command, 'C'),
            DO(auto_close = true))  ?:
        parse_eos(&command);

    if (error)
    {
        error_extend(error, "Parse error at offset %zu", command - command_in);
        if (raw_mode)
        {
            ERROR_REPORT(error, "Error parsing \"%s\"", command_in);
            auto_close = true;
        }
        else
        {
            write_formatted_string(file, "%s\n", error_format(error));
            error_discard(error);
        }
    }
    else
    {
        if (!raw_mode)
            write_char(file, '\0');
        send_memory_data(file, count, offset);
    }
    return !auto_close;
}


bool process_detector_command(struct buffered_file *file, const char *command)
{
    write_formatted_string(file, "DET\n");
    return true;
}
