# PVs for Tune PLL

from common import *

for a in axes('PLL', lmbf_mode):
    polled_readbacks = []

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

    # Debug readbacks
    with name_prefix('DEBUG'):
        boolOut('ENABLE', 'Off', 'On', DESC = 'Enable debug readbacks')
        Trigger('READ',
            Waveform('WFI', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL detector I'),
            Waveform('WFQ', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL detector Q'),
            Waveform('ANGLE', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL angle'),
            Waveform('MAG', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL magnitude'),
            overflow('FIFO_OVF', 'Debug FIFO readout overrun'))
        boolOut('SELECT', 'IQ', 'CORDIC',
            DESC = 'Select captured readback values')

    # Filtered readbacks
    with name_prefix('FILT'):
        polled_readbacks.extend([
            aIn('I', PREC = 8,
                DESC = 'Filtered Tune PLL detector I'),
            aIn('Q', PREC = 8,
                DESC = 'Filtered Tune PLL detector Q'),
            aIn('MAG', PREC = 8,
                DESC = 'Filtered Tune PLL detector magnitude'),
            aIn('PHASE', PREC = 2, EGU = 'deg',
                DESC = 'Filtered Tune PLL phase offset'),
        ])
        boolOut('SELECT', 'IQ', 'CORDIC',
            DESC = 'Select filtered readback values')

    # Status readbacks
    with name_prefix('STA'):
        polled_readbacks.extend([
            overflow('DET_OVF', 'Detector overflow'),
            overflow('MAG_ERROR', 'Magnitude error', error = 'Too small'),
            overflow('OFFSET_OVF', 'Offset overflow'),
        ])

    # Process all the polled readbacks
    Action('POLL',
        DESC = 'Poll Tune PLL readbacks',
        SCAN = '.1 second',
        FLNK = create_fanout('FAN', *polled_readbacks))
