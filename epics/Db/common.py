# Common definitions for all TMBF records

import sys, os

sys.path.append(os.environ['EPICS_DEVICE'])

from epics_device import *

set_MDEL_default(-1)
set_out_name(lambda name: name + '_S')
SetTemplateRecordNames()


KB = 1024
MB = KB * KB


# Global parameters

# Channel names
CHANNEL0 = Parameter('CHAN0', 'Prefix for channel 0')
CHANNEL1 = Parameter('CHAN1', 'Prefix for channel 1')
CHANNELS = [CHANNEL0, CHANNEL1]

BUNCHES_PER_TURN = Parameter('BUNCHES_PER_TURN',
    'Bunches per machine revolution')


def for_channels(prefix, action):
    for channel in CHANNELS:
        push_name_prefix(channel)
        push_name_prefix(prefix)
        action()
        pop_name_prefix()
        pop_name_prefix()

def dBrange(count, step, start = 0):
    return ['%sdB' % db for db in range(start, start + count*step, step)]

def overflow(name, desc):
    return boolIn(name, 'Ok', 'Overflow', OSV = 'MAJOR', DESC = desc)

def event(name, desc):
    return boolIn(name, 'No', 'Yes', ZSV = 'MINOR', DESC = desc)
