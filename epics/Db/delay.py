# PVs for fine delay

from common import *


def dac_delays():
    # Fine delay control with readback
    fine_delay = longOut('FINE_DELAY', 0, 23,
        DESC = 'DAC clock fine delay')

    # Simlarly coarse delay control with readback
    coarse_delay = longOut('COARSE_DELAY',
        DESC = 'DAC clock coarse delay')
    Action('STEP', FLNK = coarse_delay,
        DESC = 'Advance coarse delay')
    Action('RESET', FLNK = coarse_delay,
        DESC = 'Reset coarse delay')

    # Compute the overall delay
    delay_ps = records.calc('DELAY_PS',
        EGU  = 'ps', CALC = 'A*C+D*E',
        INPA = coarse_delay,
        INPC = step_size,
        INPD = fine_delay,
        INPE = 25)
    coarse_delay.FLNK = delay_ps
    fine_delay.FLNK = delay_ps

    # Monitor of DAC FIFO
    longIn('FIFO', SCAN = '.2 second', DESC = 'DAC output FIFO depth')


def turn_sync():
    Action('SYNC', DESC = 'Synchronise turn clock')

    turn_delay = longOut('DELAY', 0, 31, DESC = 'Turn clock input delay')
    turn_delay.FLNK = records.calc('DELAY_PS',
        EGU  = 'ps', CALC = 'A*B',   INPA = turn_delay,  INPB = 78.125)

    turn_count = longIn('TURNS', DESC = 'Turns sampled')
    error_count = longIn('ERRORS',
        HIGH = 1, HSV = 'MINOR', DESC = 'Turn clock errors')
    turn_events = [
        mbbIn('STATUS',
            ('Armed', 0, 'MINOR'),
            ('Synced', 1),
            ('Sync Errors', 2, 'MAJOR'),
            DESC = 'Turn clock status'),
        turn_count,
        error_count,
        records.calc('RATE',
            CALC = '100*A/B', INPA = MS(error_count), INPB = turn_count,
            PREC = 3, EGU = '%',
            DESC = 'Clock error rate'),
    ]
    longOut('OFFSET', DESC = 'Turn clock offset')
    Action('POLL',
        SCAN = '.2 second', FLNK = create_fanout('FAN', *turn_events),
        DESC = 'Update turn status')


with name_prefix('DLY'):
    step_size = aIn('STEP_SIZE', PINI = 'YES', EGU = 'ps',
        DESC = 'Duration of coarse step')

    with name_prefix('DAC'):
        dac_delays()

    with name_prefix('TURN'):
        turn_sync()
