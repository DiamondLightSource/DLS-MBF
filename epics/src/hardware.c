/* Hardware interfacing to MBF system. */

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <fcntl.h>
#include <stdarg.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <pthread.h>

#include "error.h"

#include "amc525_mbf_device.h"
#include "register_defs.h"

#include "common.h"
#include "hardware.h"


/* Externally published hardware configuration, initialised during call to
 * initialise_hardware(), subsequently constant. */
const struct hardware_config hardware_config;


static int dram0_device = -1;
static int dram1_device = -1;
/* We share the dram devices between two axes under a single lock, as there is
 * absolutely no benefit in running two copies of this file handle -- there's
 * only one underlying DMA device anyway. */
static pthread_mutex_t dram_mutex = PTHREAD_MUTEX_INITIALIZER;


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


/* This is designed to be called thus:
 *      WRITE_DSP_MIRROR(axis, reg, .field = value)
 * Unfortunately any syntax errors will produce *very* confusing results! */
#define WRITE_DSP_MIRROR(axis, reg, field_value) \
    dsp_mirror[axis].reg field_value; \
    WRITEL(dsp_regs[axis]->reg, dsp_mirror[axis].reg)


/* Convert array of bits to an array of booleans. */
static void bits_to_bools(unsigned int count, uint32_t bits, bool bools[])
{
    for (unsigned int i = 0; i < count; i ++)
    {
        bools[i] = bits & 1;
        bits >>= 1;
    }
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
    error__t error;
    WITH_MUTEX(dram_mutex)
    {
        error = TEST_IO(lseek(device, seek_offset, SEEK_SET));
        while (!error  &&  read_request > 0)
        {
            ssize_t read_size;
            error =
                TEST_IO(read_size = read(device, result, read_request))  ?:
                TEST_OK_(read_size > 0, "Unexpected end of file");
            result += read_size;
            read_request -= (size_t) read_size;
        }
    }
    return error;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* System registers. */

static volatile struct sys *sys_regs;
static pthread_mutex_t sys_lock = PTHREAD_MUTEX_INITIALIZER;


void hw_read_fpga_version(struct fpga_version *version)
{
    struct sys_version sys_version = READL(sys_regs->version);
    struct sys_git_version git_version = READL(sys_regs->git_version);
    *version = (struct fpga_version) {
        .major = sys_version.major,
        .minor = sys_version.minor,
        .patch = sys_version.patch,
        .firmware = sys_version.firmware,
        .git_sha = git_version.sha,
        .git_dirty = git_version.dirty,
        .build_seed = READL(sys_regs->seed_value),
    };
}

void hw_read_system_status(struct system_status *result)
{
    struct sys_status status = READL(sys_regs->status);
    *result = (struct system_status) {
        .dsp_ok = status.dsp_ok,
        .vcxo_ok = status.vcxo_ok,
        .adc_ok = status.adc_ok,
        .dac_ok = status.dac_ok,
        .vcxo_locked = status.pll_ld1,
        .vco_locked = status.pll_ld2,
        .dac_irq = !status.dac_irqn,
        .temp_alert = status.temp_alert,
    };
}

void hw_write_turn_clock_idelay(unsigned int delay)
{
    WRITE_FIELDS(sys_regs->rev_idelay, .value = delay & 0x1F, .write = 1);
}

void hw_write_fmc500_spi(enum fmc500_spi spi, unsigned int reg, uint8_t value)
{
    WITH_MUTEX(sys_lock)
    {
        WRITE_FIELDS(sys_regs->fmc_spi,
            .address = reg & 0x7FFF, .select = spi, .rw_n = 0, .data = value);
        /* Need to read back to ensure write has completed.  Ought to fix this
         * in the firmware one of these days. */
        READL(sys_regs->fmc_spi);
    }
}

uint8_t hw_read_fmc500_spi(enum fmc500_spi spi, unsigned int reg)
{
    uint8_t result;
    WITH_MUTEX(sys_lock)
    {
        WRITE_FIELDS(sys_regs->fmc_spi,
            .address = reg & 0x7FFF, .select = spi, .rw_n = 1);
        result = READL(sys_regs->fmc_spi).data;
    }
    return result;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Shared Control registers. */

static volatile struct ctrl *ctrl_regs;
static pthread_mutex_t ctrl_lock = PTHREAD_MUTEX_INITIALIZER;
static struct ctrl ctrl_mirror;


void hw_write_lmbf_mode(bool lmbf_mode)
{
    WITH_MUTEX(ctrl_lock)
    {
        ctrl_mirror.control.adc_mux  = lmbf_mode;
        ctrl_mirror.control.nco0_mux = lmbf_mode;
        ctrl_mirror.control.nco1_mux = lmbf_mode;
        ctrl_mirror.control.nco2_mux = lmbf_mode;
        ctrl_mirror.control.nco3_mux = lmbf_mode;
        ctrl_mirror.control.bank_mux = lmbf_mode;
        WRITEL(ctrl_regs->control, ctrl_mirror.control);
    }
}

void hw_write_loopback_enable(int axis, bool loopback)
{
    WITH_MUTEX(ctrl_lock)
    {
        uint32_t loopbacks = write_selected_bit(
            ctrl_mirror.control.loopback, (unsigned) axis, loopback);
        ctrl_mirror.control.loopback = loopbacks & 0x3;
        WRITEL(ctrl_regs->control, ctrl_mirror.control);
    }
}

void hw_write_output_enable(int axis, bool enable)
{
    WITH_MUTEX(ctrl_lock)
    {
        uint32_t enables = write_selected_bit(
            ctrl_mirror.control.output, (unsigned) axis, enable);
        ctrl_mirror.control.output = enables & 0x3;
        WRITEL(ctrl_regs->control, ctrl_mirror.control);
    }
}


/* DRAM capture registers - - - - - - - - - - - - - - - - - - - - - - - - - */

void hw_write_dram_mux(uint16_t mux)
{
    WITH_MUTEX(ctrl_lock)
    {
        ctrl_mirror.mem_config.mux_select = mux & 0xFU;
        WRITEL(ctrl_regs->mem_config, ctrl_mirror.mem_config);
    }
}

void hw_write_dram_runout(unsigned int count)
{
    WRITE_FIELDS(ctrl_regs->mem_count, .count = count & 0xFFFFFFF);
}

unsigned int hw_read_dram_address(void)
{
    return READL(ctrl_regs->mem_address);
}

void hw_write_dram_capture_command(bool start, bool stop)
{
    WRITE_FIELDS(ctrl_regs->mem_command,
        .start = start,
        .stop = stop);
}

bool hw_read_dram_active(void)
{
    return READL(ctrl_regs->mem_status).enable;
}

void hw_read_dram_memory(size_t offset, size_t samples, uint32_t result[])
{
    error__t error = read_dma_memory(
        dram0_device, offset & (DRAM0_LENGTH - 1),
        samples * sizeof(uint32_t), result);
    ERROR_REPORT(error, "Error reading from DRAM0");
}


/* Trigger registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

static uint32_t trigger_sources_to_triggers_in(
    const struct trigger_sources *sources)
{
    struct triggers_in result = (struct triggers_in) {
        .soft = sources->soft,
        .ext = sources->ext,
        .pm = sources->pm,
        .adc0 = sources->adc0,
        .adc1 = sources->adc1,
        .dac0 = sources->dac0,
        .dac1 = sources->dac1,
        .seq0 = sources->seq0,
        .seq1 = sources->seq1,
    };
    return CAST_TO(uint32_t, result);
}

static void triggers_in_to_trigger_sources(
    uint32_t triggers, struct trigger_sources *sources)
{
    struct triggers_in triggers_in = CAST_TO(struct triggers_in, triggers);
    *sources = (struct trigger_sources) {
        .soft = triggers_in.soft,
        .ext = triggers_in.ext,
        .pm = triggers_in.pm,
        .adc0 = triggers_in.adc0,
        .adc1 = triggers_in.adc1,
        .dac0 = triggers_in.dac0,
        .dac1 = triggers_in.dac1,
        .seq0 = triggers_in.seq0,
        .seq1 = triggers_in.seq1,
    };
}


static void hw_write_bunch_count(unsigned int bunches)
{
    WITH_MUTEX(ctrl_lock)
    {
        ctrl_mirror.trg_config_turn.max_bunch = (bunches - 1) & 0x7FF;
        WRITEL(ctrl_regs->trg_config_turn, ctrl_mirror.trg_config_turn);
    }
}

void hw_write_turn_clock_sync(void)
{
    WRITE_FIELDS(ctrl_regs->trg_control, .sync_turn = 1);
}

void hw_read_turn_clock_counts(
    unsigned int *turn_count, unsigned int *error_count)
{
    WRITE_FIELDS(ctrl_regs->trg_control, .read_sync = 1);
    *turn_count  = READL(ctrl_regs->trg_turn_count).count;
    *error_count = READL(ctrl_regs->trg_error_count).count;
}

void hw_write_turn_clock_offset(unsigned int offset)
{
    /* Note!  If offset >= bunches_per_turn then turn clocks will stop being
     * generated.  Unfortunately this will then cause reading mms.count to hang
     * which will then freeze the system.  So don't. */
    ASSERT_OK(offset < hardware_config.bunches);
    WITH_MUTEX(ctrl_lock)
    {
        ctrl_mirror.trg_config_turn.turn_offset = offset & 0x7FF;
        WRITEL(ctrl_regs->trg_config_turn, ctrl_mirror.trg_config_turn);
    }
}

void hw_read_trigger_events(struct trigger_sources *sources, bool *blanking)
{
    struct ctrl_trg_pulsed events = READL(ctrl_regs->trg_pulsed);
    triggers_in_to_trigger_sources(events.triggers, sources);
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
    *result = (struct trigger_status) {
        .sync_busy = status.sync_busy,
        .seq0_armed = status.seq0_armed,
        .seq1_armed = status.seq1_armed,
        .dram_armed = status.dram0_armed,
    };
}

void hw_read_trigger_sources(
    enum trigger_target_id target, struct trigger_sources *sources)
{
    struct ctrl_trg_sources trg_sources = READL(ctrl_regs->trg_sources);
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
    triggers_in_to_trigger_sources(source_mask, sources);
}

void hw_write_trigger_blanking_duration(unsigned int duration)
{
    WRITE_FIELDS(ctrl_regs->trg_config_blanking, .turns = duration & 0xFFFF);
}

void hw_write_trigger_delay(
    enum trigger_target_id target, unsigned int delay)
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
    enum trigger_target_id target, const struct trigger_sources *sources)
{
    uint32_t source_mask = trigger_sources_to_triggers_in(sources);
    WITH_MUTEX(ctrl_lock)
    {
        switch (target)
        {
            case TRIGGER_SEQ0:
                ctrl_mirror.trg_config_trig_seq0.enable = source_mask & 0x1FF;
                WRITEL(ctrl_regs->trg_config_trig_seq0,
                    ctrl_mirror.trg_config_trig_seq0);
                break;
            case TRIGGER_SEQ1:
                ctrl_mirror.trg_config_trig_seq1.enable = source_mask & 0x1FF;
                WRITEL(ctrl_regs->trg_config_trig_seq1,
                    ctrl_mirror.trg_config_trig_seq1);
                break;
            case TRIGGER_DRAM:
                ctrl_mirror.trg_config_trig_dram.enable = source_mask & 0x1FF;
                WRITEL(ctrl_regs->trg_config_trig_dram,
                    ctrl_mirror.trg_config_trig_dram);
                break;
        }
    }
}

