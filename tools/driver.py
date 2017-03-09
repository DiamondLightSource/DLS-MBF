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

        # Extract the four relevant register banks according to the following
        # address map:
        #   0x0000..0x0FFF  System registers: top level hardware control
        #   0x2000..0x27FF  DSP master control
        #   0x2800..0x2FFF  (unused)
        #   0x3000..0x37FF  DSP 0 control
        #   0x3800..0x3FFF  DSP 1 control
        # For convenience we just export the first 32 registers in each block.
        self.reg_system   = regs[0x0000:0x0020]
        self.reg_dsp_ctrl = regs[0x2000:0x2020]
        self.reg_dsp      = [regs[0x3000:0x3020], regs[0x3800:0x3820]]

        self.spi_reg = self.reg_system[4:5]

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

PLL = SPI(regs, 0)
ADC = SPI(regs, 1)
DAC = SPI(regs, 2)

REG_SYSTEM = regs.reg_system
REG_CTRL   = regs.reg_dsp_ctrl
REG_DSP    = regs.reg_dsp

__all__ = [
    'DDR0_BUF_LEN',
    'PLL', 'ADC', 'DAC',
    'REG_SYSTEM', 'REG_CTRL', 'REG_DSP',
]
