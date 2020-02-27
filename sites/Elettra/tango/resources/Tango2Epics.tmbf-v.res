#
# Resource backup , created Fri Jun 28 15:07:03 CEST 2019
#

#---------------------------------------------------------
# SERVER Tango2Epics/tmbf-v, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/tmbf-v/DEVICE/Tango2Epics: "tmbf/processor/v"


# --- tmbf/processor/v properties

tmbf/processor/v->ArrayAccessTimeout: 0.3
tmbf/processor/v->polled_attr: dac_mms_std_mean,\ 
                                       1000
tmbf/processor/v->ScalarAccessTimeout: 0.2
tmbf/processor/v->SubscriptionCycle: 0.4
tmbf/processor/v->Variables: SR-TMBF:Y:ADC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_DRAM_SOURCE_S,\ 
                                     SR-TMBF:Y:ADC:EVENT*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_EVENT,\ 
                                     SR-TMBF:Y:ADC:EVENT_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*ADC_EVENT_LIMIT_S,\ 
                                     SR-TMBF:Y:ADC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*ADC_FILTER_S,\ 
                                     SR-TMBF:Y:ADC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_FIR_OVF,\ 
                                     SR-TMBF:Y:ADC:INP_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_INP_OVF,\ 
                                     SR-TMBF:Y:ADC:LOOPBACK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_LOOPBACK_S,\ 
                                     SR-TMBF:Y:ADC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_ARCHIVE_DONE_S,\ 
                                     SR-TMBF:Y:ADC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*ADC_MMS_ARCHIVE_TRIG,\ 
                                     SR-TMBF:Y:ADC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_ARCHIVE_TRIG_FAN,\ 
                                     SR-TMBF:Y:ADC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_DELTA,\ 
                                     SR-TMBF:Y:ADC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_FAN,\ 
                                     SR-TMBF:Y:ADC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_FAN1,\ 
                                     SR-TMBF:Y:ADC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MAX,\ 
                                     SR-TMBF:Y:ADC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MEAN,\ 
                                     SR-TMBF:Y:ADC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MEAN_MEAN,\ 
                                     SR-TMBF:Y:ADC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MIN,\ 
                                     SR-TMBF:Y:ADC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_MMS_OVERFLOW,\ 
                                     SR-TMBF:Y:ADC:MMS:RESET_FAULT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_RESET_FAULT_S,\ 
                                     SR-TMBF:Y:ADC:MMS:SCAN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_SCAN_CMD,\ 
                                     SR-TMBF:Y:ADC:MMS:SCAN_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_SCAN_S,\ 
                                     SR-TMBF:Y:ADC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD,\ 
                                     SR-TMBF:Y:ADC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MAX_WF,\ 
                                     SR-TMBF:Y:ADC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN,\ 
                                     SR-TMBF:Y:ADC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN_DB,\ 
                                     SR-TMBF:Y:ADC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN_WF,\ 
                                     SR-TMBF:Y:ADC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MIN_WF,\ 
                                     SR-TMBF:Y:ADC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*ADC_MMS_TURNS,\ 
                                     SR-TMBF:Y:ADC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_MMS_SOURCE_S,\ 
                                     SR-TMBF:Y:ADC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_OVF,\ 
                                     SR-TMBF:Y:ADC:OVF_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*ADC_OVF_LIMIT_S,\ 
                                     SR-TMBF:Y:ADC:REJECT_COUNT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_REJECT_COUNT_S,\ 
                                     SR-TMBF:Y:BUN:0:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_0_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:0:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_0_DAC_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:0:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_0_FIRWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:0:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_FIRWF_STA,\ 
                                     SR-TMBF:Y:BUN:0:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_0_FIRWF_S,\ 
                                     SR-TMBF:Y:BUN:0:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_0_FIR_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:0:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_0_GAINWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:0:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_GAINWF_STA,\ 
                                     SR-TMBF:Y:BUN:0:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_0_GAINWF_S,\ 
                                     SR-TMBF:Y:BUN:0:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_0_GAIN_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:0:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_0_OUTWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:0:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_OUTWF_STA,\ 
                                     SR-TMBF:Y:BUN:0:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_0_OUTWF_S,\ 
                                     SR-TMBF:Y:BUN:0:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_SELECT_STATUS,\ 
                                     SR-TMBF:Y:BUN:1:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_1_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:1:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_1_DAC_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:1:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_1_FIRWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:1:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_FIRWF_STA,\ 
                                     SR-TMBF:Y:BUN:1:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_1_FIRWF_S,\ 
                                     SR-TMBF:Y:BUN:1:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_1_FIR_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:1:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_1_GAINWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:1:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_GAINWF_STA,\ 
                                     SR-TMBF:Y:BUN:1:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_1_GAINWF_S,\ 
                                     SR-TMBF:Y:BUN:1:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_1_GAIN_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:1:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_1_OUTWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:1:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_OUTWF_STA,\ 
                                     SR-TMBF:Y:BUN:1:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_1_OUTWF_S,\ 
                                     SR-TMBF:Y:BUN:1:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_SELECT_STATUS,\ 
                                     SR-TMBF:Y:BUN:2:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_2_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:2:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_2_DAC_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:2:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_2_FIRWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:2:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_FIRWF_STA,\ 
                                     SR-TMBF:Y:BUN:2:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_2_FIRWF_S,\ 
                                     SR-TMBF:Y:BUN:2:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_2_FIR_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:2:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_2_GAINWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:2:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_GAINWF_STA,\ 
                                     SR-TMBF:Y:BUN:2:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_2_GAINWF_S,\ 
                                     SR-TMBF:Y:BUN:2:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_2_GAIN_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:2:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_2_OUTWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:2:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_OUTWF_STA,\ 
                                     SR-TMBF:Y:BUN:2:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_2_OUTWF_S,\ 
                                     SR-TMBF:Y:BUN:2:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_SELECT_STATUS,\ 
                                     SR-TMBF:Y:BUN:3:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_3_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:3:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_3_DAC_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:3:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_3_FIRWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:3:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_FIRWF_STA,\ 
                                     SR-TMBF:Y:BUN:3:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_3_FIRWF_S,\ 
                                     SR-TMBF:Y:BUN:3:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_3_FIR_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:3:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_3_GAINWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:3:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_GAINWF_STA,\ 
                                     SR-TMBF:Y:BUN:3:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_3_GAINWF_S,\ 
                                     SR-TMBF:Y:BUN:3:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_3_GAIN_SELECT_S,\ 
                                     SR-TMBF:Y:BUN:3:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_3_OUTWF_SET_S,\ 
                                     SR-TMBF:Y:BUN:3:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_OUTWF_STA,\ 
                                     SR-TMBF:Y:BUN:3:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_3_OUTWF_S,\ 
                                     SR-TMBF:Y:BUN:3:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_SELECT_STATUS,\ 
                                     SR-TMBF:Y:BUN:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_MODE,\ 
                                     SR-TMBF:Y:DAC:BUN_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_BUN_OVF,\ 
                                     SR-TMBF:Y:DAC:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_DELAY_S,\ 
                                     SR-TMBF:Y:DAC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_DRAM_SOURCE_S,\ 
                                     SR-TMBF:Y:DAC:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_ENABLE_S,\ 
                                     SR-TMBF:Y:DAC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*DAC_FILTER_S,\ 
                                     SR-TMBF:Y:DAC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_FIR_OVF,\ 
                                     SR-TMBF:Y:DAC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_ARCHIVE_DONE_S,\ 
                                     SR-TMBF:Y:DAC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DAC_MMS_ARCHIVE_TRIG,\ 
                                     SR-TMBF:Y:DAC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_ARCHIVE_TRIG_FAN,\ 
                                     SR-TMBF:Y:DAC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_DELTA,\ 
                                     SR-TMBF:Y:DAC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_FAN,\ 
                                     SR-TMBF:Y:DAC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_FAN1,\ 
                                     SR-TMBF:Y:DAC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MAX,\ 
                                     SR-TMBF:Y:DAC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MEAN,\ 
                                     SR-TMBF:Y:DAC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MEAN_MEAN,\ 
                                     SR-TMBF:Y:DAC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MIN,\ 
                                     SR-TMBF:Y:DAC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_MMS_OVERFLOW,\ 
                                     SR-TMBF:Y:DAC:MMS:RESET_FAULT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_RESET_FAULT_S,\ 
                                     SR-TMBF:Y:DAC:MMS:SCAN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_SCAN_CMD,\ 
                                     SR-TMBF:Y:DAC:MMS:SCAN_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_SCAN_S,\ 
                                     SR-TMBF:Y:DAC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD,\ 
                                     SR-TMBF:Y:DAC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MAX_WF,\ 
                                     SR-TMBF:Y:DAC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN,\ 
                                     SR-TMBF:Y:DAC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN_DB,\ 
                                     SR-TMBF:Y:DAC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN_WF,\ 
                                     SR-TMBF:Y:DAC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MIN_WF,\ 
                                     SR-TMBF:Y:DAC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*DAC_MMS_TURNS,\ 
                                     SR-TMBF:Y:DAC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_MMS_SOURCE_S,\ 
                                     SR-TMBF:Y:DAC:MUX_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_MUX_OVF,\ 
                                     SR-TMBF:Y:DAC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_OVF,\ 
                                     SR-TMBF:Y:DET:0:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_0_BUNCHES_S,\ 
                                     SR-TMBF:Y:DET:0:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_0_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:DET:0:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_0_COUNT,\ 
                                     SR-TMBF:Y:DET:0:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_0_ENABLE,\ 
                                     SR-TMBF:Y:DET:0:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_0_ENABLE_S,\ 
                                     SR-TMBF:Y:DET:0:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_I,\ 
                                     SR-TMBF:Y:DET:0:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_0_MAX_POWER,\ 
                                     SR-TMBF:Y:DET:0:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_0_OUT_OVF,\ 
                                     SR-TMBF:Y:DET:0:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_PHASE,\ 
                                     SR-TMBF:Y:DET:0:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_POWER,\ 
                                     SR-TMBF:Y:DET:0:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_Q,\ 
                                     SR-TMBF:Y:DET:0:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_0_RESET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:0:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_0_SCALING_S,\ 
                                     SR-TMBF:Y:DET:0:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_0_SELECT_STATUS,\ 
                                     SR-TMBF:Y:DET:0:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_0_SET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:1:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_1_BUNCHES_S,\ 
                                     SR-TMBF:Y:DET:1:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_1_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:DET:1:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_1_COUNT,\ 
                                     SR-TMBF:Y:DET:1:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_1_ENABLE,\ 
                                     SR-TMBF:Y:DET:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_1_ENABLE_S,\ 
                                     SR-TMBF:Y:DET:1:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_I,\ 
                                     SR-TMBF:Y:DET:1:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_1_MAX_POWER,\ 
                                     SR-TMBF:Y:DET:1:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_1_OUT_OVF,\ 
                                     SR-TMBF:Y:DET:1:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_PHASE,\ 
                                     SR-TMBF:Y:DET:1:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_POWER,\ 
                                     SR-TMBF:Y:DET:1:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_Q,\ 
                                     SR-TMBF:Y:DET:1:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_1_RESET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:1:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_1_SCALING_S,\ 
                                     SR-TMBF:Y:DET:1:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_1_SELECT_STATUS,\ 
                                     SR-TMBF:Y:DET:1:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_1_SET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:2:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_2_BUNCHES_S,\ 
                                     SR-TMBF:Y:DET:2:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_2_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:DET:2:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_2_COUNT,\ 
                                     SR-TMBF:Y:DET:2:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_2_ENABLE,\ 
                                     SR-TMBF:Y:DET:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_2_ENABLE_S,\ 
                                     SR-TMBF:Y:DET:2:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_I,\ 
                                     SR-TMBF:Y:DET:2:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_2_MAX_POWER,\ 
                                     SR-TMBF:Y:DET:2:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_2_OUT_OVF,\ 
                                     SR-TMBF:Y:DET:2:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_PHASE,\ 
                                     SR-TMBF:Y:DET:2:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_POWER,\ 
                                     SR-TMBF:Y:DET:2:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_Q,\ 
                                     SR-TMBF:Y:DET:2:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_2_RESET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:2:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_2_SCALING_S,\ 
                                     SR-TMBF:Y:DET:2:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_2_SELECT_STATUS,\ 
                                     SR-TMBF:Y:DET:2:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_2_SET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:3:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_3_BUNCHES_S,\ 
                                     SR-TMBF:Y:DET:3:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_3_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:DET:3:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_3_COUNT,\ 
                                     SR-TMBF:Y:DET:3:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_3_ENABLE,\ 
                                     SR-TMBF:Y:DET:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_3_ENABLE_S,\ 
                                     SR-TMBF:Y:DET:3:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_I,\ 
                                     SR-TMBF:Y:DET:3:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_3_MAX_POWER,\ 
                                     SR-TMBF:Y:DET:3:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_3_OUT_OVF,\ 
                                     SR-TMBF:Y:DET:3:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_PHASE,\ 
                                     SR-TMBF:Y:DET:3:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_POWER,\ 
                                     SR-TMBF:Y:DET:3:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_Q,\ 
                                     SR-TMBF:Y:DET:3:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_3_RESET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:3:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_3_SCALING_S,\ 
                                     SR-TMBF:Y:DET:3:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_3_SELECT_STATUS,\ 
                                     SR-TMBF:Y:DET:3:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_3_SET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:FILL_WAVEFORM_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_FILL_WAVEFORM_S,\ 
                                     SR-TMBF:Y:DET:FIR_DELAY_S*Scalar*Double*READ_WRITE*ATTRIBUTE*DET_FIR_DELAY_S,\ 
                                     SR-TMBF:Y:DET:SAMPLES*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_SAMPLES,\ 
                                     SR-TMBF:Y:DET:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_SCALE,\ 
                                     SR-TMBF:Y:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_SELECT_S,\ 
                                     SR-TMBF:Y:DET:TIMEBASE*Array:4096*Int*READ_ONLY*ATTRIBUTE*DET_TIMEBASE,\ 
                                     SR-TMBF:Y:DET:UNDERRUN*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_UNDERRUN,\ 
                                     SR-TMBF:Y:DET:UPDATE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_DONE_S,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_UPDATE_TRIG,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN1,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG:FAN2*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN2,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG:FAN3*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN3,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG:FAN4*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN4,\ 
                                     SR-TMBF:Y:DET:UPDATE:TRIG:FAN5*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN5,\ 
                                     SR-TMBF:Y:DET:UPDATE_SCALE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_SCALE_DONE_S,\ 
                                     SR-TMBF:Y:DET:UPDATE_SCALE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_UPDATE_SCALE_TRIG,\ 
                                     SR-TMBF:Y:DET:UPDATE_SCALE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_SCALE_TRIG_FAN,\ 
                                     SR-TMBF:Y:FIR:0:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_CYCLES_S,\ 
                                     SR-TMBF:Y:FIR:0:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_LENGTH_S,\ 
                                     SR-TMBF:Y:FIR:0:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_0_PHASE_S,\ 
                                     SR-TMBF:Y:FIR:0:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_RELOAD_S,\ 
                                     SR-TMBF:Y:FIR:0:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_0_TAPS,\ 
                                     SR-TMBF:Y:FIR:0:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_0_TAPS_S,\ 
                                     SR-TMBF:Y:FIR:0:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_0_USEWF_S,\ 
                                     SR-TMBF:Y:FIR:1:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_CYCLES_S,\ 
                                     SR-TMBF:Y:FIR:1:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_LENGTH_S,\ 
                                     SR-TMBF:Y:FIR:1:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_1_PHASE_S,\ 
                                     SR-TMBF:Y:FIR:1:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_RELOAD_S,\ 
                                     SR-TMBF:Y:FIR:1:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_1_TAPS,\ 
                                     SR-TMBF:Y:FIR:1:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_1_TAPS_S,\ 
                                     SR-TMBF:Y:FIR:1:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_1_USEWF_S,\ 
                                     SR-TMBF:Y:FIR:2:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_CYCLES_S,\ 
                                     SR-TMBF:Y:FIR:2:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_LENGTH_S,\ 
                                     SR-TMBF:Y:FIR:2:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_2_PHASE_S,\ 
                                     SR-TMBF:Y:FIR:2:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_RELOAD_S,\ 
                                     SR-TMBF:Y:FIR:2:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_2_TAPS,\ 
                                     SR-TMBF:Y:FIR:2:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_2_TAPS_S,\ 
                                     SR-TMBF:Y:FIR:2:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_2_USEWF_S,\ 
                                     SR-TMBF:Y:FIR:3:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_CYCLES_S,\ 
                                     SR-TMBF:Y:FIR:3:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_LENGTH_S,\ 
                                     SR-TMBF:Y:FIR:3:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_3_PHASE_S,\ 
                                     SR-TMBF:Y:FIR:3:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_RELOAD_S,\ 
                                     SR-TMBF:Y:FIR:3:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_3_TAPS,\ 
                                     SR-TMBF:Y:FIR:3:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_3_TAPS_S,\ 
                                     SR-TMBF:Y:FIR:3:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_3_USEWF_S,\ 
                                     SR-TMBF:Y:FIR:GAIN:DN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_GAIN_DN_S,\ 
                                     SR-TMBF:Y:FIR:GAIN:UP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_GAIN_UP_S,\ 
                                     SR-TMBF:Y:FIR:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_GAIN_S,\ 
                                     SR-TMBF:Y:FIR:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*FIR_OVF,\ 
                                     SR-TMBF:Y:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*NCO_ENABLE_S,\ 
                                     SR-TMBF:Y:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*NCO_FREQ_S,\ 
                                     SR-TMBF:Y:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*NCO_GAIN_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:KI_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_KI_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:KP_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_KP_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:MAX_OFFSET_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_MAX_OFFSET_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:MIN_MAG_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_MIN_MAG_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:START_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_START_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STATUS,\ 
                                     SR-TMBF:Y:PLL:CTRL:STOP:DET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_DET_OVF,\ 
                                     SR-TMBF:Y:PLL:CTRL:STOP:MAG_ERROR*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_MAG_ERROR,\ 
                                     SR-TMBF:Y:PLL:CTRL:STOP:OFFSET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_OFFSET_OVF,\ 
                                     SR-TMBF:Y:PLL:CTRL:STOP:STOP*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_STOP,\ 
                                     SR-TMBF:Y:PLL:CTRL:STOP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_STOP_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:TARGET_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_TARGET_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:UPDATE_STATUS:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_UPDATE_STATUS_DONE_S,\ 
                                     SR-TMBF:Y:PLL:CTRL:UPDATE_STATUS:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_CTRL_UPDATE_STATUS_TRIG,\ 
                                     SR-TMBF:Y:PLL:CTRL:UPDATE_STATUS:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_UPDATE_STATUS_TRIG_FAN,\ 
                                     SR-TMBF:Y:PLL:DEBUG:ANGLE*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_ANGLE,\ 
                                     SR-TMBF:Y:PLL:DEBUG:COMPENSATE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DEBUG_COMPENSATE_S,\ 
                                     SR-TMBF:Y:PLL:DEBUG:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DEBUG_ENABLE_S,\ 
                                     SR-TMBF:Y:PLL:DEBUG:FIFO_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_DEBUG_FIFO_OVF,\ 
                                     SR-TMBF:Y:PLL:DEBUG:MAG*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_MAG,\ 
                                     SR-TMBF:Y:PLL:DEBUG:READ:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DEBUG_READ_DONE_S,\ 
                                     SR-TMBF:Y:PLL:DEBUG:READ:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_DEBUG_READ_TRIG,\ 
                                     SR-TMBF:Y:PLL:DEBUG:READ:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DEBUG_READ_TRIG_FAN,\ 
                                     SR-TMBF:Y:PLL:DEBUG:READ:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DEBUG_READ_TRIG_FAN1,\ 
                                     SR-TMBF:Y:PLL:DEBUG:RSTD*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD,\ 
                                     SR-TMBF:Y:PLL:DEBUG:RSTD_ABS*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD_ABS,\ 
                                     SR-TMBF:Y:PLL:DEBUG:RSTD_ABS_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD_ABS_DB,\ 
                                     SR-TMBF:Y:PLL:DEBUG:RSTD_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD_DB,\ 
                                     SR-TMBF:Y:PLL:DEBUG:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DEBUG_SELECT_S,\ 
                                     SR-TMBF:Y:PLL:DEBUG:WFI*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_WFI,\ 
                                     SR-TMBF:Y:PLL:DEBUG:WFQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_WFQ,\ 
                                     SR-TMBF:Y:PLL:DET:BLANKING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DET_BLANKING_S,\ 
                                     SR-TMBF:Y:PLL:DET:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*PLL_DET_BUNCHES_S,\ 
                                     SR-TMBF:Y:PLL:DET:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*PLL_DET_BUNCH_SELECT_S,\ 
                                     SR-TMBF:Y:PLL:DET:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_DET_COUNT,\ 
                                     SR-TMBF:Y:PLL:DET:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DET_DWELL_S,\ 
                                     SR-TMBF:Y:PLL:DET:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DET_RESET_SELECT_S,\ 
                                     SR-TMBF:Y:PLL:DET:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DET_SCALING_S,\ 
                                     SR-TMBF:Y:PLL:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DET_SELECT_S,\ 
                                     SR-TMBF:Y:PLL:DET:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*PLL_DET_SELECT_STATUS,\ 
                                     SR-TMBF:Y:PLL:DET:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DET_SET_SELECT_S,\ 
                                     SR-TMBF:Y:PLL:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_FAN,\ 
                                     SR-TMBF:Y:PLL:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_FAN1,\ 
                                     SR-TMBF:Y:PLL:FILT:I*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_I,\ 
                                     SR-TMBF:Y:PLL:FILT:MAG*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_MAG,\ 
                                     SR-TMBF:Y:PLL:FILT:MAG_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_MAG_DB,\ 
                                     SR-TMBF:Y:PLL:FILT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_PHASE,\ 
                                     SR-TMBF:Y:PLL:FILT:Q*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_Q,\ 
                                     SR-TMBF:Y:PLL:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_NCO_ENABLE_S,\ 
                                     SR-TMBF:Y:PLL:NCO:FIFO_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_NCO_FIFO_OVF,\ 
                                     SR-TMBF:Y:PLL:NCO:FREQ*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_FREQ,\ 
                                     SR-TMBF:Y:PLL:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_NCO_FREQ_S,\ 
                                     SR-TMBF:Y:PLL:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_NCO_GAIN_S,\ 
                                     SR-TMBF:Y:PLL:NCO:MEAN_OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_MEAN_OFFSET,\ 
                                     SR-TMBF:Y:PLL:NCO:OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_OFFSET,\ 
                                     SR-TMBF:Y:PLL:NCO:OFFSETWF*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_OFFSETWF,\ 
                                     SR-TMBF:Y:PLL:NCO:READ:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_NCO_READ_DONE_S,\ 
                                     SR-TMBF:Y:PLL:NCO:READ:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_NCO_READ_TRIG,\ 
                                     SR-TMBF:Y:PLL:NCO:READ:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_NCO_READ_TRIG_FAN,\ 
                                     SR-TMBF:Y:PLL:NCO:RESET_FIFO_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_NCO_RESET_FIFO_S,\ 
                                     SR-TMBF:Y:PLL:NCO:STD_OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_STD_OFFSET,\ 
                                     SR-TMBF:Y:PLL:NCO:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_TUNE,\ 
                                     SR-TMBF:Y:PLL:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_POLL_S,\ 
                                     SR-TMBF:Y:PLL:STA:DET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_STA_DET_OVF,\ 
                                     SR-TMBF:Y:PLL:STA:MAG_ERROR*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_STA_MAG_ERROR,\ 
                                     SR-TMBF:Y:PLL:STA:OFFSET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_STA_OFFSET_OVF,\ 
                                     SR-TMBF:Y:SEQ:0:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_0_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:1:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:1:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:1:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:1:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:1:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:1:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:1:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:1:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:1:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:1:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:1:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:1:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:1:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:2:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:2:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:2:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:2:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:2:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:2:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:2:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:2:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:2:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:2:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:2:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:2:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:2:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:3:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:3:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:3:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:3:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:3:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:3:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:3:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:3:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:3:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:3:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:3:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:3:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:3:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:4:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:4:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:4:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:4:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:4:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:4:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:4:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:4:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:4:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:4:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:4:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:4:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:4:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:4:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:5:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:5:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:5:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:5:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:5:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:5:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:5:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:5:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:5:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:5:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:5:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:5:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:5:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:5:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:6:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:6:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:6:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:6:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:6:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:6:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:6:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:6:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:6:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:6:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:6:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:6:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:6:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:6:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:7:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_BANK_S,\ 
                                     SR-TMBF:Y:SEQ:7:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_BLANK_S,\ 
                                     SR-TMBF:Y:SEQ:7:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_CAPTURE_S,\ 
                                     SR-TMBF:Y:SEQ:7:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:7:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_DWELL_S,\ 
                                     SR-TMBF:Y:SEQ:7:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_ENABLE_S,\ 
                                     SR-TMBF:Y:SEQ:7:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_END_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:7:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_ENWIN_S,\ 
                                     SR-TMBF:Y:SEQ:7:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_GAIN_S,\ 
                                     SR-TMBF:Y:SEQ:7:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:7:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_START_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:7:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_STATE_HOLDOFF_S,\ 
                                     SR-TMBF:Y:SEQ:7:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_STEP_FREQ_S,\ 
                                     SR-TMBF:Y:SEQ:7:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_TUNE_PLL_S,\ 
                                     SR-TMBF:Y:SEQ:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*SEQ_BUSY,\ 
                                     SR-TMBF:Y:SEQ:COUNT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_COUNT_FAN,\ 
                                     SR-TMBF:Y:SEQ:DURATION*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_DURATION,\ 
                                     SR-TMBF:Y:SEQ:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_DURATION_S,\ 
                                     SR-TMBF:Y:SEQ:LENGTH*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_LENGTH,\ 
                                     SR-TMBF:Y:SEQ:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*SEQ_MODE,\ 
                                     SR-TMBF:Y:SEQ:PC*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_PC,\ 
                                     SR-TMBF:Y:SEQ:PC_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_PC_S,\ 
                                     SR-TMBF:Y:SEQ:RESET_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_RESET_S,\ 
                                     SR-TMBF:Y:SEQ:RESET_WIN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_RESET_WIN_S,\ 
                                     SR-TMBF:Y:SEQ:STATUS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_STATUS_FAN,\ 
                                     SR-TMBF:Y:SEQ:STATUS:READ_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_STATUS_READ_S,\ 
                                     SR-TMBF:Y:SEQ:SUPER:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_SUPER_COUNT,\ 
                                     SR-TMBF:Y:SEQ:SUPER:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_SUPER_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:SUPER:OFFSET_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*SEQ_SUPER_OFFSET_S,\ 
                                     SR-TMBF:Y:SEQ:SUPER:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_SUPER_RESET_S,\ 
                                     SR-TMBF:Y:SEQ:TOTAL:DURATION*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_DURATION,\ 
                                     SR-TMBF:Y:SEQ:TOTAL:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_DURATION_S,\ 
                                     SR-TMBF:Y:SEQ:TOTAL:LENGTH*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_LENGTH,\ 
                                     SR-TMBF:Y:SEQ:TRIGGER_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_TRIGGER_S,\ 
                                     SR-TMBF:Y:SEQ:UPDATE_COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_UPDATE_COUNT_S,\ 
                                     SR-TMBF:Y:SEQ:WINDOW_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*SEQ_WINDOW_S,\ 
                                     SR-TMBF:Y:STA:STATUS*Scalar*Double*READ_ONLY*ATTRIBUTE*STA_STATUS,\ 
                                     SR-TMBF:Y:TRG:SEQ:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC0_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC0_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_ADC0_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC1_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC1_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_ADC1_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_ARM_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_DELAY_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_DISARM_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_EXT_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_EXT_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_EXT_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*TRG_SEQ_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_HIT_FAN,\ 
                                     SR-TMBF:Y:TRG:SEQ:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_HIT_FAN1,\ 
                                     SR-TMBF:Y:TRG:SEQ:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_MODE_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_PM_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_PM_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_PM_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ0_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ0_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SEQ0_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ1_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ1_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SEQ1_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SOFT_BL_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SOFT_EN_S,\ 
                                     SR-TMBF:Y:TRG:SEQ:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SOFT_HIT,\ 
                                     SR-TMBF:Y:TRG:SEQ:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_STATUS

