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


def destination_pvs():
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

    longOut('DELAY', 0, 2**24 - 1, DESC = 'Trigger delay')

    Action('ARM', DESC = 'Arm trigger')
    Action('DISARM', DESC = 'Disarm trigger')
    mbbOut('MODE', 'One Shot', 'Rearm', 'Shared', DESC = 'Arming mode')
    mbbIn('STATUS', 'Idle', 'Armed', 'Busy',
        SCAN = 'I/O Intr',
        DESC = 'Trigger destination status')


def trigger_channel_pvs():
    with_name_prefix('SEQ', destination_pvs)
    longOut('BLANKING', 0, 2**16-1, EGU = 'turns', DESC = 'Blanking duration')

def trigger_common_pvs():
    with_name_prefix('MEM', destination_pvs)

    events_in = event_set('IN', 'input')
    events_in.append(event('BLNK:IN', 'Blanking event'))
    Action('IN',
        SCAN = '.2 second', FLNK = create_fanout('IN:FAN', *events_in),
        DESC = 'Scan input events')
    Action('SOFT', DESC = 'Soft trigger')

    Action('ARM', DESC = 'Arm all shared destinations')
    Action('DISARM', DESC = 'Disarm all shared destinations')

    # Temporary
    Action('POLL', SCAN = '.1 second')


for_channels('TRG', trigger_channel_pvs)
with_name_prefix('TRG', trigger_common_pvs)