void hw_write_trigger_blanking_mask(
    enum trigger_target_id target, const struct trigger_sources *sources)
{
    uint32_t source_mask = trigger_sources_to_triggers_in(sources);
    WITH_MUTEX(ctrl_lock)
    {
        switch (target)
        {
            case TRIGGER_SEQ0:
                ctrl_mirror.trg_config_trig_seq0.blanking = source_mask & 0x1FF;
                WRITEL(ctrl_regs->trg_config_trig_seq0,
                    ctrl_mirror.trg_config_trig_seq0);
                break;
            case TRIGGER_SEQ1:
                ctrl_mirror.trg_config_trig_seq1.blanking = source_mask & 0x1FF;
                WRITEL(ctrl_regs->trg_config_trig_seq1,
                    ctrl_mirror.trg_config_trig_seq1);
                break;
            case TRIGGER_DRAM:
                ctrl_mirror.trg_config_trig_dram.blanking = source_mask & 0x1FF;
                WRITEL(ctrl_regs->trg_config_trig_dram,
                    ctrl_mirror.trg_config_trig_dram);
                break;
        }
    }
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* DSP registers. */

static volatile struct dsp *dsp_regs[AXIS_COUNT];
static pthread_mutex_t dsp_locks[AXIS_COUNT] = {
    PTHREAD_MUTEX_INITIALIZER, PTHREAD_MUTEX_INITIALIZER, };
static struct dsp dsp_mirror[AXIS_COUNT];


/* Reads min/max/sum: shared between ADC and DAC, which have identical
 * registers. */
static void read_mms(
    int axis, volatile struct mms *mms, struct mms_result *result)
{
    WITH_MUTEX(dsp_locks[axis])
    {
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

            result->sum[i] = (int32_t) READL(mms->readout.sum);

            uint32_t sum2_low = READL(mms->readout.sum2_low);
            uint32_t sum2_high = READL(mms->readout.sum2_high).sum2;
            result->sum2[i] = sum2_low | (uint64_t) sum2_high << 32;
        }
    }
}


