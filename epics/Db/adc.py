# ADC waveforms

from common import *

import mms


adc_events = []

for a in axes('ADC'):
    WaveformOut('FILTER', ADC_TAPS, 'FLOAT',
        DESC = 'Input compensation filter')
    longOut('FILTER:DELAY', 0, 7, DESC = 'Compensation filter group delay')

    aOut('OVF_LIMIT', 0, 1, PREC = 4, DESC = 'Overflow limit threshold')
    aOut('EVENT_LIMIT', 0, 1, PREC = 4, DESC = 'ADC min/max event threshold')
    boolOut('LOOPBACK', 'Normal', 'Loopback', OSV = 'MAJOR', VAL = 0,
        DESC = 'Enable DAC -> ADC loopback')

    boolOut('MMS_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of min/max/sum data')
    boolOut('DRAM_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of memory data')

    adc_events.extend([
        overflow('INP_OVF', 'ADC input overflow'),
        overflow('FIR_OVF', 'ADC FIR overflow'),
        overflow('OVF', 'ADC overflow'),
        event('EVENT', 'ADC min/max event'),
    ])

    mms.mms_pvs('ADC')


with name_prefix('ADC'):
    Action('EVENTS',
        SCAN = '.1 second',
        FLNK = create_fanout('EVENTS:FAN', *adc_events),
        DESC = 'ADC event detect scan')
