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

#include "register_defs.h"
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
#include "memory.h"
#include "events.h"
#include "triggers.h"
#include "detector.h"
#include "socket_server.h"
#include "delay.h"


/* External declaration of DBD binding. */
extern int mbf_registerRecordDeviceDriver(struct dbBase *pdbbase);


/* Device prefix for EPICS files. */
static const char *path_prefix = ".";

/* File to read hardware configuration settings. */
static const char *hardware_config_file = NULL;

/* Configuration files to load. */
static const char *system_config_file;

/* Whether to lock registers on startup.  Only for debug. */
static bool lock_registers = true;

/* Can be reset for quiet operation. */
static bool enable_pv_logging = true;

/* Set for operation with hardware disabled.  Useful for standalone development
 * of interfacing systems. */
static bool no_hardware = false;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Argument handling. */


static void usage(void)
{
    printf(
"MBF IOC.  Options:\n"
"   -C: Specify directory where EPICS files are found\n"
"   -u  Startup with hardware registers unlocked (debug only)\n"
"   -q  Disable PV logging\n"
"   -n  Disable hardware\n"
    );
}


static error__t process_options(int *argc, char *const *argv[])
{
    while (true)
    {
        switch (getopt(*argc, *argv, "+hC:uqn"))
        {
            case 'h':   usage();                                exit(1);
            case 'C':   path_prefix = optarg;                   break;
            case 'u':   lock_registers = false;                 break;
            case 'q':   enable_pv_logging = false;              break;
            case 'n':   no_hardware = true;                     break;
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


static error__t process_arg(
    int *argc, char *const *argv[],
    const char **result, const char *description)
{
    if (*argc <= 0)
    {
        if (description)
            /* Mandatory argument, just fail. */
            return FAIL_("Missing argument: %s", description);
        else
            /* Missing optional argument. */
            return ERROR_OK;
    }
    else
    {
        *result = **argv;
        *argv += 1;
        *argc -= 1;
        return ERROR_OK;
    }
}


static error__t process_args(int argc, char *const argv[])
{
    return
        process_arg(&argc, &argv, &system_config_file, "system config file")  ?:
        process_arg(&argc, &argv, &hardware_config_file, NULL)  ?:
        TEST_OK_(argc == 0, "Unexpected extra arguments");
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
    database_add_macro("AXIS0", "%s", system_config.axis0_name);
    database_add_macro("AXIS1", "%s", system_config.axis1_name);
    if (system_config.lmbf_mode)
        database_add_macro("AXIS01", "%s%s",
            system_config.axis0_name, system_config.axis1_name);
    database_add_macro("ADC_TAPS", "%d", hardware_config.adc_taps);
    database_add_macro("BUNCH_TAPS", "%d", hardware_config.bunch_taps);
    database_add_macro("DAC_TAPS", "%d", hardware_config.dac_taps);
    database_add_macro("BUNCHES_PER_TURN", "%d", hardware_config.bunches);
    database_add_macro(
        "REVOLUTION_FREQUENCY", "%g", system_config.revolution_frequency);
    database_add_macro(
        "MEMORY_READOUT_LENGTH", "%d", system_config.memory_readout_length);
    database_add_macro("DETECTOR_LENGTH", "%d", system_config.detector_length);
    return database_load_file(database);
}


static error__t initialise_epics(void)
{
    char filename[PATH_MAX];
#define MAKE_PATH(name) \
    ( { snprintf(filename, PATH_MAX, "%s/%s", path_prefix, name); \
        filename; } )

    const char *database =
        system_config.lmbf_mode ? "db/lmbf.db" : "db/tmbf.db";
    set_prompt();
    return
        start_caRepeater()  ?:
        IF(enable_pv_logging,
            hook_pv_logging(
                MAKE_PATH("db/access.acf"),
                system_config.pv_log_array_length))  ?:
        TEST_OK(dbLoadDatabase(MAKE_PATH("dbd/mbf.dbd"), NULL, NULL) == 0)  ?:
        TEST_OK(mbf_registerRecordDeviceDriver(pdbbase) == 0)  ?:
        load_database(MAKE_PATH(database))  ?:
        TEST_OK(iocInit() == 0)  ?:
        TEST_OK(check_unused_record_bindings(true) == 0);

#undef MAKE_PATH
}


/* We'd like all EPICS record scanning to stop before we unload the hardware,
 * but alas it looks like this the best we can do. */
static void stop_epics(void)
{
    scanPause();
    usleep(100000);     // Give things time to settle
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/* Signal handler for orderly shutdown. */
static void at_exit(int signum)
{
    log_message("Closing on signal %d", signum);
    close(STDIN_FILENO);
}


static error__t initialise_signals(void)
{
    sigset_t signal_mask;
    struct sigaction do_shutdown = {
        .sa_handler = at_exit, .sa_flags = SA_RESTART };
    struct sigaction do_ignore = {
        .sa_handler = SIG_IGN, .sa_flags = SA_RESTART };
    struct sigaction do_default = { .sa_handler = SIG_DFL, };
    return
        /* Make sure that we can actually see the signals we're going handle,
         * and block everything else. */
        TEST_IO(sigfillset(&signal_mask))  ?:
        TEST_IO(sigdelset(&signal_mask, SIGHUP))  ?:
        TEST_IO(sigdelset(&signal_mask, SIGINT))  ?:
        TEST_IO(sigdelset(&signal_mask, SIGTERM))  ?:
        TEST_IO(sigdelset(&signal_mask, SIGPIPE))  ?:
        TEST_IO(sigdelset(&signal_mask, SIGQUIT))  ?:
        TEST_IO(sigprocmask(SIG_SETMASK, &signal_mask, NULL))  ?:

        /* Catch the usual interruption signals and use them to trigger an
         * orderly shutdown.  As a reminder, these are the sources of these
         * three signals:
         *  1  HUP      Terminal hangup, also often used for config reload
         *  2  INT      Keyboard interrupt (CTRL-C)
         *  15 TERM     Normal termination request, default kill signal */
        TEST_IO(sigfillset(&do_shutdown.sa_mask))  ?:
        TEST_IO(sigaction(SIGHUP,  &do_shutdown, NULL))  ?:
        TEST_IO(sigaction(SIGINT,  &do_shutdown, NULL))  ?:
        TEST_IO(sigaction(SIGTERM, &do_shutdown, NULL))  ?:

        /* When acting as a server we need to ignore SIGPIPE, of course. */
        TEST_IO(sigaction(SIGPIPE, &do_ignore,   NULL))  ?:

        /* Allow SIGQUIT to kill us unconditionally.  This is useful if the
         * server has become stuck. */
        TEST_IO(sigaction(SIGQUIT, &do_default,  NULL));
}


/* Initialises the various subsystems. */
static error__t initialise_subsystems(void)
{
    return
        initialise_delay()  ?:
        initialise_system()  ?:
        initialise_adc()  ?:
        initialise_dac()  ?:
        initialise_bunch_fir()  ?:
        initialise_bunch_select()  ?:
        initialise_sequencer()  ?:
        initialise_memory()  ?:
        initialise_triggers()  ?:
        initialise_detector()  ?:

        /* Post initialisation startup. */
        start_mms_handlers()  ?:
        ERROR_OK;
}


int main(int argc, char *const argv[])
{
    error__t error =
        process_options(&argc, &argv)  ?:
        process_args(argc, argv)  ?:

        load_configs(hardware_config_file, system_config_file)  ?:
        initialise_hardware(
            system_config.device_address, system_config.bunches_per_turn,
            lock_registers, system_config.lmbf_mode, no_hardware)  ?:
        initialise_epics_device()  ?:

        initialise_subsystems()  ?:
        initialise_events()  ?:

        load_persistent_state(
            system_config.persistence_file,
            system_config.persistence_interval, false)  ?:
        initialise_epics()  ?:
        initialise_socket_server(system_config.data_port)  ?:

        initialise_signals();

    if (!error)
    {
        printf("EPICS MBF Driver, Version %s.  Built: %s.\n",
            MBF_VERSION, BUILD_DATE_TIME);
        printf("Running in %s mode\n",
            system_config.lmbf_mode ? "LMBF" : "TMBF");

        error = TEST_OK(iocsh(NULL) == 0);

        terminate_persistent_state();
    }

    /* Orderly shutdown. */
    terminate_socket_server();
    stop_epics();
    stop_mms_handlers();
    terminate_events();
    terminate_hardware();

    return ERROR_REPORT(error, "Unable to start IOC") ? 1 : 0;
}
