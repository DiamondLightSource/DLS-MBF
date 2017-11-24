/* Hardware interfacing to LMBF system. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>
#include <fcntl.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <pthread.h>

#include "error.h"

#include "amc525_lmbf_device.h"
#include "register_defs.h"

#include "common.h"
#include "hardware.h"


/* Externally published hardware configuration, initialised during call to
 * initialise_hardware(), subsequently constant. */
const struct hardware_config hardware_config;


static int dram0_device = -1;
static int dram1_device = -1;
/* We share the dram1 device between two channels under a lock, as there is
 * absolutely no benefit in running two copies of this file handle -- there's
 * only one underly DMA device anyway. */
static pthread_mutex_t dram1_mutex = PTHREAD_MUTEX_INITIALIZER;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Register access support. */


/* I'm quite nervous of the compiler doing bad things to our register access, so
 * we force all register IO to go through these two helper functions. */
static void writel(volatile uint32_t *reg, uint32_t value)
{
    *reg = value;
}

static uint32_t readl(volatile uint32_t *reg)
{
    return *reg;
}


/* This rather tricksy macro ensures that we can safely execute the assignment
 * reg = value, but actually converts the types on both sides so that we can do
 * the assignment via writel() instead.  We do this to try and avoid unhealthy
 * "optimisations" from the compiler, which seems to have some very dangerous
 * notions about volatile. */
#define _id_WRITEL(temp_val, temp_reg, reg, value) \
    do { \
        uint32_t temp_val = CAST_FROM_TO(typeof(reg), uint32_t, (value)); \
        volatile uint32_t *temp_reg = CAST_TO(volatile uint32_t *, &(reg)); \
        writel(temp_reg, temp_val); \
    } while(0)
#define WRITEL(args...) \
    _id_WRITEL(UNIQUE_ID(), UNIQUE_ID(), args)


/* Similar for reading. */
#define _id_READL(temp_reg, reg) \
    ( { \
        volatile uint32_t *temp_reg = CAST_TO(volatile uint32_t *, &(reg)); \
        CAST_TO(typeof(reg), readl(temp_reg)); \
    } )
#define READL(args...) \
    _id_READL(UNIQUE_ID(), args)


/* This is used to write to a group of fields.  Mainly saves the work of writing
 * the target type out. */
#define WRITE_FIELDS(target, fields...) \
    WRITEL(target, ((typeof(target)) { fields }))


#define WRITE_DSP_MIRROR(channel, reg, field, value) \
    dsp_mirror[channel].reg.field = (value); \
    WRITEL(dsp_regs[channel]->reg, dsp_mirror[channel].reg)


/* Convert array of bits to an array of booleans. */
static void bits_to_bools(unsigned int count, uint32_t bits, bool bools[])
{
    for (unsigned int i = 0; i < count; i ++)
    {
        bools[i] = bits & 1;
        bits >>= 1;
    }
}

/* Convert an array of booleans to an array of bits. */
static uint32_t bools_to_bits(unsigned int count, const bool bools[])
{
    uint32_t result = 0;
    for (unsigned int i = 0; i < count; i ++)
        result |= (unsigned) bools[i] << i;
    return result;
}


/* Updates one bit in a bit array.*/
static uint32_t write_selected_bit(
    uint32_t bits, unsigned int bit, bool value)
{
    return (bits & ~(1U << bit)) | ((uint32_t) value << bit);
}


/* Seeks to the given offset and reads the requested number of bytes from the
 * given device, returning an error if anything fails. */
