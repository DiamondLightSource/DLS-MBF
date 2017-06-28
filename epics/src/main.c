#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/utsname.h>

#include <epicsThread.h>
#include <iocsh.h>
#include <caerr.h>
#include <envDefs.h>
#include <dbAccess.h>
#include <iocInit.h>

#include "error.h"
#include "persistence.h"
#include "epics_device.h"
#include "epics_extra.h"
#include "pvlogging.h"

#include "hardware.h"



/* External declaration of DBD binding. */
extern int lmbf_registerRecordDeviceDriver(struct dbBase *pdbbase);



/* Persistence state management. */
static const char *persistence_state_file = NULL;
static int persistence_interval = 120;              // 2 minute update interval

/* Device name configured on startup. */
static const char *device_name = NULL;

/* Device prefix for hardware interface. */
static const char *device_prefix = NULL;

/* Number of bunches per turn. */
static unsigned int bunches_per_turn;

/* File to read hardware configuration settings. */
static const char *hardware_config_file = NULL;

/* Limits length of waveforms logged on output. */
static int max_log_array_length = 10000;



/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Argument handling. */


static void usage(void)
{
    printf(
"LMBF IOC.  Options:\n"
"   -s: Specify name of file where persistent state is stored (required)\n"
"   -b: Specify number of bunches per turn (required)\n"
"   -i: Specify persistence update interval in seconds\n"
"   -l: Specify maximum array length written out by pv logging\n"
"   -p: Specify device prefix used to locate LMBF device (required)\n"
"   -d: Specify IOC device name (required)\n"
"   -H: Specifgy hardware configuration file (required)\n"
    );
}


static error__t process_options(int *argc, char *const *argv[])
{
    while (true)
    {
        switch (getopt(*argc, *argv, "+hs:b:i:l:p:d:H:"))
        {
            case 'h':   usage();                                exit(1);
            case 'b':
                bunches_per_turn = (unsigned int) atoi(optarg);
                break;
            case 's':   persistence_state_file = optarg;        break;
            case 'i':   persistence_interval = atoi(optarg);    break;
            case 'l':   max_log_array_length = atoi(optarg);    break;
            case 'p':   device_prefix = optarg;                 break;
            case 'd':   device_name = optarg;                   break;
            case 'H':   hardware_config_file = optarg;          break;
            default:
                return FAIL_("Invalid command line option");
            case -1:
                /* All options successfully read.  Consume them and return
                 * success. */
                *argc -= optind;
                *argv += optind;
                return ERROR_OK;
        }
    }
    // Never get here!
}


