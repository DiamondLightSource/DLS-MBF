from common import *

# Bunch selection

def bank_pvs(bank):
    # The output selection is summarised in a single status PV, this is updated
    # each time any of the output gain control PVs is updated.
    bank_status = stringIn('STATUS', DESC = 'Bank %d output status' % bank)

    # For each of the five output sources we have a similar group of PVs.
    for output in ['FIR', 'NCO1', 'SEQ', 'PLL', 'NCO2']:
        with name_prefix(output):
            # Summary status of this source
            source_status = stringIn('STATUS',
                FLNK = bank_status,
                DESC = 'Bank %d %s source status' % (bank, output))

            # Two waveforms to directly control the output gain and a readback
            # waveform to show the gain in dB
            WaveformOut('ENABLE', BUNCHES_PER_TURN, 'CHAR',
                FLNK = source_status, DESC = 'Enables for %s output' % output)
            gain_db = Waveform('GAIN_DB', BUNCHES_PER_TURN, 'FLOAT',
                EGU = 'dB', FLNK = source_status,
                DESC = '%s output gain in dB' % output)
            WaveformOut('GAIN', BUNCHES_PER_TURN, 'FLOAT',
                FLNK = gain_db, DESC = 'Gains for %s output' % output)

            # Control PVs for setting waveforms
            Action('SET_ENABLE', DESC = 'Set enable for %s' % output)
            Action('SET_DISABLE', DESC = 'Set disable for %s' % output)
            aOut('GAIN_SELECT', -8, 8, PREC = 5,
                 DESC = 'Select %s gain' % output)
            Action('SET_GAIN', DESC = 'Set %s gain' % output)

    # The FIR control PVs are separate
    fir_status = stringIn('FIRWF:STA', DESC = 'FIR status')
    WaveformOut('FIRWF', BUNCHES_PER_TURN, 'CHAR',
        FLNK = fir_status, DESC = 'FIR bank select')
    mbbOut('FIR_SELECT', 'FIR 0', 'FIR 1', 'FIR 2', 'FIR 3',
        DESC = 'Select FIR setting')
    Action('FIRWF:SET', DESC = 'Set selected bunches')

    Action('RESET_GAINS', DESC = 'Set all source gains to 1')

    # Finally we have an aggregate enable PV for the legacy interface
    WaveformOut('OUTWF', BUNCHES_PER_TURN, 'CHAR',
        PINI = 'NO', DESC = 'DAC output select')

    # Selector for bunch selection editing
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

    # Provide bank copy PVs
    mbbOut('COPY_FROM', 'Bank 0', 'Bank 1', 'Bank 2', 'Bank 3',
        DESC = 'Select source bank to copy')
    mbbOut('COPY_TO', 'Bank 0', 'Bank 1', 'Bank 2', 'Bank 3',
        DESC = 'Select target bank to copy')
    Action('COPY_BANK', DESC = 'Copy bank to bank')