static error__t read_dma_memory(
    int device, off_t seek_offset, size_t read_request, void *result)
{
    error__t error = TEST_IO(lseek(device, seek_offset, SEEK_SET));
    while (!error  &&  read_request > 0)
    {
        ssize_t read_size;
        error = TEST_IO(read_size = read(device, result, read_request));
        result += read_size;
        read_request -= (size_t) read_size;
        if (read_size == 0) break;          // Shouldn't happen.
    }
    return error;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* System registers. */

static volatile struct sys *sys_regs;


void hw_read_fpga_version(struct fpga_version *version)
{
    struct sys_version sys_version = sys_regs->version;
    struct sys_git_version git_version = sys_regs->git_version;
    *version = (struct fpga_version) {
        .major = sys_version.major,
        .minor = sys_version.minor,
        .patch = sys_version.patch,
        .git_sha = git_version.sha,
        .git_dirty = git_version.dirty,
    };
}

void hw_read_system_status(struct system_status *result)
{
    struct sys_status status = sys_regs->status;
    result->dsp_ok = status.dsp_ok;
    result->vcxo_ok = status.vcxo_ok;
    result->adc_ok = status.adc_ok;
    result->dac_ok = status.dac_ok;
    result->vcxo_locked = status.pll_ld1;
    result->vco_locked = status.pll_ld2;
    result->dac_irq = !status.dac_irqn;
    result->temp_alert = status.temp_alert;
}

void hw_write_turn_clock_idelay(unsigned int delay)
{
    WRITE_FIELDS(sys_regs->rev_idelay, .value = delay & 0x1F, .write = 1);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared Control registers. */

static volatile struct ctrl *ctrl_regs;
static pthread_mutex_t ctrl_lock = PTHREAD_MUTEX_INITIALIZER;
static struct ctrl ctrl_mirror;


void hw_write_lmbf_mode(bool lmbf_mode)
{
    LOCK(ctrl_lock);
    ctrl_mirror.control.adc_mux  = lmbf_mode;
    ctrl_mirror.control.nco0_mux = lmbf_mode;
    ctrl_mirror.control.nco1_mux = lmbf_mode;
    ctrl_mirror.control.bank_mux = lmbf_mode;
    WRITEL(ctrl_regs->control, ctrl_mirror.control);
    UNLOCK(ctrl_lock);
}

void hw_write_loopback_enable(int channel, bool loopback)
{
    LOCK(ctrl_lock);
    uint32_t loopbacks = write_selected_bit(
        ctrl_mirror.control.loopback, (unsigned) channel, loopback);
    ctrl_mirror.control.loopback = loopbacks & 0x3;
    WRITEL(ctrl_regs->control, ctrl_mirror.control);
    UNLOCK(ctrl_lock);
}

void hw_write_output_enable(int channel, bool enable)
{
    LOCK(ctrl_lock);
    uint32_t enables = write_selected_bit(
        ctrl_mirror.control.output, (unsigned) channel, enable);
    ctrl_mirror.control.output = enables & 0x3;
    WRITEL(ctrl_regs->control, ctrl_mirror.control);
    UNLOCK(ctrl_lock);
}


/* DRAM capture registers - - - - - - - - - - - - - - - - - - - - - - - - - */

void hw_write_dram_mux(unsigned int mux)
{
    LOCK(ctrl_lock);
    ctrl_mirror.mem_config.mux_select = mux & 0xF;
    WRITEL(ctrl_regs->mem_config, ctrl_mirror.mem_config);
    UNLOCK(ctrl_lock);
}

void hw_write_dram_fir_gains(bool gains[CHANNEL_COUNT])
{
    LOCK(ctrl_lock);
    ctrl_mirror.mem_config.fir0_gain = gains[0];
    ctrl_mirror.mem_config.fir1_gain = gains[1];
    WRITEL(ctrl_regs->mem_config, ctrl_mirror.mem_config);
    UNLOCK(ctrl_lock);
}

void hw_write_dram_runout(unsigned int count)
{
    WRITE_FIELDS(ctrl_regs->mem_count, .count = count & 0xFFFFFFF);
}

unsigned int hw_read_dram_address(void)
{
    return readl(&ctrl_regs->mem_address);
}

void hw_write_dram_capture_command(bool start, bool stop)
{
    WRITE_FIELDS(ctrl_regs->mem_command,
        .start = start,
        .stop = stop);
}

bool hw_read_dram_active(void)
{
    struct ctrl_mem_status status = READL(ctrl_regs->mem_status);
    return status.enable;
}

void hw_read_dram_status(bool fir_overflow[CHANNEL_COUNT])
{
    struct ctrl_mem_pulsed pulsed = READL(ctrl_regs->mem_pulsed);
    bits_to_bools(CHANNEL_COUNT, pulsed.fir_ovf, fir_overflow);
}

void hw_read_dram_memory(size_t offset, size_t samples, uint32_t result[])
{
    error__t error = read_dma_memory(
        dram0_device, offset & (DRAM0_LENGTH - 1),
        samples * sizeof(uint32_t), result);
    ERROR_REPORT(error, "Error reading from DRAM0");
}


/* Trigger registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


static void hw_write_bunch_count(unsigned int bunches)
{
    LOCK(ctrl_lock);
    ctrl_mirror.trg_config_turn.max_bunch = (bunches - 1) & 0x3FF;
    WRITEL(ctrl_regs->trg_config_turn, ctrl_mirror.trg_config_turn);
    UNLOCK(ctrl_lock);
}

void hw_write_turn_clock_sync(void)
{
    WRITE_FIELDS(ctrl_regs->trg_control, .sync_turn = 1);
}

void hw_read_turn_clock_counts(
    unsigned int *turn_count, unsigned int *error_count)
{
    WRITE_FIELDS(ctrl_regs->trg_control, .read_sync = 1);
    *turn_count = ctrl_regs->trg_turn_count.count;
    *error_count = ctrl_regs->trg_error_count.count;
}

void hw_write_turn_clock_offset(int channel, unsigned int offset)
{
    /* Note!  If offset >= bunches_per_turn then turn clocks will stop being
     * generated.  Unfortunately this will then cause reading mms.count to hang
     * which will then freeze the system.  So don't. */
    ASSERT_OK(offset < hardware_config.bunches);
    LOCK(ctrl_lock);
    switch (channel)
    {
        case 0:
            ctrl_mirror.trg_config_turn.dsp0_offset = offset & 0x3FF;
            break;
        case 1:
            ctrl_mirror.trg_config_turn.dsp1_offset = offset & 0x3FF;
            break;
    }
    WRITEL(ctrl_regs->trg_config_turn, ctrl_mirror.trg_config_turn);
    UNLOCK(ctrl_lock);
}

void hw_read_trigger_events(bool sources[TRIGGER_SOURCE_COUNT], bool *blanking)
{
    struct ctrl_trg_pulsed events = READL(ctrl_regs->trg_pulsed);
    bits_to_bools(TRIGGER_SOURCE_COUNT, events.triggers, sources);
    *blanking = events.blanking;
}

void hw_write_trigger_arm(const bool arm[TRIGGER_TARGET_COUNT])
{
    WRITE_FIELDS(ctrl_regs->trg_control,
        .seq0_arm = arm[TRIGGER_SEQ0],
        .seq1_arm = arm[TRIGGER_SEQ1],
        .dram0_arm = arm[TRIGGER_DRAM]
    );
}

void hw_write_trigger_fire(const bool fire[TRIGGER_TARGET_COUNT])
{
    WRITE_FIELDS(ctrl_regs->trg_control,
        .seq0_fire = fire[TRIGGER_SEQ0],
        .seq1_fire = fire[TRIGGER_SEQ1],
        .dram0_fire = fire[TRIGGER_DRAM]
    );
}

void hw_write_trigger_disarm(const bool disarm[TRIGGER_TARGET_COUNT])
{
    WRITE_FIELDS(ctrl_regs->trg_control,
        .seq0_disarm = disarm[TRIGGER_SEQ0],
        .seq1_disarm = disarm[TRIGGER_SEQ1],
        .dram0_disarm = disarm[TRIGGER_DRAM]
    );
}

void hw_write_trigger_soft_trigger(void)
{
    WRITE_FIELDS(ctrl_regs->trg_control, .trigger = 1);
}

void hw_read_trigger_status(struct trigger_status *result)
{
    struct ctrl_trg_status status = READL(ctrl_regs->trg_status);
    result->sync_busy = status.sync_busy;
    result->seq0_armed = status.seq0_armed;
    result->seq1_armed = status.seq1_armed;
    result->dram_armed = status.dram0_armed;
}

void hw_read_trigger_sources(
    enum trigger_target target,
    bool sources[TRIGGER_SOURCE_COUNT])
{
    struct ctrl_trg_sources trg_sources = ctrl_regs->trg_sources;
    uint32_t source_mask = 0;
    switch (target)
    {
        case TRIGGER_SEQ0:
            source_mask = trg_sources.seq0;
            break;
        case TRIGGER_SEQ1:
            source_mask = trg_sources.seq1;
            break;
        case TRIGGER_DRAM:
            source_mask = trg_sources.dram0;
            break;
    }
    bits_to_bools(TRIGGER_SOURCE_COUNT, source_mask, sources);
}

void hw_write_trigger_blanking_duration(int channel, unsigned int duration)
{
    LOCK(ctrl_lock);
    switch (channel)
    {
        case 0:
            ctrl_mirror.trg_config_blanking.dsp0 = duration & 0xFFFF;
            break;
        case 1:
            ctrl_mirror.trg_config_blanking.dsp1 = duration & 0xFFFF;
            break;
    }
    WRITEL(ctrl_regs->trg_config_blanking, ctrl_mirror.trg_config_blanking);
    UNLOCK(ctrl_lock);
}

void hw_write_trigger_delay(
    enum trigger_target target, unsigned int delay)
{
    switch (target)
    {
        case TRIGGER_SEQ0:
            WRITE_FIELDS(
                ctrl_regs->trg_config_seq0, .delay = delay & 0xFFFF);
            break;
        case TRIGGER_SEQ1:
            WRITE_FIELDS(
                ctrl_regs->trg_config_seq1, .delay = delay & 0xFFFF);
            break;
        case TRIGGER_DRAM:
            WRITE_FIELDS(
                ctrl_regs->trg_config_dram0, .delay = delay & 0xFFFF);
            break;
    }
}

void hw_write_trigger_enable_mask(
    enum trigger_target target,
    const bool sources[TRIGGER_SOURCE_COUNT])
{
    uint32_t source_mask = bools_to_bits(TRIGGER_SOURCE_COUNT, sources);
    LOCK(ctrl_lock);
    switch (target)
    {
        case TRIGGER_SEQ0:
            ctrl_mirror.trg_config_trig_seq.enable0 = source_mask & 0x7F;
            WRITEL(ctrl_regs->trg_config_trig_seq,
                ctrl_mirror.trg_config_trig_seq);
            break;
        case TRIGGER_SEQ1:
            ctrl_mirror.trg_config_trig_seq.enable1 = source_mask & 0x7F;
            WRITEL(ctrl_regs->trg_config_trig_seq,
                ctrl_mirror.trg_config_trig_seq);
            break;
        case TRIGGER_DRAM:
            ctrl_mirror.trg_config_trig_dram.enable = source_mask & 0x7F;
            WRITEL(ctrl_regs->trg_config_trig_dram,
                ctrl_mirror.trg_config_trig_dram);
            break;
    }
    UNLOCK(ctrl_lock);
}

void hw_write_trigger_blanking_mask(
    enum trigger_target target,
    const bool sources[TRIGGER_SOURCE_COUNT])
{
    uint32_t source_mask = bools_to_bits(TRIGGER_SOURCE_COUNT, sources);
    LOCK(ctrl_lock);
    switch (target)
    {
        case TRIGGER_SEQ0:
            ctrl_mirror.trg_config_trig_seq.blanking0 = source_mask & 0x7F;
            WRITEL(ctrl_regs->trg_config_trig_seq,
                ctrl_mirror.trg_config_trig_seq);
            break;
        case TRIGGER_SEQ1:
            ctrl_mirror.trg_config_trig_seq.blanking1 = source_mask & 0x7F;
            WRITEL(ctrl_regs->trg_config_trig_seq,
                ctrl_mirror.trg_config_trig_seq);
            break;
        case TRIGGER_DRAM:
            ctrl_mirror.trg_config_trig_dram.blanking = source_mask & 0x7F;
            WRITEL(ctrl_regs->trg_config_trig_dram,
                ctrl_mirror.trg_config_trig_dram);
            break;
    }
    UNLOCK(ctrl_lock);
}

void hw_write_trigger_dram_blanking(const bool blanking[CHANNEL_COUNT])
{
    uint32_t blanking_mask = bools_to_bits(CHANNEL_COUNT, blanking);
    LOCK(ctrl_lock);
    ctrl_mirror.trg_config_trig_dram.blanking_sel = blanking_mask & 0x3;
    WRITEL(ctrl_regs->trg_config_trig_dram, ctrl_mirror.trg_config_trig_dram);
    UNLOCK(ctrl_lock);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* DSP registers. */

static volatile struct dsp *dsp_regs[2];
static pthread_mutex_t dsp_locks[2] = {
    PTHREAD_MUTEX_INITIALIZER, PTHREAD_MUTEX_INITIALIZER, };
static struct dsp dsp_mirror[2];


/* Reads min/max/sum: shared between ADC and DAC, which have identical
 * registers. */
static void read_mms(
    int channel, volatile struct mms *mms, struct mms_result *result)
{
    LOCK(dsp_locks[channel]);

    struct mms_count count = READL(mms->count);
    result->turns = count.turns + 1U;
    result->turns_ovfl = count.turns_ovfl;
    result->sum_ovfl = count.sum_ovfl;
    result->sum2_ovfl = count.sum2_ovfl;

    FOR_BUNCHES(i)
    {
        struct mms_readout_min_max min_max = READL(mms->readout.min_max);
        result->minimum[i] = (int16_t) min_max.min;
        result->maximum[i] = (int16_t) min_max.max;

        result->sum[i] = (int32_t) readl(&mms->readout.sum);

        uint32_t sum2_low = readl(&mms->readout.sum2_low);
        uint32_t sum2_high = READL(mms->readout.sum2_high).sum2;
        result->sum2[i] = sum2_low | (uint64_t) sum2_high << 32;
    }

    UNLOCK(dsp_locks[channel]);
}


void hw_write_nco0_frequency(int channel, unsigned int frequency)
{
    writel(&dsp_regs[channel]->nco0_freq, frequency);
}


/* ADC registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


void hw_write_adc_overflow_threshold(int channel, unsigned int threshold)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, adc_config, threshold, threshold & 0x3FFF);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_adc_delta_threshold(int channel, unsigned int delta)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, adc_config, delta, delta & 0xFFFF);
    UNLOCK(dsp_locks[channel]);
}

void hw_read_adc_events(int channel, struct adc_events *result)
{
    struct dsp_adc_events events = READL(dsp_regs[channel]->adc_events);
    result->input_ovf = events.inp_ovf;
    result->fir_ovf = events.fir_ovf;
    result->delta_event = events.delta;
}

void hw_write_adc_taps(int channel, const int taps[])
{
    LOCK(dsp_locks[channel]);
    WRITE_FIELDS(dsp_regs[channel]->adc_command, .write = 1);
    for (unsigned int i = 0; i < hardware_config.adc_taps; i ++)
        writel(&dsp_regs[channel]->adc_taps, (uint32_t) taps[i]);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_adc_mms_source(int channel, bool after_fir)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, adc_config, mms_source, after_fir);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_adc_dram_source(int channel, bool after_fir)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, adc_config, dram_source, after_fir);
    UNLOCK(dsp_locks[channel]);
}

void hw_read_adc_mms(int channel, struct mms_result *result)
{
    read_mms(channel, &dsp_regs[channel]->adc_mms, result);
    /* Re-arm delta event after mms readout. */
    WRITE_FIELDS(dsp_regs[channel]->adc_command, .reset_delta = 1);
}


/* Bunch registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


void hw_write_bunch_config(
    int channel, unsigned int bank, const struct bunch_config *config)
{
    LOCK(dsp_locks[channel]);
    WRITE_FIELDS(dsp_regs[channel]->bunch_config, .bank = bank & 0x3);
    FOR_BUNCHES(i)
    {
        int gain = config->gain[i] >> (32 - 13);
        WRITE_FIELDS(dsp_regs[channel]->bunch_bank,
            .fir_select = (unsigned int) config->fir_select[i] & 0x3,
            .gain = (unsigned int) gain & 0x1FFF,
            .fir_enable = config->fir_enable[i],
            .nco0_enable = config->nco0_enable[i],
            .nco1_enable = config->nco1_enable[i]);
    }
    UNLOCK(dsp_locks[channel]);
}

void hw_write_bunch_decimation(int channel, unsigned int decimation)
{
    /* Compute the required shift corresponding to the given decimation.  We
     * need  2^shift >= decimation, ie shift >= log2(decimation), and we use CLZ
     * as a short cut computation of log2. */
    COMPILE_ASSERT(sizeof(decimation) == 4);    // Need 32-bit integers here
    unsigned int decimation_shift =
        decimation == 1 ? 0 : 32 - (unsigned int) __builtin_clz(decimation - 1);

    LOCK(dsp_locks[channel]);
    dsp_mirror[channel].fir_config.limit = (decimation - 1) & 0x3F;
    dsp_mirror[channel].fir_config.shift = decimation_shift & 0x7;
    WRITEL(dsp_regs[channel]->fir_config, dsp_mirror[channel].fir_config);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_bunch_fir_taps(int channel, unsigned int fir, const int taps[])
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, fir_config, bank, fir & 0x3);
    for (unsigned int i = 0; i < hardware_config.bunch_taps; i ++)
        writel(&dsp_regs[channel]->fir_taps, (uint32_t) taps[i]);
    UNLOCK(dsp_locks[channel]);
}


