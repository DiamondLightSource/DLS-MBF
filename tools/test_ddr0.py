#!/usr/bin/env python

# Crude test of DDR0 memory

import sys
import os
import mmap
import fcntl
import numpy
import time


class Ticker:
    ticks = '|/-\\'
    def __init__(self):
        self.state = 0
    def tick(self):
        sys.stdout.write(self.ticks[self.state] + '\r')
        sys.stdout.flush()
        self.state = (self.state + 1) % 4



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

K = 1024
M = K * K

# DDR0_BUF_LEN = 1024*1024
print 'buf', DDR0_BUF_LEN

def test_ddr0(start, step, count):
    print 'test_ddr0', start, step, count
    # Interpret start and step as 32 bit values
    mem_gen_regs[0] = start
    mem_gen_regs[1] = start + step
    mem_gen_regs[2] = 2 * step
    mem_gen_regs[3] = 2 * step

    print 'Writing'
    mem_gen_regs[4] = count

    # Wait for write to complete.
    ticker = Ticker()
    while mem_gen_regs[7] & 1:
        ticker.tick()

    # Check no write errors reported
    assert (mem_gen_regs[4:7] == 0).all(), "Memory write error"

    # Writing 8 bytes per counted write
    bytes_left = count * 8

    # Create test buffer of increments
    print 'Reading'
    test_buf = step * numpy.arange(DDR0_BUF_LEN / 4, dtype = numpy.uint32)
    with open(DDR0) as ddr0:
        loop_count = 0
        while bytes_left > 0:
            ticker.tick()
            read_length_bytes = min(DDR0_BUF_LEN, bytes_left)
            read_length = read_length_bytes / 4

            buf = ddr0.read(read_length_bytes)
            buf = numpy.frombuffer(buf, dtype = numpy.uint32)

            diffs = buf != test_buf[:read_length] + start
            if diffs.any():
                print 'Buffer mismatch after', loop_count, 'reads'
                print 'Diffs at:', numpy.flatnonzero(diffs)
                print 'Expected:', test_buf[diffs] + start
                print 'Read:', buf[diffs]
            start += step * read_length
            bytes_left -= read_length_bytes
            loop_count += 1

# All memory is 2G, at 8 bytes per write this is filled by 256M writes:
test_ddr0(0, 0, 256*M - 1)
test_ddr0(0, 1, 256*M - 1)

# There is an anomaly, it looks as if memory writing overruns by one write.
