#!/usr/bin/env python

# Configuration for Analog Devices AD9122 DAC.

import time

from driver import REG_SYSTEM, DAC

def setup_dac():
    # Check that the DAC power good signal is ok
#     assert REG_SYSTEM[1] & (1 << 4), "DAC power good not detected"

    # Apply a reset, give it time to respond.
    DAC[0x00] = 0x20
    time.sleep(0.01)
    DAC[0x00] = 0x00
    time.sleep(0.01)

    DAC[0x01] = 0x10        # Leave temperature sensor ADC off
    DAC[0x03] = 0x00        # 2's complement 16-bit words
    DAC[0x04] = 0x03        # FIFO warning 1 & 2 enabled
    DAC[0x05] = 0x1C        # Enable AED comparisons
    DAC[0x06] = 0xFF        # Clear PLL, Sync, FIFO event flags
    DAC[0x07] = 0xFF        # Clear ADC event flags
    DAC[0x08] = 0x2F        # DACCLK differential crossing correction
    DAC[0x0A] = 0x40        # PLL clock multiplier disabled

    # FIFO synchronisation


    # Datapath control, defaults are to disable everything, which is fine
    DAC[0x1B] = 0xA4        # Enable sinc inverse filter

    # Bypass the three half band filters
    DAC[0x1C] = 0x01
    DAC[0x1D] = 0x01
    DAC[0x1E] = 0x01

if __name__ == '__main__':
    setup_dac()
