import os
import mmap
import fcntl
import numpy

# Driver device names
DDR0_NAME = '/dev/amc525_lmbf.0.ddr0'
DDR1_NAME = '/dev/amc525_lmbf.0.ddr1'
REGS_NAME = '/dev/amc525_lmbf.0.reg'

# Register area size ioctl code
LMBF_MAP_SIZE = ord('L') << 8           # _IO('L', 0)
LMBF_BUF_SIZE = (ord('L') << 8) | 1     # _IO('L', 1)

# Register map parameters.  These must match definitions in vhd/defines.vhd
MOD_ADDR_COUNT = 2**2
REG_ADDR_COUNT = 2**5


# Interrogate DMA buffer size
ddr0_file = os.open(DDR0_NAME, os.O_RDONLY)
DDR0_BUF_LEN = fcntl.ioctl(ddr0_file, LMBF_BUF_SIZE)
os.close(ddr0_file)



class Regs:
    def __init__(self, regs_device):
        # Open register file and map into memory.
        self.reg_file = os.open(regs_device, os.O_RDWR | os.O_SYNC)
        reg_size = fcntl.ioctl(self.reg_file, LMBF_MAP_SIZE)
        self.reg_map = mmap.mmap(self.reg_file, reg_size)
        regs = numpy.frombuffer(self.reg_map, dtype = numpy.uint32)

        # Reshape register space into individual modules
        regs = regs[:MOD_ADDR_COUNT * REG_ADDR_COUNT]
        regs = regs.reshape((MOD_ADDR_COUNT, REG_ADDR_COUNT))

        self.regs = regs
        self.spi_reg = self.regs[0, 4:5]

    def spi_read(self, dev, addr):
        dev &= 3
        addr &= 0xFFF
        self.spi_reg[0] = 0x80000000 | (dev << 29) | (addr << 8)
        return self.spi_reg[0]

    def spi_write(self, dev, addr, data):
        dev &= 3
        addr &= 0xFFF
        data &= 0xFF
        self.spi_reg[0] = (dev << 29) | (addr << 8) | data
        # Must read back to ensure that write has completed
        resp = self.spi_reg[0]


class SPI:
    def __init__(self, regs, dev):
        self.regs = regs
        self.dev = dev

    def read(self, addr):
        return self.regs.spi_read(self.dev, addr)

    def write(self, addr, data):
        self.regs.spi_write(self.dev, addr, data)

    __getitem__ = read
    __setitem__ = write


regs = Regs(REGS_NAME)

REGS = regs.regs
PLL = SPI(regs, 0)
ADC = SPI(regs, 1)
DAC = SPI(regs, 2)


__all__ = ['DDR0_BUF_LEN', 'regs', 'PLL', 'ADC', 'DAC']
