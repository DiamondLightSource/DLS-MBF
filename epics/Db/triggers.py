# Triggering control

from common import *

trigger_sources = [
    ('SOFT', 'Soft trigger'),
    ('EXT',  'External trigger'),
    ('PM',   'Postmortem trigger'),
    ('ADC0', '%s ADC event' % AXIS0),
    ('ADC1', '%s ADC event' % AXIS1),
    ('DAC0', '%s DAC event' % AXIS0),
    ('DAC1', '%s DAC event' % AXIS1),
    ('SEQ0', '%s SEQ event' % AXIS0),
    ('SEQ1', '%s SEQ event' % AXIS1),
]

def event_set(suffix, suffix_desc):
    return [
        event('%s:%s' % (source, suffix), '%s %s' % (desc, suffix_desc))
        for source, desc in trigger_sources]


def target_pvs(prefix):
    with name_prefix(prefix):
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
        modes = ['One Shot', 'Rearm', 'Shared']
        if prefix == 'SEQ':
            # Only enable special "Free Run" mode for SEQ triggers
            modes.append('Free Run')
        mbbOut('MODE', *modes, DESC = 'Arming mode')
        mbbIn('STATUS', 'Idle', 'Armed', 'Busy', 'Locked',
            SCAN = 'I/O Intr',
            DESC = 'Trigger target status')


for a in axes('TRG', lmbf_mode):
    target_pvs('SEQ')


with name_prefix('TRG'):
    target_pvs('MEM')

    events_in = event_set('IN', 'input')
    events_in.append(event('BLNK:IN', 'Blanking event'))
    Action('IN',
        SCAN = '.2 second', FLNK = create_fanout('IN:FAN', *events_in),
        DESC = 'Scan input events')
    Action('SOFT', DESC = 'Soft trigger')

    Action('ARM', DESC = 'Arm all shared targets')
    Action('DISARM', DESC = 'Disarm all shared targets')

    boolOut('MODE', 'One Shot', 'Rearm', DESC = 'Shared trigger mode')
    mbbIn('STATUS', 'Idle', 'Armed', 'Locked', 'Busy', 'Mixed', 'Invalid',
        SCAN = 'I/O Intr',
        DESC = 'Shared trigger target status')
    stringIn('SHARED', SCAN = 'I/O Intr', DESC = 'List of shared targets')

    longOut('BLANKING', 0, 2**16-1, EGU = 'turns', DESC = 'Blanking duration')
