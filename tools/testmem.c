/* Tool for testing LMBF register space. */

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
#include <errno.h>

#include "amc525_lmbf_device.h"
#include "error.h"


#define DEVICE      "/dev/amc525_lmbf.0.reg"



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Device mapping. */

static int map_file = -1;
static size_t register_map_size;
static uint32_t *register_map;


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
            TEST_IO(munmap(register_map, register_map_size)))  ?:
        IF(map_file >= 0,
            TEST_IO(close(map_file))),
        "Calling terminate_hardware");
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Args. */

static error__t read_arg(char ***argv, const char **result)
{
    return
        TEST_OK_(**argv, "Not enough arguments")  ?:
        DO(*result = *(*argv)++);
}


static error__t parse_uint(char ***argv, unsigned long int *result)
{
    errno = 0;
    const char *start;
    char *end;
    return
        read_arg(argv, &start)  ?:
        DO(*result = strtoul(start, &end, 0))  ?:
        TEST_OK_(end > start, "Number missing")  ?:
        TEST_IO_(errno == 0, "Error converting number");
}


static error__t read_words(char *argv[])
{
    unsigned long int start;
    unsigned long int length = 1;
    return
        parse_uint(&argv, &start)  ?:
        IF(*argv, parse_uint(&argv, &length))  ?:
        DO(dump_words(stdout, register_map + start, length));
}


static error__t write_words(char *argv[])
{
    unsigned long int offset;
    unsigned long int value;
    return
        parse_uint(&argv, &offset)  ?:
        parse_uint(&argv, &value)  ?:
        DO(register_map[offset] = (uint32_t) value);
}


static error__t copy_block(void *destination, size_t max_length)
{
    char block[4096];
    ssize_t read_size = read(STDIN_FILENO, block, sizeof(block));
    if (read_size > (ssize_t) max_length)
        read_size = (ssize_t) max_length;
    printf("read_size = %zd, writing:\n", read_size);
    return
        TEST_IO(read_size)  ?:
        DO(dump_bytes(stdout, block, (size_t) read_size))  ?:
        DO(memcpy(destination, block, (size_t) read_size));
}


static error__t read_block(char *argv[])
{
    unsigned long int offset;
    unsigned long int max_length;
    return
        parse_uint(&argv, &offset)  ?:
        parse_uint(&argv, &max_length)  ?:
        copy_block(register_map + offset, max_length);
}


static error__t do_command(int argc, char *argv[])
{
    argv += 1;
    const char *action;
    return
        read_arg(&argv, &action)  ?:
        IF_ELSE(strcmp(action, "r") == 0,
            read_words(argv),
        //else
        IF_ELSE(strcmp(action, "w") == 0,
            write_words(argv),
        //else
        IF_ELSE(strcmp(action, "b") == 0,
            read_block(argv),
        //else
            FAIL_("Unknown command"))));
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int main(int argc, char *argv[])
{
    error__t error =
        initialise_hardware()  ?:
        do_command(argc, argv);
    error_report(error);
    terminate_hardware();
    return error ? 1 : 0;
}
