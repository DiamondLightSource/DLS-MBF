# Common definitions for all TMBF records

import sys, os

sys.path.append(os.environ['EPICS_DEVICE'])

from epics_device import *

set_MDEL_default(-1)
set_out_name(lambda name: name + '_S')
SetTemplateRecordNames()


KB = 1024
MB = KB * KB


# We build TMBF and LMBF databases slightly differently
Target = sys.argv[2]
assert Target in ['lmbf', 'tmbf']
lmbf_mode = Target == 'lmbf'


# Axis names
AXIS0 = Parameter('AXIS0', 'Prefix for axis 0')
AXIS1 = Parameter('AXIS1', 'Prefix for axis 1')
AXES = [AXIS0, AXIS1]

if lmbf_mode:
    AXIS01 = Parameter('AXIS01', 'Prefix for common axis')

BUNCHES_PER_TURN = \
    Parameter('BUNCHES_PER_TURN', 'Bunches per machine revolution')
DETECTOR_LENGTH = Parameter('DETECTOR_LENGTH', 'Detector readout length')
MEMORY_READOUT_LENGTH = \
    Parameter('MEMORY_READOUT_LENGTH', 'Length of memory readout waveforms')

ADC_TAPS = Parameter('ADC_TAPS', 'Number of taps in ADC filter')
DAC_TAPS = Parameter('DAC_TAPS', 'Number of taps in DAC filter')
BUNCH_TAPS = Parameter('BUNCH_TAPS', 'Number of taps in Bunch by Bunch FIR')

REVOLUTION_FREQUENCY = \
    Parameter('REVOLUTION_FREQUENCY', 'Machine revolution frequency in Hz')


# Context manager for name prefix, allows us to write
#
#   with name_prefix(prefix):
#       generate pvs
#
# to generate PVs named prefix:name
class name_prefix:
    def __init__(self, prefix):
        self.prefix = prefix

    def __enter__(self):
        push_name_prefix(self.prefix)

    def __exit__(self, *exception):
        pop_name_prefix()


# Generates name prefixes for records with names axis:prefix:name
# If lmbf_mode is passed as the second argument and is True then a single prefix
# of the form IQ:prefix:name is generated.
def axes(prefix, iq_mode = False):
    if iq_mode:
        with name_prefix(AXIS01):
            with name_prefix(prefix):
                yield AXIS01
    else:
        for axis in AXES:
            with name_prefix(axis):
                with name_prefix(prefix):
                    yield axis


def dBrange(count, step, start = 0):
    return ['%sdB' % db for db in range(start, start + count*step, step)]

def overflow(name, desc, **args):
    return boolIn(name, 'Ok', 'Overflow', OSV = 'MAJOR', DESC = desc, **args)

def event(name, desc, **args):
    return boolIn(name, 'No', 'Yes', ZSV = 'MINOR', DESC = desc, **args)
