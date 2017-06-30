from common import *

# Bunch selection

# For each bunch setting there is an associated status string which is updated
# as the waveform is updated.
def BunchWaveforms(bank, name, FTVL, desc):
    status = stringIn('%s:STA' % name,
        DESC = 'Bank %d %s status' % (bank, name))
    WaveformOut(name, BUNCHES_PER_TURN, FTVL,
        FLNK = status, DESC = 'Set %d %s' % (bank, desc))


def bunch_select_pvs():
    # We have four banks and for each bank three waveforms of parameters to
    # configure.   Very similar to FIR.
    for bank in range(4):
        push_name_prefix('%d' % bank)

        # Waveform settings with status update
        BunchWaveforms(bank, 'FIRWF', 'CHAR', 'FIR bank select')
        BunchWaveforms(bank, 'OUTWF', 'CHAR', 'DAC output select')
        BunchWaveforms(bank, 'GAINWF', 'FLOAT', 'DAC output gain')

        pop_name_prefix()

    # Feedback mode.  This is aggregated from the sequencer state and the
    # selected DAC output status.
    stringIn('MODE', SCAN = '1 second', DESC = 'Feedback mode')


for_channels('BUN', bunch_select_pvs)