# --- tmbf/processor/v attribute properties

tmbf/processor/v/ADC_DRAM_SOURCE_S->description: "Source of memory data"
tmbf/processor/v/ADC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                        "After FIR",\ 
                                                        "FIR no fill"
tmbf/processor/v/ADC_EVENT->description: "ADC min/max event"
tmbf/processor/v/ADC_EVENT->EnumLabels: No,\ 
                                                Yes
tmbf/processor/v/ADC_EVENT_LIMIT_S->description: "ADC min/max event threshold"
tmbf/processor/v/ADC_EVENT_LIMIT_S->format: %5.4f
tmbf/processor/v/ADC_EVENT_LIMIT_S->max_value: 2.0
tmbf/processor/v/ADC_EVENT_LIMIT_S->min_value: 0.0
tmbf/processor/v/ADC_FILTER_DELAY_S->description: "Compensation filter group delay"
tmbf/processor/v/ADC_FILTER_DELAY_S->max_value: 7.0
tmbf/processor/v/ADC_FILTER_DELAY_S->min_value: 0.0
tmbf/processor/v/ADC_FILTER_S->description: "Input compensation filter"
tmbf/processor/v/ADC_FIR_OVF->description: "ADC FIR overflow"
tmbf/processor/v/ADC_FIR_OVF->EnumLabels: Ok,\ 
                                                  Overflow
