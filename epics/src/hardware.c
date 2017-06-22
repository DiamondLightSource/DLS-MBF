/* Hardware interfacing to LMBF system. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

#include "error.h"
#include "epics_device.h"

#include "amc525_lmbf_device.h"
#include "register_defs.h"
#include "hardware.h"





/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* System control. */

static volatile struct sys *sys_space;


static const char *dram0_device_name;

error__t hw_read_fast_dram_name(char *name, size_t length)
{
    strncpy(name, dram0_device_name, length);
    return ERROR_OK;
}


uint32_t hw_read_fpga_version(void)
{
    return sys_space->version;
}



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Miscellaneous control. */

static volatile struct ctrl *ctrl_space;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* DSP control. */

static volatile struct dsp *dsp_space[2];



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation */


/* The bases for the individual address spaces are hard-wired into the address
 * decoding in the firmware.  The address space is 16 bits, and the top three
 * bits are decoded as follows:
 *
 *   15 14 13
 *  +--+--+--+
 *    0  x  x       System registers        SYS
 *    1  0  0       Control registers       CTRL
 *    1  0  1       (unused)
 *    1  1  0       DSP0 registers          DSP0
 *    1  1  1       DSP1 registers          DSP1
 */
#define SYS_ADDRESS_BASE        0x0000
#define CTRL_ADDRESS_BASE       0x8000
#define DSP0_ADDRESS_BASE       0xC000
#define DSP1_ADDRESS_BASE       0xE000


static int reg_device = -1;
static int ddr1_device = -1;
static void *config_space;
static size_t config_space_size;



static error__t map_config_space(void)
{
    sys_space    = config_space + SYS_ADDRESS_BASE;
    ctrl_space   = config_space + CTRL_ADDRESS_BASE;
    dsp_space[0] = config_space + DSP0_ADDRESS_BASE;
    dsp_space[1] = config_space + DSP1_ADDRESS_BASE;
    return ERROR_OK;
}


error__t initialise_hardware(const char *prefix, const char *config)
{
    printf("initialise_hardware %s %s\n", prefix, config);

    /* Compute device node names from the prefix. */
    size_t prefix_length = strlen(prefix);
    char reg_device_name[prefix_length + 8];
    char ddr0_device_name[prefix_length + 8];
    char ddr1_device_name[prefix_length + 8];
    sprintf(reg_device_name, "%s.reg", prefix);
    sprintf(ddr0_device_name, "%s.ddr0", prefix);
    sprintf(ddr1_device_name, "%s.ddr1", prefix);

    dram0_device_name = strdup(ddr0_device_name);
    return
        TEST_IO_(ddr1_device = open(ddr1_device_name, O_RDONLY),
            "Unable to find LMBF device with prefix %s", prefix)  ?:
        TEST_IO(reg_device = open(reg_device_name, O_RDWR | O_SYNC))  ?:
        TEST_IO_(ioctl(reg_device, LMBF_REG_LOCK),
            "Device cannot be locked")  ?:
        TEST_IO(
            config_space_size = (size_t) ioctl(reg_device, LMBF_MAP_SIZE))  ?:
        TEST_IO(config_space = mmap(
            0, config_space_size, PROT_READ | PROT_WRITE, MAP_SHARED,
            reg_device, 0))  ?:
        map_config_space();
}


void terminate_hardware(void)
{
    if (config_space)
        munmap(config_space, config_space_size);
    if (reg_device)
        close(reg_device);
    if (ddr1_device)
        close(ddr1_device);
}
