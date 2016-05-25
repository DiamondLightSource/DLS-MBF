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

#include "amc525_lmbf_device.h"
#include "error.h"


#define DEVICE      "/dev/amc525_lmbf.0.reg"



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Device mapping. */

static int map_file = -1;
static size_t register_map_size;
static void *register_map;


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

static error__t do_command(int argc, char *argv[])
{
    if (argc < 4)
        return FAIL_("Not enough arguments");
    else if (strcmp(argv[1], "r") == 0)
    {
        size_t start = (size_t) atol(argv[2]);
        size_t length = (size_t) atol(argv[3]);
        dump_binary(stdout, register_map + start, length);
        return ERROR_OK;
    }
    else if (strcmp(argv[1], "w") == 0)
    {
        size_t offset = (size_t) atol(argv[2]);
        int32_t value = atoi(argv[3]);
        *(int32_t *) (register_map + offset) = value;
        return ERROR_OK;
    }
    else
        return FAIL_("Unknown command");
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