tmbf/processor/v/ADC_INP_OVF->description: "ADC input overflow"
tmbf/processor/v/ADC_INP_OVF->EnumLabels: Ok,\ 
                                                  Overflow
tmbf/processor/v/ADC_LOOPBACK_S->description: "Enable DAC -> ADC loopback"
tmbf/processor/v/ADC_LOOPBACK_S->EnumLabels: Normal,\ 
                                                     Loopback
tmbf/processor/v/ADC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
tmbf/processor/v/ADC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
tmbf/processor/v/ADC_MMS_DELTA->description: "Max ADC values per bunch"
tmbf/processor/v/ADC_MMS_MAX->description: "Max ADC values per bunch"
tmbf/processor/v/ADC_MMS_MEAN->description: "Mean ADC values per bunch"
tmbf/processor/v/ADC_MMS_MEAN_MEAN->description: "Mean position"
tmbf/processor/v/ADC_MMS_MEAN_MEAN->format: %9.6f
tmbf/processor/v/ADC_MMS_MEAN_MEAN->max_value: 1.0
tmbf/processor/v/ADC_MMS_MEAN_MEAN->min_value: -1.0
tmbf/processor/v/ADC_MMS_MIN->description: "Min ADC values per bunch"
tmbf/processor/v/ADC_MMS_OVERFLOW->description: "MMS capture overflow status"
tmbf/processor/v/ADC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                                       "Turns Overflow",\ 
                                                       "Sum Overflow",\ 
                                                       "Turns+Sum Overflow",\ 
                                                       "Sum2 Overflow",\ 
                                                       "Turns+Sum2 Overflow",\ 
                                                       "Sum+Sum2 Overflow",\ 
                                                       "Turns+Sum+Sum2 Overflow"
tmbf/processor/v/ADC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
tmbf/processor/v/ADC_MMS_SCAN_CMD->description: "ADC min/max scanning"
tmbf/processor/v/ADC_MMS_SCAN_S->description: "ADC min/max scanning"
tmbf/processor/v/ADC_MMS_SCAN_S->EnumLabels: Passive,\ 
                                                     Event,\ 
                                                     "I/O Intr",\ 
                                                     "10 s",\ 
                                                     "5 s",\ 
                                                     "2 s",\ 
                                                     "1 s",\ 
                                                     "500 ms",\ 
                                                     "200 ms",\ 
                                                     "100 ms"
tmbf/processor/v/ADC_MMS_SOURCE_S->description: "Source of min/max/sum data"
tmbf/processor/v/ADC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                       "After FIR",\ 
                                                       "FIR no fill"
