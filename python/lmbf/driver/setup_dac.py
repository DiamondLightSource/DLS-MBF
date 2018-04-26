# Configuration for Analog Devices AD9122 DAC.

import time

def setup_dac(regs):
    DAC_SPI = regs.DAC_SPI

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

    # Datapath control, defaults are to disable everything, which is fine
    DAC_SPI[0x1B] = 0xE4        # Disable sinc inverse filter

    # Bypass the three half band filters
    DAC_SPI[0x1C] = 0x01
    DAC_SPI[0x1D] = 0x01
    DAC_SPI[0x1E] = 0x01

    # Set output gains to maximum levels
    DAC_SPI[0x40] = 0xFF
    DAC_SPI[0x41] = 0x03
    DAC_SPI[0x44] = 0xFF
    DAC_SPI[0x45] = 0x03

    # FIFO synchronisation
    # This is the relative FIFO reset process documented on p34 of the AD9122
    # manual (Rev. B).  Depending on our clocks this may still leave an
    # uncertainty of one clock tick, to be investigated...
    print 'Setting DAC FIFO synchronisation'
    DAC_SPI[0x17] = 0x05            # Set nominal FIFO phase offset to 5
    status = DAC_SPI[0X18]
    DAC_SPI[0x18] = status | 2      # Set soft alignment request bit
    status = DAC_SPI[0X18]
    assert status & 0x04            # Validate FIFO acknowlege
    DAC_SPI[0x18] = status & ~2     # Reset soft alignment bit
    status = DAC_SPI[0X18]
    assert not (status & 0x04)      # Validate FIFO acknowlege
    spacing = DAC_SPI[0X19]
    print 'spacing: %02x' % spacing
    assert spacing in [0x07, 0x0F]  # Validate programmed spacing