/* Fixed NCO configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

void hw_write_nco_frequency(int axis, enum fixed_nco nco, uint64_t frequency)
{
    volatile struct nco_freq *nco_freq = NULL;
    switch (nco)
    {
        case FIXED_NCO1:
            nco_freq = &dsp_regs[axis]->fixed_nco_nco1_freq;
            break;
        case FIXED_NCO2:
            nco_freq = &dsp_regs[axis]->fixed_nco_nco2_freq;
            break;
    }
    WRITEL(nco_freq->low, frequency & 0xFFFFFFFF);
    WRITE_FIELDS(nco_freq->high,
        .bits = (frequency >> 32) & 0xFFFF,
        .reset_phase = frequency == 0);
}


void hw_write_nco_gain(int axis, enum fixed_nco nco, unsigned int gain)
{
    WITH_MUTEX(dsp_locks[axis])
        switch (nco)
        {
            case FIXED_NCO1:
                WRITE_DSP_MIRROR(axis, fixed_nco_nco1, .gain = gain & 0x3FFFF);
                break;
            case FIXED_NCO2:
                WRITE_DSP_MIRROR(axis, fixed_nco_nco2, .gain = gain & 0x3FFFF);
                break;
        }
}


void hw_write_nco_track_pll(int axis, enum fixed_nco nco, bool enable)
{
    WITH_MUTEX(dsp_locks[axis])
        switch (nco)
        {
            case FIXED_NCO1:
                WRITE_DSP_MIRROR(axis, fixed_nco_nco1, .ena_tune_pll = enable);
                break;
            case FIXED_NCO2:
                WRITE_DSP_MIRROR(axis, fixed_nco_nco2, .ena_tune_pll = enable);
                break;
        }
}


/* ADC registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


void hw_write_adc_overflow_threshold(int axis, unsigned int threshold)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(
            axis, adc_limits, .threshold = threshold & 0x3FFF);
}

void hw_write_adc_delta_threshold(int axis, unsigned int delta)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, adc_limits, .delta = delta & 0xFFFF);
}

void hw_write_adc_reject_shift(int axis, uint16_t shift)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, adc_config, .reject_shift = shift & 0xFU);
}

void hw_read_adc_events(int axis, struct adc_events *result)
{
    struct dsp_adc_events events = READL(dsp_regs[axis]->adc_events);
    *result = (struct adc_events) {
        .input_ovf = events.inp_ovf,
        .fir_ovf = events.fir_ovf,
        .delta_event = events.delta,
    };
}

void hw_write_adc_taps(int axis, const int taps[])
{
    WITH_MUTEX(dsp_locks[axis])
    {
        WRITE_FIELDS(dsp_regs[axis]->adc_command, .write = 1);
        for (unsigned int i = 0; i < hardware_config.adc_taps; i ++)
            WRITEL(dsp_regs[axis]->adc_taps, (uint32_t) taps[i]);
    }
}

void hw_write_adc_mms_source(int axis, uint16_t source)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, adc_config, .mms_source = source & 0x3U);
}

void hw_write_adc_dram_source(int axis, uint16_t source)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, adc_config, .dram_source = source & 0x3U);
}

void hw_read_adc_mms(int axis, struct mms_result *result)
{
    read_mms(axis, &dsp_regs[axis]->adc_mms, result);
    /* Re-arm delta event after mms readout. */
    WRITE_FIELDS(dsp_regs[axis]->adc_command, .reset_delta = 1);
}


