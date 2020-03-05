# PVs for DAC interface

from common import *
from system import add_aggregate

import mms


dac_events = []

for a in axes('DAC'):
    WaveformOut('FILTER', DAC_TAPS, 'FLOAT',
        DESC = 'Output preemphasis filter')

    aOut('EVENT_LIMIT', 0, 2, PREC = 4, DESC = 'DAC min/max event threshold')
    longOut('DELAY', DESC = 'DAC output delay')

    enable = boolOut('ENABLE', 'Off', 'On',
        ZSV = 'MAJOR', DESC = 'DAC output enable')
    mbbOut('MMS_SOURCE', 'Before PEMPH', 'After PEMPH', 'Feedback',
        DESC = 'Source of min/max/sum data')
    boolOut('DRAM_SOURCE', 'Before PEMPH', 'After PEMPH',
        DESC = 'Source of memory data')

    overflows = [
        overflow('BUN_OVF', 'DAC bunch FIR clipping'),
        overflow('MUX_OVF', 'DAC output overflow'),
        overflow('FIR_OVF', 'DAC PEMPH overflow'),]
    ovf = overflow('OVF', 'DAC overflow')   # Aggregates BUN, MUX, FIR _OVF
    dac_events.extend(overflows)
    dac_events.append(ovf)

    dac_events.append(event('EVENT', 'DAC min/max event'))
    dac_events.append(overflow('MMS_OVF', 'DAC bunch FIR overflow'))

    add_aggregate(a, ovf, enable)

    mms.mms_pvs('DAC')


with name_prefix('DAC'):
    Action('EVENTS',
        SCAN = '.1 second',
        FLNK = create_fanout('EVENTS:FAN', *dac_events),
        DESC = 'DAC event detect scan')
