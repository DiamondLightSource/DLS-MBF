# Swept NCOs

import sys

from common import *

def create_gain_controls(title):
    c_title = title.capitalize()
    boolOut('ENABLE', 'Off', 'On', DESC = 'Enable %s output' % title)
    aOut('GAIN_SCALAR', 0, 1, PREC = 5, DESC = 'Set %s gain' % title)
    # The following two PVs are slaved off GAIN_SCALAR above, so must not be
    # processed at startup.  The GAIN mbbo record is for compatibility.
    aOut('GAIN_DB', EGU = 'dB', PREC = 2,
        PINI = 'NO', DESC = 'Set %s gain dB' % title)
    mbbOut('GAIN', *dBrange(15, -6) + ['Other'],
        PINI = 'NO', DESC = 'Select %s gain' % c_title)


for nco in [1, 2]:
    for a in axes('NCO%d' % nco, lmbf_mode):
        aOut('FREQ',
            None, None, 'tune', 5,
            DESC = 'Configure NCO with fixed frequency')
        aOut('FIXED_FREQ',
            None, None, 'tune', 5,
            DESC = 'Fixed frequency value')
        Action('SET_FIXED_FREQ', DESC = 'Configure a fixed frequency NCO')

        aOut('START_FREQ',
            None, None, 'tune', 5,
            DESC = 'Sweep NCO start frequency')
        aOut('STEP_FREQ',
            None, None, 'tune', 7,
            DESC = 'Sweep NCO step frequency')
        aOut('END_FREQ',
            None, None, 'tune', 5,
            PINI = 'NO', DESC = 'Sweep NCO end frequency')

        longOut('DWELL', 1, 1<<16,
            EGU = 'turns', DESC = 'Sweep dwell time')
        longOut('COUNT', 1, 1<<16,
            DESC = 'Sweep count')
        longOut('REPEAT:COUNT', DESC = 'Sweep repetition count')
        boolOut('REPEAT:MODE',
            'Count', 'Infinite',
            DESC = 'Sweep repetition mode')
        Action('REPEAT:START', DESC = 'Starts a frequency sweep repetition')
        Action('REPEAT:RESET',
            DESC = 'Halt frequency sweep in progress')

        longIn('REPEAT:COUNT',
            SCAN = '.1 second',
            DESC = 'Current Sweep repetition count')

        boolOut('TUNE_PLL', 'Ignore', 'Follow', DESC = 'Track tune PLL')
        create_gain_controls('fixed nco')