/* Bunch registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


void hw_write_bunch_config(
    int axis, uint16_t bank, const struct bunch_config *config)
{
    WITH_MUTEX(dsp_locks[axis])
    {
        WRITE_FIELDS(dsp_regs[axis]->bunch_config, .bank = bank & 0x3U);
        FOR_BUNCHES(i)
        {
            WRITE_FIELDS(dsp_regs[axis]->bunch_bank.nco01,
                .nco0_high = ((uint32_t) config->nco0_gains[i] >> 2) & 0xFFFF,
                .nco1_high = ((uint32_t) config->nco1_gains[i] >> 2) & 0xFFFF);
            WRITE_FIELDS(dsp_regs[axis]->bunch_bank.nco23,
                .nco2_high = ((uint32_t) config->nco2_gains[i] >> 2) & 0xFFFF,
                .nco3_high = ((uint32_t) config->nco3_gains[i] >> 2) & 0xFFFF);
            WRITE_FIELDS(dsp_regs[axis]->bunch_bank.extra,
                .fir_select = (uint32_t) config->fir_select[i] & 0x3,
                .fir_gain = (uint32_t) config->fir_gains[i] & 0x3FFFF,
                .fir_enable = config->fir_enable[i],
                .nco0_low = (uint32_t) config->nco0_gains[i] & 0x3,
                .nco1_low = (uint32_t) config->nco1_gains[i] & 0x3,
                .nco2_low = (uint32_t) config->nco2_gains[i] & 0x3,
                .nco3_low = (uint32_t) config->nco3_gains[i] & 0x3);
        }
    }
}

void hw_write_bunch_decimation(int axis, unsigned int decimation)
{
    /* Compute the required shift corresponding to the given decimation.  We
     * need  2^shift >= decimation, ie shift >= log2(decimation), and we use CLZ
     * as a short cut computation of log2. */
    COMPILE_ASSERT(sizeof(decimation) == 4);    // Need 32-bit integers here
    unsigned int decimation_shift =
        decimation == 1 ? 0 : 32 - (unsigned int) __builtin_clz(decimation - 1);

    WITH_MUTEX(dsp_locks[axis])
    {
        dsp_mirror[axis].fir_config.limit = (decimation - 1) & 0x3F;
        dsp_mirror[axis].fir_config.shift = decimation_shift & 0x7;
        WRITEL(dsp_regs[axis]->fir_config, dsp_mirror[axis].fir_config);
    }
}

void hw_write_bunch_fir_taps(int axis, uint16_t fir, const int taps[])
{
    WITH_MUTEX(dsp_locks[axis])
    {
        WRITE_DSP_MIRROR(axis, fir_config, .bank = fir & 0x3U);
        for (unsigned int i = 0; i < hardware_config.bunch_taps; i ++)
            WRITEL(dsp_regs[axis]->fir_taps, (uint32_t) taps[i]);
    }
}

bool hw_read_bunch_overflow(int axis)
{
    return READL(dsp_regs[axis]->fir_events).overflow;
}


/* DAC registers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */


void hw_write_dac_delta_threshold(int axis, unsigned int delta)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, dac_limits, .delta = delta & 0xFFFF);
}


void hw_write_dac_delay(int axis, unsigned int delay)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, dac_config, .delay = delay & 0x7FF);
}

void hw_write_dac_fir_gain(int axis, uint16_t gain)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, dac_config, .fir_gain = gain & 0xFU);
}

void hw_write_dac_mms_source(int axis, enum dac_mms_source source)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, dac_config, .mms_source = source & 0x3);
}

void hw_write_dac_dram_source(int axis, bool after_fir)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, dac_config, .dram_source = after_fir);
}


