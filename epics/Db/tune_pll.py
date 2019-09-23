# PVs for Tune PLL

from common import *


def db_record(name, source, **kargs):
    return records.calc(name, PREC = 1, EGU = 'dB',
        CALC = '20*log(A)', INPA = source, **kargs)


# These two controls act on both axes simultaneously
if not lmbf_mode:
    with name_prefix('PLL:CTRL'):
        Action('START', DESC = 'Start tune PLL')
        Action('STOP', DESC = 'Stop tune PLL')


for a in axes('PLL', lmbf_mode):
    # All these readbacks are polled at 10 Hz
    polled_readbacks = []

    # Direct control over NCO
    with name_prefix('NCO'):
        Trigger('READ',
            Waveform('OFFSETWF', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL offset'),
            aIn('MEAN_OFFSET', PREC = 7, EGU = 'tune',
                DESC = 'Mean tune PLL offset'),
            aIn('STD_OFFSET', PREC = 7, EGU = 'tune',
                DESC = 'Standard deviation of offset'),
            aIn('TUNE', 0, 1, PREC = 7, EGU = 'tune',
                DESC = 'Measured tune frequency'),
            overflow('FIFO_OVF', 'Offset FIFO readout overrun'))
        Action('RESET_FIFO', DESC = 'Reset FIFO readout to force fresh sample')

        # Frequency readbacks
        nco_freq = aIn('FREQ', PREC = 7, EGU = 'tune',
            DESC = 'Tune PLL NCO frequency')
        aIn('OFFSET', PREC = 7, EGU = 'tune',
            SCAN = 'I/O Intr',
            FLNK = nco_freq,
            DESC = 'Filtered frequency offset')

        # NCO control
        aOut('FREQ', PREC = 7, EGU = 'tune',
            DESC = 'Base Tune PLL NCO frequency')
        mbbOut('GAIN', DESC = 'Tune PLL NCO gain', *dBrange(16, -6))
        boolOut('ENABLE', 'Off', 'On', DESC = 'Enable Tune PLL NCO output')

    # Feedback control
    with name_prefix('CTRL'):
        aOut('KI', DESC = 'Integral factor for controller')
        aOut('KP', DESC = 'Proportional factor for controller')
        aOut('MIN_MAG', 0, 1, PREC = 5,
            DESC = 'Minimum magnitude for feedback')
        aOut('MAX_OFFSET', PREC = 7, EGU = 'tune',
            DESC = 'Maximum frequency offset for feedback')
        aOut('TARGET', -180, 180, PREC = 2, DESC = 'Target phase')

        Action('START', DESC = 'Start tune PLL')
        Action('STOP', DESC = 'Stop tune PLL')

        Trigger('UPDATE_STATUS',
            boolIn('STATUS', 'Stopped', 'Running',
                DESC = 'Tune PLL feedback status'),
            overflow('STOP:STOP', 'Stopped by user', error = 'Stopped'),
            overflow('STOP:DET_OVF', 'Detector overflow'),
            overflow('STOP:MAG_ERROR', 'Magnitude error', error = 'Too small'),
            overflow('STOP:OFFSET_OVF', 'Offset overflow'))

    # Detector control
    with name_prefix('DET'):
        mbbOut('SELECT', 'ADC', 'FIR', 'ADC no fill',
            DESC = 'Select detector source')
        mbbOut('SCALING', DESC = 'Readout scaling', *dBrange(4, -6*6, 8*6))
        longOut('DWELL', 1, 2**16, DESC = 'Dwell time in turns')
        boolOut('BLANKING', 'Ignore', 'Blanking',
            DESC = 'Response to blanking trigger')

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
        boolOut('ENABLE', 'Off', 'On',
            OSV = 'MINOR',
            DESC = 'Enable debug readbacks')
        relative_std = aIn('RSTD', PREC = 2,
            DESC = 'IQ relative standard deviation')
        relative_std_abs = aIn('RSTD_ABS', PREC = 2,
            DESC = 'Magnitude relative standard deviation')
        Trigger('READ',
            Waveform('WFI', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL detector I'),
            Waveform('WFQ', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL detector Q'),
            Waveform('ANGLE', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL angle'),
            Waveform('MAG', TUNE_PLL_LENGTH, 'FLOAT',
                DESC = 'Tune PLL magnitude'),
            overflow('FIFO_OVF', 'Debug FIFO readout overrun'),
            relative_std,
            db_record('RSTD_DB', relative_std),
            relative_std_abs,
            db_record('RSTD_ABS_DB', relative_std_abs))
        boolOut('SELECT', 'IQ', 'CORDIC',
            DESC = 'Select captured readback values')

    # Filtered readbacks
    with name_prefix('FILT'):
        magnitude = aIn('MAG', 0, 1, PREC = 8,
            DESC = 'Filtered Tune PLL detector magnitude')
        polled_readbacks.extend([
            aIn('I', -1, 1, PREC = 8,
                DESC = 'Filtered Tune PLL detector I'),
            aIn('Q', -1, 1, PREC = 8,
                DESC = 'Filtered Tune PLL detector Q'),
            aIn('PHASE', -180, 180, PREC = 2, EGU = 'deg',
                DESC = 'Filtered Tune PLL phase offset'),
            magnitude,
            db_record('MAG_DB', magnitude, LOW = -16*6, LSV = 'MINOR'),
        ])

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
