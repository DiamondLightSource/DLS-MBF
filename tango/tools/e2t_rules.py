# -*- coding: utf-8 -*-

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
'HOSTNAME':
    {'pv_type': 'String', 'scal_ar': 'Scalar' },

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
'DAC:MMS:MEAN_MEAN':
    {'format': '%.6f'},
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
