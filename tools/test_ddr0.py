#!/usr/bin/env python

# Crude test of DDR0 memory

import sys
import numpy

from driver import *


class Ticker:
    ticks = '|/-\\'
    def __init__(self):
        self.state = 0
    def tick(self):
        sys.stdout.write(self.ticks[self.state] + '\r')
        sys.stdout.flush()
        self.state = (self.state + 1) % 4


K = 1024
M = K * K


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
# Oddly, it looks as if we write two more words than requested...
test_ddr0(0, 0, 256*M - 2)
test_ddr0(0, 1, 256*M - 2)