tmbf/processor/v/ADC_MMS_STD->description: "ADC standard deviation per bunch"
tmbf/processor/v/ADC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
tmbf/processor/v/ADC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
tmbf/processor/v/ADC_MMS_STD_MEAN->format: %.6f
tmbf/processor/v/ADC_MMS_STD_MEAN->max_value: 1.0
tmbf/processor/v/ADC_MMS_STD_MEAN->min_value: 0.0
tmbf/processor/v/ADC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
tmbf/processor/v/ADC_MMS_STD_MEAN_DB->format: %.1f
tmbf/processor/v/ADC_MMS_STD_MEAN_DB->unit: dB
tmbf/processor/v/ADC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
tmbf/processor/v/ADC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
tmbf/processor/v/ADC_MMS_TURNS->description: "Number of turns in this sample"
tmbf/processor/v/ADC_OVF->description: "ADC overflow"
tmbf/processor/v/ADC_OVF->EnumLabels: Ok,\ 
                                              Overflow
tmbf/processor/v/ADC_OVF_LIMIT_S->description: "Overflow limit threshold"
tmbf/processor/v/ADC_OVF_LIMIT_S->format: %5.4f
tmbf/processor/v/ADC_OVF_LIMIT_S->max_value: 1.0
tmbf/processor/v/ADC_OVF_LIMIT_S->min_value: 0.0
tmbf/processor/v/ADC_REJECT_COUNT_S->description: "Samples in fill pattern reject filter"
tmbf/processor/v/ADC_REJECT_COUNT_S->EnumLabels: "1 turns",\ 
                                                         "2 turns",\ 
                                                         "4 turns",\ 
                                                         "8 turns",\ 
                                                         "16 turns",\ 
                                                         "32 turns",\ 
                                                         "64 turns",\ 
                                                         "128 turns",\ 
                                                         "256 turns",\ 
                                                         "512 turns",\ 
                                                         "1024 turns",\ 
                                                         "2048 turns",\ 
                                                         "4096 turns"
tmbf/processor/v/AXIS_STATUS->description: "Axis Y signal health"
tmbf/processor/v/BUN_0_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/BUN_0_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/v/BUN_0_DAC_SELECT_S->EnumLabels: Off,\ 
                                                         FIR,\ 
                                                         NCO,\ 
                                                         NCO+FIR,\ 
                                                         Sweep,\ 
                                                         Sweep+FIR,\ 
                                                         Sweep+NCO,\ 
                                                         Sweep+NCO+FIR,\ 
                                                         PLL,\ 
                                                         PLL+FIR,\ 
                                                         PLL+NCO,\ 
                                                         PLL+NCO+FIR,\ 
                                                         PLL+Sweep,\ 
                                                         PLL+Sweep+FIR,\ 
                                                         PLL+Sweep+NCO,\ 
                                                         PLL+Sweep+NCO+FIR
tmbf/processor/v/BUN_0_FIRWF_S->description: "Set 0 FIR bank select"
tmbf/processor/v/BUN_0_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_0_FIRWF_STA->description: "Bank 0 FIRWF status"
tmbf/processor/v/BUN_0_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/v/BUN_0_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                         "FIR 1",\ 
                                                         "FIR 2",\ 
                                                         "FIR 3"
tmbf/processor/v/BUN_0_GAINWF_S->description: "Set 0 DAC output gain"
tmbf/processor/v/BUN_0_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_0_GAINWF_STA->description: "Bank 0 GAINWF status"
tmbf/processor/v/BUN_0_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/v/BUN_0_GAIN_SELECT_S->format: %.5f
tmbf/processor/v/BUN_0_OUTWF_S->description: "Set 0 DAC output select"
tmbf/processor/v/BUN_0_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_0_OUTWF_STA->description: "Bank 0 OUTWF status"
tmbf/processor/v/BUN_0_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/BUN_1_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/BUN_1_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/v/BUN_1_DAC_SELECT_S->EnumLabels: Off,\ 
                                                         FIR,\ 
                                                         NCO,\ 
                                                         NCO+FIR,\ 
                                                         Sweep,\ 
                                                         Sweep+FIR,\ 
                                                         Sweep+NCO,\ 
                                                         Sweep+NCO+FIR,\ 
                                                         PLL,\ 
                                                         PLL+FIR,\ 
                                                         PLL+NCO,\ 
                                                         PLL+NCO+FIR,\ 
                                                         PLL+Sweep,\ 
                                                         PLL+Sweep+FIR,\ 
                                                         PLL+Sweep+NCO,\ 
                                                         PLL+Sweep+NCO+FIR
tmbf/processor/v/BUN_1_FIRWF_S->description: "Set 1 FIR bank select"
tmbf/processor/v/BUN_1_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_1_FIRWF_STA->description: "Bank 1 FIRWF status"
tmbf/processor/v/BUN_1_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/v/BUN_1_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                         "FIR 1",\ 
                                                         "FIR 2",\ 
                                                         "FIR 3"
tmbf/processor/v/BUN_1_GAINWF_S->description: "Set 1 DAC output gain"
tmbf/processor/v/BUN_1_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_1_GAINWF_STA->description: "Bank 1 GAINWF status"
tmbf/processor/v/BUN_1_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/v/BUN_1_GAIN_SELECT_S->format: %.5f
tmbf/processor/v/BUN_1_OUTWF_S->description: "Set 1 DAC output select"
tmbf/processor/v/BUN_1_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_1_OUTWF_STA->description: "Bank 1 OUTWF status"
tmbf/processor/v/BUN_1_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/BUN_2_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/BUN_2_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/v/BUN_2_DAC_SELECT_S->EnumLabels: Off,\ 
                                                         FIR,\ 
                                                         NCO,\ 
                                                         NCO+FIR,\ 
                                                         Sweep,\ 
                                                         Sweep+FIR,\ 
                                                         Sweep+NCO,\ 
                                                         Sweep+NCO+FIR,\ 
                                                         PLL,\ 
                                                         PLL+FIR,\ 
                                                         PLL+NCO,\ 
                                                         PLL+NCO+FIR,\ 
                                                         PLL+Sweep,\ 
                                                         PLL+Sweep+FIR,\ 
                                                         PLL+Sweep+NCO,\ 
                                                         PLL+Sweep+NCO+FIR
tmbf/processor/v/BUN_2_FIRWF_S->description: "Set 2 FIR bank select"
tmbf/processor/v/BUN_2_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_2_FIRWF_STA->description: "Bank 2 FIRWF status"
tmbf/processor/v/BUN_2_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/v/BUN_2_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                         "FIR 1",\ 
                                                         "FIR 2",\ 
                                                         "FIR 3"
tmbf/processor/v/BUN_2_GAINWF_S->description: "Set 2 DAC output gain"
tmbf/processor/v/BUN_2_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_2_GAINWF_STA->description: "Bank 2 GAINWF status"
tmbf/processor/v/BUN_2_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/v/BUN_2_GAIN_SELECT_S->format: %.5f
tmbf/processor/v/BUN_2_OUTWF_S->description: "Set 2 DAC output select"
tmbf/processor/v/BUN_2_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_2_OUTWF_STA->description: "Bank 2 OUTWF status"
tmbf/processor/v/BUN_2_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/BUN_3_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/BUN_3_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/v/BUN_3_DAC_SELECT_S->EnumLabels: Off,\ 
                                                         FIR,\ 
                                                         NCO,\ 
                                                         NCO+FIR,\ 
                                                         Sweep,\ 
                                                         Sweep+FIR,\ 
                                                         Sweep+NCO,\ 
                                                         Sweep+NCO+FIR,\ 
                                                         PLL,\ 
                                                         PLL+FIR,\ 
                                                         PLL+NCO,\ 
                                                         PLL+NCO+FIR,\ 
                                                         PLL+Sweep,\ 
                                                         PLL+Sweep+FIR,\ 
                                                         PLL+Sweep+NCO,\ 
                                                         PLL+Sweep+NCO+FIR
tmbf/processor/v/BUN_3_FIRWF_S->description: "Set 3 FIR bank select"
tmbf/processor/v/BUN_3_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_3_FIRWF_STA->description: "Bank 3 FIRWF status"
tmbf/processor/v/BUN_3_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/v/BUN_3_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                         "FIR 1",\ 
                                                         "FIR 2",\ 
                                                         "FIR 3"
tmbf/processor/v/BUN_3_GAINWF_S->description: "Set 3 DAC output gain"
tmbf/processor/v/BUN_3_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_3_GAINWF_STA->description: "Bank 3 GAINWF status"
tmbf/processor/v/BUN_3_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/v/BUN_3_GAIN_SELECT_S->format: %.5f
tmbf/processor/v/BUN_3_OUTWF_S->description: "Set 3 DAC output select"
tmbf/processor/v/BUN_3_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/v/BUN_3_OUTWF_STA->description: "Bank 3 OUTWF status"
tmbf/processor/v/BUN_3_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/BUN_MODE->description: "Feedback mode"
tmbf/processor/v/DAC_BUN_OVF->description: "Bunch FIR overflow"
tmbf/processor/v/DAC_BUN_OVF->EnumLabels: Ok,\ 
                                                  Overflow
tmbf/processor/v/DAC_DELAY_S->description: "DAC output delay"
tmbf/processor/v/DAC_DRAM_SOURCE_S->description: "Source of memory data"
tmbf/processor/v/DAC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                        "After FIR"
tmbf/processor/v/DAC_ENABLE_S->description: "DAC output enable"
tmbf/processor/v/DAC_ENABLE_S->EnumLabels: Off,\ 
                                                   On
tmbf/processor/v/DAC_FILTER_DELAY_S->description: "Preemphasis filter group delay"
tmbf/processor/v/DAC_FILTER_DELAY_S->max_value: 7.0
tmbf/processor/v/DAC_FILTER_DELAY_S->min_value: 0.0
tmbf/processor/v/DAC_FILTER_S->description: "Output preemphasis filter"
tmbf/processor/v/DAC_FIR_OVF->description: "DAC FIR overflow"
tmbf/processor/v/DAC_FIR_OVF->EnumLabels: Ok,\ 
                                                  Overflow
tmbf/processor/v/DAC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
tmbf/processor/v/DAC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
tmbf/processor/v/DAC_MMS_DELTA->description: "Max DAC values per bunch"
tmbf/processor/v/DAC_MMS_MAX->description: "Max DAC values per bunch"
tmbf/processor/v/DAC_MMS_MEAN->description: "Mean DAC values per bunch"
tmbf/processor/v/DAC_MMS_MEAN_MEAN->description: "Mean position"
tmbf/processor/v/DAC_MMS_MEAN_MEAN->format: %.6f
tmbf/processor/v/DAC_MMS_MEAN_MEAN->max_value: 1.0
tmbf/processor/v/DAC_MMS_MEAN_MEAN->min_value: -1.0
tmbf/processor/v/DAC_MMS_MIN->description: "Min DAC values per bunch"
tmbf/processor/v/DAC_MMS_OVERFLOW->description: "MMS capture overflow status"
tmbf/processor/v/DAC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                                       "Turns Overflow",\ 
                                                       "Sum Overflow",\ 
                                                       "Turns+Sum Overflow",\ 
                                                       "Sum2 Overflow",\ 
                                                       "Turns+Sum2 Overflow",\ 
                                                       "Sum+Sum2 Overflow",\ 
                                                       "Turns+Sum+Sum2 Overflow"
