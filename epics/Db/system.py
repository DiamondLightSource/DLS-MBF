# System level PVs

import sys

from common import *


# System identification PVs
stringIn('VERSION', PINI = 'YES', DESC = 'Software version')
stringIn('FPGA_VERSION', PINI = 'YES', DESC = 'Firmware version')
Waveform('HOSTNAME', 256,
    PINI = 'YES', FTVL = 'CHAR', DESC = 'Host name of LMBF IOC')
longIn('SOCKET', PINI = 'YES', DESC = 'Socket number for data server')
stringIn('DEVICE', PINI = 'YES', DESC = 'Name of AMC525 device')
boolIn('MODE', 'TMBF', 'LMBF', PINI = 'YES', DESC = 'Operational mode')

# A variety of constants
records.longin('BUNCHES', VAL = BUNCHES_PER_TURN, PINI = 'YES',
    DESC = 'Number of bunches per revolution')
records.longin('ADC_TAPS', VAL = ADC_TAPS, PINI = 'YES',
    DESC = 'Length of ADC compensation filter')
records.longin('DAC_TAPS', VAL = DAC_TAPS, PINI = 'YES',
    DESC = 'Length of DAC pre-emphasis filter')
records.longin('BUNCH_TAPS', VAL = BUNCH_TAPS, PINI = 'YES',
    DESC = 'Length of bunch-by-bunch feedback filter')

# Names of the two axes
records.stringin('AXIS0', VAL = CHANNEL0, PINI = 'YES',
    DESC = 'Name of first axis')
records.stringin('AXIS1', VAL = CHANNEL1, PINI = 'YES',
    DESC = 'Name of second axis')


for c in channels('NCO', lmbf_mode):
    aOut('FREQ', PREC = 5, DESC = 'Fixed NCO frequency')
    mbbOut('GAIN', DESC = 'Fixed NCO gain', *dBrange(16, -6))
    boolOut('ENABLE', 'Off', 'On', DESC = 'Enable fixed NCO output')


def clock_status(name, desc):
    return boolIn(name, 'Unlocked', 'Locked', ZSV = 'MAJOR', DESC = desc)


with name_prefix('STA'):
    Action('POLL',
        SCAN = '.2 second', FLNK = create_fanout('FAN',
            clock_status('CLOCK', 'ADC clock status'),
            clock_status('VCO', 'VCO clock status'),
            clock_status('VCXO', 'VCXO clock status')))
