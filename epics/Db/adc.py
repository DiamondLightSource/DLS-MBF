# ADC waveforms

from common import *

import mms


ADC_TAPS = Parameter('ADC_TAPS', 'Number of taps in ADC filter')


adc_events = []
def adc_pvs():
    WaveformOut('FILTER', ADC_TAPS, 'FLOAT',
        DESC = 'Input compensation filter')

    aOut('OVF_LIMIT', 0, 1, PREC = 4, DESC = 'Overflow limit threshold')
    aOut('EVENT_LIMIT', 0, 1, PREC = 4, DESC = 'ADC min/max event threshold')

    adc_events.extend([
        overflow('INPUT_OVF', 'ADC input overflow'),
        overflow('FIR_OVF', 'ADC FIR overflow'),
        overflow('MMS_OVF', 'Overflow in MMS'),
        event('EVENT', 'ADC min/max event'),
    ])

    Action('ARM', DESC = 'Arm ADC min/max event')

    mms.mms_pvs('ADC')


for_channels('ADC', adc_pvs)


Action('ADC:EVENTS',
    SCAN = '.1 second',
    FLNK = create_fanout('ADC:SCAN:FAN', *adc_events),
    DESC = 'ADC event detect scan')
