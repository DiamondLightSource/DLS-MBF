# PVs for DAC interface

from common import *
from system import add_aggregate

import mms


dac_events = []

for a in axes('DAC'):
    WaveformOut('FILTER', DAC_TAPS, 'FLOAT',
        DESC = 'Output preemphasis filter')
    longOut('FILTER:DELAY', 0, 7, DESC = 'Preemphasis filter group delay')

    longOut('DELAY', DESC = 'DAC output delay')

    enable = boolOut('ENABLE', 'Off', 'On',
        ZSV = 'MAJOR', DESC = 'DAC output enable')
    boolOut('MMS_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of min/max/sum data')
    boolOut('DRAM_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of memory data')

    overflows = [
        overflow('BUN_OVF', 'Bunch FIR overflow'),
        overflow('MUX_OVF', 'DAC output overflow'),
        overflow('FIR_OVF', 'DAC FIR overflow'),]
    ovf = overflow('OVF', 'DAC overflow')   # Aggregates BUN, MUX, FIR _OVF
    dac_events.extend(overflows)
    dac_events.append(ovf)

    add_aggregate(a, ovf, enable)

    mms.mms_pvs('DAC')


with name_prefix('DAC'):
    Action('EVENTS',
        SCAN = '.1 second',
        FLNK = create_fanout('SCAN:FAN', *dac_events),
        DESC = 'DAC event detect scan')
