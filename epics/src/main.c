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

#include "error.h"
#include "persistence.h"
#include "epics_device.h"
#include "epics_extra.h"
#include "pvlogging.h"

#include "hardware.h"
#include "common.h"
#include "system.h"
#include "mms.h"
#include "adc.h"
#include "dac.h"
#include "bunch_fir.h"
#include "bunch_select.h"


/* External declaration of DBD binding. */
extern int lmbf_registerRecordDeviceDriver(struct dbBase *pdbbase);


/* Persistence state management. */
static const char *persistence_state_file = NULL;
static int persistence_interval = 120;              // 2 minute update interval

/* Device name configured on startup. */
static const char *device_name = NULL;

/* Channel names for the two channels. */
static const char *channel_names[CHANNEL_COUNT];

/* Device prefix for hardware interface. */
static const char *device_prefix = NULL;

/* Number of bunches per turn. */
static unsigned int bunches_per_turn;

/* File to read hardware configuration settings. */
static const char *hardware_config_file = NULL;

/* Limits length of waveforms logged on output. */
static int max_log_array_length = 10000;

/* Polling interval for MMS scanning. */
static unsigned int mms_poll_interval = 100000;

/* Machine revolution frequency, used for timing calculations in GUI. */
static double revolution_frequency = 533848;

/* Whether to lock registers on startup.  Only for debug. */
static bool lock_registers = true;



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
"   -H: Specify hardware configuration file (required)\n"
"   -C: Specify comma separated channel names (required)\n"
"   -m: Specify MMS poll interval\n"
"   -f: Specify machine revolution frequency for timing calculations\n"
"   -u  Startup with hardware registers unlocked (debug only)\n"
    );
}


static error__t parse_channel_names(char *names)
{
    char *comma = strchr(names, ',');
    return
        TEST_OK_(comma, "Must specify two channel names")  ?:
        DO(
            *comma = '\0';
            channel_names[0] = names;
            channel_names[1] = comma + 1)  ?:
        TEST_OK_(names[0]  &&  comma[1], "Empty channel names");
}


static error__t process_options(int *argc, char *const *argv[])
{
    error__t error = ERROR_OK;
    while (!error)
    {
        switch (getopt(*argc, *argv, "+hs:b:i:l:p:d:H:C:m:f:u"))
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
            case 'C':   error = parse_channel_names(optarg);    break;
            case 'm':
                mms_poll_interval = (unsigned) atoi(optarg);
                break;
            case 'f':   revolution_frequency = atof(optarg);    break;
            case 'u':   lock_registers = false;                 break;
            default:
                error = FAIL_("Invalid command line option");
            case -1:
                /* All options successfully read.  Consume them and return
                 * success. */
                *argc -= optind;
                *argv += optind;
                return ERROR_OK;
        }
    }
    return error;
}


static error__t validate_options(int argc)
{
    return
        TEST_OK_(argc == 0, "Unexpected extra arguments")  ?:
        TEST_OK_(bunches_per_turn > 0, "Must specify bunches per turn")  ?:
        TEST_OK_(persistence_state_file, "Must specify state file")  ?:
        TEST_OK_(device_prefix, "Must specify device prefix")  ?:
        TEST_OK_(hardware_config_file, "Must specify config file")  ?:
        TEST_OK_(device_name, "Must specify device name")  ?:
        TEST_OK_(channel_names[0]  &&  channel_names[1],
            "Must specify channel names");
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
    database_add_macro("CHAN0", "%s", channel_names[0]);
    database_add_macro("CHAN1", "%s", channel_names[1]);
    database_add_macro("ADC_TAPS", "%d", hardware_config.adc_taps);
    database_add_macro("BUNCH_TAPS", "%d", hardware_config.bunch_taps);
    database_add_macro("DAC_TAPS", "%d", hardware_config.dac_taps);
    database_add_macro("BUNCHES_PER_TURN", "%d", hardware_config.bunches);
    database_add_macro("REVOLUTION_FREQUENCY", "%g", revolution_frequency);
    return database_load_file(database);
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
        TEST_OK(iocInit() == 0);
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
//         initialise_sequencer()  ?:
//         initialise_triggers()  ?:
//         initialise_sensors()  ?:
//         initialise_detector()  ?:
//         initialise_tune()  ?:
//         initialise_tune_peaks()  ?:
//         initialise_tune_follow();

        /* Post initialisation startup. */
        start_mms_handlers(mms_poll_interval)  ?:
        ERROR_OK;
}


int main(int argc, char *const argv[])
{
    error__t error =
        process_options(&argc, &argv) ?:
        validate_options(argc)  ?:

        initialise_hardware(
            device_prefix, bunches_per_turn, lock_registers)  ?:
        initialise_epics_device()  ?:

        DO(set_channel_names(channel_names))  ?:
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
