# PVs for Tune PLL

from common import *

for a in axes('PLL', lmbf_mode):
    pass

    # Direct control over NCO
    with name_prefix('NCO'):
        aOut('FREQ', PREC = 5, DESC = 'Base Tune PLL NCO frequency')
        aIn('FREQ', PREC = 5,
            SCAN = 'I/O Intr', DESC = 'Tune PLL NCO frequency')
        mbbOut('GAIN', DESC = 'Tune PLL NCO gain', *dBrange(16, -6))
        boolOut('ENABLE', 'Off', 'On', DESC = 'Enable Tune PLL NCO output')

    # Detector control
    with name_prefix('DET'):
        mbbOut('SELECT', 'ADC', 'FIR', 'ADC no fill',
            DESC = 'Select detector source')
        mbbOut('SCALING', DESC = 'Readout scaling', *dBrange(2, -8*6))
        longOut('DWELL', 1, 2**16, DESC = 'Dwell time in turns')

        bunch_count = longIn('COUNT', DESC = 'Number of enabled bunches')
        WaveformOut('BUNCHES', BUNCHES_PER_TURN, 'CHAR',
            FLNK = bunch_count,
            DESC = 'Enable bunches for detector')

        # PVs for user interface to bunch enable waveform
        stringOut('BUNCH_SELECT', DESC = 'Select bunch to set',
            FLNK = stringIn('SELECT_STATUS', DESC = 'Status of selection'))
        Action('SET_SELECT', DESC = 'Enable selected bunches')
        Action('RESET_SELECT', DESC = 'Disable selected bunches')

    # Readbacks of filtered data
    Action('POLL',
        DESC = 'Poll Tune PLL readbacks',
        SCAN = '.1 second', FLNK = create_fanout('FAN',
            aIn('DET:I', PREC = 8,
                DESC = 'Filtered Tune PLL detector I'),
            aIn('DET:Q', PREC = 8,
                DESC = 'Filtered Tune PLL detector Q'),
            aIn('DET:MAG', PREC = 8,
                DESC = 'Filtered Tune PLL detector magnitude'),
            aIn('PHASE', PREC = 2, EGU = 'deg',
                DESC = 'Filtered Tune PLL phase offset'),
            aIn('OFFSET', PREC = 6, EGU = 'tune',
                DESC = 'Filtered Frequency offset out')))

    # Debug readbacks
    with name_prefix('DEBUG'):
        boolOut('ENABLE', 'Off', 'On', DESC = 'Enable debug readbacks')
        Trigger('READ',
            Waveform('WFI', TUNE_PLL_LENGTH, 'LONG',
                DESC = 'Tune PLL detector I'),
            Waveform('WFQ', TUNE_PLL_LENGTH, 'LONG',
                DESC = 'Tune PLL detector Q'),
            overflow('FIFO_OVF', 'Debug FIFO readout overrun'))
