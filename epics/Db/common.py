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


# Channel names
CHANNEL0 = Parameter('CHAN0', 'Prefix for channel 0')
CHANNEL1 = Parameter('CHAN1', 'Prefix for channel 1')
CHANNELS = [CHANNEL0, CHANNEL1]

if lmbf_mode:
    CHANNEL01 = Parameter('CHAN01', 'Prefix for common channel')

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
class name_prefix:
    def __init__(self, prefix):
        self.prefix = prefix

    def __enter__(self):
        push_name_prefix(self.prefix)

    def __exit__(self, *exception):
        pop_name_prefix()

class iq_prefix:
    def __init__(self, prefix):
        self.prefix = prefix

    def __enter__(self):
        push_name_prefix(CHANNEL01)
        push_name_prefix(self.prefix)

    def __exit__(self, *exception):
        pop_name_prefix()
        pop_name_prefix()


def for_channels(prefix, action, *args):
    for channel in CHANNELS:
        with name_prefix(channel):
            with name_prefix(prefix):
                action(*args)


def dBrange(count, step, start = 0):
    return ['%sdB' % db for db in range(start, start + count*step, step)]

def overflow(name, desc, **args):
    return boolIn(name, 'Ok', 'Overflow', OSV = 'MAJOR', DESC = desc, **args)

def event(name, desc, **args):
    return boolIn(name, 'No', 'Yes', ZSV = 'MINOR', DESC = desc, **args)
