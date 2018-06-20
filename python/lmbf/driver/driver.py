import sys
import os
import mmap
import fcntl
import select
import struct
import numpy

from register_defs import register_groups


# Register area size ioctl code
def MBF_IOCTL(n):
    return (1 << 30) | (ord('L') << 8) | n
MBF_MAP_SIZE = MBF_IOCTL(0)
MBF_BUF_SIZE = MBF_IOCTL(1)



# We want to support two ways to specify the device name: by sequence number, or
# by PCI address (which encodes the backplane port).
def device_name(part, prefix = 0):
    if isinstance(prefix, int):
        # Assume the prefix is just a device number identification
        return '/dev/amc525_lmbf.%d.%s' % (prefix, part)
    else:
        # All string prefixes are PCI addresses.  In this case we'll allow a
        # full form (starting 'pci-') and a short form (nn).
        if not prefix.startswith('pci-'):
            prefix = 'pci-0000:%s:00.0' % prefix
        return '/dev/amc525_lmbf/%s/amc525_lmbf.%s' % (prefix, part)



class RawRegisters:
    def __init__(self, prefix):
        regs_device = device_name('reg', prefix)

        # Open register file and map into memory.
        self.reg_file = os.open(regs_device, os.O_RDWR | os.O_SYNC)
        reg_size = fcntl.ioctl(self.reg_file, MBF_MAP_SIZE)
        self.reg_map = mmap.mmap(self.reg_file, reg_size)
        regs = numpy.frombuffer(self.reg_map, dtype = numpy.uint32)

        # Extract the four relevant register banks according to the following
        # address map:
        #   0x0000..0x1FFF  System registers: top level hardware control
        #   0x2000..0x27FF  DSP master control
        #   0x2800..0x2FFF  (unused)
        #   0x3000..0x37FF  DSP 0 control
        #   0x3800..0x3FFF  DSP 1 control
        # For convenience we just export the first 32 registers in each block.
        self.reg_system   = regs[0x0000:0x0020]
        self.reg_dsp_ctrl = regs[0x2000:0x2020]
        self.reg_dsp      = [regs[0x3000:0x3020], regs[0x3800:0x3820]]

    def __del__(self):
        if hasattr(self, 'reg_file'):
            os.close(self.reg_file)

    def read_events(self, wait):
        if not wait:
            r, w, x = select.select([self.reg_file], [], [], 0)
            if not r:
                return 0
        return struct.unpack('I', os.read(self.reg_file, 4))[0]


class RegisterMap:
    def __init__(self, registers, name):
        self.registers = registers
        self.name = name

    def _read_value(self, offset):
        return self.registers[offset]

    def _write_value(self, offset, value):
        self.registers[offset] = value


def make_register(name, map):
    return register_groups[name](RegisterMap(map, name))


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
        value = self.spi_reg.DATA

    __getitem__ = read
    __setitem__ = write



class Registers:
    def __init__(self, prefix):
        self.DDR0_NAME = device_name('ddr0', prefix)
        self.DDR1_NAME = device_name('ddr1', prefix)

        self.raw_registers = RawRegisters(prefix)

        self.SYS  = make_register('SYS',  self.raw_registers.reg_system)
        self.CTRL = make_register('CTRL', self.raw_registers.reg_dsp_ctrl)
        self.DSP0 = make_register('DSP',  self.raw_registers.reg_dsp[0])
        self.DSP1 = make_register('DSP',  self.raw_registers.reg_dsp[1])

        self.PLL_SPI = SPI(self.SYS, 0)
        self.ADC_SPI = SPI(self.SYS, 1)
        self.DAC_SPI = SPI(self.SYS, 2)

        self._DDR0_BUF_LEN = None

    def SPI(self, dev):
        return SPI(self.SYS, dev)

    @property
    def DDR_BUF_LEN(self):
        if self._DDR0_BUF_LEN is None:
            with os.open(self.DDR0_NAME, os.O_RDONLY) as ddr0:
                self.DDR0_BUF_LEN = fcntl.ioctl(ddr0_file, MBF_BUF_SIZE)
        return self._DDR0_BUF_LEN

    def read_events(self, wait = True):
        return self.raw_registers.read_events(wait)


__all__ = ['Registers']
