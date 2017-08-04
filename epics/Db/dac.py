# PVs for DAC interface

from common import *

import mms


dac_events = []
def dac_pvs():
    WaveformOut('FILTER', DAC_TAPS, 'FLOAT',
        DESC = 'Output preemphasis filter')

    longOut('DELAY', DESC = 'DAC output delay')

    boolOut('ENABLE', 'Off', 'On', ZSV = 'MAJOR', DESC = 'DAC output enable')
    boolOut('MMS_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of min/max/sum data')
    boolOut('DRAM_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of memory data')

    dac_events.extend([
        overflow('BUN_OVF', 'Bunch FIR overflow'),
        overflow('MUX_OVF', 'DAC output overflow'),
        overflow('FIR_OVF', 'DAC FIR overflow'),
        overflow('MMS_OVF', 'Overflow in MMS'),
    ])

    mms.mms_pvs('DAC')

for_channels('DAC', dac_pvs)

Action('DAC:EVENTS',
    SCAN = '.1 second',
    FLNK = create_fanout('DAC:SCAN:FAN', *dac_events),
    DESC = 'DAC event detect scan')
