# Min/Max/Sum PVs

from common import *

def mms_waveform(name, desc, **kargs):
    return Waveform(name, BUNCHES_PER_TURN, 'FLOAT', DESC = desc, **kargs)


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
    ]
    Action('SCAN',
        SCAN = '.2 second',
        FLNK = create_fanout('FAN', *pvs),
        DESC = '%s min/max scanning' % source)

    # Archival PVs for standard deviation
    Trigger('ARCHIVE',
        mms_waveform('STD_MEAN_WF', 'Power average of standard deviation'),
        mms_waveform('STD_MIN_WF', 'Minimum of standard deviation'),
        mms_waveform('STD_MAX_WF', 'Maximum of standard deviation'))


def mms_pvs(source):
    with name_prefix('MMS'):
        do_mms_pvs(source)
