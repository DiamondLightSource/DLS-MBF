from common import *

# Bunch selection

def select_from(l):
    if l:
        for x in select_from(l[1:]):
            yield x
            yield x + [l[0]]
    else:
        yield []

def dac_select(*options):
    selection = list(select_from(options))
    return ['Off'] + ['+'.join(s) for s in selection[1:]]


def bank_pvs(bank):

    # For each bunch setting there is an associated status string which is
    # updated as the waveform is updated.
    def BunchWaveforms(name, FTVL, desc):
        status = stringIn('%s:STA' % name,
            DESC = 'Bank %d %s status' % (bank, name))
        WaveformOut(name, BUNCHES_PER_TURN, FTVL,
            FLNK = status, DESC = 'Set %d %s' % (bank, desc))
        Action('%s:SET' % name, DESC = 'Set selected bunches')

    # Waveform settings with status update
    BunchWaveforms('FIRWF', 'CHAR', 'FIR bank select')
    BunchWaveforms('OUTWF', 'CHAR', 'DAC output select')
    BunchWaveforms('GAINWF', 'FLOAT', 'DAC output gain')

    # PVs for setting waveforms via user interface
    mbbOut('FIR_SELECT', 'FIR 0', 'FIR 1', 'FIR 2', 'FIR 3',
        DESC = 'Select FIR setting')
    longOut('DAC_SELECT', 0, 31, DESC = 'Select DAC output')
    aOut('GAIN_SELECT', PREC = 5, DESC = 'Select bunch gain')

    stringOut('BUNCH_SELECT', DESC = 'Select bunch to set',
        FLNK = stringIn('SELECT_STATUS', DESC = 'Status of selection'))


for a in axes('BUN', lmbf_mode):
    # We have four banks and for each bank three waveforms of parameters to
    # configure.   Very similar to FIR.
    for bank in range(4):
        with name_prefix('%d' % bank):
            bank_pvs(bank)

    # Feedback mode.  This summarises the quiescent state of the system, when
    # the sequencer is not running.
    stringIn('MODE', SCAN = '1 second', DESC = 'Feedback mode')