tmbf/processor/v/DAC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
tmbf/processor/v/DAC_MMS_SCAN_CMD->description: "DAC min/max scanning"
tmbf/processor/v/DAC_MMS_SCAN_S->description: "DAC min/max scanning"
tmbf/processor/v/DAC_MMS_SCAN_S->EnumLabels: Passive,\ 
                                                     Event,\ 
                                                     "I/O Intr",\ 
                                                     "10 s",\ 
                                                     "5 s",\ 
                                                     "2 s",\ 
                                                     "1 s",\ 
                                                     "500 ms",\ 
                                                     "200 ms",\ 
                                                     "100 ms"
tmbf/processor/v/DAC_MMS_SOURCE_S->description: "Source of min/max/sum data"
tmbf/processor/v/DAC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                       "After FIR"
tmbf/processor/v/DAC_MMS_STD->description: "DAC standard deviation per bunch"
tmbf/processor/v/DAC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
tmbf/processor/v/DAC_MMS_STD_MEAN->archive_abs_change: -1e-06,\ 
                                                               1e-06
tmbf/processor/v/DAC_MMS_STD_MEAN->archive_period: 3600000
tmbf/processor/v/DAC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
tmbf/processor/v/DAC_MMS_STD_MEAN->event_period: 1234
tmbf/processor/v/DAC_MMS_STD_MEAN->format: %.6f
tmbf/processor/v/DAC_MMS_STD_MEAN->max_value: 1.0
tmbf/processor/v/DAC_MMS_STD_MEAN->min_value: 0.0
tmbf/processor/v/DAC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
tmbf/processor/v/DAC_MMS_STD_MEAN_DB->format: %.1f
tmbf/processor/v/DAC_MMS_STD_MEAN_DB->unit: dB
tmbf/processor/v/DAC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
tmbf/processor/v/DAC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
tmbf/processor/v/DAC_MMS_TURNS->description: "Number of turns in this sample"
tmbf/processor/v/DAC_MUX_OVF->description: "DAC output overflow"
tmbf/processor/v/DAC_MUX_OVF->EnumLabels: Ok,\ 
                                                  Overflow
tmbf/processor/v/DAC_OVF->description: "DAC overflow"
tmbf/processor/v/DAC_OVF->EnumLabels: Ok,\ 
                                              Overflow
tmbf/processor/v/DET_0_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/v/DET_0_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/DET_0_COUNT->description: "Number of enabled bunches"
tmbf/processor/v/DET_0_ENABLE->description: "Current detector enable state"
tmbf/processor/v/DET_0_ENABLE->EnumLabels: Disabled,\ 
                                                   Enabled
tmbf/processor/v/DET_0_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/v/DET_0_ENABLE_S->EnumLabels: Disabled,\ 
                                                     Enabled
tmbf/processor/v/DET_0_I->description: "Detector I"
tmbf/processor/v/DET_0_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/v/DET_0_MAX_POWER->unit: dB
tmbf/processor/v/DET_0_OUT_OVF->description: "Output overflow"
tmbf/processor/v/DET_0_OUT_OVF->EnumLabels: Ok,\ 
                                                    Overflow
tmbf/processor/v/DET_0_PHASE->description: "Detector Phase"
tmbf/processor/v/DET_0_POWER->description: "Detector Power"
tmbf/processor/v/DET_0_Q->description: "Detector Q"
tmbf/processor/v/DET_0_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/v/DET_0_SCALING_S->description: "Readout scaling"
tmbf/processor/v/DET_0_SCALING_S->EnumLabels: 0dB,\ 
                                                      -48dB
tmbf/processor/v/DET_0_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/DET_0_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/v/DET_1_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/v/DET_1_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/DET_1_COUNT->description: "Number of enabled bunches"
tmbf/processor/v/DET_1_ENABLE->description: "Current detector enable state"
tmbf/processor/v/DET_1_ENABLE->EnumLabels: Disabled,\ 
                                                   Enabled
tmbf/processor/v/DET_1_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/v/DET_1_ENABLE_S->EnumLabels: Disabled,\ 
                                                     Enabled
tmbf/processor/v/DET_1_I->description: "Detector I"
tmbf/processor/v/DET_1_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/v/DET_1_MAX_POWER->unit: dB
tmbf/processor/v/DET_1_OUT_OVF->description: "Output overflow"
tmbf/processor/v/DET_1_OUT_OVF->EnumLabels: Ok,\ 
                                                    Overflow
tmbf/processor/v/DET_1_PHASE->description: "Detector Phase"
tmbf/processor/v/DET_1_POWER->description: "Detector Power"
tmbf/processor/v/DET_1_Q->description: "Detector Q"
tmbf/processor/v/DET_1_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/v/DET_1_SCALING_S->description: "Readout scaling"
tmbf/processor/v/DET_1_SCALING_S->EnumLabels: 0dB,\ 
                                                      -48dB
tmbf/processor/v/DET_1_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/DET_1_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/v/DET_2_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/v/DET_2_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/DET_2_COUNT->description: "Number of enabled bunches"
tmbf/processor/v/DET_2_ENABLE->description: "Current detector enable state"
tmbf/processor/v/DET_2_ENABLE->EnumLabels: Disabled,\ 
                                                   Enabled
tmbf/processor/v/DET_2_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/v/DET_2_ENABLE_S->EnumLabels: Disabled,\ 
                                                     Enabled
tmbf/processor/v/DET_2_I->description: "Detector I"
tmbf/processor/v/DET_2_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/v/DET_2_MAX_POWER->unit: dB
tmbf/processor/v/DET_2_OUT_OVF->description: "Output overflow"
tmbf/processor/v/DET_2_OUT_OVF->EnumLabels: Ok,\ 
                                                    Overflow
tmbf/processor/v/DET_2_PHASE->description: "Detector Phase"
tmbf/processor/v/DET_2_POWER->description: "Detector Power"
tmbf/processor/v/DET_2_Q->description: "Detector Q"
tmbf/processor/v/DET_2_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/v/DET_2_SCALING_S->description: "Readout scaling"
tmbf/processor/v/DET_2_SCALING_S->EnumLabels: 0dB,\ 
                                                      -48dB
tmbf/processor/v/DET_2_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/DET_2_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/v/DET_3_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/v/DET_3_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/DET_3_COUNT->description: "Number of enabled bunches"
tmbf/processor/v/DET_3_ENABLE->description: "Current detector enable state"
tmbf/processor/v/DET_3_ENABLE->EnumLabels: Disabled,\ 
                                                   Enabled
tmbf/processor/v/DET_3_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/v/DET_3_ENABLE_S->EnumLabels: Disabled,\ 
                                                     Enabled
tmbf/processor/v/DET_3_I->description: "Detector I"
tmbf/processor/v/DET_3_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/v/DET_3_MAX_POWER->unit: dB
tmbf/processor/v/DET_3_OUT_OVF->description: "Output overflow"
tmbf/processor/v/DET_3_OUT_OVF->EnumLabels: Ok,\ 
                                                    Overflow
tmbf/processor/v/DET_3_PHASE->description: "Detector Phase"
tmbf/processor/v/DET_3_POWER->description: "Detector Power"
tmbf/processor/v/DET_3_Q->description: "Detector Q"
tmbf/processor/v/DET_3_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/v/DET_3_SCALING_S->description: "Readout scaling"
tmbf/processor/v/DET_3_SCALING_S->EnumLabels: 0dB,\ 
                                                      -48dB
tmbf/processor/v/DET_3_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/DET_3_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/v/DET_FILL_WAVEFORM_S->description: "Treatment of truncated waveforms"
tmbf/processor/v/DET_FILL_WAVEFORM_S->EnumLabels: Truncated,\ 
                                                          Filled
tmbf/processor/v/DET_FIR_DELAY_S->description: "FIR nominal group delay"
tmbf/processor/v/DET_FIR_DELAY_S->format: %4.1f
tmbf/processor/v/DET_FIR_DELAY_S->unit: turns
tmbf/processor/v/DET_SAMPLES->description: "Number of captured samples"
tmbf/processor/v/DET_SCALE->description: "Scale for frequency sweep"
tmbf/processor/v/DET_SELECT_S->description: "Select detector source"
tmbf/processor/v/DET_SELECT_S->EnumLabels: ADC,\ 
                                                   FIR,\ 
                                                   "ADC no fill"
tmbf/processor/v/DET_TIMEBASE->description: "Timebase for frequency sweep"
tmbf/processor/v/DET_UNDERRUN->description: "Data output underrun"
tmbf/processor/v/DET_UNDERRUN->EnumLabels: Ok,\ 
                                                   Underrun
tmbf/processor/v/DET_UPDATE_DONE_S->description: "UPDATE processing done"
tmbf/processor/v/DET_UPDATE_SCALE_DONE_S->description: "UPDATE_SCALE processing done"
tmbf/processor/v/DET_UPDATE_SCALE_TRIG->description: "UPDATE_SCALE processing trigger"
tmbf/processor/v/DET_UPDATE_TRIG->description: "UPDATE processing trigger"
tmbf/processor/v/FIR_0_CYCLES_S->description: "Cycles in filter"
tmbf/processor/v/FIR_0_CYCLES_S->format: %2d
tmbf/processor/v/FIR_0_CYCLES_S->max_value: 16.0
tmbf/processor/v/FIR_0_CYCLES_S->min_value: 1.0
tmbf/processor/v/FIR_0_LENGTH_S->description: "Length of filter"
tmbf/processor/v/FIR_0_LENGTH_S->format: %2d
tmbf/processor/v/FIR_0_LENGTH_S->max_value: 16.0
tmbf/processor/v/FIR_0_LENGTH_S->min_value: 2.0
tmbf/processor/v/FIR_0_PHASE_S->description: "FIR phase"
tmbf/processor/v/FIR_0_PHASE_S->format: %3.0f
tmbf/processor/v/FIR_0_PHASE_S->max_value: 360.0
tmbf/processor/v/FIR_0_PHASE_S->min_value: -360.0
tmbf/processor/v/FIR_0_RELOAD_S->description: "Reload filter"
tmbf/processor/v/FIR_0_TAPS->description: "Current waveform taps"
tmbf/processor/v/FIR_0_TAPS_S->description: "Set waveform taps"
tmbf/processor/v/FIR_0_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/v/FIR_0_USEWF_S->EnumLabels: Settings,\ 
                                                    Waveform
