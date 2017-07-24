/* Fast memory readout support. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

#include "error.h"
#include "epics_device.h"
#include "epics_extra.h"

#include "register_defs.h"
#include "hardware.h"
#include "common.h"
#include "configs.h"
#include "events.h"

#include "memory.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Channel selection. */


/* Selection control PVs. */
static struct epics_record *memory_select;
static struct epics_record *chan0_select;
static struct epics_record *chan1_select;


/* We map the global memory selection into individual channel selections via the
 * map below. */
enum chan_select { ADC0, FIR0, DAC0, ADC1, FIR1, DAC1 };
struct map_entry {
    enum chan_select ch0;
    enum chan_select ch1;
};
static const struct map_entry select_map[15] = {
    { ADC0, ADC1 },     // 0 ADC
    { ADC0, FIR1 },
    { ADC0, DAC1 },
    { ADC0, FIR0 },
    { FIR0, ADC1 },
    { FIR0, FIR1 },     // 5 FIR
    { FIR0, DAC1 },
    { FIR0, DAC0 },
    { DAC0, ADC1 },
    { DAC0, FIR1 },
    { DAC0, DAC1 },     // 10 DAC
    { DAC0, ADC0 },
    { ADC1, FIR1 },
    { FIR1, DAC1 },
    { DAC1, ADC1 },
};

/* When considering a repeated selection we only inspect the true pairs. */
static const unsigned int select_map_pairs[] = { 0, 5, 10, };

/* Convert repeated selection into a sensible pair. */
static enum chan_select find_single_selection(enum chan_select sel)
{
    for (unsigned int i = 0; i < ARRAY_SIZE(select_map_pairs); i ++)
    {
        unsigned int ix = select_map_pairs[i];
        struct map_entry entry = select_map[ix];
        if (entry.ch0 == sel  ||  entry.ch1 == sel)
            return ix;
    }

    return 0;       // Should not happen!
}


static bool map_eq(struct map_entry a, struct map_entry b)
{
    return a.ch0 == b.ch0  &&  a.ch1 == b.ch1;
}

static enum chan_select find_paired_selection(
    enum chan_select sel0, enum chan_select sel1)
{
    const struct map_entry fwd = { sel0, sel1 };
    const struct map_entry rev = { sel1, sel0 };
    for (unsigned int i = 0; i < ARRAY_SIZE(select_map); i ++)
        if (map_eq(select_map[i], fwd)  ||  map_eq(select_map[i], rev))
            return i;

    return 0;       // Should not happen!
}


static enum chan_select find_selection(
    enum chan_select sel0, enum chan_select sel1)
{
    if (sel0 == sel1)
        return find_single_selection(sel0);
    else
        return find_paired_selection(sel0, sel1);
}


static enum chan_select chan0_selection;
static enum chan_select chan1_selection;


static void write_memory_select(unsigned int mux)
{
    struct map_entry entry = select_map[mux];
    chan0_selection = entry.ch0;
    WRITE_OUT_RECORD(mbbo, chan0_select, chan0_selection, false);
    chan1_selection = entry.ch1;
    WRITE_OUT_RECORD(mbbo, chan1_select, chan1_selection, false);
    hw_write_dram_mux(mux);
}

static void write_chan0_select(unsigned int value)
{
    enum chan_select selection = find_selection(value, chan1_selection);
    WRITE_OUT_RECORD(mbbo, memory_select, selection, true);
}

