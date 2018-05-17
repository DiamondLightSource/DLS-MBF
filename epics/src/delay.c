/* Support for fine delay of ADC and DAC. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "delay.h"


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* PLL interface. */

/* When the LMK04828 PLL is operating in phase locked mode (rather than in
 * passthrough mode) we have full control over the ADC and DAC clocks.  The
 * architecture of the PLL and its connections is as follows:
 *
 *                                              +----[-----]----> ADC   (12/13)
 *                                              |
 *  RF clock -------> [ PD ] ---> (VCXO/VCO) ---+----[ DLY ]----> DAC   (4)
 *                      ^                       |
 *             Feedback |                       +----[-----]----+ FB    (8)
 *                      |                                       |
 *                      +---------------------------------------+
 *
 * We have two delay controls on each output, a fine delay in 24 steps of 25ps,
 * and a coarser delay in steps determined by the VCO frequency, either roughly
 * 200ps or roughly 165ps (exact delay depends on feedback parameters).
 *
 * One constraint of the LMK is that we cannot reliably step the digital delay
 * earlier when our VCO divisor is equal to 5; it appears that the required
 * CNTL/H divisor of 2/2 is too small for reliable operation.
 *
 * A second important constraint is that any kind of dynamic delay on the ADC
 * output can cause the FPGA PLL to briefly unlock, so we don't touch this.
 *
 * A final constraint is that large clock steps on the PLL feedback can also
 * cause unlocking.  So in the end all we can do is step the DAC forwards, and
 * then reset everything. */

/* The following register base is used to manage the DAC. */
#define PLL_OUT_DAC     0x110       // DAC on DCLKout4


/* The following structures and registers are needed to interface to the PLL.
 * All structure names refer to the register number, and all section numbers
 * refer to the LMK04828-EP manual SNAS703 (April 2017). */

/* Section 9.7.2.1. */
struct pll_0x0 {
    uint8_t DCLK_DIV : 5;           // Output clock divider
    uint8_t CLK_IDL : 1;
    uint8_t CLK_ODL : 1;
    uint8_t _unused : 1;
};

/* Section 9.7.2.4. */
struct pll_0x3 {
    uint8_t DCLK_MUX : 2;
    uint8_t DCLK_ADLY_MUX : 1;
    uint8_t DCLK_ADLY : 5;          // Analogue delay
};

/* Section 9.7.2.5. */
struct pll_0x4 {
    uint8_t SDCLK_HS : 1;
    uint8_t SDCLK_DDLY : 4;
    uint8_t SDCLK_MUX : 1;
    uint8_t DCLK_HS : 1;            // DCLK half step value
    uint8_t _unused : 1;
};

/* Section 9.7.3.1. */
struct pll_0x138 {
    uint8_t OSCout_FMT : 4;
    uint8_t OSCout_MUX : 1;
    uint8_t VCO_MUX : 2;            // Internal clock source selection
    uint8_t _unused : 1;
};

/* Section 9.7.3.8. */
struct pll_0x141 {
    uint8_t DDLYd0_EN : 1;
    uint8_t DDLYd2_EN : 1;
    uint8_t DDLYd4_EN : 1;          // Dynamic Digital Delay enable for DAC
    uint8_t DDLYd6_EN : 1;
    uint8_t DDLYd8_EN : 1;
    uint8_t DDLYd10_EN : 1;
    uint8_t DDLYd12_EN : 1;
    uint8_t DDLYd_SYSREF_EN : 1;
};

/* Section 9.7.3.9. */
struct pll_0x142 {
    uint8_t DDLYd_STEP_CNT : 4;     // Write triggers DDD advance
    uint8_t _unused : 4;
};

/* Section 9.7.3.10 */
struct pll_0x143 {
    uint8_t SYNC_MODE : 2;
    uint8_t SYNC_PLL1_DLD : 1;
    uint8_t SYNC_PLL2_DLD : 1;
    uint8_t SYNC_EN : 1;
    uint8_t SYNC_POL : 1;           // Synchronisation enable
    uint8_t SYNC_1SHOT_EN : 1;
    uint8_t SYSREF_CLR : 1;
};


#define READ_PLL(reg, type) \
    CAST_TO(type, hw_read_fmc500_spi(FMC500_SPI_PLL, reg))

#define WRITE_PLL(reg, value) \
    hw_write_fmc500_spi(FMC500_SPI_PLL, reg, CAST_TO(uint8_t, value));


/* All access to the PLL is managed under this mutex. */
static pthread_mutex_t delay_lock = PTHREAD_MUTEX_INITIALIZER;


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Clock and DAC synchronisation. */


/* Page 26 of AD9122 Rev. B manual. */
struct dac_0x18 {
    uint8_t _unused1 : 1;
    uint8_t FIFO_soft_align_request : 1;
    uint8_t FIFO_soft_align_acknowledge : 1;
    uint8_t _unused2 : 3;
    uint8_t FIFO_warning_2 : 1;
    uint8_t FIFO_warning_1 : 1;
};

#define READ_DAC(reg, type) \
    CAST_TO(type, hw_read_fmc500_spi(FMC500_SPI_DAC, reg))

#define WRITE_DAC(reg, value) \
    hw_write_fmc500_spi(FMC500_SPI_DAC, reg, CAST_TO(uint8_t, value));



/* Timing resynchronisation and DAC FIFO alignment needs to be done both at
 * startup and when resetting the DAC delay. */

/* This follows the procedure described in section 9.3.2.1.1 of the PLL manual,
 * but in fact everything has already been set up, so all we need to do is
 * trigger the sync event. */
