# Sequencer and NCO

from common import *


SUPER_SEQ_STATES = 1024


# Used for converting turns into duration.
REVOLUTION_FREQUENCY = \
    Parameter('REVOLUTION_FREQUENCY', 'Machine revolution frequency in Hz')


def bank_pvs(update_count):
    # END_FREQ is internally updated whenever START_FREQ, STEP_FREQ, or COUNT
    # changes, however when COUNT changes we process the change internally.
    update_end = Action('UPDATE_END', DESC = 'Update end frequency')

    aOut('START_FREQ',
        None, None, 'tune', 5,
        FLNK = update_end, DESC = 'Sweep NCO start frequency')
    aOut('STEP_FREQ',
        None, None, 'tune', 7,
        FLNK = update_end, DESC = 'Sweep NCO step frequency')
    longOut('DWELL', 1, 1<<16,
        FLNK = update_count, EGU = 'turns', DESC = 'Sweep dwell time')
    longOut('COUNT', 1, 1<<12,
        FLNK = update_count, DESC = 'Sweep count')
    longOut('HOLDOFF', 0, 65535,
        FLNK = update_count, DESC = 'Detector holdoff')
    mbbOut('BANK', 'Bank 0', 'Bank 1', 'Bank 2', 'Bank 3',
        DESC = 'Bunch bank selection')
    mbbOut('GAIN', DESC = 'Sweep NCO gain', *dBrange(16, -6))
    boolOut('ENABLE', 'Off', 'On', DESC = 'Enable Sweep NCO')
    boolOut('ENWIN', 'Disabled', 'Windowed',
        DESC = 'Enable detector window')
    boolOut('CAPTURE', 'Discard', 'Capture',
        FLNK = update_count, DESC = 'Enable data capture')
    boolOut('BLANK', 'Off', 'Blanking',
        DESC = 'Detector blanking control')

    # This fellow is treated a little differently and is processed
    # internally.
    aOut('END_FREQ',
        None, None, 'tune', 5,
        PINI = 'NO', DESC = 'Sweep NCO end frequency')


# The super sequencer is controlled by two settings: the OFFSET waveform which
# is added to the frequency in each sequencer state, and the COUNT which
# determines the number of super sequencer states used.
def super_pvs():
    super_count = longOut('COUNT', 1, SUPER_SEQ_STATES,
        DESC = 'Super sequencer count')

    offsets = WaveformOut('OFFSET', SUPER_SEQ_STATES, 'DOUBLE',
        PREC = 5,
        DESC = 'Frequency offsets for super sequencer')
    Action('RESET', FLNK = offsets,
        DESC = 'Reset super sequencer offsets')

    return super_count


# These PVs are processed every time any of the sequencer timing parameters
# change, returns PV to be updated when any parameter changes.
def count_pvs(super_count):
    duration = longIn('DURATION',
        EGU = 'turns', DESC = 'Raw capture duration')
    length = longIn('LENGTH', DESC = 'Sequencer capture count')
    super_duration = records.calc('TOTAL:DURATION',
        CALC = 'A*B', INPA = super_count, INPB = duration,
        EGU = 'turns', DESC = 'Super sequence raw capture duration')

    # The grand total PVs are computed from all the parameters above, and need
    # to be processed whenever any relevant sequencer or super sequencer
    # parameter changes.
    total_fanout = create_fanout('TOTAL:FAN',
        super_duration,
        records.calc('TOTAL:DURATION:S',
            CALC = 'A/B',
            INPA = super_duration, INPB = REVOLUTION_FREQUENCY,
            PREC = 3, EGU = 's', DESC = 'Super capture duration'),
        records.calc('TOTAL:LENGTH',
            CALC = 'A*B', INPA = super_count, INPB = length,
            DESC = 'Super sequencer capture count'))
    super_count.FLNK = total_fanout

    # These PVs count the duration and samples from a single sequencer program.
    count_fanout = create_fanout('COUNT:FAN',
        duration,
        length,
        records.calc('DURATION:S',
            CALC = 'A/B',
            INPA = duration, INPB = REVOLUTION_FREQUENCY,
            PREC = 3, EGU = 's',
            DESC = 'Capture duration'),
        total_fanout)

    # This PV will be processed when any sequencer PV which affects the duration
    # and sample count is updated.  The duration and length are then updated and
    # all the PVs defined above are updated.
    return Action('UPDATE_COUNT',
        FLNK = count_fanout, DESC = 'Internal sequencer state update')


# The sequencer has eight possible states, however state 0 has somewhat
# different behaviour from the remaining 7.
def sequencer_pvs():
    # Super-sequencer control and state.  Returns PV controlling number of super
    # sequencer states
    super_count = with_name_prefix('SUPER', super_pvs)

    # This PV needs to be updated by any parameter which changes sequencer
    # duration or capture count.
    update_count = count_pvs(super_count)

    # This is the only valid control in state 0.
    mbbOut('0:BANK', 'Bank 0', 'Bank 1', 'Bank 2', 'Bank 3',
        DESC = 'Bunch bank selection')

    # PVs for the 7 programmable banks
    for state in range(1, 8):
        with_name_prefix('%d' % state, bank_pvs, update_count)

    # Number of sequencer states when triggered
    longOut('PC', 1, 7, FLNK = update_count, DESC = 'Sequencer PC')

    Action('RESET', DESC = 'Halt sequencer if busy')
    longOut('TRIGGER', 0, 7, DESC = 'State to generate sequencer trigger')

    Action('STATUS:READ',
        SCAN = '.1 second',
        FLNK = create_fanout('STATUS:FAN',
            longIn('PC', DESC = 'Current sequencer state'),
            longIn('SUPER:COUNT', 0, SUPER_SEQ_STATES,
                DESC = 'Current super sequencer count'),
            boolIn('BUSY', 'Idle', 'Busy', OSV = 'MINOR')))



for_channels('SEQ', sequencer_pvs)
