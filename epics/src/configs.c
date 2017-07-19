/* Loads configurations.
 *
 * There are two configurations loaded during startup.  One defines hardware
 * delays, the other defines basic system configuration settings. */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>

#include "error.h"

#include "config_file.h"

#include "configs.h"


const struct hardware_delays hardware_delays;
const struct system_config system_config;


/* We're going to be naughty in the following code and create mutable references
 * to the "constant" structures above so that we can load them at startup.  Tell
 * gcc to shush for the duration. */
#pragma GCC diagnostic ignored "-Wcast-qual"


#define DELAY_ENTRY(entry) \
    { \
        .entry_type = CONFIG_uint, \
        .name = #entry, \
        .address = (void *) &hardware_delays.entry, \
    }

static const struct config_entry hardware_delays_entries[] = {
    DELAY_ENTRY(adc_mms_offset),
    DELAY_ENTRY(dac_pre_fir_mms_offset),
    DELAY_ENTRY(dac_post_fir_mms_offset),
    DELAY_ENTRY(bunch_fir_offset),
    DELAY_ENTRY(bunch_out_offset),
    DELAY_ENTRY(bunch_gain_offset),
};


#define SYSTEM_ENTRY(type, entry) \
    { \
        .entry_type = CONFIG_##type, \
        .name = #entry, \
        .address = (void *) &system_config.entry, \
    }

static const struct config_entry system_config_entries[] = {
    SYSTEM_ENTRY(string, epics_name),
    SYSTEM_ENTRY(string, channel0_name),
    SYSTEM_ENTRY(string, channel1_name),
    SYSTEM_ENTRY(uint, bunches_per_turn),
    SYSTEM_ENTRY(double, revolution_frequency),
    SYSTEM_ENTRY(uint, mms_poll_interval),
    SYSTEM_ENTRY(string, persistence_file),
    SYSTEM_ENTRY(int, persistence_interval),
    SYSTEM_ENTRY(int, pv_log_array_length),
    SYSTEM_ENTRY(uint, memory_readout_length),
    SYSTEM_ENTRY(uint, detector_length),
};


error__t load_configs(
    const char *hardware_config_file, const char *system_config_file)
{
    return
        load_config_file(
            hardware_config_file, hardware_delays_entries,
            ARRAY_SIZE(hardware_delays_entries))  ?:
        load_config_file(
            system_config_file, system_config_entries,
            ARRAY_SIZE(system_config_entries));
}
