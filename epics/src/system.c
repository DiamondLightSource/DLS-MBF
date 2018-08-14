/* System level definitions. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/utsname.h>

#include <iocsh.h>

#include "error.h"
#include "epics_device.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "delay.h"

#include "system.h"


static struct nco_context {
    int axis;
} nco_context[AXIS_COUNT];

static bool set_nco_frequency(void *context, double *tune)
{
    struct nco_context *nco = context;
    unsigned int frequency = tune_to_freq(*tune);
    *tune = freq_to_tune(frequency);
    hw_write_nco0_frequency(nco->axis, frequency);
    return true;
}

static bool set_nco_gain(void *context, unsigned int *gain)
{
    struct nco_context *nco = context;
    hw_write_dac_nco0_gain(nco->axis, *gain);
    return true;
}

static bool set_nco_enable(void *context, bool *enable)
{
    struct nco_context *nco = context;
    hw_write_dac_nco0_enable(nco->axis, *enable);
    return true;
}

static void publish_nco_pvs(void)
{
    FOR_AXIS_NAMES(axis, "NCO", system_config.lmbf_mode)
    {
        struct nco_context *nco = &nco_context[axis];
        nco->axis = axis;
        PUBLISH_C_P(ao, "FREQ", set_nco_frequency, nco);
        PUBLISH_C_P(mbbo, "GAIN", set_nco_gain, nco);
        PUBLISH_C_P(bo, "ENABLE", set_nco_enable, nco);
    }
}


static struct system_status system_status;
static unsigned int vco_locked;
static unsigned int vcxo_locked;

static void read_system_status(void)
{
    hw_read_system_status(&system_status);
    if (read_clock_passthrough())
    {
        vco_locked = 2;     // Passthrough mode
        vcxo_locked = 2;    // Passthrough mode
    }
    else
    {
        vco_locked = system_status.vco_locked;
        vcxo_locked = system_status.vcxo_locked;
    }
}

static void publish_status_pvs(void)
{
    WITH_NAME_PREFIX("STA")
    {
        PUBLISH_ACTION("POLL", read_system_status);
        PUBLISH_READ_VAR(bi, "CLOCK", system_status.dsp_ok);
        PUBLISH_READ_VAR(mbbi, "VCO", vco_locked);
        PUBLISH_READ_VAR(mbbi, "VCXO", vcxo_locked);
    }
}


/* Some published strings for system identification etc. */
static EPICS_STRING version_string = { MBF_VERSION };
static EPICS_STRING git_version_string = { GIT_VERSION };
static EPICS_STRING fpga_version = { };
static EPICS_STRING fpga_git_version = { };
static EPICS_STRING driver_version = { };
static char hostname[256];
static EPICS_STRING device_name;


static error__t get_hostname(char name[], size_t length)
{
    struct utsname utsname;
    return
        TEST_IO(uname(&utsname))  ?:
        DO(strncpy(name, utsname.nodename, length));
}


static error__t get_driver_version(EPICS_STRING *version)
{
    FILE *file = fopen("/sys/module/amc525_mbf/version", "r");
    return
        TEST_OK(file)  ?:
        DO_FINALLY(
            TEST_OK(fgets(version->s, sizeof(version->s), file))  ?:
            DO(*strchrnul(version->s, '\n') = '\0'),
        // finally
            fclose(file))  ?:
        DO(log_message("Driver version %s", version->s));
}


static error__t initialise_constants(void)
{
    PUBLISH_READ_VAR(stringin, "VERSION", version_string);
    PUBLISH_READ_VAR(stringin, "GIT_VERSION", git_version_string);
    PUBLISH_READ_VAR(stringin, "FPGA_VERSION", fpga_version);
    PUBLISH_READ_VAR(stringin, "FPGA_GIT_VERSION", fpga_git_version);
    PUBLISH_WF_READ_VAR(char, "HOSTNAME", sizeof(hostname), hostname);
    PUBLISH_READ_VAR(bi, "MODE", system_config.lmbf_mode);
    PUBLISH_READ_VAR(ulongin, "SOCKET", system_config.data_port);
    PUBLISH_READ_VAR(stringin, "DEVICE", device_name);
    PUBLISH_READ_VAR(stringin, "DRIVER_VERSION", driver_version);

    struct fpga_version fpga;
    hw_read_fpga_version(&fpga);
    sprintf(fpga_version.s, "%u.%u.%u", fpga.major, fpga.minor, fpga.patch);
    sprintf(fpga_git_version.s, "%07x%s",
        fpga.git_sha, fpga.git_dirty ? "-dirty" : "");
    strncpy(device_name.s, system_config.device_address, sizeof(device_name.s));
    log_message("FPGA version %s, git %s", fpga_version.s, fpga_git_version.s);

    return
        get_hostname(hostname, sizeof(hostname))  ?:
        IF(!hardware_config.no_hardware,
            get_driver_version(&driver_version));
}


static void call_lock_registers(const iocshArgBuf *args)
{
    if (!error_report(hw_lock_registers()))
        printf("MBF control registers locked for exclusive access\n");
}

static void call_unlock_registers(const iocshArgBuf *args)
{
    if (!error_report(hw_unlock_registers()))
        printf("MBF control registers unlocked\n");
}

static void call_set_lmbf_mode(const iocshArgBuf *args)
{
    hw_write_lmbf_mode(true);
    printf("Running in LMBF mode with I/Q axes\n");
}

static void call_set_tmbf_mode(const iocshArgBuf *args)
{
    hw_write_lmbf_mode(false);
    printf("Running in TMBF mode with X/Y axes\n");
}

static error__t register_iocsh_commands(void)
{
    static iocshFuncDef lock_registers_def   = { "lock_registers",   0, NULL };
    static iocshFuncDef unlock_registers_def = { "unlock_registers", 0, NULL };
    static iocshFuncDef set_lmbf_mode_def    = { "set_lmbf_mode", 0, NULL };
    static iocshFuncDef set_tmbf_mode_def    = { "set_tmbf_mode", 0, NULL };
    iocshRegister(&lock_registers_def,   call_lock_registers);
    iocshRegister(&unlock_registers_def, call_unlock_registers);
    iocshRegister(&set_lmbf_mode_def,    call_set_lmbf_mode);
    iocshRegister(&set_tmbf_mode_def,    call_set_tmbf_mode);
    return ERROR_OK;
}


error__t initialise_system(void)
{
    log_message("%u bunches, %u ADC taps, %u bunch taps, %u DAC taps",
        hardware_config.bunches,
        hardware_config.adc_taps,
        hardware_config.bunch_taps,
        hardware_config.dac_taps);

    publish_nco_pvs();
    publish_status_pvs();
    return
        initialise_constants()  ?:
        register_iocsh_commands();
}
