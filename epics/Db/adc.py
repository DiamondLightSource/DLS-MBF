# PVs for ADC interface

from common import *
from system import add_aggregate

import mms


adc_events = []

for a in axes('ADC'):
    WaveformOut('FILTER', ADC_TAPS, 'FLOAT',
        DESC = 'Input compensation filter')

    aOut('OVF_LIMIT', 0, 1, PREC = 4, DESC = 'Overflow limit threshold')
    aOut('EVENT_LIMIT', 0, 2, PREC = 4, DESC = 'ADC min/max event threshold')
    loopback = boolOut('LOOPBACK', 'Normal', 'Loopback', OSV = 'MAJOR', VAL = 0,
        DESC = 'Enable DAC -> ADC loopback')

    mbbOut('MMS_SOURCE', 'Before FIR', 'After FIR', 'Fill Reject',
        DESC = 'Source of min/max/sum data')
    mbbOut('DRAM_SOURCE', 'Before FIR', 'After FIR', 'Fill Reject',
        DESC = 'Source of memory data')
    longOut('REJECT_SHIFT', 0, 15, DESC = 'Reject filter counter shift')

    overflows = [
        overflow('INP_OVF', 'ADC input overflow'),
        overflow('FIR_OVF', 'ADC FIR overflow'),]
    ovf = overflow('OVF', 'ADC overflow')   # Aggregates INP_OVF and FIR_OVF
    adc_events.extend(overflows)
    adc_events.append(ovf)
    adc_events.append(event('EVENT', 'ADC min/max event'))

    if not lmbf_mode or a == AXIS0:
        # In LMBF mode we only aggregate the channel 0 PVs
        add_aggregate(a, loopback, ovf)

    mms.mms_pvs('ADC')


with name_prefix('ADC'):
    Action('EVENTS',
        SCAN = '.1 second',
        FLNK = create_fanout('EVENTS:FAN', *adc_events),
        DESC = 'ADC event detect scan')


if lmbf_mode:
    for a in axes('ADC', lmbf_mode):
        # Create bunch phase and magnitude measurement PVs derived from MMS
        # waveforms.
        phase_pvs = [
            mms.mms_waveform('MAGNITUDE', 'Bunch magnitude'),
            mms.mms_waveform('PHASE', 'Bunch phase', EGU = 'deg'),
            aIn('PHASE_MEAN', -180, 180, EGU = 'deg', PREC = 2,
                DESC = 'Average bunch phase'),
            aIn('MAGNITUDE_MEAN', 0, 1, PREC = 6,
                DESC = 'Average bunch magnitude'),
        ]
        Action('TRIGGER',
            SCAN = '.2 second',
            FLNK = create_fanout('FAN', *phase_pvs),
            DESC = 'Update bunch phase')
        aOut('THRESHOLD', 0, 1, PREC = 3, DESC = 'Magnitude phase threshold')
