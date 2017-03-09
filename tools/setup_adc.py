#!/usr/bin/env python

# Configuration for Analog Devices AD9684 ADC.

import time

from driver import REG_SYSTEM, ADC


def setup_adc():
    # Check that the VCXO and ADC power good signals are ok
    assert REG_SYSTEM[1] & (1 << 2), "VCXO power good not detected"
#     assert REG_SYSTEM[1] & (1 << 3), "ADC power good not detected"

    # Start by resetting the ADC, must sleep for 5ms before doing anything more.
    ADC[0] = 0x81
    time.sleep(0.005)

    # 100 Ohm input termination
    ADC[0x016] = 0x2C

    # Configure settings for DC to 250MHz input, as described in table 9, page
    # 26 of the AD9684 manual.
    ADC[0x018] = 0x20               # 2.0x buffer current
    ADC[0x025] = 0x0C               # 2.06 V p-p
    ADC[0x030] = 0x04               # (for 2.06 V input)

    # Check that we have clock
    assert ADC[0x11c] == 1, 'No clock detected'

    # Test mode is configured by writing register 0x550.  Useful values seem to
    # be:
    #   00  normal operation
    #   04  alternating checkerboard (1555/2AAA)
    #   07  Alternating 0000/3FFF
    #   0F  ramp output
    ADC[0x550] = 0x00

    # Configure dual converter parallel interleaved output mode
    ADC[0x568] = 0x01               # parallel interleaved mode (two converters)


    # Set up data capture from ADC
    REG_SYSTEM[3] = 0x10c


if __name__ == '__main__':
    setup_adc()
