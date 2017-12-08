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
#include "trigger_target.h"

#include "memory.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Channel selection. */


/* Selection control PVs. */
static struct epics_record *memory_select;
static struct epics_record *chan0_select;
static struct epics_record *chan1_select;

/* Current channel selection. */
enum chan_select { ADC0, FIR0, DAC0, ADC1, FIR1, DAC1 };
static enum chan_select chan_selection[CHANNEL_COUNT];



/* We map the global memory selection into individual channel selections via the
 * map below. */
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
    { ADC0, DAC0 },
    { ADC1, FIR1 },
    { FIR1, DAC1 },
    { ADC1, DAC1 },
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


static void write_memory_select(unsigned int mux)
{
    struct map_entry entry = select_map[mux];
    chan_selection[0] = entry.ch0;
    WRITE_OUT_RECORD(mbbo, chan0_select, chan_selection[0], false);
    chan_selection[1] = entry.ch1;
    WRITE_OUT_RECORD(mbbo, chan1_select, chan_selection[1], false);
    hw_write_dram_mux(mux);
}

static void write_chan0_select(unsigned int value)
{
    enum chan_select selection = find_selection(value, chan_selection[1]);
    WRITE_OUT_RECORD(mbbo, memory_select, selection, true);
}

static void write_chan1_select(unsigned int value)
{
    enum chan_select selection = find_selection(chan_selection[0], value);
    WRITE_OUT_RECORD(mbbo, memory_select, selection, true);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Data capture. */


static struct epics_interlock *memory_readout;

static uint32_t *memory_buffer;
static int16_t *memory_wf0;
static int16_t *memory_wf1;

static struct in_epics_record_bi *busy_status;

static unsigned int trigger_origin;
static int readout_offset;

/* dac_delays[] is written by the DAC control, as this delay is a bit dynamic.
 * channel_delays[] is written when capture is complete, so that we don't see
 * changes while working with the runout. */
static unsigned int dac_delays[CHANNEL_COUNT];
static unsigned int adc_delays[CHANNEL_COUNT];
static unsigned int channel_delays[CHANNEL_COUNT];
static unsigned int channel_skew;


void set_memory_dac_offset(int channel, unsigned int delay)
{
    dac_delays[channel] = delay;
}

void set_memory_adc_offset(int channel, unsigned int delay)
{
    adc_delays[channel] = delay;
}

void set_memory_turn_clock_offsets(unsigned int offsets[CHANNEL_COUNT])
{
    unsigned int bunches_per_turn = system_config.bunches_per_turn;
    channel_skew =
        (bunches_per_turn + offsets[0] - offsets[1]) % bunches_per_turn;
}


/* We record the channel delays current at the time capture to memory is
 * completed.  This is as good a time as any to take a snapshot. */
static void update_channel_delays(void)
{
    for (int channel = 0; channel < CHANNEL_COUNT; channel ++)
    {
        unsigned int delay = 0;
        switch (chan_selection[channel])
        {
            case ADC0: delay = adc_delays[0]; break;
            case ADC1: delay = adc_delays[1]; break;
            case FIR0: case FIR1:
                delay = hardware_delays.DRAM_FIR_DELAY;
                break;
            case DAC0: delay = dac_delays[0]; break;
            case DAC1: delay = dac_delays[1]; break;
        }

        switch (chan_selection[channel])
        {
            case ADC0: case FIR0: case DAC0:
                channel_delays[channel] = delay;
                break;
            case ADC1: case FIR1: case DAC1:
                channel_delays[channel] =
                    (delay + channel_skew) % hardware_config.bunches;
                break;
        }
    }
}


size_t compute_dram_offset(int offset_turns)
{
    return
        (size_t) trigger_origin +
        (size_t) (
            offset_turns *
            (int) system_config.bunches_per_turn *
            (int) sizeof(uint32_t));
}


void get_memory_channel_delays(unsigned int *d0, unsigned int *d1)
{
    *d0 = channel_delays[0];
    *d1 = channel_delays[1];
}


static void readout_memory(void)
{
    unsigned int readout_length = system_config.memory_readout_length;
    unsigned int bunches_per_turn = system_config.bunches_per_turn;

    size_t offset = compute_dram_offset(readout_offset);
    hw_read_dram_memory(
        offset, readout_length + bunches_per_turn, memory_buffer);

    interlock_wait(memory_readout);

    unsigned int d0 = channel_delays[0];
    unsigned int d1 = channel_delays[1];
    for (unsigned int i = 0; i < readout_length; i ++)
    {
        memory_wf0[i] = (int16_t) memory_buffer[i + d0];
        memory_wf1[i] = (int16_t) (memory_buffer[i + d1] >> 16);
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


static void capture_complete(void)
{
    update_channel_delays();
    trigger_origin = hw_read_dram_address();
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


static bool fir_gains[CHANNEL_COUNT];
static bool fir_overflow[CHANNEL_COUNT];


static void write_fir_gain(void)
{
    hw_write_dram_fir_gains(fir_gains);
}

static void read_dram_status(void)
{
    hw_read_dram_status(fir_overflow);
}


error__t initialise_memory(void)
{
    unsigned int readout_length = system_config.memory_readout_length;
    unsigned int bunches_per_turn = system_config.bunches_per_turn;

    /* Allocate one extra turn for the memory readout buffer. */
    memory_buffer = CALLOC(uint32_t, readout_length + bunches_per_turn);
    memory_wf0 = CALLOC(int16_t, readout_length);
    memory_wf1 = CALLOC(int16_t, readout_length);

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

        /* FIR gain and status monitoring. */
        PUBLISH_ACTION("WRITE_GAIN", write_fir_gain);
        PUBLISH_WRITE_VAR_P(bo, "FIR0_GAIN", fir_gains[0]);
        PUBLISH_WRITE_VAR_P(bo, "FIR1_GAIN", fir_gains[1]);
        PUBLISH_ACTION("READ_OVF", read_dram_status);
        PUBLISH_READ_VAR(bi, "FIR0_OVF", fir_overflow[0]);
        PUBLISH_READ_VAR(bi, "FIR1_OVF", fir_overflow[1]);

        /* Capture triggering. */
        PUBLISH_ACTION("CAPTURE", immediate_memory_capture);
        busy_status = PUBLISH_IN_VALUE_I(bi, "BUSY");
        PUBLISH_WRITER_P(mbbo, "RUNOUT", write_dram_runout);
    }

    register_event_handler(
        INTERRUPT_HANDLER_MEMORY,
        INTERRUPTS(.dram_busy = 1, .dram_done = 1),
        NULL, handle_memory_event);

    return ERROR_OK;
}
