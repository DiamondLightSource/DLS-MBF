/* Tool to read debug memory. */

#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include "amc525_lmbf_device.h"
#include "error.h"


#define DEVICE      "/dev/amc525_lmbf.0.reg"

/* Register offsets. */

/* Read offsets. */
#define DEBUG_WIDTH     0x784       /* Returns row width in bits. */
#define DEBUG_DEPTH     0x788       /* Returns number of rows. */
#define DEBUG_READ_WORD 0x7A0       /* Returns one word from debug array. */
/* Write offsets. */
#define DEBUG_RESET     0x784       /* Resets read pointer. */
#define DEBUG_ADVANCE   0x788       /* Advances read pointer. */


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Device mapping. */

static int map_file = -1;
static size_t register_map_size;
static volatile void *register_map;


static error__t initialise_hardware(void)
{
    return
        TEST_IO_(map_file = open(DEVICE, O_RDWR | O_SYNC),
            "Unable to open device " DEVICE)  ?:
        TEST_IO(register_map_size =
            (size_t) ioctl(map_file, LMBF_MAP_SIZE))  ?:
        TEST_IO(register_map = mmap(
            0, register_map_size,
            PROT_READ | PROT_WRITE, MAP_SHARED, map_file, 0));
}


static void terminate_hardware(void)
{
    ERROR_REPORT(
        IF(register_map,
            TEST_IO(munmap(
                CAST_FROM_TO(volatile uint32_t *, void *, register_map),
                register_map_size)))  ?:
        IF(map_file >= 0,
            TEST_IO(close(map_file))),
        "Calling terminate_hardware");
}


static uint32_t read_register(size_t offset)
{
    return *(volatile uint32_t *) (register_map + offset);
}

static void write_register(size_t offset)
{
    *(volatile uint32_t *) (register_map + offset) = 0;
}


static uint32_t read_next_word(void)
{
    uint32_t result = read_register(DEBUG_READ_WORD);
    write_register(DEBUG_ADVANCE);
    return result;
}


static void prepare_read(unsigned int *width, unsigned int *depth)
{
    *width = (unsigned int) read_register(DEBUG_WIDTH) / 32;
    *depth = (unsigned int) read_register(DEBUG_DEPTH);
    write_register(DEBUG_RESET);
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#define MAX_FIELDS  128

static unsigned int *field_widths;
static unsigned int field_count = 0;


static error__t parse_fields(int argc, const char *argv[])
{
    field_count = (unsigned int) argc - 1;
    field_widths = malloc(sizeof(int) * field_count);
    for (unsigned int i = 0; i < field_count; i ++)
        field_widths[i] = (unsigned int) atoi(argv[i + 1]);
    return TEST_OK_(field_count > 0, "No fields specified");
}


static unsigned long read_field(
    const void *row, unsigned int width, unsigned int start)
{
    const unsigned long *data = row;
    unsigned int word_bits = 8 * sizeof(unsigned long);
    unsigned long word = data[start / word_bits];
    word = word >> start % word_bits;
    word = word & ((1UL << width) - 1);
    return word;
}


static error__t read_debug(void)
{
    unsigned int width, depth;
    prepare_read(&width, &depth);

    for (unsigned int row = 0; row < depth; row ++)
    {
        uint32_t row_data[width];
        for (unsigned int col = 0; col < width; col ++)
            row_data[col] = read_next_word();

        unsigned int field_start = 0;
        for (unsigned int field = 0; field < field_count; field ++)
        {
            unsigned int field_width = field_widths[field];
            unsigned long value =
                read_field(row_data, field_width, field_start);
            printf("%0*lx ", (field_width + 3) / 4, value);
            field_start += field_width;
        }
        printf("\n");
    }
    return ERROR_OK;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int main(int argc, const char *argv[])
{
    error__t error =
        initialise_hardware()  ?:
        parse_fields(argc, argv)  ?:
        read_debug();
    error_report(error);
    terminate_hardware();
    return error ? 1 : 0;
}
