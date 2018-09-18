# Bunch by bunch FIR

from common import *
from system import add_aggregate


def bank_pvs():
    boolOut('USEWF', 'Settings', 'Waveform',
        DESC = 'Use direct waveform or settings')

    # Direct settings of FIR parameters
    ForwardLink('RELOAD', 'Reload filter',
        longOut('LENGTH', 2, BUNCH_TAPS, DESC = 'Length of filter'),
        longOut('CYCLES', 1, BUNCH_TAPS, DESC = 'Cycles in filter'),
        aOut('PHASE', -360, 360, DESC = 'FIR phase'))


def bank_waveforms():
    # Waveform taps in two forms: TAPS_S is what is set directly as a
    # waveform write, TAPS is what is current loaded.
    WaveformOut('TAPS', BUNCH_TAPS, 'FLOAT', address = 'TAPS_S',
        DESC = 'Set waveform taps')
    Waveform('TAPS', BUNCH_TAPS, 'FLOAT',
        SCAN = 'I/O Intr', DESC = 'Current waveform taps')


def bunch_fir_pvs():
    # There are four banks of FIR coefficients, each can either be written
    # directly as a waveform or by separately controlling phase and fractional
    # frequency.
    for bank in range(4):
        with name_prefix('%d' % bank):
            bank_pvs()

    mbbOut('GAIN', DESC = 'FIR gain select', *dBrange(16, -6, 48))
    Action('GAIN:UP', DESC = 'Increase FIR gain')
    Action('GAIN:DN', DESC = 'Decrease FIR gain')


for a in axes('FIR', lmbf_mode):
    bunch_fir_pvs()
    if lmbf_mode:
        longOut('DECIMATION', 1, 128, DESC = 'Bunch by bunch decimation')


overflows = []
for a in axes('FIR'):
    # The bank waveforms are the same in both TMBF and LMBF modes
    for bank in range(4):
        with name_prefix('%d' % bank):
            bank_waveforms()

    # Axis specific overflow detection
    ovf = overflow('OVF', 'Overflow in %s bunch-by-bunch filter' % a)
    overflows.append(ovf)
    add_aggregate(a, ovf)

with name_prefix('FIR'):
    Action('EVENTS',
        SCAN = '.1 second',
        FLNK = create_fanout('EVENTS:FAN', *overflows),
        DESC = 'FIR event detect scan')