void hw_read_dac_events(int axis, struct dac_events *result)
{
    struct dsp_dac_events events = READL(dsp_regs[axis]->dac_events);
    *result = (struct dac_events) {
        .fir_ovf = events.fir_ovf,
        .mms_ovf = events.mms_ovf,
        .mux_ovf = events.mux_ovf,
        .out_ovf = events.out_ovf,
        .delta_event = events.delta,
    };
}

void hw_write_dac_taps(int axis, const int taps[])
{
    WITH_MUTEX(dsp_locks[axis])
    {
        WRITE_FIELDS(dsp_regs[axis]->dac_command, .write = 1);
        for (unsigned int i = 0; i < hardware_config.dac_taps; i ++)
            WRITEL(dsp_regs[axis]->dac_taps, (uint32_t) taps[i]);
    }
}

void hw_read_dac_mms(int axis, struct mms_result *result)
{
    read_mms(axis, &dsp_regs[axis]->dac_mms, result);
    /* Re-arm delta event after mms readout. */
    WRITE_FIELDS(dsp_regs[axis]->dac_command, .reset_delta = 1);
}


/* Sequencer registers - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* Writes a single sequencer state as a sequence of 8 writes. */
static void write_sequencer_state(
    int axis, bool state0, const struct seq_entry *entry)
{
    volatile union dsp_seq_state *target = &dsp_regs[axis]->seq_state;

    WRITE_FIELDS(target->start_freq,
        .low_bits = entry->start_freq & 0xFFFFFFFF);
    WRITE_FIELDS(target->delta_freq,
        .low_bits = entry->delta_freq & 0xFFFFFFFF);
    WRITE_FIELDS(target->high_bits,
        .start_high = (entry->start_freq >> 32) & 0xFFFF,
        .delta_high = (entry->delta_freq >> 32) & 0xFFFF);
    WRITE_FIELDS(target->time,
        .dwell = (entry->dwell_time - 1) & 0xFFFF,
        .capture = (entry->capture_count - 1) & 0xFFFF);
    WRITE_FIELDS(target->config,
        .bank = entry->bunch_bank & 0x3U,
        .nco_gain = entry->nco_gain & 0x3FFFF,
        .ena_window = entry->enable_window,
        .ena_write = entry->write_enable,
        .ena_blank = entry->enable_blanking,
        .reset_phase = entry->reset_phase,
        .ena_tune_pll = entry->use_tune_pll,
        .dis_super = state0);
    WRITEL(target->window_rate, entry->window_rate);
    WRITE_FIELDS(target->holdoff,
        .holdoff = entry->holdoff & 0xFFFF,
        .state_holdoff = entry->state_holdoff & 0xFFFF);
    WRITEL(target->padding, 0);
}

/* Writes the complete sequencer memory. */
static void write_sequencer_entries(
    int axis, uint16_t bank0,
    const struct seq_entry entries[MAX_SEQUENCER_COUNT])
{
    WRITE_FIELDS(dsp_regs[axis]->seq_command, .write = 1);
    WRITE_DSP_MIRROR(axis, seq_config, .target = 0);
    write_sequencer_state(axis, true, &(struct seq_entry) {
        .dwell_time = 1,
        .bunch_bank = bank0,
        .capture_count = 1,
        .reset_phase = true,
    });
    if (entries)
        for (unsigned int i = 0; i < MAX_SEQUENCER_COUNT; i ++)
            write_sequencer_state(axis, false, &entries[i]);
}

/* Writes the sequencer detector window. */
static void write_sequencer_window(int axis, const int window[])
{
    WRITE_FIELDS(dsp_regs[axis]->seq_command, .write = 1);
    WRITE_DSP_MIRROR(axis, seq_config, .target = 1);
    for (unsigned int i = 0; i < DET_WINDOW_LENGTH; i ++)
        WRITEL(dsp_regs[axis]->seq_det_window, (uint32_t) window[i]);
}

/* Writes the super sequencer entries. */
static void write_sequencer_super_entries(
    int axis, unsigned int super_count, const uint64_t offsets[])
{
    WRITE_FIELDS(dsp_regs[axis]->seq_command, .write = 1);
    dsp_mirror[axis].seq_config.target = 2;
    dsp_mirror[axis].seq_config.super_count = (super_count - 1) & 0x7FF;
    WRITEL(dsp_regs[axis]->seq_config, dsp_mirror[axis].seq_config);

    /* When writing the offsets memory we have to write in reverse order to
     * match the fact that states will be read from count down to 0, and we
     * only need to write the states that will actually be used. */
    for (unsigned int i = 0; i < super_count; i ++)
    {
        uint64_t offset = offsets[super_count - 1 - i];
        /* Write offset in two steps, 32-bits then 16-bits. */
        WRITEL(dsp_regs[axis]->seq_super_state, (uint32_t) offset);
        WRITEL(dsp_regs[axis]->seq_super_state, (uint32_t) (offset >> 32));
    }
}


void hw_write_seq_config(int axis, const struct seq_config *config)
{
    WITH_MUTEX(dsp_locks[axis])
    {
        write_sequencer_entries(axis, config->bank0, config->entries);
        write_sequencer_window(axis, config->window);
        write_sequencer_super_entries(
            axis, config->super_seq_count, config->super_offsets);
        WRITE_DSP_MIRROR(axis, seq_config, .pc = config->sequencer_pc & 0x7);
    }
}