static void pll_sync(void)
{
    struct pll_0x143 value = READ_PLL(0x143, struct pll_0x143);
    value.SYNC_POL = 1;
    WRITE_PLL(0x143, value);
    usleep(50000);              // Allow enough time
    value.SYNC_POL = 0;
    WRITE_PLL(0x143, value);
}


/* Similarly, this follows the procedure described on page 34 of the DAC manual,
 * and again all we need to do is to trigger the reset. */
static void reset_dac_pll(void)
{
    struct dac_0x18 value = READ_DAC(0x18, struct dac_0x18);
    value.FIFO_soft_align_request = 1;
    WRITE_DAC(0x18, value);
    value = READ_DAC(0x18, struct dac_0x18);
    value.FIFO_soft_align_request = 0;
    WRITE_DAC(0x18, value);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Initialisation by reading PLL state. */

static bool clock_passthrough;

/* Dynamic delay step size, initialised from PLL frequency. */
static double ddd_step_size = 400.0;


static void read_pll_setup(void)
{
    /* First check whether the PLL is in passthrough mode.  If so this will
     * cramp our style somewhat. */
    unsigned int vco_mux = READ_PLL(0x138, struct pll_0x138).VCO_MUX;
    clock_passthrough = vco_mux == 2;

    /* Now figure out our RF frequency from the PLL settings. */
    if (!clock_passthrough)
    {
        unsigned int pll_divisor =
            READ_PLL(PLL_OUT_DAC + 0x0, struct pll_0x0).DCLK_DIV;
        double machine_rf =
            system_config.revolution_frequency * system_config.bunches_per_turn;
        ddd_step_size = 1e12 / machine_rf / pll_divisor;    // Hz to ps
    }
}


bool read_clock_passthrough(void)
{
    return clock_passthrough;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Fine delay control. */

static unsigned int dac_fine_delay = 0;

static void set_fine_delay(unsigned int base, unsigned int delay)
{
    /* Read and update so we don't disturb the existing settings. */
    struct pll_0x3 value = READ_PLL(base + 3, struct pll_0x3);
    value.DCLK_ADLY = delay & 0x1F;
    WRITE_PLL(base + 3, value);
}

static void slew_fine_delay(
    unsigned int base, unsigned int target, unsigned int delay)
{
    /* To avoid glitches, slew to the target delay rather than jumping there
     * directly.  Single steps are guaranteed to be glitchless. */
    while (delay < target)
    {
        delay += 1;
        set_fine_delay(base, delay);
    }

    while (delay > target)
    {
        delay -= 1;
        set_fine_delay(base, delay);
    }
}

static void slew_dac_fine_delay(unsigned int delay)
{
    slew_fine_delay(PLL_OUT_DAC, delay, dac_fine_delay);
    dac_fine_delay = delay;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* Coarse delay control (Dynamic Digital Delay). */

#define MAX_COARSE_DELAY    7

static unsigned int dac_coarse_delay = 0;

static struct epics_record *coarse_delay_pv;


static bool set_half_step(bool half_step)
{
    if (clock_passthrough)
        return false;
    else
    {
        struct pll_0x4 value = READ_PLL(PLL_OUT_DAC + 4, struct pll_0x4);
        value.DCLK_HS = half_step;
        WRITE_PLL(PLL_OUT_DAC + 4, value);
        return true;
    }
}


static bool set_coarse_delay(unsigned int target)
{
    if (clock_passthrough)
        return false;
    else if (dac_coarse_delay <= target  &&  target <= MAX_COARSE_DELAY)
    {
        if (target > dac_coarse_delay)
        {
            WRITE_PLL(0x141, (struct pll_0x141) { .DDLYd4_EN = 1 });
            WRITE_PLL(0x142, (struct pll_0x142) {
                .DDLYd_STEP_CNT = (target - dac_coarse_delay) & 0xF });
            dac_coarse_delay = target;
        }
        return true;
    }
    else
        return false;
}


static void step_coarse_delay(void)
{
    WRITE_OUT_RECORD(ulongout, coarse_delay_pv, dac_coarse_delay + 1, true);
}


static void reset_coarse_delay(void)
{
    printf("reset required\n");
    pll_sync();
    reset_dac_pll();
    WRITE_OUT_RECORD(ulongout, coarse_delay_pv, 0, false);
    dac_coarse_delay = 0;
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

static int read_dac_fifo(void)
{
    return hw_read_fmc500_spi(FMC500_SPI_DAC, 0x019);
}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

error__t initialise_delay(void)
{
    read_pll_setup();

    WITH_NAME_PREFIX("DLY")
    {
        PUBLISH_READ_VAR(ai, "STEP_SIZE", ddd_step_size);

        WITH_NAME_PREFIX("DAC")
        {
            PUBLISH_WRITER_P(ulongout, "FINE_DELAY",
                slew_dac_fine_delay, .mutex = &delay_lock);

            PUBLISH_WRITER_B_P(bo, "HALF_STEP",
                set_half_step, .mutex = &delay_lock);

            coarse_delay_pv = PUBLISH_WRITER_B_P(ulongout, "COARSE_DELAY",
                set_coarse_delay, .mutex = &delay_lock);

            PUBLISH_ACTION("STEP", step_coarse_delay);
            PUBLISH_ACTION("RESET", reset_coarse_delay, .mutex = &delay_lock);

            PUBLISH_READER(longin, "FIFO", read_dac_fifo);
        }
    }
    return ERROR_OK;
}
