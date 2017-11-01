# Triggering control

from common import *

trigger_sources = [
    ('SOFT', 'Soft trigger'),
    ('EXT',  'External trigger'),
    ('PM',   'Postmortem trigger'),
    ('ADC0', '%s ADC event' % CHANNEL0),
    ('ADC1', '%s ADC event' % CHANNEL1),
    ('SEQ0', '%s SEQ event' % CHANNEL0),
    ('SEQ1', '%s SEQ event' % CHANNEL1),
]

def event_set(suffix, suffix_desc):
    return [
        event('%s:%s' % (source, suffix), '%s %s' % (desc, suffix_desc))
        for source, desc in trigger_sources]


def target_pvs():
    source_events = event_set('HIT', 'source')
    boolIn('HIT',
        FLNK = create_fanout('HIT:FAN', *source_events),
        SCAN = 'I/O Intr',
        DESC = 'Update source events')

    write_en = Action('EN', DESC = 'Write enables')
    write_bl = Action('BL', DESC = 'Write blanking')
    for source, desc in trigger_sources:
        boolOut('%s:EN' % source, 'Ignore', 'Enable',
            FLNK = write_en,
            DESC = 'Enable %s input' % desc)
        boolOut('%s:BL' % source, 'All', 'Blanking',
            FLNK = write_bl,
            DESC = 'Enable blanking for trigger source')

    longOut('DELAY', 0, 2**16 - 1, DESC = 'Trigger delay')

    Action('ARM', DESC = 'Arm trigger')
    Action('DISARM', DESC = 'Disarm trigger')
    mbbOut('MODE', 'One Shot', 'Rearm', 'Shared', DESC = 'Arming mode')
    mbbIn('STATUS', 'Idle', 'Armed', 'Busy',
        SCAN = 'I/O Intr',
        DESC = 'Trigger target status')


def trigger_channel_pvs():
    with name_prefix('SEQ'):
        target_pvs()
    longOut('BLANKING', 0, 2**16-1, EGU = 'turns', DESC = 'Blanking duration')

    longOut('TURN:OFFSET', DESC = 'Turn clock offset')


def turn_pvs():
    Action('SYNC', DESC = 'Synchronise turn clock')
    longOut('DELAY', 0, 31, DESC = 'Turn clock input delay')
    turn_count = longIn('TURNS', DESC = 'Turns sampled')
    error_count = longIn('ERRORS',
        HIGH = 1, HSV = 'MINOR', DESC = 'Turn clock errors')
    turn_events = [
        mbbIn('STATUS', 'Unsynced', 'Armed', 'Synced',
            DESC = 'Turn clock synchronisation status'),
        turn_count,
        error_count,
        records.calc('RATE',
            CALC = '100*A/B', INPA = MS(error_count), INPB = turn_count,
            PREC = 3, EGU = '%',
            DESC = 'Clock error rate'),
    ]
    Action('POLL',
        SCAN = '.2 second', FLNK = create_fanout('FAN', *turn_events),
        DESC = 'Update turn status')


def trigger_common_pvs():
    with name_prefix('MEM'):
        target_pvs()

    events_in = event_set('IN', 'input')
    events_in.append(event('BLNK:IN', 'Blanking event'))
    Action('IN',
        SCAN = '.2 second', FLNK = create_fanout('IN:FAN', *events_in),
        DESC = 'Scan input events')
    Action('SOFT', DESC = 'Soft trigger')

    Action('ARM', DESC = 'Arm all shared targets')
    Action('DISARM', DESC = 'Disarm all shared targets')

    boolOut('MODE', 'One Shot', 'Rearm', DESC = 'Shared trigger mode')
    mbbIn('STATUS', 'Idle', 'Armed', 'Busy',
        SCAN = 'I/O Intr',
        DESC = 'Trigger target status')

    with name_prefix('TURN'):
        turn_pvs()


for c in channels('TRG'):
    trigger_channel_pvs()
with name_prefix('TRG'):
    trigger_common_pvs()
