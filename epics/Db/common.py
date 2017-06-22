# Common definitions for all TMBF records

import sys, os

sys.path.append(os.environ['EPICS_DEVICE'])

from epics_device import *

set_MDEL_default(-1)
set_out_name(lambda name: name + '_S')
SetTemplateRecordNames()


KB = 1024
MB = KB * KB

BUNCHES_PER_TURN = int(os.environ['BUNCHES_PER_TURN'])


def dBrange(count, step, start = 0):
    return ['%sdB' % db for db in range(start, start + count*step, step)]
