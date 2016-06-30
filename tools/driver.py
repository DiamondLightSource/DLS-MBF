import os
import mmap
import fcntl
import numpy

# Driver device names
DDR0 = '/dev/amc525_lmbf.0.ddr0'
DDR1 = '/dev/amc525_lmbf.0.ddr1'
REGS = '/dev/amc525_lmbf.0.reg'

# Register area size ioctl code
LMBF_MAP_SIZE = ord('L') << 8           # _IO('L', 0)
LMBF_BUF_SIZE = (ord('L') << 8) | 1     # _IO('L', 1)

# Interrogate DMA buffer size
ddr0_file = os.open(DDR0, os.O_RDONLY)
DDR0_BUF_LEN = fcntl.ioctl(ddr0_file, LMBF_BUF_SIZE)
os.close(ddr0_file)

# Open register file and map into memory.
reg_file = os.open(REGS, os.O_RDWR | os.O_SYNC)
reg_size = fcntl.ioctl(reg_file, LMBF_MAP_SIZE)
map = mmap.mmap(reg_file, reg_size)
regs = numpy.frombuffer(map, dtype = numpy.uint32)

# Register space is currently structured as 16 modules of 32 registers each.
regs = regs[:16*32].reshape((16, 32))

mem_gen_regs = regs[0]
misc_regs = regs[2]
debug_regs = regs[15]

__all__ = [
    'DDR0', 'DDR1',
    'DDR0_BUF_LEN',
    'regs', 'mem_gen_regs', 'misc_regs', 'debug_regs']
