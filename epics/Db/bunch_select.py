from common import *

# Bunch selection


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
    mbbOut('DAC_SELECT',
        'Off',   'FIR',    'NCO',    'FIR+NCO',
        'Sweep', 'Sw+FIR', 'Sw+NCO', 'Sw+NCO+FIR',
        DESC = 'Select DAC output')
    aOut('GAIN_SELECT', PREC = 5, DESC = 'Select bunch gain')
    Action('ALL:SET', DESC = 'Set selected bunches')

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
