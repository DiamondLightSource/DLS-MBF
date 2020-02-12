# Fixed frequency NCOs

import sys

from common import *

def create_gain_controls(title):
    c_title = title.capitalize()
    mbbOut('GAIN', DESC = 'Select %s gain' % c_title,
        *dBrange(15, -6) + ['Other'])
    boolOut('ENABLE', 'Off', 'On', DESC = 'Enable %s output' % title)
    aOut('GAIN_DB', EGU = 'dB', PREC = 2, DESC = 'Set %s gain dB' % title)
    aOut('GAIN_SCALAR', 0, 1, PREC = 5, DESC = 'Set %s gain' % title)


for nco in [1, 2]:
    for a in axes('NCO%d' % nco, lmbf_mode):
        aOut('FREQ', PREC = 5, DESC = 'Fixed NCO frequency')
        boolOut('TUNE_PLL', 'Ignore', 'Follow', DESC = 'Track tune PLL')
        create_gain_controls('fixed nco')
