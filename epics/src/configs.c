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



/* We're rather tricksy about the hardware delays.  We read them as int into an
 * unsigned int, and then later perform some conversions to ensure they are true
 * unsigned ints.  Ick. */
#define DELAY_ENTRY(entry) \
    { \
        .entry_type = CONFIG_int, \
        .name = #entry, \
        .address = (void *) &hardware_delays.entry, \
    }

static const struct config_entry hardware_delays_entries[] = {
    DELAY_ENTRY(MMS_ADC_DELAY),
    DELAY_ENTRY(MMS_ADC_FIR_DELAY),
    DELAY_ENTRY(MMS_ADC_REJECT_DELAY),
    DELAY_ENTRY(MMS_DAC_DELAY),
    DELAY_ENTRY(MMS_DAC_FIR_DELAY),

    DELAY_ENTRY(DRAM_ADC_DELAY),
    DELAY_ENTRY(DRAM_ADC_FIR_DELAY),
    DELAY_ENTRY(DRAM_ADC_REJECT_DELAY),
    DELAY_ENTRY(DRAM_DAC_DELAY),
    DELAY_ENTRY(DRAM_FIR_DELAY),
    DELAY_ENTRY(DRAM_DAC_FIR_DELAY),

    DELAY_ENTRY(BUNCH_GAIN_OFFSET),
    DELAY_ENTRY(BUNCH_FIR_OFFSET),

    DELAY_ENTRY(DET_ADC_OFFSET),
    DELAY_ENTRY(DET_FIR_OFFSET),

    DELAY_ENTRY(DET_FIR_DELAY),
    DELAY_ENTRY(DET_ADC_DELAY),
};


#define SYSTEM_ENTRY(type, entry) \
    { \
        .entry_type = CONFIG_##type, \
        .name = #entry, \
        .address = (void *) &system_config.entry, \
    }

static const struct config_entry system_config_entries[] = {
    SYSTEM_ENTRY(string, device_address),
    SYSTEM_ENTRY(string, epics_name),
    SYSTEM_ENTRY(string, axis0_name),
    SYSTEM_ENTRY(string, axis1_name),
    SYSTEM_ENTRY(uint, bunches_per_turn),
    SYSTEM_ENTRY(bool, lmbf_mode),
    SYSTEM_ENTRY(double, lmbf_fir_offset),
    SYSTEM_ENTRY(double, revolution_frequency),
    SYSTEM_ENTRY(uint, mms_poll_interval),
    SYSTEM_ENTRY(string, persistence_file),
    SYSTEM_ENTRY(int, persistence_interval),
    SYSTEM_ENTRY(int, pv_log_array_length),
    SYSTEM_ENTRY(int, archive_interval),
    SYSTEM_ENTRY(uint, memory_readout_length),
    SYSTEM_ENTRY(uint, detector_length),
    SYSTEM_ENTRY(uint, data_port),
};


static unsigned int convert_field(unsigned int value)
{
    int result = (int) value;
    if (result < 0)
        result += (int) system_config.bunches_per_turn;
    ASSERT_OK(0 <= result  &&  result < (int) system_config.bunches_per_turn);
    return (unsigned int) result;
}


#define ASSIGN_FIELD(field, value) \
    *CAST_TO(typeof(value) *, &(field)) = (value)
#define CONVERT_FIELD(name) \
    ASSIGN_FIELD(hardware_delays.name, convert_field(hardware_delays.name))
#if 0
#define CONVERT_FIELD(name) \
    *CAST_TO(unsigned int *, &hardware_delays.name) = \
        convert_field(hardware_delays.name)
#endif

static void convert_hardware_config(void)
{
    ASSIGN_FIELD(hardware_delays.valid, true);

    CONVERT_FIELD(MMS_ADC_DELAY);
    CONVERT_FIELD(MMS_ADC_FIR_DELAY);
    CONVERT_FIELD(MMS_ADC_REJECT_DELAY);
    CONVERT_FIELD(MMS_DAC_DELAY);
    CONVERT_FIELD(MMS_DAC_FIR_DELAY);

    CONVERT_FIELD(DRAM_ADC_DELAY);
    CONVERT_FIELD(DRAM_ADC_FIR_DELAY),
    CONVERT_FIELD(DRAM_ADC_REJECT_DELAY),
    CONVERT_FIELD(DRAM_DAC_DELAY);
    CONVERT_FIELD(DRAM_FIR_DELAY);
    CONVERT_FIELD(DRAM_DAC_FIR_DELAY);

    CONVERT_FIELD(BUNCH_GAIN_OFFSET);
    CONVERT_FIELD(BUNCH_FIR_OFFSET);

    CONVERT_FIELD(DET_ADC_OFFSET);
    CONVERT_FIELD(DET_FIR_OFFSET);
}


error__t load_configs(
    const char *hardware_config_file, const char *system_config_file)
{
    return
        load_config_file(
            system_config_file, system_config_entries,
            ARRAY_SIZE(system_config_entries), true)  ?:
        IF_ELSE(hardware_config_file,
            load_config_file(
                hardware_config_file, hardware_delays_entries,
                ARRAY_SIZE(hardware_delays_entries), false)  ?:
            DO(convert_hardware_config()),
        // else
            DO(log_message("Disabling delay compensation")));
}