static void write_chan1_select(unsigned int value)
{
    enum chan_select selection = find_selection(chan0_selection, value);
    WRITE_OUT_RECORD(mbbo, memory_select, selection, true);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Data capture. */


static struct epics_interlock *memory_readout;

static uint32_t *memory_buffer;
static int16_t *memory_wf0;
static int16_t *memory_wf1;

static struct in_epics_record_bi *busy_status;

static struct epics_record *origin_pv;

static bool triggered_capture;
static unsigned int trigger_origin;
static int readout_offset;


static void readout_memory(void)
{
    unsigned int readout_length = system_config.memory_readout_length;

    size_t origin = (size_t) trigger_origin;
    size_t delta = (size_t) (readout_offset * (int) sizeof(uint32_t));
    size_t offset = origin + delta;
    hw_read_dram_memory(offset, readout_length, memory_buffer);

    interlock_wait(memory_readout);

    for (unsigned int i = 0; i < readout_length; i ++)
    {
        memory_wf0[i] = (int16_t) memory_buffer[i];
        memory_wf1[i] = (int16_t) (memory_buffer[i] >> 16);
    }

    interlock_signal(memory_readout, NULL);
}


static void write_dram_runout(unsigned int runout)
{
    static const unsigned int runout_lookup[] = {
        0x00000000,         // 0 %
        0x04000000,         // 25 %
        0x08000000,         // 50 %
        0x0C000000,         // 75 %
        0x0FFFFFFF          // 100 %
    };
    hw_write_dram_runout(runout_lookup[runout]);
}


static void write_readout_offset(int offset)
{
    readout_offset = offset;
    if (check_epics_ready())
        readout_memory();
}


static void start_capture(void)
{
    hw_write_dram_capture_command(true, !triggered_capture);
}


static void stop_capture(void)
{
    hw_write_dram_capture_command(false, true);
}


static void capture_complete(void)
{
    trigger_origin = hw_read_dram_address();
    trigger_record(origin_pv);
    readout_memory();
}


static void handle_memory_event(void *context, struct interrupts interrupts)
{
    WRITE_IN_RECORD(bi, busy_status, hw_read_dram_active());

    if (interrupts.dram_done)
        capture_complete();
}


void prepare_memory(void)
{
    hw_write_dram_capture_command(true, false);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static char device_name[256];


error__t initialise_memory(void)
{
    unsigned int readout_length = system_config.memory_readout_length;
    memory_buffer = calloc(sizeof(int32_t), readout_length);
    memory_wf0 = calloc(sizeof(int16_t), readout_length);
    memory_wf1 = calloc(sizeof(int16_t), readout_length);

    register_event_handler(
        INTERRUPT_HANDLER_MEMORY,
        INTERRUPTS(.dram_busy = 1, .dram_done = 1),
        NULL, handle_memory_event);

    WITH_NAME_PREFIX("MEM")
    {
        /* Memory readout. */
        memory_readout = create_interlock("READOUT", false);
        PUBLISH_WF_READ_VAR(short, "WF0", readout_length, memory_wf0);
        PUBLISH_WF_READ_VAR(short, "WF1", readout_length, memory_wf1);

        PUBLISH_WRITER_P(longout, "OFFSET", write_readout_offset);

        /* Channel readout configuration. */
        memory_select = PUBLISH_WRITER_P(mbbo, "SELECT", write_memory_select);
        chan0_select = PUBLISH_WRITER(mbbo, "SEL0", write_chan0_select);
        chan1_select = PUBLISH_WRITER(mbbo, "SEL1", write_chan1_select);
        PUBLISH_WRITER_P(bo, "FIR_GAIN", hw_write_dram_fir_gain);

        /* Capture triggering. */
        PUBLISH_ACTION("START", start_capture);
        PUBLISH_ACTION("STOP", stop_capture);
        PUBLISH_WRITE_VAR_P(bo, "TRIGGERED", triggered_capture);
        busy_status = PUBLISH_IN_VALUE_I(bi, "BUSY");
        PUBLISH_WRITER_P(mbbo, "RUNOUT", write_dram_runout);

        PUBLISH_WF_READ_VAR(char, "DEVICE", sizeof(device_name), device_name);
        origin_pv = PUBLISH_READ_VAR_I(ulongin, "ORIGIN", trigger_origin);
    }

    return
        hw_read_fast_dram_name(device_name, sizeof(device_name));
}
