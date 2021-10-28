# System level PVs

import sys

from common import *


with name_prefix('INFO'):
    # System identification PVs
    stringIn('VERSION', PINI = 'YES', DESC = 'Software version')
    stringIn('GIT_VERSION', PINI = 'YES', DESC = 'Software git version')
    stringIn('FPGA_VERSION', PINI = 'YES', DESC = 'Firmware version')
    stringIn('FPGA_GIT_VERSION', PINI = 'YES', DESC = 'Firmware git version')
    longIn('FPGA_SEED', PINI = 'YES', DESC = 'Firmware build seed')
    stringIn('DRIVER_VERSION', PINI = 'YES', DESC = 'Kernel driver version')

    Waveform('HOSTNAME', 256,
        PINI = 'YES', FTVL = 'CHAR', DESC = 'Host name of MBF IOC')
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
    records.stringin('AXIS0', VAL = AXIS0, PINI = 'YES',
        DESC = 'Name of first axis')
    records.stringin('AXIS1', VAL = AXIS1, PINI = 'YES',
        DESC = 'Name of second axis')


def clock_status(name, desc):
    return boolIn(name, 'Unlocked', 'Locked', ZSV = 'MAJOR', DESC = desc)

def vco_status(name, desc):
    return mbbIn(name,
        ('Unlocked', 'MAJOR'), 'Locked', 'Passthrough', DESC = desc)

with name_prefix('STA'):
    Action('POLL',
        DESC = 'Poll system status',
        SCAN = '.2 second', FLNK = create_fanout('FAN',
            clock_status('CLOCK', 'ADC clock status'),
            vco_status('VCO', 'VCO clock status'),
            vco_status('VCXO', 'VCXO clock status')))


# Functions for aggregate severity support
aggregate_pvs = {}
def add_aggregate(axis, *pvs):
    if lmbf_mode:
        axis = AXIS01
    aggregate_pvs.setdefault(axis, []).extend(pvs)

def create_aggregate_pvs():
    for axis in axes('STA', lmbf_mode):
        pvs = map(CP, aggregate_pvs[axis])
        AggregateSeverity('STATUS', 'Axis %s signal health' % axis, pvs)
