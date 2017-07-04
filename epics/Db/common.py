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


def with_name_prefix(prefix, action, *args):
    push_name_prefix(prefix)
    result = action(*args)
    pop_name_prefix()
    return result

def for_channels(prefix, action, *args):
    for channel in CHANNELS:
        with_name_prefix(channel,
            lambda: with_name_prefix(prefix, action, *args))


def dBrange(count, step, start = 0):
    return ['%sdB' % db for db in range(start, start + count*step, step)]

def overflow(name, desc):
    return boolIn(name, 'Ok', 'Overflow', OSV = 'MAJOR', DESC = desc)

def event(name, desc):
    return boolIn(name, 'No', 'Yes', ZSV = 'MINOR', DESC = desc)
