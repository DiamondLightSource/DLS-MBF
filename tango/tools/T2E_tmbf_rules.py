# -*- coding: utf-8 -*-

import re
from config import horizontal_axis_number

re_scope = re.compile("\$\(DEVICE\):\$\(AXIS([01])\):")

def get_scope(pv):
    rout = re_scope.match(pv)
    if rout:
        if rout.group(1) == '{:d}'.format(horizontal_axis_number):
            scope = 'horizontal'
        else:
            scope = 'vertical'
    else:
        scope = 'global'
    return scope

def add_scope_field(dico_tango):
    for pv_name in dico_tango:
        d = dico_tango[pv_name]
        pv = d['pv']
        d['scope'] = get_scope(pv)

def keep_one_scope(dico_tango, current_scope):
    keys = dico_tango.keys()
    for pv_name in keys:
        if dico_tango[pv_name]['scope'] != current_scope:
            dico_tango.pop(pv_name)


pv_dot_PROC = [
    'DLY:TURN:SYNC_S',
    'MEM:CAPTURE_S',
    'TRG:ARM_S',
    'TRG:DISARM_S',
    'TRG:MEM:ARM_S',
    'TRG:MEM:DISARM_S',
    'TRG:SOFT_S',
    'ADC:MMS:RESET_FAULT_S',
    'ADC:MMS:SCAN_S',
    'DAC:MMS:RESET_FAULT_S',
    'DAC:MMS:SCAN_S',
    'SEQ:RESET_S',
    'SEQ:RESET_WIN_S',
    'TRG:SEQ:ARM_S',
    'TRG:SEQ:DISARM_S' ]

pv_dot_SCAN = [
    'TRG:SOFT_S',
    'ADC:MMS:SCAN_S',
    'DAC:MMS:SCAN_S' ]

e2t_exceptions = {
'TRG:SOFT_S.PROC':
    {'tango_att_name': "TRG_SOFT_CMD" },
'ADC:MMS:SCAN_S.PROC':
    {'tango_att_name': "ADC_MMS_SCAN_CMD" },
'DAC:MMS:SCAN_S.PROC':
    {'tango_att_name': "DAC_MMS_SCAN_CMD" },
'STATUS':
    {'tango_att_name': "AXIS_STATUS" },

'INFO:AXIS0':
    {'tango_att_name': 'AXIS0'},
'INFO:AXIS1':
    {'tango_att_name': 'AXIS1'},
'INFO:BUNCHES':
    {'tango_att_name': 'BUNCHES'},
'INFO:BUNCH_TAPS':
    {'tango_att_name': 'BUNCH_TAPS'},
'INFO:DEVICE':
    {'tango_att_name': 'DEVICE'},
'INFO:DRIVER_VERSION':
    {'tango_att_name': 'DRIVER_VERSION'},
'INFO:FPGA_GIT_VERSION':
    {'tango_att_name': 'FPGA_GIT_VERSION'},
'INFO:FPGA_VERSION':
    {'tango_att_name': 'FPGA_VERSION'},
'INFO:GIT_VERSION':
    {'tango_att_name': 'GIT_VERSION'},
'INFO:HOSTNAME':
    {'tango_att_name': 'HOSTNAME'},
'INFO:MODE':
    {'tango_att_name': 'MODE'},
'INFO:SOCKET':
    {'tango_att_name': 'SOCKET'},
'INFO:VERSION':
    {'tango_att_name': 'VERSION'},

'DLY:DAC:COARSE_DELAY_S':
    {'format': '%3d'},
'DLY:TURN:OFFSET_S':
    {'format': '%3d'},
'DLY:TURN:RATE':
    {'format': '%.3f'},
'ADC:EVENT_LIMIT_S':
    {'format': '%5.4f'},
'ADC:MMS:MEAN_MEAN':
    {'format': '%9.6f'},
'DAC:MMS:MEAN_MEAN':
    {'format': '%.6f'},
'ADC:MMS:STD_MEAN':
    {'format': '%.6f'},
'ADC:MMS:STD_MEAN_DB':
    {'format': '%.1f'},
'ADC:OVF_LIMIT_S':
    {'format': '%5.4f'},
'DAC:MMS:STD_MEAN':
    {'format': '%.6f'},
'DAC:MMS:STD_MEAN_DB':
    {'format': '%.1f'},
'DET:FIR_DELAY_S':
    {'format': '%4.1f'},
'FIR:0:PHASE_S':
    {'format': '%3.0f'},
'FIR:1:PHASE_S':
    {'format': '%3.0f'},
'FIR:2:PHASE_S':
    {'format': '%3.0f'},
'FIR:3:PHASE_S':
    {'format': '%3.0f'},
'NCO:FREQ_S':
    {'format': '%8.5f'},
'SEQ:1:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:1:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:1:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:2:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:2:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:2:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:3:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:3:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:3:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:4:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:4:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:4:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:5:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:5:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:5:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:6:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:6:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:6:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:7:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:7:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:7:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:DURATION:S':
    {'format': '%.3f'},
'SEQ:TOTAL:DURATION':
    {'format': '%.0f'},
'SEQ:TOTAL:DURATION:S':
    {'format': '%.3f'},
'SEQ:TOTAL:LENGTH':
    {'format': '%.0f'},
'TRG:SEQ:DELAY_S':
    {'format': '%3d'},
'ADC:EVENT_LIMIT_S':
    {'format': '%5.4f'},
'ADC:MMS:STD_MEAN':
    {'format': '%.6f'},
'ADC:MMS:STD_MEAN_DB':
    {'format': '%.1f'},
'ADC:OVF_LIMIT_S':
    {'format': '%5.4f'},
'DAC:MMS:STD_MEAN':
    {'format': '%.6f'},
'DAC:MMS:STD_MEAN_DB':
    {'format': '%.1f'},
'DET:FIR_DELAY_S':
    {'format': '%4.1f'},
'FIR:0:PHASE_S':
    {'format': '%3.0f'},
'FIR:1:PHASE_S':
    {'format': '%3.0f'},
'FIR:2:PHASE_S':
    {'format': '%3.0f'},
'FIR:3:PHASE_S':
    {'format': '%3.0f'},
'NCO:FREQ_S':
    {'format': '%8.5f'},
'SEQ:1:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:1:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:1:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:2:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:2:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:2:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:3:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:3:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:3:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:4:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:4:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:4:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:5:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:5:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:5:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:6:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:6:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:6:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:7:END_FREQ_S':
    {'format': '%8.5f'},
'SEQ:7:START_FREQ_S':
    {'format': '%8.5f'},
'SEQ:7:STEP_FREQ_S':
    {'format': '%10.7f'},
'SEQ:DURATION:S':
    {'format': '%.3f'},
'SEQ:TOTAL:DURATION':
    {'format': '%.0f'},
'SEQ:TOTAL:DURATION:S':
    {'format': '%.3f'},
'SEQ:TOTAL:LENGTH':
    {'format': '%.0f'},
'TRG:SEQ:DELAY_S':
    {'format': '%3d'}
}

