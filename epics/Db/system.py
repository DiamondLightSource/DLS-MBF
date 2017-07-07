# System level PVs

import sys

from common import *


# Version string from build
stringIn('VERSION', PINI = 'YES', DESC = 'LMBF version')
stringIn('FPGA_VERSION', PINI = 'YES', DESC = 'LMBF version')
stringIn('HOSTNAME', PINI = 'YES', DESC = 'Host name of LMBF IOC')

records.longin('BUNCHES', VAL = BUNCHES_PER_TURN, PINI = 'YES')

def channel_pvs():
    aOut('FREQ', PREC = 5, DESC = 'Fixed NCO frequency')
    mbbOut('GAIN', DESC = 'Fixed NCO gain', *dBrange(15, -6) + ['Off'])

for_channels('NCO', channel_pvs)