tmbf/processor/v/FIR_1_CYCLES_S->description: "Cycles in filter"
tmbf/processor/v/FIR_1_CYCLES_S->format: %2d
tmbf/processor/v/FIR_1_CYCLES_S->max_value: 16.0
tmbf/processor/v/FIR_1_CYCLES_S->min_value: 1.0
tmbf/processor/v/FIR_1_LENGTH_S->description: "Length of filter"
tmbf/processor/v/FIR_1_LENGTH_S->format: %2d
tmbf/processor/v/FIR_1_LENGTH_S->max_value: 16.0
tmbf/processor/v/FIR_1_LENGTH_S->min_value: 2.0
tmbf/processor/v/FIR_1_PHASE_S->description: "FIR phase"
tmbf/processor/v/FIR_1_PHASE_S->format: %3.0f
tmbf/processor/v/FIR_1_PHASE_S->max_value: 360.0
tmbf/processor/v/FIR_1_PHASE_S->min_value: -360.0
tmbf/processor/v/FIR_1_RELOAD_S->description: "Reload filter"
tmbf/processor/v/FIR_1_TAPS->description: "Current waveform taps"
tmbf/processor/v/FIR_1_TAPS_S->description: "Set waveform taps"
tmbf/processor/v/FIR_1_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/v/FIR_1_USEWF_S->EnumLabels: Settings,\ 
                                                    Waveform
tmbf/processor/v/FIR_2_CYCLES_S->description: "Cycles in filter"
tmbf/processor/v/FIR_2_CYCLES_S->format: %2d
tmbf/processor/v/FIR_2_CYCLES_S->max_value: 16.0
tmbf/processor/v/FIR_2_CYCLES_S->min_value: 1.0
tmbf/processor/v/FIR_2_LENGTH_S->description: "Length of filter"
tmbf/processor/v/FIR_2_LENGTH_S->format: %2d
tmbf/processor/v/FIR_2_LENGTH_S->max_value: 16.0
tmbf/processor/v/FIR_2_LENGTH_S->min_value: 2.0
tmbf/processor/v/FIR_2_PHASE_S->description: "FIR phase"
tmbf/processor/v/FIR_2_PHASE_S->format: %3.0f
tmbf/processor/v/FIR_2_PHASE_S->max_value: 360.0
tmbf/processor/v/FIR_2_PHASE_S->min_value: -360.0
tmbf/processor/v/FIR_2_RELOAD_S->description: "Reload filter"
tmbf/processor/v/FIR_2_TAPS->description: "Current waveform taps"
tmbf/processor/v/FIR_2_TAPS_S->description: "Set waveform taps"
tmbf/processor/v/FIR_2_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/v/FIR_2_USEWF_S->EnumLabels: Settings,\ 
                                                    Waveform
tmbf/processor/v/FIR_3_CYCLES_S->description: "Cycles in filter"
tmbf/processor/v/FIR_3_CYCLES_S->format: %2d
tmbf/processor/v/FIR_3_CYCLES_S->max_value: 16.0
tmbf/processor/v/FIR_3_CYCLES_S->min_value: 1.0
tmbf/processor/v/FIR_3_LENGTH_S->description: "Length of filter"
tmbf/processor/v/FIR_3_LENGTH_S->format: %2d
tmbf/processor/v/FIR_3_LENGTH_S->max_value: 16.0
tmbf/processor/v/FIR_3_LENGTH_S->min_value: 2.0
tmbf/processor/v/FIR_3_PHASE_S->description: "FIR phase"
tmbf/processor/v/FIR_3_PHASE_S->format: %3.0f
tmbf/processor/v/FIR_3_PHASE_S->max_value: 360.0
tmbf/processor/v/FIR_3_PHASE_S->min_value: -360.0
tmbf/processor/v/FIR_3_RELOAD_S->description: "Reload filter"
tmbf/processor/v/FIR_3_TAPS->description: "Current waveform taps"
tmbf/processor/v/FIR_3_TAPS_S->description: "Set waveform taps"
tmbf/processor/v/FIR_3_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/v/FIR_3_USEWF_S->EnumLabels: Settings,\ 
                                                    Waveform
tmbf/processor/v/FIR_GAIN_DN_S->description: "Decrease FIR gain"
tmbf/processor/v/FIR_GAIN_S->description: "FIR gain select"
tmbf/processor/v/FIR_GAIN_S->EnumLabels: 48dB,\ 
                                                 42dB,\ 
                                                 36dB,\ 
                                                 30dB,\ 
                                                 24dB,\ 
                                                 18dB,\ 
                                                 12dB,\ 
                                                 6dB,\ 
                                                 0dB,\ 
                                                 -6dB,\ 
                                                 -12dB,\ 
                                                 -18dB,\ 
                                                 -24dB,\ 
                                                 -30dB,\ 
                                                 -36dB,\ 
                                                 -42dB
tmbf/processor/v/FIR_GAIN_UP_S->description: "Increase FIR gain"
tmbf/processor/v/FIR_OVF->description: "Overflow in Y bunch-by-bunch filter"
tmbf/processor/v/FIR_OVF->EnumLabels: Ok,\ 
                                              Overflow
tmbf/processor/v/NCO_ENABLE_S->description: "Enable fixed NCO output"
tmbf/processor/v/NCO_ENABLE_S->EnumLabels: Off,\ 
                                                   On
tmbf/processor/v/NCO_FREQ_S->description: "Fixed NCO frequency"
tmbf/processor/v/NCO_FREQ_S->format: %8.5f
tmbf/processor/v/NCO_GAIN_S->description: "Fixed NCO gain"
tmbf/processor/v/NCO_GAIN_S->EnumLabels: 0dB,\ 
                                                 -6dB,\ 
                                                 -12dB,\ 
                                                 -18dB,\ 
                                                 -24dB,\ 
                                                 -30dB,\ 
                                                 -36dB,\ 
                                                 -42dB,\ 
                                                 -48dB,\ 
                                                 -54dB,\ 
                                                 -60dB,\ 
                                                 -66dB,\ 
                                                 -72dB,\ 
                                                 -78dB,\ 
                                                 -84dB,\ 
                                                 -90dB
tmbf/processor/v/PLL_CTRL_KI_S->description: "Integral factor for controller"
tmbf/processor/v/PLL_CTRL_KP_S->description: "Proportional factor for controller"
tmbf/processor/v/PLL_CTRL_MAX_OFFSET_S->description: "Maximum frequency offset for feedback"
tmbf/processor/v/PLL_CTRL_MAX_OFFSET_S->format: %.7f
tmbf/processor/v/PLL_CTRL_MAX_OFFSET_S->unit: tune
tmbf/processor/v/PLL_CTRL_MIN_MAG_S->description: "Minimum magnitude for feedback"
tmbf/processor/v/PLL_CTRL_MIN_MAG_S->format: %1.5f
tmbf/processor/v/PLL_CTRL_MIN_MAG_S->max_value: 1.0
tmbf/processor/v/PLL_CTRL_MIN_MAG_S->min_value: 0.0
tmbf/processor/v/PLL_CTRL_START_S->description: "Start tune PLL"
tmbf/processor/v/PLL_CTRL_STATUS->description: "Tune PLL feedback status"
tmbf/processor/v/PLL_CTRL_STATUS->EnumLabels: Stopped,\ 
                                                      Running
tmbf/processor/v/PLL_CTRL_STOP_DET_OVF->description: "Detector overflow"
tmbf/processor/v/PLL_CTRL_STOP_DET_OVF->EnumLabels: Ok,\ 
                                                            Overflow
tmbf/processor/v/PLL_CTRL_STOP_MAG_ERROR->description: "Magnitude error"
tmbf/processor/v/PLL_CTRL_STOP_MAG_ERROR->EnumLabels: Ok,\ 
                                                              "Too small"
tmbf/processor/v/PLL_CTRL_STOP_OFFSET_OVF->description: "Offset overflow"
tmbf/processor/v/PLL_CTRL_STOP_OFFSET_OVF->EnumLabels: Ok,\ 
                                                               Overflow
tmbf/processor/v/PLL_CTRL_STOP_S->description: "Stop tune PLL"
tmbf/processor/v/PLL_CTRL_STOP_STOP->description: "Stopped by user"
tmbf/processor/v/PLL_CTRL_STOP_STOP->EnumLabels: Ok,\ 
                                                         Stopped
tmbf/processor/v/PLL_CTRL_TARGET_S->description: "Target phase"
tmbf/processor/v/PLL_CTRL_TARGET_S->format: %3.2f
tmbf/processor/v/PLL_CTRL_TARGET_S->max_value: 180.0
tmbf/processor/v/PLL_CTRL_TARGET_S->min_value: -180.0
tmbf/processor/v/PLL_CTRL_UPDATE_STATUS_DONE_S->description: "UPDATE_STATUS processing done"
tmbf/processor/v/PLL_CTRL_UPDATE_STATUS_TRIG->description: "UPDATE_STATUS processing trigger"
tmbf/processor/v/PLL_DEBUG_ANGLE->description: "Tune PLL angle"
tmbf/processor/v/PLL_DEBUG_COMPENSATE_S->description: "Compensate debug readbacks"
tmbf/processor/v/PLL_DEBUG_COMPENSATE_S->EnumLabels: Raw,\ 
                                                             Compensated
tmbf/processor/v/PLL_DEBUG_ENABLE_S->description: "Enable debug readbacks"
tmbf/processor/v/PLL_DEBUG_ENABLE_S->EnumLabels: Off,\ 
                                                         On
tmbf/processor/v/PLL_DEBUG_FIFO_OVF->description: "Debug FIFO readout overrun"
tmbf/processor/v/PLL_DEBUG_FIFO_OVF->EnumLabels: Ok,\ 
                                                         Overflow
tmbf/processor/v/PLL_DEBUG_MAG->description: "Tune PLL magnitude"
tmbf/processor/v/PLL_DEBUG_READ_DONE_S->description: "READ processing done"
tmbf/processor/v/PLL_DEBUG_READ_TRIG->description: "READ processing trigger"
tmbf/processor/v/PLL_DEBUG_RSTD->description: "IQ relative standard deviation"
tmbf/processor/v/PLL_DEBUG_RSTD_ABS->description: "Magnitude relative standard deviation"
tmbf/processor/v/PLL_DEBUG_RSTD_ABS_DB->unit: dB
tmbf/processor/v/PLL_DEBUG_RSTD_DB->unit: dB
tmbf/processor/v/PLL_DEBUG_SELECT_S->description: "Select captured readback values"
tmbf/processor/v/PLL_DEBUG_SELECT_S->EnumLabels: IQ,\ 
                                                         CORDIC
tmbf/processor/v/PLL_DEBUG_WFI->description: "Tune PLL detector I"
tmbf/processor/v/PLL_DEBUG_WFQ->description: "Tune PLL detector Q"
tmbf/processor/v/PLL_DET_BLANKING_S->description: "Response to blanking trigger"
tmbf/processor/v/PLL_DET_BLANKING_S->EnumLabels: Ignore,\ 
                                                         Blanking