void hw_write_seq_bank0(int axis, uint16_t bank0)
{
    WITH_MUTEX(dsp_locks[axis])
        write_sequencer_entries(axis, bank0, NULL);
}

void hw_write_seq_trigger_state(int axis, unsigned int state)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, seq_config, .trigger = state & 0x7);
}

void hw_write_seq_abort(int axis)
{
    WRITE_FIELDS(dsp_regs[axis]->seq_command, .abort = 1);
}

void hw_read_seq_state(int axis, struct seq_state *state)
{
    struct dsp_seq_status status = READL(dsp_regs[axis]->seq_status);
    *state = (struct seq_state) {
        .busy = status.busy,
        .pc = status.pc,
        .super_pc = status.super,
    };
}


/* Detector registers - - - - - - - - - - - - - - - - - - - - - - - - - - - */


/* Helper for writing bunch enables with delay compensation to detector memory.
 * This is designed for both standard and tune PLL detector use. */
static void write_det_bunch_enable_array(
    volatile uint32_t *write_reg, unsigned int delay, const bool enables[])
{
    /* Convert array of bits into an array of 32-bit words. */
    uint32_t enable_mask = 0;
    FOR_BUNCHES_OFFSET(i, j, delay)
    {
        enable_mask |= (uint32_t) enables[j] << (i & 0x1F);
        if ((i & 0x1F) == 0x1F)
        {
            WRITEL(*write_reg, enable_mask);
            enable_mask = 0;
        }
    }
    if (hardware_config.bunches & 0x1F)
        WRITEL(*write_reg, enable_mask);
}


static void write_det_bunch_enable(
    int axis, struct dsp_det_config det_config,
    int det, unsigned int delay, const bool enables[])
{
    /* Select the requested bank and start write. */
    det_config.bank = (unsigned int) det & 0x3;
    WRITEL(dsp_regs[axis]->det_config, det_config);
    WRITE_FIELDS(dsp_regs[axis]->det_command, .write = 1);

    /* Write the enable bit array. */
    write_det_bunch_enable_array(&dsp_regs[axis]->det_bunch, delay, enables);
}

void hw_write_det_config(
    int axis, uint16_t input_select, unsigned int delay,
    const struct detector_config config[DETECTOR_COUNT])
{
    struct dsp_det_config det_config = {
        .select  = input_select & 0x3U,
        .scale0  = config[0].scaling & 0x1U,
        .enable0 = config[0].enable,
        .scale1  = config[1].scaling & 0x1U,
        .enable1 = config[1].enable,
        .scale2  = config[2].scaling & 0x1U,
        .enable2 = config[2].enable,
        .scale3  = config[3].scaling & 0x1U,
        .enable3 = config[3].enable,
    };

    WITH_MUTEX(dsp_locks[axis])
        for (int i = 0; i < DETECTOR_COUNT; i ++)
            write_det_bunch_enable(
                axis, det_config, i, delay, config[i].bunch_enables);
}

void hw_write_det_start(int axis)
{
    WRITE_FIELDS(dsp_regs[axis]->det_command, .reset = 1);
}

void hw_read_det_events(int axis,
    bool output_ovf[DETECTOR_COUNT], bool *underrun)
{
    struct dsp_det_events events = READL(dsp_regs[axis]->det_events);
    bits_to_bools(DETECTOR_COUNT, events.output_ovfl, output_ovf);
    /* For underrun don't pick out the individual axes, just report any
     * underrun event.  This will mean major trouble. */
    *underrun = events.underrun;
}


void hw_read_det_memory(
    int axis, unsigned int result_count, unsigned int offset,
    struct detector_result result[])
{
    error__t error = read_dma_memory(
        dram1_device, (unsigned int) axis * (DRAM1_LENGTH / 2) + offset,
        result_count * sizeof(struct detector_result), result);
    ERROR_REPORT(error, "Error reading from DRAM1");
}


/* Tune PLL configuration - - - - - - - - - - - - - - - - - - - - - - - - - */

void hw_write_pll_nco_frequency(int axis, uint64_t frequency)
{
    /* Must write low order bits before high order bits. */
    WRITEL(dsp_regs[axis]->tune_pll_control_nco_freq.low,
        frequency & 0xFFFFFFFF);
    WRITE_FIELDS(dsp_regs[axis]->tune_pll_control_nco_freq.high,
        .bits = (frequency >> 32) & 0xFFFF,
        .reset_phase = frequency == 0);
}


uint64_t hw_read_pll_nco_frequency(int axis)
{
    /* Must read high order bits first. */
    uint32_t high_bits = dsp_regs[axis]->tune_pll_control_nco_freq.high.bits;
    uint32_t low_bits  = dsp_regs[axis]->tune_pll_control_nco_freq.low;
    return ((uint64_t) high_bits << 32) | low_bits;
}


void hw_write_pll_nco_gain(int axis, unsigned int gain)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, tune_pll_control_config_extra,
            .nco_gain = gain & 0x3FFFF);
}


void hw_write_pll_dwell_time(int axis, unsigned int dwell)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, tune_pll_control_config,
            .dwell_time = (dwell - 1) & 0xFFF);
}


