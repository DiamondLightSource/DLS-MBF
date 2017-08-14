# ADC waveforms

from common import *

import mms


adc_events = []
def adc_pvs():
    WaveformOut('FILTER', ADC_TAPS, 'FLOAT',
        DESC = 'Input compensation filter')
    longOut('FILTER:DELAY', 0, 7, DESC = 'Compensation filter group delay')

    aOut('OVF_LIMIT', 0, 1, PREC = 4, DESC = 'Overflow limit threshold')
    aOut('EVENT_LIMIT', 0, 1, PREC = 4, DESC = 'ADC min/max event threshold')
    boolOut('LOOPBACK', 'Normal', 'Loopback', OSV = 'MAJOR', VAL = 0,
        DESC = 'Enable DAC -> ADC loopback')

    adc_events.extend([
        overflow('INPUT_OVF', 'ADC input overflow'),
        overflow('FIR_OVF', 'ADC FIR overflow'),
        overflow('MMS_OVF', 'Overflow in MMS'),
        event('EVENT', 'ADC min/max event'),
    ])

    boolOut('MMS_SOURCE', 'Before FIR', 'After FIR',
        DESC = 'Source of min/max/sum data')
    mms.mms_pvs('ADC')


for_channels('ADC', adc_pvs)


Action('ADC:EVENTS',
    SCAN = '.1 second',
    FLNK = create_fanout('ADC:SCAN:FAN', *adc_events),
    DESC = 'ADC event detect scan')
