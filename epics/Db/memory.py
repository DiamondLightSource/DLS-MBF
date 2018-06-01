# PVs for fast memory readout
#
# Unlike most other parts of the system, the memory interface is not split into
# axes.

from common import *


def memory_wf(name, desc):
    return Waveform(name, MEMORY_READOUT_LENGTH, 'SHORT', DESC = desc)

# Map of possible memory readout selection options
select_options = [
    'ADC0/ADC1',
    'ADC0/FIR1',
    'ADC0/DAC1',
    'ADC0/FIR0',
    'FIR0/ADC1',
    'FIR0/FIR1',
    'FIR0/DAC1',
    'FIR0/DAC0',
    'DAC0/ADC1',
    'DAC0/FIR1',
    'DAC0/DAC1',
    'ADC0/DAC0',
    'ADC1/FIR1',
    'FIR1/DAC1',
    'ADC1/DAC1',
]

# Selector for single channel
select_channel = [
    'ADC0',
    'FIR0',
    'DAC0',
    'ADC1',
    'FIR1',
    'DAC1',
]


with name_prefix('MEM'):
    Trigger('READOUT',
        memory_wf('WF0', 'Capture waveform #0'),
        memory_wf('WF1', 'Capture waveform #1'))

    # Select capture configuration.  Because SELECT is the master controller
    # here, we don't want SEL0,1 to process during startup.
    mbbOut('SELECT', DESC = 'Control memory capture selection', *select_options)
    mbbOut('SEL0', PINI = 'NO',
        DESC = 'Channel 0 capture selection', *select_channel)
    mbbOut('SEL1', PINI = 'NO',
        DESC = 'Channel 1 capture selection', *select_channel)

    # FIR gain control
    write_gain = Action('WRITE_GAIN', DESC = 'Write FIR gain')
    boolOut('FIR0_GAIN', '+54dB', '0dB',
        FLNK = write_gain,
        DESC = 'FIR 0 capture gain')
    boolOut('FIR1_GAIN', '+54dB', '0dB',
        FLNK = write_gain,
        DESC = 'FIR 1 capture gain')
    Action('READ_OVF',
        SCAN = '.2 second',
        FLNK = create_fanout('READ:FAN',
            overflow('FIR0_OVF', 'FIR 0 capture will overflow'),
            overflow('FIR1_OVF', 'FIR 1 capture will overflow')),
        DESC = 'Poll overflow events')

    longOut('OFFSET', EGU = 'turns', DESC = 'Offset of readout')

    # Capture control
    Action('CAPTURE', DESC = 'Untriggered immediate capture')
    boolIn('BUSY', 'Ready', 'Busy',
        OSV = 'MINOR', SCAN = 'I/O Intr', DESC = 'Capture status')
    mbbOut('RUNOUT', '12.5%', '25%', '50%', '75%', '99.5%',
        DESC = 'Post trigger capture count')