void hw_write_pll_blanking(int axis, bool blanking)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, tune_pll_control_config,
            .blanking = blanking);
}


void hw_write_pll_target_phase(int axis, int32_t phase)
{
    dsp_regs[axis]->tune_pll_control_target_phase = (uint32_t) phase;
}


void hw_write_pll_integral_factor(int axis, int32_t integral)
{
    dsp_regs[axis]->tune_pll_control_integral = (uint32_t) integral;
}


void hw_write_pll_proportional_factor(int axis, int32_t proportional)
{
    dsp_regs[axis]->tune_pll_control_proportional = (uint32_t) proportional;
}


void hw_write_pll_minimum_magnitude(int axis, uint32_t magnitude)
{
    dsp_regs[axis]->tune_pll_control_min_magnitude = magnitude;
}


void hw_write_pll_maximum_offset(int axis, uint32_t max_offset)
{
    dsp_regs[axis]->tune_pll_control_max_offset_error = max_offset;
}


void hw_write_pll_det_scaling(int axis, uint16_t scaling)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, tune_pll_control_config,
            .det_shift = scaling & 0x3U);
}


void hw_write_pll_det_config(
    int axis, uint16_t input_select,
    unsigned int offset, const bool bunch_enables[])
{
    WITH_MUTEX(dsp_locks[axis])
    {
        /* Configure input selection. */
        WRITE_DSP_MIRROR(axis, tune_pll_control_config,
            .select = input_select & 0x3U);

        /* Write the bunch enables array. */
        WRITE_FIELDS(dsp_regs[axis]->tune_pll_control_command,
            .write_bunch = 1);
        write_det_bunch_enable_array(
            &dsp_regs[axis]->tune_pll_control_bunch, offset, bunch_enables);
    }
}


void hw_write_pll_captured_cordic(int axis, bool cordic)
{
    WITH_MUTEX(dsp_locks[axis])
        WRITE_DSP_MIRROR(axis, tune_pll_control_config,
            .capture_cordic = cordic);
}


void hw_write_pll_start(bool axis0, bool axis1)
{
    WRITE_FIELDS(ctrl_regs->trg_control,
        .start_pll0 = axis0, .start_pll1 = axis1);
}


void hw_write_pll_stop(bool axis0, bool axis1)
{
    WRITE_FIELDS(ctrl_regs->trg_control,
        .stop_pll0 = axis0, .stop_pll1 = axis1);
}


void hw_read_pll_events(int axis, struct tune_pll_events *result)
{
    struct dsp_tune_pll_control_events events =
        READL(dsp_regs[axis]->tune_pll_control_events);
    *result = (struct tune_pll_events) {
        .det_overflow = events.det_ovfl,
        .magnitude_error = events.mag_error,
        .offset_error = events.offset_error,
    };
}


void hw_read_pll_status(int axis, struct tune_pll_status *result)
{
    struct dsp_tune_pll_control_status status =
        READL(dsp_regs[axis]->tune_pll_control_status);
    *result = (struct tune_pll_status) {
        .running = status.running,
        .stopped = status.stop_stop,
        .overflow = status.stop_overflow,
        .too_small = status.stop_magnitude,
        .bad_offset = status.stop_offset,
    };
}


struct detector_result hw_read_pll_filtered_detector(int axis)
{
    return (struct detector_result) {
        .i = (int32_t) dsp_regs[axis]->tune_pll_control_filtered_i,
        .q = (int32_t) dsp_regs[axis]->tune_pll_control_filtered_q,
    };
}

int32_t hw_read_pll_filtered_offset(int axis)
{
    return (int32_t) dsp_regs[axis]->tune_pll_control_filtered_offset;
}


