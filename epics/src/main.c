#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>

#include <epicsThread.h>
#include <iocsh.h>
#include <caerr.h>
#include <envDefs.h>
#include <dbAccess.h>
#include <iocInit.h>
#include <dbScan.h>

#include "error.h"
#include "persistence.h"
#include "epics_device.h"
#include "epics_extra.h"
#include "pvlogging.h"

#include "hardware.h"
#include "common.h"
#include "system.h"
#include "configs.h"
#include "mms.h"
#include "adc.h"
#include "dac.h"
#include "bunch_fir.h"
#include "bunch_select.h"
#include "sequencer.h"


/* External declaration of DBD binding. */
extern int lmbf_registerRecordDeviceDriver(struct dbBase *pdbbase);


/* Device prefix for hardware interface. */
static const char *device_prefix = NULL;

/* File to read hardware configuration settings. */
static const char *hardware_config_file = NULL;

/* Configuration files to load. */
static const char *system_config_file;

/* Whether to lock registers on startup.  Only for debug. */
static bool lock_registers = true;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Argument handling. */


static void usage(void)
{
    printf(
"LMBF IOC.  Options:\n"
"   -p: Specify device prefix used to locate LMBF device (required)\n"
"   -H: Specify hardware configuration file (required)\n"
"   -S: Specify system configuration file (required)\n"
"   -u  Startup with hardware registers unlocked (debug only)\n"
    );
}


static error__t process_options(int *argc, char *const *argv[])
{
    while (true)
    {
        switch (getopt(*argc, *argv, "+hp:H:S:u"))
        {
            case 'h':   usage();                                exit(1);
            case 'p':   device_prefix = optarg;                 break;
            case 'H':   hardware_config_file = optarg;          break;
            case 'S':   system_config_file = optarg;            break;
            case 'u':   lock_registers = false;                 break;
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
    return ERROR_OK;    // Never reach here
}


static error__t validate_options(int argc)
{
    return
        TEST_OK_(argc == 0, "Unexpected extra arguments")  ?:
        TEST_OK_(device_prefix, "Must specify device prefix")  ?:
        TEST_OK_(hardware_config_file, "Must specify hardware config file")  ?:
        TEST_OK_(system_config_file, "Must specify system config file");
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Core EPICS startup (st.cmd equivalent processing). */


/* Configures the IOC prompt to show the EPICS device name. */
static void set_prompt(void)
{
    char prompt[256];
    snprintf(prompt, sizeof(prompt), "%s> ", system_config.epics_name);
    epicsEnvSet("IOCSH_PS1", prompt);
}


static error__t load_database(const char *database)
{
    database_add_macro("DEVICE", "%s", system_config.epics_name);
    database_add_macro("CHAN0", "%s", system_config.channel0_name);
    database_add_macro("CHAN1", "%s", system_config.channel1_name);
    database_add_macro("ADC_TAPS", "%d", hardware_config.adc_taps);
    database_add_macro("BUNCH_TAPS", "%d", hardware_config.bunch_taps);
    database_add_macro("DAC_TAPS", "%d", hardware_config.dac_taps);
    database_add_macro("BUNCHES_PER_TURN", "%d", hardware_config.bunches);
    database_add_macro(
        "REVOLUTION_FREQUENCY", "%g", system_config.revolution_frequency);
    return database_load_file(database);
}


static error__t initialise_epics(void)
{
    set_prompt();
    return
        start_caRepeater()  ?:
        hook_pv_logging("db/access.acf", system_config.pv_log_array_length)  ?:
        TEST_OK(dbLoadDatabase("dbd/lmbf.dbd", NULL, NULL) == 0)  ?:
        TEST_OK(lmbf_registerRecordDeviceDriver(pdbbase) == 0)  ?:
        load_database("db/lmbf.db")  ?:
        TEST_OK(iocInit() == 0);
}


/* We'd like all EPICS record scanning to stop before we unload the hardware,
 * but alas it looks like this the best we can do. */
static void stop_epics(void)
{
    scanPause();
    usleep(100000);     // Give things time to settle
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* Initialises the various subsystems. */
static error__t initialise_subsystems(void)
{
    return
        initialise_system()  ?:
        initialise_adc()  ?:
        initialise_dac()  ?:
        initialise_bunch_fir()  ?:
        initialise_bunch_select()  ?:
        initialise_sequencer()  ?:
//         initialise_triggers()  ?:
//         initialise_sensors()  ?:
//         initialise_detector()  ?:
//         initialise_tune()  ?:
//         initialise_tune_peaks()  ?:
//         initialise_tune_follow();

        /* Post initialisation startup. */
        start_mms_handlers()  ?:
        ERROR_OK;
}


int main(int argc, char *const argv[])
{
    error__t error =
        process_options(&argc, &argv) ?:
        validate_options(argc)  ?:

        load_configs(hardware_config_file, system_config_file)  ?:
        initialise_hardware(
            device_prefix, system_config.bunches_per_turn, lock_registers)  ?:
        initialise_epics_device()  ?:

        initialise_subsystems()  ?:

        load_persistent_state(
            system_config.persistence_file,
            system_config.persistence_interval, false)  ?:
        initialise_epics();

    if (!error)
    {
        printf("EPICS TMBF Driver, Version %s.  Built: %s.\n",
            LMBF_VERSION, BUILD_DATE_TIME);

        error = TEST_OK(iocsh(NULL) == 0);

        terminate_persistent_state();
    }

    /* Orderly shutdown. */
    stop_epics();
    stop_mms_handlers();
    terminate_hardware();

    return ERROR_REPORT(error, "Unable to start IOC") ? 1 : 0;
}
