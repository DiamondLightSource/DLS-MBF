/* Support for fine delay of ADC and DAC. */

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <pthread.h>

#include "error.h"
#include "epics_device.h"

#include "hardware.h"
#include "common.h"
#include "configs.h"

#include "delay.h"


/* When the LMK04820 PLL is operating in phase locked mode (rather than in
 * passthrough mode) we have full control over the ADC and DAC clocks.  The
 * architecture of the PLL and its connections is as follows:
 *
 *                                              +----[ DLY ]----> DAC
 *                                              |
 *  RF clock -------> [ PD ] ---> (VCXO/VCO) ---+----[-----]----> ADC
 *                      ^                       |
 *             Feedback |                       +----[ DLY ]----+
 *                      |                                       |
 *                      +---------------------------------------+
 *
 * We have two delay controls, a fine delay in 24 steps of 25ps, and a coarser
 * delay in steps determined by the VCO frequency, either roughly 200ps or
 * roughly 165ps (exact delay depends on feedback parameters).
 *
 * For the ADC clock we do not use the coarse delay to avoid stepping the
 * sampling frequency beyond 500 MHz. */

/* The following register bases are used to manage the DAC and Feedback. */
#define PLL_OUT_DAC     0x110       // DAC on DCLKout4
#define PLL_OUT_FB      0x120       // Feedback on DCLKout8


/* The following structures and registers are needed to interface to the PLL. */

/* Used to read clock divisor at startup. */
struct pll_0x0 {
    uint8_t DCLK_DIV : 5;           // Clock divider
    uint8_t CLK_IDL : 1;
    uint8_t CLK_ODL : 1;
    uint8_t _unused : 1;
};

/* Section 9.7.2.2. */
struct pll_0x1 {
    uint8_t DCLK_DDLY_CNTL : 4;     // Half dividers to program for single step
    uint8_t DCLK_DDLY_CNTH : 4;
};

/* Section 9.7.2.3 (undocumented in original manual). */
struct pll_0x2 {
    uint8_t DCLK_DDLYd_CNTL : 4;    // Needs to be copy of register above
    uint8_t DCLK_DDLYd_CNTH : 4;
};

/* Section 9.7.2.4. */
struct pll_0x3 {
    uint8_t DCLK_MUX : 2;           // Must be left as configured
    uint8_t DCLK_ADLY_MUX : 1;      // Ditto
    uint8_t DCLK_ADLY : 5;          // Analogue delay
};


#define READ_PLL(reg, type) \
    CAST_TO(type, hw_read_fmc500_spi(FMC500_SPI_PLL, reg))

#define WRITE_PLL(reg, value) \
    hw_write_fmc500_spi(FMC500_SPI_PLL, reg, CAST_TO(uint8_t, value));


static pthread_mutex_t delay_lock = PTHREAD_MUTEX_INITIALIZER;
static unsigned int dac_fine_delay = 0;
static unsigned int adc_fine_delay = 0;

static void set_fine_delay(unsigned int delay, unsigned int base)
{
    /* Read and update so we don't disturb the existing settings. */
    struct pll_0x3 value = READ_PLL(base + 3, struct pll_0x3);
    value.DCLK_ADLY = delay & 0x1F;
    WRITE_PLL(base + 3, value);
}

static void slew_fine_delay(
    unsigned int target, unsigned int *delay, unsigned int base)
{
    /* To avoid glitches, slew to the target delay rather than jumping there
     * directly.  Single steps are guaranteed to be glitchless. */
    if (*delay < target)
        for (unsigned int d = *delay + 1; d < target; d ++)
            set_fine_delay(d, base);
    else if (*delay > target)
        for (unsigned int d = *delay - 1; d > target; d --)
            set_fine_delay(d, base);
    set_fine_delay(target, base);
    *delay = target;
}

static void slew_dac_fine_delay(unsigned int delay)
{
    slew_fine_delay(delay, &dac_fine_delay, PLL_OUT_DAC);
}

static void slew_adc_fine_delay(unsigned int delay)
{
    slew_fine_delay(delay, &adc_fine_delay, PLL_OUT_FB);
}


error__t initialise_delay(void)
{
    WITH_NAME_PREFIX("DLY")
    {
        WITH_NAME_PREFIX("DAC")
        {
            PUBLISH_WRITER_P(ulongout, "FINE_DELAY",
                slew_dac_fine_delay, .mutex = &delay_lock);
        }

        WITH_NAME_PREFIX("ADC")
        {
            PUBLISH_WRITER_P(ulongout, "FINE_DELAY",
                slew_adc_fine_delay, .mutex = &delay_lock);
        }
    }
    return ERROR_OK;
}