unsigned int hw_read_pll_readout_fifo(
    int axis, enum pll_readout_fifo fifo,
    bool enable_interrupt, bool *reset, int32_t data[PLL_FIFO_SIZE])
{
    unsigned int samples;
    WITH_MUTEX(dsp_locks[axis])
    {
        struct dsp_tune_pll_readout_status status =
            READL(dsp_regs[axis]->tune_pll_readout_status);

        /* Set things up to read the selected FIFO. */
        volatile uint32_t *readout_reg;
        bool fifo_overrun;
        struct dsp_tune_pll_readout_command reset_command;
        struct dsp_tune_pll_readout_command enable_command;
        switch (fifo)
        {
            case PLL_FIFO_DEBUG:
                readout_reg = &dsp_regs[axis]->tune_pll_readout_debug_fifo;
                fifo_overrun = status.debug_overrun;
                samples = status.debug_count;
                reset_command = (struct dsp_tune_pll_readout_command) {
                    .reset_debug = 1 };
                enable_command = (struct dsp_tune_pll_readout_command) {
                    .enable_debug = 1 };
                break;
            case PLL_FIFO_OFFSET:
                readout_reg = &dsp_regs[axis]->tune_pll_readout_offset_fifo;
                fifo_overrun = status.offset_overrun;
                samples = status.offset_count;
                reset_command = (struct dsp_tune_pll_readout_command) {
                    .reset_offset = 1 };
                enable_command = (struct dsp_tune_pll_readout_command) {
                    .enable_offset = 1 };
                break;
            default:
                ASSERT_FAIL();
        }

        /* If this fails then the hardware is messing with us! */
        ASSERT_OK(samples <= PLL_FIFO_SIZE);

        /* Read all the data we're told there is. */
        for (unsigned int i = 0; i < samples; i ++)
            *data++ = (int32_t) readl(readout_reg);

        /* Configure FIFO for next read.  If an overrun was detected we need to
         * reset the FIFO, and enable interrupts if requested.  The reset needs
         * to be done before enabling interrupts. */
        *reset = fifo_overrun;
        if (fifo_overrun)
            WRITEL(dsp_regs[axis]->tune_pll_readout_command, reset_command);
        if (enable_interrupt)
            WRITEL(dsp_regs[axis]->tune_pll_readout_command, enable_command);
    }
    return samples;
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


static error__t check_firmware_version(bool no_hardware)
{
    if (no_hardware)
        return ERROR_OK;
    else
    {
        struct sys_version sys_version = READL(sys_regs->version);
        error__t error =
            TEST_OK_(sys_version.firmware == FIRMWARE_COMPAT_VERSION,
                "Firmware version mismatch: read %u, expected %u",
                sys_version.firmware, FIRMWARE_COMPAT_VERSION);
        if (FIRMWARE_COMPAT_VERSION == FIRMWARE_COMPAT_UNSTABLE)
            log_message("WARNING: Running with UNSTABLE firmware version");
        return error;
    }
}


error__t hw_lock_registers(void)
{
    return TEST_IO_(ioctl(reg_device, MBF_REG_LOCK),
        "Unable to lock MBF registers");
}

error__t hw_unlock_registers(void)
{
    return TEST_IO_(ioctl(reg_device, MBF_REG_UNLOCK),
        "Unable to unlock MBF registers");
}


static error__t set_hardware_config(
    unsigned int bunches, bool lmbf_mode, bool no_hardware)
{
    hw_write_bunch_count(bunches);
    hw_write_lmbf_mode(lmbf_mode);

    struct sys_info sys_info = sys_regs->info;
    if (no_hardware)
        sys_info = (struct sys_info) {
            .adc_taps = 20,
            .bunch_taps = 16,
            .dac_taps = 20,
        };

    /* Here we update the "constant" hardware configuration.  This is constant
     * everywhere except for this one place where we initialise it. */
    *CAST_TO(struct hardware_config *,
        &hardware_config) = (struct hardware_config)
    {
        .bunches = bunches,
        .adc_taps   = sys_info.adc_taps,
        .bunch_taps = sys_info.bunch_taps,
        .dac_taps   = sys_info.dac_taps,
        .no_hardware = no_hardware,
    };

    return ERROR_OK;
}


error__t initialise_hardware(
    const char *device_address, unsigned int bunches,
    bool lock_registers, bool lmbf_mode, bool no_hardware)
{
    if (no_hardware)
        log_message("running with hardware disabled");
    else
        log_message("initialise_hardware @%s %s",
            *device_address ? device_address : "/dev/amc525_mbf.0.*",
            lock_registers ? "" : "unlocked");

    /* Compute device node names from the device_address. */
    char reg_device_name[PATH_MAX];
    char dram0_device_name[PATH_MAX];
    char dram1_device_name[PATH_MAX];
    if (*device_address)
    {
        const char *device_template = "/dev/amc525_mbf/%s/amc525_mbf.%s";
        sprintf(reg_device_name,   device_template, device_address, "reg");
        sprintf(dram0_device_name, device_template, device_address, "ddr0");
        sprintf(dram1_device_name, device_template, device_address, "ddr1");
    }
    else
    {
        strcpy(reg_device_name,   "/dev/amc525_mbf.0.reg");
        strcpy(dram0_device_name, "/dev/amc525_mbf.0.ddr0");
        strcpy(dram1_device_name, "/dev/amc525_mbf.0.ddr1");
    }

    return
        IF_ELSE(no_hardware,
            DO( config_regs_size = 65536;
                config_regs = calloc(config_regs_size, 1)),
        //else
            TEST_IO_(reg_device = open(reg_device_name, O_RDWR | O_SYNC),
                "Unable to open MBF device %s", reg_device_name)  ?:
            TEST_IO(dram0_device = open(dram0_device_name, O_RDONLY))  ?:
            TEST_IO(dram1_device = open(dram1_device_name, O_RDONLY))  ?:
            IF(lock_registers,
                hw_lock_registers())  ?:
            TEST_IO(
                config_regs_size =
                    (size_t) ioctl(reg_device, MBF_MAP_SIZE))  ?:
            TEST_IO(config_regs = mmap(
                0, config_regs_size, PROT_READ | PROT_WRITE, MAP_SHARED,
                reg_device, 0)))  ?:
        map_config_regs()  ?:
        check_firmware_version(no_hardware)  ?:
        set_hardware_config(bunches, lmbf_mode, no_hardware);
}


void terminate_hardware(void)
{
    if (config_regs  &&  !hardware_config.no_hardware)
        munmap(config_regs, config_regs_size);
    if (reg_device != -1)
        close(reg_device);
    if (dram0_device != -1)
        close(dram0_device);
    if (dram1_device != -1)
        close(dram1_device);
}