static error__t validate_options(int argc)
{
    return
        TEST_OK_(argc == 0, "Unexpected extra arguments")  ?:
        TEST_OK_(bunches_per_turn > 0, "Must specify bunches per turn")  ?:
        TEST_OK_(persistence_state_file, "Must specify state file")  ?:
        TEST_OK_(device_prefix, "Must specify device prefix")  ?:
        TEST_OK_(hardware_config_file, "Must specify config file")  ?:
        TEST_OK_(device_name, "Must specify device name");
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Core EPICS startup (st.cmd equivalent processing). */


/* Configures the IOC prompt to show the EPICS device name. */
static void set_prompt(void)
{
    char prompt[256];
    snprintf(prompt, sizeof(prompt), "%s> ", device_name);
    epicsEnvSet("IOCSH_PS1", prompt);
}


static error__t load_database(const char *database)
{
    database_add_macro("DEVICE", "%s", device_name);
//     database_add_macro("FIR_LENGTH", "%d", hw_read_fir_length());
    return database_load_file(database);
}


static void call_lock_registers(const iocshArgBuf *args)
{
    if (!error_report(hw_lock_registers()))
        printf("LMBF control registers locked for exclusive access\n");
}

static void call_unlock_registers(const iocshArgBuf *args)
{
    if (!error_report(hw_unlock_registers()))
        printf("LMBF control registers unlocked\n");
}

static error__t register_iocsh_commands(void)
{
    static iocshFuncDef lock_registers_def   = { "lock_registers",   0, NULL };
    static iocshFuncDef unlock_registers_def = { "unlock_registers", 0, NULL };
    iocshRegister(&lock_registers_def,   call_lock_registers);
    iocshRegister(&unlock_registers_def, call_unlock_registers);
    return ERROR_OK;
}


static error__t initialise_epics(void)
{
    set_prompt();
    return
        start_caRepeater()  ?:
        hook_pv_logging("db/access.acf", max_log_array_length)  ?:
        TEST_OK(dbLoadDatabase("dbd/lmbf.dbd", NULL, NULL) == 0)  ?:
        TEST_OK(lmbf_registerRecordDeviceDriver(pdbbase) == 0)  ?:
        load_database("db/lmbf.db")  ?:
        register_iocsh_commands()  ?:
        TEST_OK(iocInit() == 0);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* Driver version. */
static EPICS_STRING version_string = { LMBF_VERSION };
static EPICS_STRING fpga_version = { };
static EPICS_STRING hostname = { };
static char dram_name[256];


static error__t initialise_strings(void)
{
    PUBLISH_READ_VAR(stringin, "VERSION", version_string);
    PUBLISH_READ_VAR(stringin, "FPGA_VERSION", fpga_version);
    PUBLISH_READ_VAR(stringin, "HOSTNAME", hostname);
    PUBLISH_WF_READ_VAR(char, "DRAM_NAME", sizeof(dram_name), dram_name);

    sprintf(fpga_version.s, "%08x", hw_read_fpga_version());

    struct utsname utsname;
    return
        TEST_IO(uname(&utsname))  ?:
        DO(strncpy(hostname.s, utsname.nodename, sizeof(hostname.s)))  ?:
        hw_read_fast_dram_name(dram_name, sizeof(dram_name));
}


/* Initialises the various subsystems. */
static error__t initialise_subsystems(void)
{

//     PUBLISH_READER(ulongin, "FPGA_VER", hw_read_version);
//     PUBLISH_WRITER(bo, "LOOPBACK", hw_write_loopback_enable);
//     PUBLISH_WRITER(bo, "COMPENSATE", hw_write_compensate_disable);

    printf("%u bunches, %u ADC taps, %u bunch taps, %u DAC taps\n",
        hardware_config.bunches,
        hardware_config.adc_taps,
        hardware_config.bunch_taps,
        hardware_config.dac_taps);

    return
        initialise_strings()  ?:
//         initialise_ddr_epics()  ?:
//         initialise_adc_dac()  ?:
//         initialise_fir()  ?:
//         initialise_bunch_select()  ?:
//         initialise_sequencer()  ?:
//         initialise_triggers()  ?:
//         initialise_sensors()  ?:
//         initialise_detector()  ?:
//         initialise_tune()  ?:
//         initialise_tune_peaks()  ?:
//         initialise_tune_follow();
        ERROR_OK;
}


int main(int argc, char *const argv[])
{
    error__t error =
        process_options(&argc, &argv) ?:
        validate_options(argc)  ?:

        initialise_hardware(
            device_prefix, bunches_per_turn, hardware_config_file)  ?:

        initialise_epics_device()  ?:
        initialise_subsystems()  ?:

        load_persistent_state(
            persistence_state_file, persistence_interval, false)  ?:
        initialise_epics();

    if (!error)
    {
        printf("EPICS TMBF Driver, Version %s.  Built: %s.\n",
            LMBF_VERSION, BUILD_DATE_TIME);

        error = TEST_OK(iocsh(NULL) == 0);

        terminate_persistent_state();
    }

    /* Orderly shutdown. */
    terminate_hardware();

    return ERROR_REPORT(error, "Unable to start IOC") ? 1 : 0;
}
