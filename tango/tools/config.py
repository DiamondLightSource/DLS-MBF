# -*- coding: utf-8 -*-

db_filename = '../../epics/db/tmbf.db'

horizontal_axis_number = 1

tango_dev_name = {
    'horizontal': 'sr/d-mfdbk/utca-horizontal',
    'vertical': 'sr/d-mfdbk/utca-vertical',
    'global': 'sr/d-mfdbk/utca-global' }

tango_instance_name = {
    'horizontal': 'mfdbk-horizontal',
    'vertical': 'mfdbk-vertical',
    'global': 'mfdbk-global' }

vars_users = {
    'DEVICE': 'SR-TMBF',
    'AXIS0': 'Y',
    'AXIS1': 'X',
    'MEMORY_READOUT_LENGTH': '16384',
    'ADC_TAPS': '20',
    'DAC_TAPS': '20',
    'BUNCHES_PER_TURN': '992',
    'DETECTOR_LENGTH': '4096',
    'BUNCH_TAPS': '16' }
