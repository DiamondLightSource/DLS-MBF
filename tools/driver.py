import sys
import os
import mmap
import fcntl
import numpy

from lmbf.register_defs import register_groups


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



class RawRegisters:
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


class RegisterMap:
    def __init__(self, registers, name):
        self.registers = registers
        self.name = name

    def _read_value(self, offset):
        result = self.registers[offset]
#         print >>sys.stderr, '%s[%d] => %08x' % (self.name, offset, result)
        return result

    def _write_value(self, offset, value):
#         print >>sys.stderr, '%s[%d] <= %08x' % (self.name, offset, value)
        self.registers[offset] = value


raw_registers = RawRegisters(REGS_NAME)

def make_register(name, map):
    return register_groups[name](RegisterMap(map, name))


SYSTEM  = make_register('SYS',  raw_registers.reg_system)
CONTROL = make_register('CTRL', raw_registers.reg_dsp_ctrl)
DSP0    = make_register('DSP',  raw_registers.reg_dsp[0])
DSP1    = make_register('DSP',  raw_registers.reg_dsp[1])


class SPI:
    def __init__(self, regs, dev):
        self.spi_reg = regs.FMC_SPI
        self.dev = dev

    def read(self, addr):
        # Trigger an SPI read
        self.spi_reg._write_fields_wo(
            ADDRESS = addr, SELECT = self.dev, RW_N = 1)
        return self.spi_reg.DATA

    def write(self, addr, data):
        self.spi_reg._write_fields_wo(
            ADDRESS = addr, SELECT = self.dev, DATA = data)
        # Trigger readback to ensure write has completed.  Should get rid of
        # this requirement one of these days...
        value = self.spi_reg._value

    __getitem__ = read
    __setitem__ = write


PLL_SPI = SPI(SYSTEM, 0)
ADC_SPI = SPI(SYSTEM, 1)
DAC_SPI = SPI(SYSTEM, 2)