tmbf/processor/v/PLL_DET_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/v/PLL_DET_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/v/PLL_DET_COUNT->description: "Number of enabled bunches"
tmbf/processor/v/PLL_DET_DWELL_S->description: "Dwell time in turns"
tmbf/processor/v/PLL_DET_DWELL_S->format: %5d
tmbf/processor/v/PLL_DET_DWELL_S->max_value: 65536.0
tmbf/processor/v/PLL_DET_DWELL_S->min_value: 1.0
tmbf/processor/v/PLL_DET_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/v/PLL_DET_SCALING_S->description: "Readout scaling"
tmbf/processor/v/PLL_DET_SCALING_S->EnumLabels: 48dB,\ 
                                                        12dB,\ 
                                                        -24dB,\ 
                                                        -60dB
tmbf/processor/v/PLL_DET_SELECT_S->description: "Select detector source"
tmbf/processor/v/PLL_DET_SELECT_S->EnumLabels: ADC,\ 
                                                       FIR,\ 
                                                       "ADC no fill"
tmbf/processor/v/PLL_DET_SELECT_STATUS->description: "Status of selection"
tmbf/processor/v/PLL_DET_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/v/PLL_FILT_I->description: "Filtered Tune PLL detector I"
tmbf/processor/v/PLL_FILT_MAG->description: "Filtered Tune PLL detector magnitude"
tmbf/processor/v/PLL_FILT_MAG_DB->unit: dB
tmbf/processor/v/PLL_FILT_PHASE->description: "Filtered Tune PLL phase offset"
tmbf/processor/v/PLL_FILT_PHASE->unit: deg
tmbf/processor/v/PLL_FILT_Q->description: "Filtered Tune PLL detector Q"
tmbf/processor/v/PLL_NCO_ENABLE_S->description: "Enable Tune PLL NCO output"
tmbf/processor/v/PLL_NCO_ENABLE_S->EnumLabels: Off,\ 
                                                       On
tmbf/processor/v/PLL_NCO_FIFO_OVF->description: "Offset FIFO readout overrun"
tmbf/processor/v/PLL_NCO_FIFO_OVF->EnumLabels: Ok,\ 
                                                       Overflow
tmbf/processor/v/PLL_NCO_FREQ->description: "Tune PLL NCO frequency"
tmbf/processor/v/PLL_NCO_FREQ->unit: tune
tmbf/processor/v/PLL_NCO_FREQ_S->description: "Base Tune PLL NCO frequency"
tmbf/processor/v/PLL_NCO_FREQ_S->format: %.7f
tmbf/processor/v/PLL_NCO_FREQ_S->unit: tune
tmbf/processor/v/PLL_NCO_GAIN_S->description: "Tune PLL NCO gain"
tmbf/processor/v/PLL_NCO_GAIN_S->EnumLabels: 0dB,\ 
                                                     -6dB,\ 
                                                     -12dB,\ 
                                                     -18dB,\ 
                                                     -24dB,\ 
                                                     -30dB,\ 
                                                     -36dB,\ 
                                                     -42dB,\ 
                                                     -48dB,\ 
                                                     -54dB,\ 
                                                     -60dB,\ 
                                                     -66dB,\ 
                                                     -72dB,\ 
                                                     -78dB,\ 
                                                     -84dB,\ 
                                                     -90dB
tmbf/processor/v/PLL_NCO_MEAN_OFFSET->description: "Mean tune PLL offset"
tmbf/processor/v/PLL_NCO_MEAN_OFFSET->unit: tune
tmbf/processor/v/PLL_NCO_OFFSET->description: "Filtered frequency offset"
tmbf/processor/v/PLL_NCO_OFFSET->unit: tune
tmbf/processor/v/PLL_NCO_OFFSETWF->description: "Tune PLL offset"
tmbf/processor/v/PLL_NCO_READ_DONE_S->description: "READ processing done"
tmbf/processor/v/PLL_NCO_READ_TRIG->description: "READ processing trigger"
tmbf/processor/v/PLL_NCO_RESET_FIFO_S->description: "Reset FIFO readout to force fresh sample"
tmbf/processor/v/PLL_NCO_STD_OFFSET->description: "Standard deviation of offset"
tmbf/processor/v/PLL_NCO_STD_OFFSET->unit: tune
tmbf/processor/v/PLL_NCO_TUNE->description: "Measured tune frequency"
tmbf/processor/v/PLL_NCO_TUNE->unit: tune
tmbf/processor/v/PLL_POLL_S->description: "Poll Tune PLL readbacks"
tmbf/processor/v/PLL_STA_DET_OVF->description: "Detector overflow"
tmbf/processor/v/PLL_STA_DET_OVF->EnumLabels: Ok,\ 
                                                      Overflow
tmbf/processor/v/PLL_STA_MAG_ERROR->description: "Magnitude error"
tmbf/processor/v/PLL_STA_MAG_ERROR->EnumLabels: Ok,\ 
                                                        "Too small"
tmbf/processor/v/PLL_STA_OFFSET_OVF->description: "Offset overflow"
tmbf/processor/v/PLL_STA_OFFSET_OVF->EnumLabels: Ok,\ 
                                                         Overflow
tmbf/processor/v/SEQ_0_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_0_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_1_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_1_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_1_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_1_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_1_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_1_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_1_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_1_COUNT_S->format: %5d
tmbf/processor/v/SEQ_1_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_1_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_1_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_1_DWELL_S->format: %5d
tmbf/processor/v/SEQ_1_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_1_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_1_DWELL_S->unit: turns
tmbf/processor/v/SEQ_1_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_1_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_1_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_1_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_1_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_1_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_1_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_1_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_1_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_1_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_1_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_1_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_1_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_1_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_1_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_1_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_1_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_1_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_1_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_1_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_1_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_1_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_1_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_1_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_1_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_1_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_2_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_2_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_2_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_2_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_2_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_2_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_2_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_2_COUNT_S->format: %5d
tmbf/processor/v/SEQ_2_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_2_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_2_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_2_DWELL_S->format: %5d
tmbf/processor/v/SEQ_2_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_2_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_2_DWELL_S->unit: turns
tmbf/processor/v/SEQ_2_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_2_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_2_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_2_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_2_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_2_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_2_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_2_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_2_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_2_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_2_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_2_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_2_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_2_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_2_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_2_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_2_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_2_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_2_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_2_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_2_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_2_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_2_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_2_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_2_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_2_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_3_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_3_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_3_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_3_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_3_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_3_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_3_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_3_COUNT_S->format: %5d
tmbf/processor/v/SEQ_3_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_3_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_3_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_3_DWELL_S->format: %5d
tmbf/processor/v/SEQ_3_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_3_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_3_DWELL_S->unit: turns
tmbf/processor/v/SEQ_3_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_3_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_3_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_3_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_3_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_3_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_3_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_3_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_3_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_3_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_3_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_3_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_3_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_3_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_3_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_3_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_3_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_3_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_3_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_3_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_3_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_3_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_3_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_3_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_3_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_3_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_4_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_4_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_4_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_4_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_4_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_4_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_4_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_4_COUNT_S->format: %5d
tmbf/processor/v/SEQ_4_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_4_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_4_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_4_DWELL_S->format: %5d
tmbf/processor/v/SEQ_4_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_4_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_4_DWELL_S->unit: turns
tmbf/processor/v/SEQ_4_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_4_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_4_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_4_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_4_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_4_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_4_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_4_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_4_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_4_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_4_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_4_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_4_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_4_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_4_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_4_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_4_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_4_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_4_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_4_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_4_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_4_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_4_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_4_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_4_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_4_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_5_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_5_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_5_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_5_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_5_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_5_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_5_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_5_COUNT_S->format: %5d
tmbf/processor/v/SEQ_5_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_5_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_5_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_5_DWELL_S->format: %5d
tmbf/processor/v/SEQ_5_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_5_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_5_DWELL_S->unit: turns
tmbf/processor/v/SEQ_5_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_5_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_5_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_5_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_5_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_5_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_5_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_5_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_5_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_5_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_5_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_5_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_5_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_5_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_5_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_5_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_5_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_5_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_5_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_5_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_5_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_5_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_5_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_5_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_5_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_5_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_6_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_6_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_6_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_6_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_6_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_6_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_6_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_6_COUNT_S->format: %5d
tmbf/processor/v/SEQ_6_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_6_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_6_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_6_DWELL_S->format: %5d
tmbf/processor/v/SEQ_6_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_6_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_6_DWELL_S->unit: turns
tmbf/processor/v/SEQ_6_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_6_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_6_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_6_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_6_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_6_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_6_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_6_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_6_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_6_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_6_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_6_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_6_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_6_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_6_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_6_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_6_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_6_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_6_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_6_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_6_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_6_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_6_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_6_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_6_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_6_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_7_BANK_S->description: "Bunch bank selection"
tmbf/processor/v/SEQ_7_BANK_S->EnumLabels: "Bank 0",\ 
                                                   "Bank 1",\ 
                                                   "Bank 2",\ 
                                                   "Bank 3"
tmbf/processor/v/SEQ_7_BLANK_S->description: "Detector blanking control"
tmbf/processor/v/SEQ_7_BLANK_S->EnumLabels: Off,\ 
                                                    Blanking
tmbf/processor/v/SEQ_7_CAPTURE_S->description: "Enable data capture"
tmbf/processor/v/SEQ_7_CAPTURE_S->EnumLabels: Discard,\ 
                                                      Capture
tmbf/processor/v/SEQ_7_COUNT_S->description: "Sweep count"
tmbf/processor/v/SEQ_7_COUNT_S->format: %5d
tmbf/processor/v/SEQ_7_COUNT_S->max_value: 65536.0
tmbf/processor/v/SEQ_7_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_7_DWELL_S->description: "Sweep dwell time"
tmbf/processor/v/SEQ_7_DWELL_S->format: %5d
tmbf/processor/v/SEQ_7_DWELL_S->max_value: 65536.0
tmbf/processor/v/SEQ_7_DWELL_S->min_value: 1.0
tmbf/processor/v/SEQ_7_DWELL_S->unit: turns
tmbf/processor/v/SEQ_7_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/v/SEQ_7_ENABLE_S->EnumLabels: Off,\ 
                                                     On
tmbf/processor/v/SEQ_7_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/v/SEQ_7_END_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_7_END_FREQ_S->unit: tune
tmbf/processor/v/SEQ_7_ENWIN_S->description: "Enable detector window"
tmbf/processor/v/SEQ_7_ENWIN_S->EnumLabels: Disabled,\ 
                                                    Windowed
tmbf/processor/v/SEQ_7_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/v/SEQ_7_GAIN_S->EnumLabels: 0dB,\ 
                                                   -6dB,\ 
                                                   -12dB,\ 
                                                   -18dB,\ 
                                                   -24dB,\ 
                                                   -30dB,\ 
                                                   -36dB,\ 
                                                   -42dB,\ 
                                                   -48dB,\ 
                                                   -54dB,\ 
                                                   -60dB,\ 
                                                   -66dB,\ 
                                                   -72dB,\ 
                                                   -78dB,\ 
                                                   -84dB,\ 
                                                   -90dB