/* DAC registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


void hw_write_dac_delay(int channel, unsigned int delay)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, dac_config, delay, delay & 0x3FF);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_dac_fir_gain(int channel, unsigned int gain)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, dac_config, fir_gain, gain & 0xF);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_dac_nco0_gain(int channel, unsigned int gain)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, dac_config, nco0_gain, gain & 0xF);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_dac_nco0_enable(int channel, bool enable)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, dac_config, nco0_enable, enable);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_dac_mms_source(int channel, bool after_fir)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, dac_config, mms_source, after_fir);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_dac_dram_source(int channel, bool after_fir)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, dac_config, dram_source, after_fir);
    UNLOCK(dsp_locks[channel]);
}


void hw_read_dac_events(int channel, struct dac_events *result)
{
    struct dsp_dac_events events = READL(dsp_regs[channel]->dac_events);
    result->fir_ovf = events.fir_ovf;
    result->mux_ovf = events.mux_ovf;
    result->out_ovf = events.out_ovf;
}

void hw_write_dac_taps(int channel, const int taps[])
{
    LOCK(dsp_locks[channel]);
    WRITE_FIELDS(dsp_regs[channel]->dac_command, .write = 1);
    for (unsigned int i = 0; i < hardware_config.dac_taps; i ++)
        writel(&dsp_regs[channel]->dac_taps, (uint32_t) taps[i]);
    UNLOCK(dsp_locks[channel]);
}

void hw_read_dac_mms(int channel, struct mms_result *result)
{
    read_mms(channel, &dsp_regs[channel]->dac_mms, result);
}


/* Sequencer registers - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Writes a single sequencer state as a sequence of 8 writes. */
static void write_sequencer_state(int channel, const struct seq_entry *entry)
{
    volatile union dsp_seq_state *target = &dsp_regs[channel]->seq_state;

    writel(&target->start_freq, entry->start_freq);
    writel(&target->delta_freq, entry->delta_freq);
    WRITE_FIELDS(target->time,
        .dwell = (entry->dwell_time - 1) & 0xFFFF,
        .capture = (entry->capture_count - 1) & 0xFFFF);
    WRITE_FIELDS(target->config,
        .bank = entry->bunch_bank & 0x3,
        .nco_gain = entry->nco_gain & 0xF,
        .ena_window = entry->enable_window,
        .ena_write = entry->write_enable,
        .ena_blank = entry->enable_blanking,
        .ena_nco = entry->nco_enable);
    writel(&target->window_rate, entry->window_rate);
    WRITE_FIELDS(target->holdoff,
        .holdoff = entry->holdoff & 0xFFFF);
    writel(&target->padding, 0);
    writel(&target->padding, 0);
}

