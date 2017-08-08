# Configuration for Analog Devices AD9122 DAC.

import time

from driver import DAC_SPI

def setup_dac():
    # Apply a reset, give it time to respond.
    DAC_SPI[0x00] = 0x20
    time.sleep(0.01)
    DAC_SPI[0x00] = 0x00
    time.sleep(0.01)

    DAC_SPI[0x01] = 0x10        # Leave temperature sensor ADC off
    DAC_SPI[0x03] = 0x00        # 2's complement 16-bit words
    DAC_SPI[0x04] = 0x03        # FIFO warning 1 & 2 enabled
    DAC_SPI[0x05] = 0x1C        # Enable AED comparisons
    DAC_SPI[0x06] = 0xFF        # Clear PLL, Sync, FIFO event flags
    DAC_SPI[0x07] = 0xFF        # Clear ADC event flags
    DAC_SPI[0x08] = 0x2F        # DACCLK differential crossing correction
    DAC_SPI[0x0A] = 0x40        # PLL clock multiplier disabled

    # FIFO synchronisation


    # Datapath control, defaults are to disable everything, which is fine
    DAC_SPI[0x1B] = 0xA4        # Enable sinc inverse filter

    # Bypass the three half band filters
    DAC_SPI[0x1C] = 0x01
    DAC_SPI[0x1D] = 0x01
    DAC_SPI[0x1E] = 0x01

    # Set output gains to maximum levels
    DAC_SPI[0x40] = 0xFF
    DAC_SPI[0x41] = 0x03
    DAC_SPI[0x44] = 0xFF
    DAC_SPI[0x45] = 0x03

if __name__ == '__main__':
    setup_dac()
