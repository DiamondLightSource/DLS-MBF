# Min/Max/Sum PVs

from common import *

def mms_waveform(name, desc):
    return Waveform(name, BUNCHES_PER_TURN, 'FLOAT', DESC = desc)


def do_mms_pvs(source):
    pvs = [
        mms_waveform('MIN', 'Min %s values per bunch' % source),
        mms_waveform('MAX', 'Max %s values per bunch' % source),
        mms_waveform('DELTA', 'Max %s values per bunch' % source),
        mms_waveform('MEAN', 'Mean %s values per bunch' % source),
        mms_waveform('STD', '%s standard deviation per bunch' % source),
        longIn('TURNS', DESC = 'Number of turns in this sample'),
        overflow('TURN_OVF', 'MMS turn counter overflow'),
        overflow('SUM_OVF', 'MMS accumulator overflow'),
        overflow('SUM2_OVF', 'MMS squares accumulator overflow'),
    ]
    Action('SCAN',
        SCAN = '.2 second',
        FLNK = create_fanout('FAN', *pvs),
        DESC = '%s min/max scanning' % source)


def mms_pvs(source):
    with_name_prefix('MMS', do_mms_pvs, source)
