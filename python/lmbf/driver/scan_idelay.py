# Functions for searching for the correct relationship between the ADC data and
# clock.

import math
import numpy

MIN_EYE_LENGTH = 4


# This is called at the start of an IDELAY scan to configure the ADC to generate
# the test pattern and to configure memory to capture raw ADC data.  The current
# IDELAY setting is returned.
def setup_scan(regs):
    # Configure checkerboard ADC capture
    regs.ADC_SPI[0x550] = 4

    # Configure DRAM capture using unprocessed ADC channels
    regs.DSP0.ADC.CONFIG.DRAM_SOURCE = 0    # Before FIR
    regs.DSP1.ADC.CONFIG.DRAM_SOURCE = 0
    regs.CTRL.MEM.CONFIG.MUX_SELECT = 0     # ADC0/ADC1

    # Return current idelay value
    return regs.SYS.ADC_IDELAY.VALUE


# This sets IDELAY to the given value.
def set_idelay(regs, delay):
    regs.SYS.ADC_IDELAY._write_fields_wo(VALUE = delay, WRITE = 1)


# This should be called after an IDELAY scan to restore normal ADC operation.
def complete_scan(regs):
    regs.ADC_SPI[0x550] = 0


# Captures the given number of samples, returns array formatted with dimensions
# [time, phase, axis].
def capture(regs, count):
    # Each counted capture corresponds to 8 captured bytes
    bytes = 8 * count
    regs.CTRL.MEM.COUNT = count + 32
    regs.CTRL.MEM.COMMAND._write_fields_wo(START = 1, STOP = 1)
    while regs.CTRL.MEM.STATUS.ENABLE:
        pass
    with open(regs.DDR0_NAME) as ddr0:
        buf = numpy.frombuffer(ddr0.read(bytes), dtype = numpy.uint16)
    return buf.reshape((-1, 2, 2))


# Returns true if the sample is properly in the eye: in this case we expect all
# values to stay constant over time and we expect both axes to see the same
# value.
def assess(c):
    return \
        (numpy.diff(c, axis = 0) == 0).all() and \
        (numpy.diff(c[0]) == 0).all()


# Returns the appropriate number of IDELAY values to scan given the RF
# frequency.  If f_rf is unknown we return 32.
#
# The IDELAY step size is 1/(32 * 2 * f_REF) with f_REF = 200 MHz, which comes
# to 78.125 ps, so 25 steps covers a 500 MHz input clock
def scan_length(f_rf):
    idelay_step = 78.125
    if f_rf:
        return min(int(math.ceil(1e6 / f_rf / idelay_step)), 32)
    else:
        return 32


# Performs scan and returns array indicating status of each capture
def capture_scan(regs, N, count):
    good = numpy.zeros(N, dtype = bool)
    for delay in range(N):
        set_idelay(regs, delay)
        good[delay] = assess(capture(regs, count))
    return good


# Given an assessed scan result probes for the best eye position
def find_idelay(scan):
    diffs = numpy.diff(numpy.int8(numpy.concatenate(([0], scan, [0]))))
    starts = numpy.where(diffs == 1)[0]
    ends = numpy.where(diffs == -1)[0]

    # Here we assume that a complete eye will fit into the scan and we don't
    # need to consider looping around.
    start = starts[0]
    end = ends[0] - 1
    if end < start:
        end = ends[1]

    # Check that the eye is large enough
    eye_length = end - start
    assert eye_length > MIN_EYE_LENGTH, 'Eye length %d too short' % eye_length
    return start + eye_length // 2, (start, end)


# Performs a complete scan and sets IDELAY accordingly
def scan_idelay(regs, f_rf, count):
    setup_scan(regs)
    N = scan_length(f_rf)
    scan = capture_scan(regs, N, count)
    print scan
    complete_scan(regs)

    idelay, eye = find_idelay(scan)
    print 'Setting IDELAY = %d, eye = %s' % (idelay, eye)
    set_idelay(regs, idelay)
