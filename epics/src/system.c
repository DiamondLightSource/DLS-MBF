/* System level definitions. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/utsname.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"

#include "common.h"
#include "system.h"


static struct nco_context {
    int channel;
} nco_context[CHANNEL_COUNT];

static bool set_nco_frequency(void *context, const double *freq)
{
    struct nco_context *nco = context;
    hw_write_nco0_frequency(nco->channel, tune_to_freq(*freq));
    return true;
}

static bool set_nco_gain(void *context, const unsigned int *gain)
{
    struct nco_context *nco = context;
    hw_write_dac_nco0_gain(nco->channel, *gain);
    hw_write_dac_nco0_enable(nco->channel, *gain < 15);
    return true;
}

static void publish_nco_pvs(void)
{
    FOR_CHANNEL_NAMES(channel, "NCO")
    {
        struct nco_context *nco = &nco_context[channel];
        nco->channel = channel;
        PUBLISH(ao, "FREQ", set_nco_frequency, .context = nco, .persist = true);
        PUBLISH(mbbo, "GAIN", set_nco_gain, .context = nco, .persist = true);
    }
}


/* Some published strings for system identification etc. */
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


error__t initialise_system(void)
{
//     PUBLISH_READER(ulongin, "FPGA_VER", hw_read_version);
//     PUBLISH_WRITER(bo, "LOOPBACK", hw_write_loopback_enable);
//     PUBLISH_WRITER(bo, "COMPENSATE", hw_write_compensate_disable);

    printf("%u bunches, %u ADC taps, %u bunch taps, %u DAC taps\n",
        hardware_config.bunches,
        hardware_config.adc_taps,
        hardware_config.bunch_taps,
        hardware_config.dac_taps);

    publish_nco_pvs();
    return initialise_strings();
}
