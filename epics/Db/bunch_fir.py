# Bunch by bunch FIR

from common import *


def bank_pvs():
    boolOut('USEWF', 'Settings', 'Waveform',
        DESC = 'Use direct waveform or settings')

    # Direct settings of FIR parameters
    ForwardLink('RELOAD', 'Reload filter',
        longOut('LENGTH', 2, BUNCH_TAPS, DESC = 'Length of filter'),
        longOut('CYCLES', 1, BUNCH_TAPS, DESC = 'Cycles in filter'),
        aOut('PHASE', -360, 360, DESC = 'FIR phase'))

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
        with_name_prefix('%d' % bank, bank_pvs)

    mbbOut('GAIN',
        DESC = 'FIR gain select', *dBrange(16, -6, 48))
    records.longin('N_TAPS', VAL = BUNCH_TAPS, PINI = 'YES',
        DESC = 'FIR filter length')

    longOut('DECIMATION', 1, 128,
        DESC = 'Bunch by bunch decimation')


for_channels('FIR', bunch_fir_pvs)