"""
'DLY:DAC:COARSE_DELAY_S':
    {'format': '%3d'},
'DLY:DAC:FINE_DELAY_S':
    {'format': '%2d'},
'DLY:TURN:DELAY_S':
    {'format': '%2d'},
'DLY:TURN:OFFSET_S':
    {'format': '%3d'},
'DLY:TURN:RATE':
    {'format': '%.3f'},
'TRG:BLANKING_S':
    {'format': '%5d'},
'ADC:EVENT_LIMIT_S':
    {'format': '%5.4f'},
'ADC:MMS:STD_MEAN':
    {'format': '%.6f'},
'ADC:MMS:STD_MEAN_DB':
    {'format': '%.1f'},
'ADC:OVF_LIMIT_S':
    {'format': '%5.4f'},
'DAC:MMS:STD_MEAN':
    {'format': '%.6f'},
'DAC:MMS:STD_MEAN_DB':
    {'format': '%.1f'},
'FIR:0:CYCLES_S':
    {'format': '%2d'},
'FIR:0:LENGTH_S':
    {'format': '%2d'},
'FIR:0:PHASE_S':
    {'format': '%3.0f'},
'FIR:1:CYCLES_S':
    {'format': '%2d'},
'FIR:1:LENGTH_S':
    {'format': '%2d'},
'FIR:1:PHASE_S':
    {'format': '%3.0f'},
'FIR:2:CYCLES_S':
    {'format': '%2d'},
'FIR:2:LENGTH_S':
    {'format': '%2d'},
'FIR:2:PHASE_S':
    {'format': '%3.0f'},
'FIR:3:CYCLES_S':
    {'format': '%2d'},
'FIR:3:LENGTH_S':
    {'format': '%2d'},
'FIR:3:PHASE_S':
    {'format': '%3.0f'},
'SEQ:DURATION:S':
    {'format': '%.3f'},
'SEQ:PC_S':
    {'format': '%1d'},
'SEQ:SUPER:COUNT_S':
    {'format': '%4d'},
'SEQ:SUPER:OFFSET_S':
    {'format': '%.5f'},
'SEQ:TOTAL:DURATION':
    {'format': '%.0f'},
'SEQ:TOTAL:DURATION:S':
    {'format': '%.3f'},
'SEQ:TOTAL:LENGTH':
    {'format': '%.0f'},
'SEQ:TRIGGER_S':
    {'format': '%1d'},
'TRG:SEQ:DELAY_S':
    {'format': '%3d'}
}
"""