/* Writes the complete sequencer memory. */
static void write_sequencer_entries(
    int channel, unsigned int bank0,
    const struct seq_entry entries[MAX_SEQUENCER_COUNT])
{
    WRITE_FIELDS(dsp_regs[channel]->seq_command, .write = 1);
    WRITE_DSP_MIRROR(channel, seq_config, target, 0);
    write_sequencer_state(channel, &(struct seq_entry) {
        .dwell_time = 1,
        .bunch_bank = bank0,
        .capture_count = 1,
    });
    if (entries)
        for (unsigned int i = 0; i < MAX_SEQUENCER_COUNT; i ++)
            write_sequencer_state(channel, &entries[i]);
}

/* Writes the sequencer detector window. */
static void write_sequencer_window(int channel, const int window[])
{
    WRITE_FIELDS(dsp_regs[channel]->seq_command, .write = 1);
    WRITE_DSP_MIRROR(channel, seq_config, target, 1);
    for (unsigned int i = 0; i < DET_WINDOW_LENGTH; i ++)
        writel(&dsp_regs[channel]->seq_det_window, (uint32_t) window[i]);
}

/* Writes the super sequencer entries. */
static void write_sequencer_super_entries(
    int channel, unsigned int super_count, const uint32_t offsets[])
{
    WRITE_FIELDS(dsp_regs[channel]->seq_command, .write = 1);
    dsp_mirror[channel].seq_config.target = 2;
    dsp_mirror[channel].seq_config.super_count = (super_count - 1) & 0x3FF;
    WRITEL(dsp_regs[channel]->seq_config, dsp_mirror[channel].seq_config);

    /* When writing the offsets memory we have to write in reverse order to
     * match the fact that states will be read from count down to 0, and we
     * only need to write the states that will actually be used. */
    for (unsigned int i = 0; i < super_count; i ++)
        writel(&dsp_regs[channel]->seq_super_state,
            offsets[super_count - 1 - i]);
}


