# Min/Max/Sum PVs

from common import *

def mms_waveform(name, desc):
    return Waveform(name, BUNCHES_PER_TURN, 'FLOAT', DESC = desc)


def do_mms_pvs(source):
    std_mean = aIn('STD_MEAN', 0, 1, PREC = 6,
        DESC = 'Mean MMS standard deviation')
    std_mean_db = records.calc('STD_MEAN_DB',
        CALC = '20*LOG(A)', INPA = std_mean,
        EGU = 'dB', PREC = 1,
        DESC = 'Mean MMS deviation in dB')
    pvs = [
        mms_waveform('MIN', 'Min %s values per bunch' % source),
        mms_waveform('MAX', 'Max %s values per bunch' % source),
        mms_waveform('DELTA', 'Max %s values per bunch' % source),
        mms_waveform('MEAN', 'Mean %s values per bunch' % source),
        mms_waveform('STD', '%s standard deviation per bunch' % source),
        aIn('MEAN_MEAN', -1, 1, PREC = 6, DESC = 'Mean position'),
        std_mean,
        std_mean_db,
        longIn('TURNS', DESC = 'Number of turns in this sample'),
        mbbIn('OVERFLOW',
            ('Ok',                       0, 'NO_ALARM'),
            ('Turns Overflow',           1, 'MAJOR'),
            ('Sum Overflow',             2, 'MAJOR'),
            ('Turns+Sum Overflow',       3, 'MAJOR'),
            ('Sum2 Overflow',            4, 'MAJOR'),
            ('Turns+Sum2 Overflow',      5, 'MAJOR'),
            ('Sum+Sum2 Overflow',        6, 'MAJOR'),
            ('Turns+Sum+Sum2 Overflow',  7, 'MAJOR'),
            DESC = 'MMS capture overflow status'),
    ]
    Action('SCAN',
        SCAN = '.2 second',
        FLNK = create_fanout('FAN', *pvs),
        DESC = '%s min/max scanning' % source)

    # If an MMS fault is detected this will reset
    boolOut('RESET_FAULT', DESC = 'Resets MMS fault accumulation')


def mms_pvs(source):
    with name_prefix('MMS'):
        do_mms_pvs(source)
