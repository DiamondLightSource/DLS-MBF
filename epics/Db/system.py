# System level PVs

import sys

from common import *


# Version string from build
stringIn('VERSION', PINI = 'YES', DESC = 'LMBF version')
stringIn('FPGA_VERSION', PINI = 'YES', DESC = 'LMBF version')
stringIn('HOSTNAME', PINI = 'YES', DESC = 'Host name of LMBF IOC')

boolIn('MODE', 'TMBF', 'LMBF', PINI = 'YES', DESC = 'Operational mode')

# A variety of constants
records.longin('BUNCHES', VAL = BUNCHES_PER_TURN, PINI = 'YES')
records.longin('ADC_TAPS', VAL = ADC_TAPS, PINI = 'YES')
records.longin('DAC_TAPS', VAL = DAC_TAPS, PINI = 'YES')
records.longin('BUNCH_TAPS', VAL = BUNCH_TAPS, PINI = 'YES')

# Names of the two axes
records.stringin('AXIS0', VAL = CHANNEL0, PINI = 'YES')
records.stringin('AXIS1', VAL = CHANNEL1, PINI = 'YES')


def channel_pvs():
    aOut('FREQ', PREC = 5, DESC = 'Fixed NCO frequency')
    mbbOut('GAIN', DESC = 'Fixed NCO gain', *dBrange(16, -6))
    boolOut('ENABLE', 'Off', 'On', DESC = 'Enable fixed NCO output')

for_channels('NCO', channel_pvs)
