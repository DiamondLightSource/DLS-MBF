# Configuration for Analog Devices AD9684 ADC.

import time
import sys


def setup_adc(regs):
    # Check that the VCXO and ADC power good signals are ok
    status = regs.SYS.STATUS._fields
    assert status.VCXO_OK, "VCXO power good not detected"
    assert status.ADC_OK, "ADC power good not detected"
    assert status.DAC_OK, "DAC power good not detected"
    assert status.PLL_LD2, "VCO not locked"
    assert status.DSP_OK, "ADC clock not locked"
    if not status.PLL_LD1:
        print >>sys.stderr, "Warning: clock not locked"


    # Start by resetting the ADC, must sleep for 5ms before doing anything more.
    regs.ADC_SPI[0] = 0x81
    time.sleep(0.005)

    # 100 Ohm input termination
    regs.ADC_SPI[0x016] = 0x2C

    # Configure settings for DC to 250MHz input, as described in table 9, page
    # 26 of the AD9684 manual.
    regs.ADC_SPI[0x018] = 0x20      # 2.0x buffer current
    regs.ADC_SPI[0x025] = 0x0C      # 2.06 V p-p
    regs.ADC_SPI[0x030] = 0x04      # (for 2.06 V input)

    # Check that we have clock
    assert regs.ADC_SPI[0x11c] == 1, 'No clock detected'

    # Test mode is configured by writing register 0x550.  Useful values seem to
    # be:
    #   00  normal operation
    #   04  alternating checkerboard (1555/2AAA)
    #   07  Alternating 0000/3FFF
    #   0F  ramp output
    regs.ADC_SPI[0x550] = 0x00

    # Configure dual converter parallel interleaved output mode
    regs.ADC_SPI[0x568] = 0x01      # parallel interleaved mode (two converters)

    # Configure ADC clock delay
    regs.SYS.ADC_IDELAY._write_fields_wo(VALUE = 12, WRITE = 1)
