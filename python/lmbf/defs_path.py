# Module to compute correct path to register definitions

import os
import sys

HERE = os.path.realpath(os.path.dirname(__file__))
TOP = os.path.abspath(os.path.join(HERE, '../..'))
sys.path.append(os.path.join(TOP, 'AMC525/python'))

DEFS = os.path.join(TOP, 'AMC525/vhd/register_defs.in')
