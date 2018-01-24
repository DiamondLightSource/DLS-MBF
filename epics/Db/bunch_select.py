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

    # Waveform settings with status update
    BunchWaveforms('FIRWF', 'CHAR', 'FIR bank select')
    BunchWaveforms('OUTWF', 'CHAR', 'DAC output select')
    BunchWaveforms('GAINWF', 'FLOAT', 'DAC output gain')


for a in axes('BUN', lmbf_mode):
    # We have four banks and for each bank three waveforms of parameters to
    # configure.   Very similar to FIR.
    for bank in range(4):
        with name_prefix('%d' % bank):
            bank_pvs(bank)

    # Feedback mode.  This is aggregated from the sequencer state and the
    # selected DAC output status.
    stringIn('MODE', SCAN = '1 second', DESC = 'Feedback mode')
