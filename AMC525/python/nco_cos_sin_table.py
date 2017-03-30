#!/usr/bin/env python

import sys

from numpy import *

# The target block ram is 1024x36
SAMPLES = 1024
# The scaling is a bit curious: we need the rounded result to fit into 15 bits
# (as an unsigned number), but we want 18 significant bits stored.
RESULT_BITS = 15
STORED_BITS = 18

EXTRA_BITS = STORED_BITS - RESULT_BITS

def generate_body():
    # Compute angles to fill up an octant.
    time = pi / 4 / SAMPLES * arange(SAMPLES)
    scale = 2**EXTRA_BITS * (2**RESULT_BITS - 1)

    sins = int_(round_(scale * sin(time)))
    coss = int_(round_(scale * cos(time)))

    mask = 2**STORED_BITS - 1

    # Assemble the sin and cos into a single 28 bit number
    result = (coss & mask) + ((sins & mask) << STORED_BITS)

    for r in result[:-1]:
        print '        X"%09x",' % r
    print '        X"%09x"' % result[-1]


print '''\
--
-- DO NOT EDIT THIS FILE !!!
--
-- This file has been automatically generated.
-- To change this file edit the source file and rebuild.
'''
for line in file(sys.argv[1]):
    if '@TABLE_BODY' in line:
        generate_body()
    else:
        print line,