void hw_write_seq_config(int channel, const struct seq_config *config)
{
    LOCK(dsp_locks[channel]);
    write_sequencer_entries(channel, config->bank0, config->entries);
    write_sequencer_window(channel, config->window);
    write_sequencer_super_entries(
        channel, config->super_seq_count, config->super_offsets);
    WRITE_DSP_MIRROR(channel, seq_config, pc, config->sequencer_pc & 0x7);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_seq_bank0(int channel, unsigned int bank0)
{
    LOCK(dsp_locks[channel]);
    write_sequencer_entries(channel, bank0, NULL);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_seq_trigger_state(int channel, unsigned int state)
{
    LOCK(dsp_locks[channel]);
    WRITE_DSP_MIRROR(channel, seq_config, trigger, state & 0x7);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_seq_abort(int channel)
{
    WRITE_FIELDS(dsp_regs[channel]->seq_command, .abort = 1);
}

void hw_read_seq_state(int channel, struct seq_state *state)
{
    struct dsp_seq_status status = READL(dsp_regs[channel]->seq_status);
    state->busy = status.busy;
    state->pc = status.pc;
    state->super_pc = status.super;
}


/* Detector registers - - - - - - - - - - - - - - - - - - - - - - - - - - - */


static void write_det_bunch_enable(
    int channel, struct dsp_det_config det_config,
    int det, unsigned int delay, const bool enables[])
{
    /* Select the requested bank. */
    det_config.bank = (unsigned int) det & 0x3;
    WRITEL(dsp_regs[channel]->det_config, det_config);

    /* Also reset the bunch write pointer. */
    WRITE_FIELDS(dsp_regs[channel]->det_command, .write = 1);

    /* Convert array of bits into an array of 32-bit words. */
    uint32_t enable_mask = 0;
    FOR_BUNCHES_OFFSET(i, j, delay)
    {
        enable_mask |= (uint32_t) enables[j] << (i & 0x1F);
        if ((i & 0x1F) == 0x1F)
        {
            writel(&dsp_regs[channel]->det_bunch, enable_mask);
            enable_mask = 0;
        }
    }
    if (hardware_config.bunches & 0x1F)
        writel(&dsp_regs[channel]->det_bunch, enable_mask);
}

void hw_write_det_config(
    int channel, bool input_select, unsigned int delay,
    const struct detector_config config[DETECTOR_COUNT])
{
    struct dsp_det_config det_config = {
        .select  = input_select,
        .scale0  = config[0].scaling & 0x1,
        .enable0 = config[0].enable,
        .scale1  = config[1].scaling & 0x1,
        .enable1 = config[1].enable,
        .scale2  = config[2].scaling & 0x1,
        .enable2 = config[2].enable,
        .scale3  = config[3].scaling & 0x1,
        .enable3 = config[3].enable,
    };

    LOCK(dsp_locks[channel]);
    for (int i = 0; i < DETECTOR_COUNT; i ++)
        write_det_bunch_enable(
            channel, det_config, i, delay, config[i].bunch_enables);
    UNLOCK(dsp_locks[channel]);
}

void hw_write_det_start(int channel)
{
    WRITE_FIELDS(dsp_regs[channel]->det_command, .reset = 1);
}

void hw_read_det_events(int channel,
    bool output_ovf[DETECTOR_COUNT], bool *underrun)
{
    struct dsp_det_events events = READL(dsp_regs[channel]->det_events);
    bits_to_bools(DETECTOR_COUNT, events.output_ovfl, output_ovf);
    /* For underrun don't pick out the individual channels, just report any
     * underrun event.  This will mean major trouble. */
    *underrun = events.underrun;
}


void hw_read_det_memory(
    int channel, unsigned int result_count, unsigned int offset,
    struct detector_result result[])
{
    LOCK(dram1_mutex);
    error__t error = read_dma_memory(
        dram1_device, (unsigned int) channel * (DRAM1_LENGTH / 2) + offset,
        result_count * sizeof(struct detector_result), result);
    UNLOCK(dram1_mutex);
    ERROR_REPORT(error, "Error reading from DRAM1");
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation */


/* The bases for the individual address spaces are hard-wired into the address
 * decoding in the firmware.  The address space is 16 bits, and the top three
 * bits are decoded as follows:
 *
 *   15 14 13
 *  +--+--+--+
 *    0  x  x       System registers        SYS
 *    1  0  0       Control registers       CTRL
 *    1  0  1       (unused)
 *    1  1  0       DSP0 registers          DSP0
 *    1  1  1       DSP1 registers          DSP1
 */
#define SYS_ADDRESS_BASE        0x0000
#define CTRL_ADDRESS_BASE       0x8000
#define DSP0_ADDRESS_BASE       0xC000
#define DSP1_ADDRESS_BASE       0xE000


static int reg_device = -1;
static void *config_regs;
static size_t config_regs_size;


error__t hw_read_interrupt_events(struct interrupts *interrupts)
{
    return TEST_IO(read(reg_device, interrupts, sizeof(*interrupts)));
}


static error__t map_config_regs(void)
{
    sys_regs    = config_regs + SYS_ADDRESS_BASE;
    ctrl_regs   = config_regs + CTRL_ADDRESS_BASE;
    dsp_regs[0] = config_regs + DSP0_ADDRESS_BASE;
    dsp_regs[1] = config_regs + DSP1_ADDRESS_BASE;
    return ERROR_OK;
}


error__t hw_lock_registers(void)
{
    return TEST_IO_(ioctl(reg_device, LMBF_REG_LOCK),
        "Unable to lock LMBF registers");
}

error__t hw_unlock_registers(void)
{
    return TEST_IO_(ioctl(reg_device, LMBF_REG_UNLOCK),
        "Unable to unlock LMBF registers");
}


static error__t set_hardware_config(unsigned int bunches, bool lmbf_mode)
{
    hw_write_bunch_count(bunches);
    hw_write_lmbf_mode(lmbf_mode);

    /* Here we update the "constant" hardware configuration.  This is constant
     * everywhere except for this one place where we initialise it. */
    struct hardware_config *p_hardware_config =
        CAST_TO(struct hardware_config *, &hardware_config);

    struct sys_info sys_info = sys_regs->info;
    *p_hardware_config = (struct hardware_config)
    {
        .bunches = bunches,
        .adc_taps   = sys_info.adc_taps,
        .bunch_taps = sys_info.bunch_taps,
        .dac_taps   = sys_info.dac_taps,
    };

    return ERROR_OK;
}


error__t initialise_hardware(
    const char *device_address, unsigned int bunches,
    bool lock_registers, bool lmbf_mode)
{
    printf("initialise_hardware @%s %s\n",
        device_address, lock_registers ? "" : "unlocked");

    /* Compute device node names from the device_address. */
    const char *device_template = "/dev/amc525_lmbf/%s/amc525_lmbf.%s";
    char reg_device_name[PATH_MAX];
    char dram0_device_name[PATH_MAX];
    char dram1_device_name[PATH_MAX];
    sprintf(reg_device_name,   device_template, device_address, "reg");
    sprintf(dram0_device_name, device_template, device_address, "ddr0");
    sprintf(dram1_device_name, device_template, device_address, "ddr1");

    return
        TEST_IO_(reg_device = open(reg_device_name, O_RDWR | O_SYNC),
            "Unable to open LMBF device %s", reg_device_name)  ?:
        TEST_IO(dram0_device = open(dram0_device_name, O_RDONLY))  ?:
        TEST_IO(dram1_device = open(dram1_device_name, O_RDONLY))  ?:
        IF(lock_registers,
            hw_lock_registers())  ?:
        TEST_IO(
            config_regs_size = (size_t) ioctl(reg_device, LMBF_MAP_SIZE))  ?:
        TEST_IO(config_regs = mmap(
            0, config_regs_size, PROT_READ | PROT_WRITE, MAP_SHARED,
            reg_device, 0))  ?:
        map_config_regs()  ?:
        set_hardware_config(bunches, lmbf_mode);
}


void terminate_hardware(void)
{
    if (config_regs)
        munmap(config_regs, config_regs_size);
    if (reg_device != -1)
        close(reg_device);
    if (dram0_device != -1)
        close(dram0_device);
    if (dram1_device != -1)
        close(dram1_device);
}