tmbf/processor/v/SEQ_7_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/v/SEQ_7_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_7_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_7_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_7_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/v/SEQ_7_START_FREQ_S->format: %8.5f
tmbf/processor/v/SEQ_7_START_FREQ_S->unit: tune
tmbf/processor/v/SEQ_7_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/v/SEQ_7_STATE_HOLDOFF_S->format: %5d
tmbf/processor/v/SEQ_7_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/v/SEQ_7_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/v/SEQ_7_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/v/SEQ_7_STEP_FREQ_S->format: %10.7f
tmbf/processor/v/SEQ_7_STEP_FREQ_S->unit: tune
tmbf/processor/v/SEQ_7_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/v/SEQ_7_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                       Follow
tmbf/processor/v/SEQ_7_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/v/SEQ_BUSY->description: "Sequencer busy state"
tmbf/processor/v/SEQ_BUSY->EnumLabels: Idle,\ 
                                               Busy
tmbf/processor/v/SEQ_DURATION->description: "Raw capture duration"
tmbf/processor/v/SEQ_DURATION->unit: turns
tmbf/processor/v/SEQ_DURATION_S->description: "Capture duration"
tmbf/processor/v/SEQ_DURATION_S->format: %.3f
tmbf/processor/v/SEQ_DURATION_S->unit: s
tmbf/processor/v/SEQ_LENGTH->description: "Sequencer capture count"
tmbf/processor/v/SEQ_MODE->description: "Sequencer mode"
tmbf/processor/v/SEQ_PC->description: "Current sequencer state"
tmbf/processor/v/SEQ_PC_S->description: "Sequencer PC"
tmbf/processor/v/SEQ_PC_S->format: %1d
tmbf/processor/v/SEQ_PC_S->max_value: 7.0
tmbf/processor/v/SEQ_PC_S->min_value: 1.0
tmbf/processor/v/SEQ_RESET_S->description: "Halt sequencer if busy"
tmbf/processor/v/SEQ_RESET_WIN_S->description: "Reset detector window to Hamming"
tmbf/processor/v/SEQ_STATUS_READ_S->description: "Poll sequencer status"
tmbf/processor/v/SEQ_SUPER_COUNT->description: "Current super sequencer count"
tmbf/processor/v/SEQ_SUPER_COUNT->max_value: 1024.0
tmbf/processor/v/SEQ_SUPER_COUNT->min_value: 0.0
tmbf/processor/v/SEQ_SUPER_COUNT_S->description: "Super sequencer count"
tmbf/processor/v/SEQ_SUPER_COUNT_S->format: %4d
tmbf/processor/v/SEQ_SUPER_COUNT_S->max_value: 1024.0
tmbf/processor/v/SEQ_SUPER_COUNT_S->min_value: 1.0
tmbf/processor/v/SEQ_SUPER_OFFSET_S->description: "Frequency offsets for super sequencer"
tmbf/processor/v/SEQ_SUPER_OFFSET_S->format: %.5f
tmbf/processor/v/SEQ_SUPER_RESET_S->description: "Reset super sequencer offsets"
tmbf/processor/v/SEQ_TOTAL_DURATION->description: "Super sequence raw capture duration"
tmbf/processor/v/SEQ_TOTAL_DURATION->format: %.0f
tmbf/processor/v/SEQ_TOTAL_DURATION->unit: turns
tmbf/processor/v/SEQ_TOTAL_DURATION_S->description: "Super capture duration"
tmbf/processor/v/SEQ_TOTAL_DURATION_S->format: %.3f
tmbf/processor/v/SEQ_TOTAL_DURATION_S->unit: s
tmbf/processor/v/SEQ_TOTAL_LENGTH->description: "Super sequencer capture count"
tmbf/processor/v/SEQ_TOTAL_LENGTH->format: %.0f
tmbf/processor/v/SEQ_TRIGGER_S->description: "State to generate sequencer trigger"
tmbf/processor/v/SEQ_TRIGGER_S->format: %1d
tmbf/processor/v/SEQ_TRIGGER_S->max_value: 7.0
tmbf/processor/v/SEQ_TRIGGER_S->min_value: 0.0
tmbf/processor/v/SEQ_UPDATE_COUNT_S->description: "Internal sequencer state update"
tmbf/processor/v/SEQ_WINDOW_S->description: "Detector window"
tmbf/processor/v/STA_STATUS->description: "Axis Y signal health"
tmbf/processor/v/TRG_SEQ_ADC0_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_ADC0_BL_S->EnumLabels: All,\ 
                                                        Blanking
tmbf/processor/v/TRG_SEQ_ADC0_EN_S->description: "Enable Y ADC event input"
tmbf/processor/v/TRG_SEQ_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                        Enable
tmbf/processor/v/TRG_SEQ_ADC0_HIT->description: "Y ADC event source"
tmbf/processor/v/TRG_SEQ_ADC0_HIT->EnumLabels: No,\ 
                                                       Yes
tmbf/processor/v/TRG_SEQ_ADC1_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_ADC1_BL_S->EnumLabels: All,\ 
                                                        Blanking
tmbf/processor/v/TRG_SEQ_ADC1_EN_S->description: "Enable X ADC event input"
tmbf/processor/v/TRG_SEQ_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                        Enable
tmbf/processor/v/TRG_SEQ_ADC1_HIT->description: "X ADC event source"
tmbf/processor/v/TRG_SEQ_ADC1_HIT->EnumLabels: No,\ 
                                                       Yes
tmbf/processor/v/TRG_SEQ_ARM_S->description: "Arm trigger"
tmbf/processor/v/TRG_SEQ_BL_S->description: "Write blanking"
tmbf/processor/v/TRG_SEQ_DELAY_S->description: "Trigger delay"
tmbf/processor/v/TRG_SEQ_DELAY_S->format: %3d
tmbf/processor/v/TRG_SEQ_DELAY_S->max_value: 65535.0
tmbf/processor/v/TRG_SEQ_DELAY_S->min_value: 0.0
tmbf/processor/v/TRG_SEQ_DISARM_S->description: "Disarm trigger"
tmbf/processor/v/TRG_SEQ_EN_S->description: "Write enables"
tmbf/processor/v/TRG_SEQ_EXT_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_EXT_BL_S->EnumLabels: All,\ 
                                                       Blanking
tmbf/processor/v/TRG_SEQ_EXT_EN_S->description: "Enable External trigger input"
tmbf/processor/v/TRG_SEQ_EXT_EN_S->EnumLabels: Ignore,\ 
                                                       Enable
tmbf/processor/v/TRG_SEQ_EXT_HIT->description: "External trigger source"
tmbf/processor/v/TRG_SEQ_EXT_HIT->EnumLabels: No,\ 
                                                      Yes
tmbf/processor/v/TRG_SEQ_HIT->description: "Update source events"
tmbf/processor/v/TRG_SEQ_MODE_S->description: "Arming mode"
tmbf/processor/v/TRG_SEQ_MODE_S->EnumLabels: "One Shot",\ 
                                                     Rearm,\ 
                                                     Shared
tmbf/processor/v/TRG_SEQ_PM_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_PM_BL_S->EnumLabels: All,\ 
                                                      Blanking
tmbf/processor/v/TRG_SEQ_PM_EN_S->description: "Enable Postmortem trigger input"
tmbf/processor/v/TRG_SEQ_PM_EN_S->EnumLabels: Ignore,\ 
                                                      Enable
tmbf/processor/v/TRG_SEQ_PM_HIT->description: "Postmortem trigger source"
tmbf/processor/v/TRG_SEQ_PM_HIT->EnumLabels: No,\ 
                                                     Yes
tmbf/processor/v/TRG_SEQ_SEQ0_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_SEQ0_BL_S->EnumLabels: All,\ 
                                                        Blanking
tmbf/processor/v/TRG_SEQ_SEQ0_EN_S->description: "Enable Y SEQ event input"
tmbf/processor/v/TRG_SEQ_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                        Enable
tmbf/processor/v/TRG_SEQ_SEQ0_HIT->description: "Y SEQ event source"
tmbf/processor/v/TRG_SEQ_SEQ0_HIT->EnumLabels: No,\ 
                                                       Yes
tmbf/processor/v/TRG_SEQ_SEQ1_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_SEQ1_BL_S->EnumLabels: All,\ 
                                                        Blanking
tmbf/processor/v/TRG_SEQ_SEQ1_EN_S->description: "Enable X SEQ event input"
tmbf/processor/v/TRG_SEQ_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                        Enable
tmbf/processor/v/TRG_SEQ_SEQ1_HIT->description: "X SEQ event source"
tmbf/processor/v/TRG_SEQ_SEQ1_HIT->EnumLabels: No,\ 
                                                       Yes
tmbf/processor/v/TRG_SEQ_SOFT_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/v/TRG_SEQ_SOFT_BL_S->EnumLabels: All,\ 
                                                        Blanking
tmbf/processor/v/TRG_SEQ_SOFT_EN_S->description: "Enable Soft trigger input"
tmbf/processor/v/TRG_SEQ_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                        Enable
tmbf/processor/v/TRG_SEQ_SOFT_HIT->description: "Soft trigger source"
tmbf/processor/v/TRG_SEQ_SOFT_HIT->EnumLabels: No,\ 
                                                       Yes
tmbf/processor/v/TRG_SEQ_STATUS->description: "Trigger target status"
tmbf/processor/v/TRG_SEQ_STATUS->EnumLabels: Idle,\ 
                                                     Armed,\ 
                                                     Busy,\ 
                                                     Locked

#---------------------------------------------------------
# CLASS Tango2Epics properties
#---------------------------------------------------------

CLASS/Tango2Epics->Description: "A device can be integrated in Tango control system by developing a ",\ 
                                "specific Tango device server software for the device. In situations when",\ 
                                "the Tango device server software is not available for the device, ",\ 
                                "but software support for the EPICS control system is available instead, ",\ 
                                "it is possible to use the Tango2Epics Tango device server to expose ",\ 
                                "the device in Tango system. It serves as a bridge, in form of a Tango device, ",\ 
                                "to EPICS control system. PVaccess device exposes the existing EPICS ",\ 
                                "Process Variables (PVs) of the device in form of Tango device attributes, ",\ 
                                "states, and emulates a preconfigured set of Tango device commands by ",\ 
                                "using the appropriate EPICS PVs. By using the Tango2Epics Tango device, ",\ 
                                "integration can be achieved through configuration only, with no development ",\ 
                                "required. More information can be found in the user manual, located: ",\ 
                                "http://sourceforge.net/p/tango-ds/code/HEAD/tree/DeviceClasses/Communication/Tango2Epics/trunk/doc/Tango2EpicsGateway.pdf."
CLASS/Tango2Epics->doc_url: "http://www.esrf.eu/computing/cs/tango/tango_doc/ds_doc/"
CLASS/Tango2Epics->InheritedFrom: TANGO_BASE_CLASS
CLASS/Tango2Epics->ProjectTitle: "Tango2Epics Tango Device"

# CLASS Tango2Epics attribute properties



# --- dserver/Tango2Epics/tmbf-v properties

dserver/Tango2Epics/tmbf-v->polling_threads_pool_conf: "tmbf/processor/v"
