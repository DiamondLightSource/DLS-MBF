#
# Resource backup , created Tue Feb 11 12:10:09 CET 2020
#

#---------------------------------------------------------
# SERVER Tango2Epics/tmbf-h, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/tmbf-h/DEVICE/Tango2Epics: "tmbf/processor/h"


# --- tmbf/processor/h properties

tmbf/processor/h->ArrayAccessTimeout: 0.3
tmbf/processor/h->HelperApplication: "tmbf-gui h"
tmbf/processor/h->polled_attr: dac_mms_std_mean,\ 
                               1000
tmbf/processor/h->ScalarAccessTimeout: 0.2
tmbf/processor/h->SubscriptionCycle: 0.4
tmbf/processor/h->Variables: T-TMBF:X:ADC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_DRAM_SOURCE_S,\ 
                             T-TMBF:X:ADC:EVENT*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_EVENT,\ 
                             T-TMBF:X:ADC:EVENT_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*ADC_EVENT_LIMIT_S,\ 
                             T-TMBF:X:ADC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*ADC_FILTER_S,\ 
                             T-TMBF:X:ADC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_FIR_OVF,\ 
                             T-TMBF:X:ADC:INP_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_INP_OVF,\ 
                             T-TMBF:X:ADC:LOOPBACK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_LOOPBACK_S,\ 
                             T-TMBF:X:ADC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_ARCHIVE_DONE_S,\ 
                             T-TMBF:X:ADC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*ADC_MMS_ARCHIVE_TRIG,\ 
                             T-TMBF:X:ADC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_ARCHIVE_TRIG_FAN,\ 
                             T-TMBF:X:ADC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_DELTA,\ 
                             T-TMBF:X:ADC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_FAN,\ 
                             T-TMBF:X:ADC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_FAN1,\ 
                             T-TMBF:X:ADC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MAX,\ 
                             T-TMBF:X:ADC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MEAN,\ 
                             T-TMBF:X:ADC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MEAN_MEAN,\ 
                             T-TMBF:X:ADC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MIN,\ 
                             T-TMBF:X:ADC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_MMS_OVERFLOW,\ 
                             T-TMBF:X:ADC:MMS:RESET_FAULT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_RESET_FAULT_S,\ 
                             T-TMBF:X:ADC:MMS:SCAN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_SCAN_CMD,\ 
                             T-TMBF:X:ADC:MMS:SCAN_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_SCAN_S,\ 
                             T-TMBF:X:ADC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD,\ 
                             T-TMBF:X:ADC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MAX_WF,\ 
                             T-TMBF:X:ADC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN,\ 
                             T-TMBF:X:ADC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN_DB,\ 
                             T-TMBF:X:ADC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN_WF,\ 
                             T-TMBF:X:ADC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MIN_WF,\ 
                             T-TMBF:X:ADC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*ADC_MMS_TURNS,\ 
                             T-TMBF:X:ADC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_MMS_SOURCE_S,\ 
                             T-TMBF:X:ADC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_OVF,\ 
                             T-TMBF:X:ADC:OVF_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*ADC_OVF_LIMIT_S,\ 
                             T-TMBF:X:ADC:REJECT_COUNT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_REJECT_COUNT_S,\ 
                             T-TMBF:X:BUN:0:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_0_BUNCH_SELECT_S,\ 
                             T-TMBF:X:BUN:0:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_0_DAC_SELECT_S,\ 
                             T-TMBF:X:BUN:0:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_0_FIRWF_SET_S,\ 
                             T-TMBF:X:BUN:0:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_FIRWF_STA,\ 
                             T-TMBF:X:BUN:0:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_0_FIRWF_S,\ 
                             T-TMBF:X:BUN:0:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_0_FIR_SELECT_S,\ 
                             T-TMBF:X:BUN:0:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_0_GAINWF_SET_S,\ 
                             T-TMBF:X:BUN:0:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_GAINWF_STA,\ 
                             T-TMBF:X:BUN:0:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_0_GAINWF_S,\ 
                             T-TMBF:X:BUN:0:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_0_GAIN_SELECT_S,\ 
                             T-TMBF:X:BUN:0:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_0_OUTWF_SET_S,\ 
                             T-TMBF:X:BUN:0:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_OUTWF_STA,\ 
                             T-TMBF:X:BUN:0:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_0_OUTWF_S,\ 
                             T-TMBF:X:BUN:0:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_SELECT_STATUS,\ 
                             T-TMBF:X:BUN:1:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_1_BUNCH_SELECT_S,\ 
                             T-TMBF:X:BUN:1:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_1_DAC_SELECT_S,\ 
                             T-TMBF:X:BUN:1:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_1_FIRWF_SET_S,\ 
                             T-TMBF:X:BUN:1:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_FIRWF_STA,\ 
                             T-TMBF:X:BUN:1:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_1_FIRWF_S,\ 
                             T-TMBF:X:BUN:1:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_1_FIR_SELECT_S,\ 
                             T-TMBF:X:BUN:1:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_1_GAINWF_SET_S,\ 
                             T-TMBF:X:BUN:1:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_GAINWF_STA,\ 
                             T-TMBF:X:BUN:1:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_1_GAINWF_S,\ 
                             T-TMBF:X:BUN:1:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_1_GAIN_SELECT_S,\ 
                             T-TMBF:X:BUN:1:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_1_OUTWF_SET_S,\ 
                             T-TMBF:X:BUN:1:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_OUTWF_STA,\ 
                             T-TMBF:X:BUN:1:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_1_OUTWF_S,\ 
                             T-TMBF:X:BUN:1:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_SELECT_STATUS,\ 
                             T-TMBF:X:BUN:2:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_2_BUNCH_SELECT_S,\ 
                             T-TMBF:X:BUN:2:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_2_DAC_SELECT_S,\ 
                             T-TMBF:X:BUN:2:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_2_FIRWF_SET_S,\ 
                             T-TMBF:X:BUN:2:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_FIRWF_STA,\ 
                             T-TMBF:X:BUN:2:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_2_FIRWF_S,\ 
                             T-TMBF:X:BUN:2:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_2_FIR_SELECT_S,\ 
                             T-TMBF:X:BUN:2:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_2_GAINWF_SET_S,\ 
                             T-TMBF:X:BUN:2:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_GAINWF_STA,\ 
                             T-TMBF:X:BUN:2:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_2_GAINWF_S,\ 
                             T-TMBF:X:BUN:2:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_2_GAIN_SELECT_S,\ 
                             T-TMBF:X:BUN:2:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_2_OUTWF_SET_S,\ 
                             T-TMBF:X:BUN:2:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_OUTWF_STA,\ 
                             T-TMBF:X:BUN:2:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_2_OUTWF_S,\ 
                             T-TMBF:X:BUN:2:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_SELECT_STATUS,\ 
                             T-TMBF:X:BUN:3:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*BUN_3_BUNCH_SELECT_S,\ 
                             T-TMBF:X:BUN:3:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_3_DAC_SELECT_S,\ 
                             T-TMBF:X:BUN:3:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_3_FIRWF_SET_S,\ 
                             T-TMBF:X:BUN:3:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_FIRWF_STA,\ 
                             T-TMBF:X:BUN:3:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_3_FIRWF_S,\ 
                             T-TMBF:X:BUN:3:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*BUN_3_FIR_SELECT_S,\ 
                             T-TMBF:X:BUN:3:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_3_GAINWF_SET_S,\ 
                             T-TMBF:X:BUN:3:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_GAINWF_STA,\ 
                             T-TMBF:X:BUN:3:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*BUN_3_GAINWF_S,\ 
                             T-TMBF:X:BUN:3:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*BUN_3_GAIN_SELECT_S,\ 
                             T-TMBF:X:BUN:3:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*BUN_3_OUTWF_SET_S,\ 
                             T-TMBF:X:BUN:3:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_OUTWF_STA,\ 
                             T-TMBF:X:BUN:3:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*BUN_3_OUTWF_S,\ 
                             T-TMBF:X:BUN:3:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_SELECT_STATUS,\ 
                             T-TMBF:X:BUN:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_MODE,\ 
                             T-TMBF:X:DAC:BUN_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_BUN_OVF,\ 
                             T-TMBF:X:DAC:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_DELAY_S,\ 
                             T-TMBF:X:DAC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_DRAM_SOURCE_S,\ 
                             T-TMBF:X:DAC:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_ENABLE_S,\ 
                             T-TMBF:X:DAC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*DAC_FILTER_S,\ 
                             T-TMBF:X:DAC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_FIR_OVF,\ 
                             T-TMBF:X:DAC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_ARCHIVE_DONE_S,\ 
                             T-TMBF:X:DAC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DAC_MMS_ARCHIVE_TRIG,\ 
                             T-TMBF:X:DAC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_ARCHIVE_TRIG_FAN,\ 
                             T-TMBF:X:DAC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_DELTA,\ 
                             T-TMBF:X:DAC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_FAN,\ 
                             T-TMBF:X:DAC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_FAN1,\ 
                             T-TMBF:X:DAC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MAX,\ 
                             T-TMBF:X:DAC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MEAN,\ 
                             T-TMBF:X:DAC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MEAN_MEAN,\ 
                             T-TMBF:X:DAC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MIN,\ 
                             T-TMBF:X:DAC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_MMS_OVERFLOW,\ 
                             T-TMBF:X:DAC:MMS:RESET_FAULT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_RESET_FAULT_S,\ 
                             T-TMBF:X:DAC:MMS:SCAN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_SCAN_CMD,\ 
                             T-TMBF:X:DAC:MMS:SCAN_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_SCAN_S,\ 
                             T-TMBF:X:DAC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD,\ 
                             T-TMBF:X:DAC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MAX_WF,\ 
                             T-TMBF:X:DAC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN,\ 
                             T-TMBF:X:DAC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN_DB,\ 
                             T-TMBF:X:DAC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN_WF,\ 
                             T-TMBF:X:DAC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MIN_WF,\ 
                             T-TMBF:X:DAC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*DAC_MMS_TURNS,\ 
                             T-TMBF:X:DAC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_MMS_SOURCE_S,\ 
                             T-TMBF:X:DAC:MUX_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_MUX_OVF,\ 
                             T-TMBF:X:DAC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_OVF,\ 
                             T-TMBF:X:DET:0:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_0_BUNCHES_S,\ 
                             T-TMBF:X:DET:0:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_0_BUNCH_SELECT_S,\ 
                             T-TMBF:X:DET:0:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_0_COUNT,\ 
                             T-TMBF:X:DET:0:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_0_ENABLE,\ 
                             T-TMBF:X:DET:0:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_0_ENABLE_S,\ 
                             T-TMBF:X:DET:0:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_I,\ 
                             T-TMBF:X:DET:0:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_0_MAX_POWER,\ 
                             T-TMBF:X:DET:0:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_0_OUT_OVF,\ 
                             T-TMBF:X:DET:0:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_PHASE,\ 
                             T-TMBF:X:DET:0:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_POWER,\ 
                             T-TMBF:X:DET:0:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_Q,\ 
                             T-TMBF:X:DET:0:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_0_RESET_SELECT_S,\ 
                             T-TMBF:X:DET:0:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_0_SCALING_S,\ 
                             T-TMBF:X:DET:0:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_0_SELECT_STATUS,\ 
                             T-TMBF:X:DET:0:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_0_SET_SELECT_S,\ 
                             T-TMBF:X:DET:1:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_1_BUNCHES_S,\ 
                             T-TMBF:X:DET:1:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_1_BUNCH_SELECT_S,\ 
                             T-TMBF:X:DET:1:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_1_COUNT,\ 
                             T-TMBF:X:DET:1:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_1_ENABLE,\ 
                             T-TMBF:X:DET:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_1_ENABLE_S,\ 
                             T-TMBF:X:DET:1:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_I,\ 
                             T-TMBF:X:DET:1:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_1_MAX_POWER,\ 
                             T-TMBF:X:DET:1:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_1_OUT_OVF,\ 
                             T-TMBF:X:DET:1:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_PHASE,\ 
                             T-TMBF:X:DET:1:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_POWER,\ 
                             T-TMBF:X:DET:1:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_Q,\ 
                             T-TMBF:X:DET:1:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_1_RESET_SELECT_S,\ 
                             T-TMBF:X:DET:1:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_1_SCALING_S,\ 
                             T-TMBF:X:DET:1:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_1_SELECT_STATUS,\ 
                             T-TMBF:X:DET:1:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_1_SET_SELECT_S,\ 
                             T-TMBF:X:DET:2:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_2_BUNCHES_S,\ 
                             T-TMBF:X:DET:2:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_2_BUNCH_SELECT_S,\ 
                             T-TMBF:X:DET:2:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_2_COUNT,\ 
                             T-TMBF:X:DET:2:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_2_ENABLE,\ 
                             T-TMBF:X:DET:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_2_ENABLE_S,\ 
                             T-TMBF:X:DET:2:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_I,\ 
                             T-TMBF:X:DET:2:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_2_MAX_POWER,\ 
                             T-TMBF:X:DET:2:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_2_OUT_OVF,\ 
                             T-TMBF:X:DET:2:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_PHASE,\ 
                             T-TMBF:X:DET:2:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_POWER,\ 
                             T-TMBF:X:DET:2:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_Q,\ 
                             T-TMBF:X:DET:2:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_2_RESET_SELECT_S,\ 
                             T-TMBF:X:DET:2:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_2_SCALING_S,\ 
                             T-TMBF:X:DET:2:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_2_SELECT_STATUS,\ 
                             T-TMBF:X:DET:2:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_2_SET_SELECT_S,\ 
                             T-TMBF:X:DET:3:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*DET_3_BUNCHES_S,\ 
                             T-TMBF:X:DET:3:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*DET_3_BUNCH_SELECT_S,\ 
                             T-TMBF:X:DET:3:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_3_COUNT,\ 
                             T-TMBF:X:DET:3:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_3_ENABLE,\ 
                             T-TMBF:X:DET:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_3_ENABLE_S,\ 
                             T-TMBF:X:DET:3:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_I,\ 
                             T-TMBF:X:DET:3:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_3_MAX_POWER,\ 
                             T-TMBF:X:DET:3:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_3_OUT_OVF,\ 
                             T-TMBF:X:DET:3:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_PHASE,\ 
                             T-TMBF:X:DET:3:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_POWER,\ 
                             T-TMBF:X:DET:3:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_Q,\ 
                             T-TMBF:X:DET:3:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_3_RESET_SELECT_S,\ 
                             T-TMBF:X:DET:3:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_3_SCALING_S,\ 
                             T-TMBF:X:DET:3:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*DET_3_SELECT_STATUS,\ 
                             T-TMBF:X:DET:3:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_3_SET_SELECT_S,\ 
                             T-TMBF:X:DET:FILL_WAVEFORM_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_FILL_WAVEFORM_S,\ 
                             T-TMBF:X:DET:FIR_DELAY_S*Scalar*Double*READ_WRITE*ATTRIBUTE*DET_FIR_DELAY_S,\ 
                             T-TMBF:X:DET:SAMPLES*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_SAMPLES,\ 
                             T-TMBF:X:DET:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_SCALE,\ 
                             T-TMBF:X:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_SELECT_S,\ 
                             T-TMBF:X:DET:TIMEBASE*Array:4096*Int*READ_ONLY*ATTRIBUTE*DET_TIMEBASE,\ 
                             T-TMBF:X:DET:UNDERRUN*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_UNDERRUN,\ 
                             T-TMBF:X:DET:UPDATE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_DONE_S,\ 
                             T-TMBF:X:DET:UPDATE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_UPDATE_TRIG,\ 
                             T-TMBF:X:DET:UPDATE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN,\ 
                             T-TMBF:X:DET:UPDATE:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN1,\ 
                             T-TMBF:X:DET:UPDATE:TRIG:FAN2*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN2,\ 
                             T-TMBF:X:DET:UPDATE:TRIG:FAN3*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN3,\ 
                             T-TMBF:X:DET:UPDATE:TRIG:FAN4*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN4,\ 
                             T-TMBF:X:DET:UPDATE:TRIG:FAN5*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN5,\ 
                             T-TMBF:X:DET:UPDATE_SCALE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_SCALE_DONE_S,\ 
                             T-TMBF:X:DET:UPDATE_SCALE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_UPDATE_SCALE_TRIG,\ 
                             T-TMBF:X:DET:UPDATE_SCALE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_SCALE_TRIG_FAN,\ 
                             T-TMBF:X:FIR:0:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_CYCLES_S,\ 
                             T-TMBF:X:FIR:0:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_LENGTH_S,\ 
                             T-TMBF:X:FIR:0:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_0_PHASE_S,\ 
                             T-TMBF:X:FIR:0:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_RELOAD_S,\ 
                             T-TMBF:X:FIR:0:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_0_TAPS,\ 
                             T-TMBF:X:FIR:0:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_0_TAPS_S,\ 
                             T-TMBF:X:FIR:0:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_0_USEWF_S,\ 
                             T-TMBF:X:FIR:1:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_CYCLES_S,\ 
                             T-TMBF:X:FIR:1:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_LENGTH_S,\ 
                             T-TMBF:X:FIR:1:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_1_PHASE_S,\ 
                             T-TMBF:X:FIR:1:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_RELOAD_S,\ 
                             T-TMBF:X:FIR:1:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_1_TAPS,\ 
                             T-TMBF:X:FIR:1:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_1_TAPS_S,\ 
                             T-TMBF:X:FIR:1:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_1_USEWF_S,\ 
                             T-TMBF:X:FIR:2:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_CYCLES_S,\ 
                             T-TMBF:X:FIR:2:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_LENGTH_S,\ 
                             T-TMBF:X:FIR:2:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_2_PHASE_S,\ 
                             T-TMBF:X:FIR:2:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_RELOAD_S,\ 
                             T-TMBF:X:FIR:2:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_2_TAPS,\ 
                             T-TMBF:X:FIR:2:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_2_TAPS_S,\ 
                             T-TMBF:X:FIR:2:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_2_USEWF_S,\ 
                             T-TMBF:X:FIR:3:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_CYCLES_S,\ 
                             T-TMBF:X:FIR:3:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_LENGTH_S,\ 
                             T-TMBF:X:FIR:3:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_3_PHASE_S,\ 
                             T-TMBF:X:FIR:3:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_RELOAD_S,\ 
                             T-TMBF:X:FIR:3:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_3_TAPS,\ 
                             T-TMBF:X:FIR:3:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_3_TAPS_S,\ 
                             T-TMBF:X:FIR:3:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_3_USEWF_S,\ 
                             T-TMBF:X:FIR:GAIN:DN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_GAIN_DN_S,\ 
                             T-TMBF:X:FIR:GAIN:UP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_GAIN_UP_S,\ 
                             T-TMBF:X:FIR:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_GAIN_S,\ 
                             T-TMBF:X:FIR:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*FIR_OVF,\ 
                             T-TMBF:X:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*NCO_ENABLE_S,\ 
                             T-TMBF:X:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*NCO_FREQ_S,\ 
                             T-TMBF:X:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*NCO_GAIN_S,\ 
                             T-TMBF:X:PLL:CTRL:KI_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_KI_S,\ 
                             T-TMBF:X:PLL:CTRL:KP_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_KP_S,\ 
                             T-TMBF:X:PLL:CTRL:MAX_OFFSET_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_MAX_OFFSET_S,\ 
                             T-TMBF:X:PLL:CTRL:MIN_MAG_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_MIN_MAG_S,\ 
                             T-TMBF:X:PLL:CTRL:START_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_START_S,\ 
                             T-TMBF:X:PLL:CTRL:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STATUS,\ 
                             T-TMBF:X:PLL:CTRL:STOP:DET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_DET_OVF,\ 
                             T-TMBF:X:PLL:CTRL:STOP:MAG_ERROR*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_MAG_ERROR,\ 
                             T-TMBF:X:PLL:CTRL:STOP:OFFSET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_OFFSET_OVF,\ 
                             T-TMBF:X:PLL:CTRL:STOP:STOP*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_CTRL_STOP_STOP,\ 
                             T-TMBF:X:PLL:CTRL:STOP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_STOP_S,\ 
                             T-TMBF:X:PLL:CTRL:TARGET_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_CTRL_TARGET_S,\ 
                             T-TMBF:X:PLL:CTRL:UPDATE_STATUS:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_UPDATE_STATUS_DONE_S,\ 
                             T-TMBF:X:PLL:CTRL:UPDATE_STATUS:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_CTRL_UPDATE_STATUS_TRIG,\ 
                             T-TMBF:X:PLL:CTRL:UPDATE_STATUS:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_UPDATE_STATUS_TRIG_FAN,\ 
                             T-TMBF:X:PLL:DEBUG:ANGLE*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_ANGLE,\ 
                             T-TMBF:X:PLL:DEBUG:COMPENSATE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DEBUG_COMPENSATE_S,\ 
                             T-TMBF:X:PLL:DEBUG:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DEBUG_ENABLE_S,\ 
                             T-TMBF:X:PLL:DEBUG:FIFO_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_DEBUG_FIFO_OVF,\ 
                             T-TMBF:X:PLL:DEBUG:MAG*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_MAG,\ 
                             T-TMBF:X:PLL:DEBUG:READ:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DEBUG_READ_DONE_S,\ 
                             T-TMBF:X:PLL:DEBUG:READ:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_DEBUG_READ_TRIG,\ 
                             T-TMBF:X:PLL:DEBUG:READ:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DEBUG_READ_TRIG_FAN,\ 
                             T-TMBF:X:PLL:DEBUG:READ:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DEBUG_READ_TRIG_FAN1,\ 
                             T-TMBF:X:PLL:DEBUG:RSTD*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD,\ 
                             T-TMBF:X:PLL:DEBUG:RSTD_ABS*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD_ABS,\ 
                             T-TMBF:X:PLL:DEBUG:RSTD_ABS_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD_ABS_DB,\ 
                             T-TMBF:X:PLL:DEBUG:RSTD_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_RSTD_DB,\ 
                             T-TMBF:X:PLL:DEBUG:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DEBUG_SELECT_S,\ 
                             T-TMBF:X:PLL:DEBUG:WFI*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_WFI,\ 
                             T-TMBF:X:PLL:DEBUG:WFQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_DEBUG_WFQ,\ 
                             T-TMBF:X:PLL:DET:BLANKING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DET_BLANKING_S,\ 
                             T-TMBF:X:PLL:DET:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*PLL_DET_BUNCHES_S,\ 
                             T-TMBF:X:PLL:DET:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*PLL_DET_BUNCH_SELECT_S,\ 
                             T-TMBF:X:PLL:DET:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_DET_COUNT,\ 
                             T-TMBF:X:PLL:DET:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DET_DWELL_S,\ 
                             T-TMBF:X:PLL:DET:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DET_RESET_SELECT_S,\ 
                             T-TMBF:X:PLL:DET:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DET_SCALING_S,\ 
                             T-TMBF:X:PLL:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_DET_SELECT_S,\ 
                             T-TMBF:X:PLL:DET:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*PLL_DET_SELECT_STATUS,\ 
                             T-TMBF:X:PLL:DET:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_DET_SET_SELECT_S,\ 
                             T-TMBF:X:PLL:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_FAN,\ 
                             T-TMBF:X:PLL:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_FAN1,\ 
                             T-TMBF:X:PLL:FILT:I*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_I,\ 
                             T-TMBF:X:PLL:FILT:MAG*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_MAG,\ 
                             T-TMBF:X:PLL:FILT:MAG_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_MAG_DB,\ 
                             T-TMBF:X:PLL:FILT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_PHASE,\ 
                             T-TMBF:X:PLL:FILT:Q*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_FILT_Q,\ 
                             T-TMBF:X:PLL:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_NCO_ENABLE_S,\ 
                             T-TMBF:X:PLL:NCO:FIFO_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_NCO_FIFO_OVF,\ 
                             T-TMBF:X:PLL:NCO:FREQ*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_FREQ,\ 
                             T-TMBF:X:PLL:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*PLL_NCO_FREQ_S,\ 
                             T-TMBF:X:PLL:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*PLL_NCO_GAIN_S,\ 
                             T-TMBF:X:PLL:NCO:MEAN_OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_MEAN_OFFSET,\ 
                             T-TMBF:X:PLL:NCO:OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_OFFSET,\ 
                             T-TMBF:X:PLL:NCO:OFFSETWF*Array:4096*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_OFFSETWF,\ 
                             T-TMBF:X:PLL:NCO:READ:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_NCO_READ_DONE_S,\ 
                             T-TMBF:X:PLL:NCO:READ:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*PLL_NCO_READ_TRIG,\ 
                             T-TMBF:X:PLL:NCO:READ:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_NCO_READ_TRIG_FAN,\ 
                             T-TMBF:X:PLL:NCO:RESET_FIFO_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_NCO_RESET_FIFO_S,\ 
                             T-TMBF:X:PLL:NCO:STD_OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_STD_OFFSET,\ 
                             T-TMBF:X:PLL:NCO:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*PLL_NCO_TUNE,\ 
                             T-TMBF:X:PLL:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_POLL_S,\ 
                             T-TMBF:X:PLL:STA:DET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_STA_DET_OVF,\ 
                             T-TMBF:X:PLL:STA:MAG_ERROR*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_STA_MAG_ERROR,\ 
                             T-TMBF:X:PLL:STA:OFFSET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*PLL_STA_OFFSET_OVF,\ 
                             T-TMBF:X:SEQ:0:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_0_BANK_S,\ 
                             T-TMBF:X:SEQ:1:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_BANK_S,\ 
                             T-TMBF:X:SEQ:1:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_BLANK_S,\ 
                             T-TMBF:X:SEQ:1:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:1:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_COUNT_S,\ 
                             T-TMBF:X:SEQ:1:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_DWELL_S,\ 
                             T-TMBF:X:SEQ:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_ENABLE_S,\ 
                             T-TMBF:X:SEQ:1:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:1:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_ENWIN_S,\ 
                             T-TMBF:X:SEQ:1:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_GAIN_S,\ 
                             T-TMBF:X:SEQ:1:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:1:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:1:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:1:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:1:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:2:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_BANK_S,\ 
                             T-TMBF:X:SEQ:2:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_BLANK_S,\ 
                             T-TMBF:X:SEQ:2:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:2:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_COUNT_S,\ 
                             T-TMBF:X:SEQ:2:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_DWELL_S,\ 
                             T-TMBF:X:SEQ:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_ENABLE_S,\ 
                             T-TMBF:X:SEQ:2:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:2:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_ENWIN_S,\ 
                             T-TMBF:X:SEQ:2:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_GAIN_S,\ 
                             T-TMBF:X:SEQ:2:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:2:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:2:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:2:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:2:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:3:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_BANK_S,\ 
                             T-TMBF:X:SEQ:3:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_BLANK_S,\ 
                             T-TMBF:X:SEQ:3:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:3:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_COUNT_S,\ 
                             T-TMBF:X:SEQ:3:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_DWELL_S,\ 
                             T-TMBF:X:SEQ:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_ENABLE_S,\ 
                             T-TMBF:X:SEQ:3:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:3:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_ENWIN_S,\ 
                             T-TMBF:X:SEQ:3:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_GAIN_S,\ 
                             T-TMBF:X:SEQ:3:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:3:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:3:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:3:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:3:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:4:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_BANK_S,\ 
                             T-TMBF:X:SEQ:4:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_BLANK_S,\ 
                             T-TMBF:X:SEQ:4:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:4:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_COUNT_S,\ 
                             T-TMBF:X:SEQ:4:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_DWELL_S,\ 
                             T-TMBF:X:SEQ:4:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_ENABLE_S,\ 
                             T-TMBF:X:SEQ:4:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:4:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_ENWIN_S,\ 
                             T-TMBF:X:SEQ:4:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_GAIN_S,\ 
                             T-TMBF:X:SEQ:4:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:4:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:4:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:4:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:4:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:5:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_BANK_S,\ 
                             T-TMBF:X:SEQ:5:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_BLANK_S,\ 
                             T-TMBF:X:SEQ:5:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:5:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_COUNT_S,\ 
                             T-TMBF:X:SEQ:5:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_DWELL_S,\ 
                             T-TMBF:X:SEQ:5:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_ENABLE_S,\ 
                             T-TMBF:X:SEQ:5:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:5:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_ENWIN_S,\ 
                             T-TMBF:X:SEQ:5:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_GAIN_S,\ 
                             T-TMBF:X:SEQ:5:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:5:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:5:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:5:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:5:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:6:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_BANK_S,\ 
                             T-TMBF:X:SEQ:6:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_BLANK_S,\ 
                             T-TMBF:X:SEQ:6:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:6:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_COUNT_S,\ 
                             T-TMBF:X:SEQ:6:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_DWELL_S,\ 
                             T-TMBF:X:SEQ:6:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_ENABLE_S,\ 
                             T-TMBF:X:SEQ:6:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:6:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_ENWIN_S,\ 
                             T-TMBF:X:SEQ:6:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_GAIN_S,\ 
                             T-TMBF:X:SEQ:6:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:6:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:6:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:6:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:6:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:7:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_BANK_S,\ 
                             T-TMBF:X:SEQ:7:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_BLANK_S,\ 
                             T-TMBF:X:SEQ:7:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_CAPTURE_S,\ 
                             T-TMBF:X:SEQ:7:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_COUNT_S,\ 
                             T-TMBF:X:SEQ:7:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_DWELL_S,\ 
                             T-TMBF:X:SEQ:7:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_ENABLE_S,\ 
                             T-TMBF:X:SEQ:7:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_END_FREQ_S,\ 
                             T-TMBF:X:SEQ:7:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_ENWIN_S,\ 
                             T-TMBF:X:SEQ:7:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_GAIN_S,\ 
                             T-TMBF:X:SEQ:7:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:7:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_START_FREQ_S,\ 
                             T-TMBF:X:SEQ:7:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_STATE_HOLDOFF_S,\ 
                             T-TMBF:X:SEQ:7:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_STEP_FREQ_S,\ 
                             T-TMBF:X:SEQ:7:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_TUNE_PLL_S,\ 
                             T-TMBF:X:SEQ:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*SEQ_BUSY,\ 
                             T-TMBF:X:SEQ:COUNT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_COUNT_FAN,\ 
                             T-TMBF:X:SEQ:DURATION*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_DURATION,\ 
                             T-TMBF:X:SEQ:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_DURATION_S,\ 
                             T-TMBF:X:SEQ:LENGTH*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_LENGTH,\ 
                             T-TMBF:X:SEQ:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*SEQ_MODE,\ 
                             T-TMBF:X:SEQ:PC*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_PC,\ 
                             T-TMBF:X:SEQ:PC_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_PC_S,\ 
                             T-TMBF:X:SEQ:RESET_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_RESET_S,\ 
                             T-TMBF:X:SEQ:RESET_WIN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_RESET_WIN_S,\ 
                             T-TMBF:X:SEQ:STATUS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_STATUS_FAN,\ 
                             T-TMBF:X:SEQ:STATUS:READ_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_STATUS_READ_S,\ 
                             T-TMBF:X:SEQ:SUPER:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_SUPER_COUNT,\ 
                             T-TMBF:X:SEQ:SUPER:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_SUPER_COUNT_S,\ 
                             T-TMBF:X:SEQ:SUPER:OFFSET_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*SEQ_SUPER_OFFSET_S,\ 
                             T-TMBF:X:SEQ:SUPER:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_SUPER_RESET_S,\ 
                             T-TMBF:X:SEQ:TOTAL:DURATION*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_DURATION,\ 
                             T-TMBF:X:SEQ:TOTAL:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_DURATION_S,\ 
                             T-TMBF:X:SEQ:TOTAL:LENGTH*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_LENGTH,\ 
                             T-TMBF:X:SEQ:TRIGGER_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_TRIGGER_S,\ 
                             T-TMBF:X:SEQ:UPDATE_COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_UPDATE_COUNT_S,\ 
                             T-TMBF:X:SEQ:WINDOW_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*SEQ_WINDOW_S,\ 
                             T-TMBF:X:STA:STATUS*Scalar*Double*READ_ONLY*ATTRIBUTE*STA_STATUS,\ 
                             T-TMBF:X:STA:STATUS.SEVR*Scalar*String*READ_ONLY*ATTRIBUTE*STA_SEVR,\ 
                             T-TMBF:X:TRG:SEQ:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC0_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC0_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_ADC0_HIT,\ 
                             T-TMBF:X:TRG:SEQ:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC1_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC1_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_ADC1_HIT,\ 
                             T-TMBF:X:TRG:SEQ:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_ARM_S,\ 
                             T-TMBF:X:TRG:SEQ:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_DELAY_S,\ 
                             T-TMBF:X:TRG:SEQ:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_DISARM_S,\ 
                             T-TMBF:X:TRG:SEQ:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_EXT_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_EXT_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_EXT_HIT,\ 
                             T-TMBF:X:TRG:SEQ:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*TRG_SEQ_HIT,\ 
                             T-TMBF:X:TRG:SEQ:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_HIT_FAN,\ 
                             T-TMBF:X:TRG:SEQ:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_HIT_FAN1,\ 
                             T-TMBF:X:TRG:SEQ:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_MODE_S,\ 
                             T-TMBF:X:TRG:SEQ:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_PM_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_PM_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_PM_HIT,\ 
                             T-TMBF:X:TRG:SEQ:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ0_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ0_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SEQ0_HIT,\ 
                             T-TMBF:X:TRG:SEQ:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ1_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ1_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SEQ1_HIT,\ 
                             T-TMBF:X:TRG:SEQ:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SOFT_BL_S,\ 
                             T-TMBF:X:TRG:SEQ:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SOFT_EN_S,\ 
                             T-TMBF:X:TRG:SEQ:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SOFT_HIT,\ 
                             T-TMBF:X:TRG:SEQ:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_STATUS

# --- tmbf/processor/h attribute properties

tmbf/processor/h/ADC_DRAM_SOURCE_S->description: "Source of memory data"
tmbf/processor/h/ADC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                "After FIR",\ 
                                                "FIR no fill"
tmbf/processor/h/ADC_EVENT->description: "ADC min/max event"
tmbf/processor/h/ADC_EVENT->EnumLabels: No,\ 
                                        Yes
tmbf/processor/h/ADC_EVENT_LIMIT_S->description: "ADC min/max event threshold"
tmbf/processor/h/ADC_EVENT_LIMIT_S->format: %5.4f
tmbf/processor/h/ADC_EVENT_LIMIT_S->max_value: 2.0
tmbf/processor/h/ADC_EVENT_LIMIT_S->min_value: 0.0
tmbf/processor/h/ADC_FILTER_DELAY_S->description: "Compensation filter group delay"
tmbf/processor/h/ADC_FILTER_DELAY_S->max_value: 7.0
tmbf/processor/h/ADC_FILTER_DELAY_S->min_value: 0.0
tmbf/processor/h/ADC_FILTER_S->description: "Input compensation filter"
tmbf/processor/h/ADC_FIR_OVF->description: "ADC FIR overflow"
tmbf/processor/h/ADC_FIR_OVF->EnumLabels: Ok,\ 
                                          Overflow
tmbf/processor/h/ADC_INP_OVF->description: "ADC input overflow"
tmbf/processor/h/ADC_INP_OVF->EnumLabels: Ok,\ 
                                          Overflow
tmbf/processor/h/ADC_LOOPBACK_S->description: "Enable DAC -> ADC loopback"
tmbf/processor/h/ADC_LOOPBACK_S->EnumLabels: Normal,\ 
                                             Loopback
tmbf/processor/h/ADC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
tmbf/processor/h/ADC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
tmbf/processor/h/ADC_MMS_DELTA->description: "Max ADC values per bunch"
tmbf/processor/h/ADC_MMS_MAX->description: "Max ADC values per bunch"
tmbf/processor/h/ADC_MMS_MEAN->description: "Mean ADC values per bunch"
tmbf/processor/h/ADC_MMS_MEAN_MEAN->description: "Mean position"
tmbf/processor/h/ADC_MMS_MEAN_MEAN->format: %9.6f
tmbf/processor/h/ADC_MMS_MEAN_MEAN->max_value: 1.0
tmbf/processor/h/ADC_MMS_MEAN_MEAN->min_value: -1.0
tmbf/processor/h/ADC_MMS_MIN->description: "Min ADC values per bunch"
tmbf/processor/h/ADC_MMS_OVERFLOW->description: "MMS capture overflow status"
tmbf/processor/h/ADC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                               "Turns Overflow",\ 
                                               "Sum Overflow",\ 
                                               "Turns+Sum Overflow",\ 
                                               "Sum2 Overflow",\ 
                                               "Turns+Sum2 Overflow",\ 
                                               "Sum+Sum2 Overflow",\ 
                                               "Turns+Sum+Sum2 Overflow"
tmbf/processor/h/ADC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
tmbf/processor/h/ADC_MMS_SCAN_CMD->description: "ADC min/max scanning"
tmbf/processor/h/ADC_MMS_SCAN_S->description: "ADC min/max scanning"
tmbf/processor/h/ADC_MMS_SCAN_S->EnumLabels: Passive,\ 
                                             Event,\ 
                                             "I/O Intr",\ 
                                             "10 s",\ 
                                             "5 s",\ 
                                             "2 s",\ 
                                             "1 s",\ 
                                             "500 ms",\ 
                                             "200 ms",\ 
                                             "100 ms"
tmbf/processor/h/ADC_MMS_SOURCE_S->description: "Source of min/max/sum data"
tmbf/processor/h/ADC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                               "After FIR",\ 
                                               "FIR no fill"
tmbf/processor/h/ADC_MMS_STD->description: "ADC standard deviation per bunch"
tmbf/processor/h/ADC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
tmbf/processor/h/ADC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
tmbf/processor/h/ADC_MMS_STD_MEAN->format: %.6f
tmbf/processor/h/ADC_MMS_STD_MEAN->max_value: 1.0
tmbf/processor/h/ADC_MMS_STD_MEAN->min_value: 0.0
tmbf/processor/h/ADC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
tmbf/processor/h/ADC_MMS_STD_MEAN_DB->format: %.1f
tmbf/processor/h/ADC_MMS_STD_MEAN_DB->unit: dB
tmbf/processor/h/ADC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
tmbf/processor/h/ADC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
tmbf/processor/h/ADC_MMS_TURNS->description: "Number of turns in this sample"
tmbf/processor/h/ADC_OVF->description: "ADC overflow"
tmbf/processor/h/ADC_OVF->EnumLabels: Ok,\ 
                                      Overflow
tmbf/processor/h/ADC_OVF_LIMIT_S->description: "Overflow limit threshold"
tmbf/processor/h/ADC_OVF_LIMIT_S->format: %5.4f
tmbf/processor/h/ADC_OVF_LIMIT_S->max_value: 1.0
tmbf/processor/h/ADC_OVF_LIMIT_S->min_value: 0.0
tmbf/processor/h/ADC_REJECT_COUNT_S->description: "Samples in fill pattern reject filter"
tmbf/processor/h/ADC_REJECT_COUNT_S->EnumLabels: "1 turns",\ 
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
tmbf/processor/h/AXIS_STATUS->description: "Axis X signal health"
tmbf/processor/h/BUN_0_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/BUN_0_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/h/BUN_0_DAC_SELECT_S->EnumLabels: Off,\ 
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
tmbf/processor/h/BUN_0_FIRWF_S->description: "Set 0 FIR bank select"
tmbf/processor/h/BUN_0_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_0_FIRWF_STA->description: "Bank 0 FIRWF status"
tmbf/processor/h/BUN_0_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/h/BUN_0_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                 "FIR 1",\ 
                                                 "FIR 2",\ 
                                                 "FIR 3"
tmbf/processor/h/BUN_0_GAINWF_S->description: "Set 0 DAC output gain"
tmbf/processor/h/BUN_0_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_0_GAINWF_STA->description: "Bank 0 GAINWF status"
tmbf/processor/h/BUN_0_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/h/BUN_0_GAIN_SELECT_S->format: %.5f
tmbf/processor/h/BUN_0_OUTWF_S->description: "Set 0 DAC output select"
tmbf/processor/h/BUN_0_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_0_OUTWF_STA->description: "Bank 0 OUTWF status"
tmbf/processor/h/BUN_0_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/BUN_1_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/BUN_1_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/h/BUN_1_DAC_SELECT_S->EnumLabels: Off,\ 
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
tmbf/processor/h/BUN_1_FIRWF_S->description: "Set 1 FIR bank select"
tmbf/processor/h/BUN_1_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_1_FIRWF_STA->description: "Bank 1 FIRWF status"
tmbf/processor/h/BUN_1_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/h/BUN_1_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                 "FIR 1",\ 
                                                 "FIR 2",\ 
                                                 "FIR 3"
tmbf/processor/h/BUN_1_GAINWF_S->description: "Set 1 DAC output gain"
tmbf/processor/h/BUN_1_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_1_GAINWF_STA->description: "Bank 1 GAINWF status"
tmbf/processor/h/BUN_1_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/h/BUN_1_GAIN_SELECT_S->format: %.5f
tmbf/processor/h/BUN_1_OUTWF_S->description: "Set 1 DAC output select"
tmbf/processor/h/BUN_1_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_1_OUTWF_STA->description: "Bank 1 OUTWF status"
tmbf/processor/h/BUN_1_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/BUN_2_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/BUN_2_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/h/BUN_2_DAC_SELECT_S->EnumLabels: Off,\ 
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
tmbf/processor/h/BUN_2_FIRWF_S->description: "Set 2 FIR bank select"
tmbf/processor/h/BUN_2_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_2_FIRWF_STA->description: "Bank 2 FIRWF status"
tmbf/processor/h/BUN_2_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/h/BUN_2_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                 "FIR 1",\ 
                                                 "FIR 2",\ 
                                                 "FIR 3"
tmbf/processor/h/BUN_2_GAINWF_S->description: "Set 2 DAC output gain"
tmbf/processor/h/BUN_2_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_2_GAINWF_STA->description: "Bank 2 GAINWF status"
tmbf/processor/h/BUN_2_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/h/BUN_2_GAIN_SELECT_S->format: %.5f
tmbf/processor/h/BUN_2_OUTWF_S->description: "Set 2 DAC output select"
tmbf/processor/h/BUN_2_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_2_OUTWF_STA->description: "Bank 2 OUTWF status"
tmbf/processor/h/BUN_2_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/BUN_3_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/BUN_3_DAC_SELECT_S->description: "Select DAC output"
tmbf/processor/h/BUN_3_DAC_SELECT_S->EnumLabels: Off,\ 
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
tmbf/processor/h/BUN_3_FIRWF_S->description: "Set 3 FIR bank select"
tmbf/processor/h/BUN_3_FIRWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_3_FIRWF_STA->description: "Bank 3 FIRWF status"
tmbf/processor/h/BUN_3_FIR_SELECT_S->description: "Select FIR setting"
tmbf/processor/h/BUN_3_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                 "FIR 1",\ 
                                                 "FIR 2",\ 
                                                 "FIR 3"
tmbf/processor/h/BUN_3_GAINWF_S->description: "Set 3 DAC output gain"
tmbf/processor/h/BUN_3_GAINWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_3_GAINWF_STA->description: "Bank 3 GAINWF status"
tmbf/processor/h/BUN_3_GAIN_SELECT_S->description: "Select bunch gain"
tmbf/processor/h/BUN_3_GAIN_SELECT_S->format: %.5f
tmbf/processor/h/BUN_3_OUTWF_S->description: "Set 3 DAC output select"
tmbf/processor/h/BUN_3_OUTWF_SET_S->description: "Set selected bunches"
tmbf/processor/h/BUN_3_OUTWF_STA->description: "Bank 3 OUTWF status"
tmbf/processor/h/BUN_3_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/BUN_MODE->description: "Feedback mode"
tmbf/processor/h/DAC_BUN_OVF->description: "Bunch FIR overflow"
tmbf/processor/h/DAC_BUN_OVF->EnumLabels: Ok,\ 
                                          Overflow
tmbf/processor/h/DAC_DELAY_S->description: "DAC output delay"
tmbf/processor/h/DAC_DRAM_SOURCE_S->description: "Source of memory data"
tmbf/processor/h/DAC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                "After FIR"
tmbf/processor/h/DAC_ENABLE_S->description: "DAC output enable"
tmbf/processor/h/DAC_ENABLE_S->EnumLabels: Off,\ 
                                           On
tmbf/processor/h/DAC_ENABLE_S->values: Off,\ 
                                       On
tmbf/processor/h/DAC_FILTER_DELAY_S->description: "Preemphasis filter group delay"
tmbf/processor/h/DAC_FILTER_DELAY_S->max_value: 7.0
tmbf/processor/h/DAC_FILTER_DELAY_S->min_value: 0.0
tmbf/processor/h/DAC_FILTER_S->description: "Output preemphasis filter"
tmbf/processor/h/DAC_FIR_OVF->description: "DAC FIR overflow"
tmbf/processor/h/DAC_FIR_OVF->EnumLabels: Ok,\ 
                                          Overflow
tmbf/processor/h/DAC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
tmbf/processor/h/DAC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
tmbf/processor/h/DAC_MMS_DELTA->description: "Max DAC values per bunch"
tmbf/processor/h/DAC_MMS_MAX->description: "Max DAC values per bunch"
tmbf/processor/h/DAC_MMS_MEAN->description: "Mean DAC values per bunch"
tmbf/processor/h/DAC_MMS_MEAN_MEAN->description: "Mean position"
tmbf/processor/h/DAC_MMS_MEAN_MEAN->format: %.6f
tmbf/processor/h/DAC_MMS_MEAN_MEAN->max_value: 1.0
tmbf/processor/h/DAC_MMS_MEAN_MEAN->min_value: -1.0
tmbf/processor/h/DAC_MMS_MIN->description: "Min DAC values per bunch"
tmbf/processor/h/DAC_MMS_OVERFLOW->description: "MMS capture overflow status"
tmbf/processor/h/DAC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                               "Turns Overflow",\ 
                                               "Sum Overflow",\ 
                                               "Turns+Sum Overflow",\ 
                                               "Sum2 Overflow",\ 
                                               "Turns+Sum2 Overflow",\ 
                                               "Sum+Sum2 Overflow",\ 
                                               "Turns+Sum+Sum2 Overflow"
tmbf/processor/h/DAC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
tmbf/processor/h/DAC_MMS_SCAN_CMD->description: "DAC min/max scanning"
tmbf/processor/h/DAC_MMS_SCAN_S->description: "DAC min/max scanning"
tmbf/processor/h/DAC_MMS_SCAN_S->EnumLabels: Passive,\ 
                                             Event,\ 
                                             "I/O Intr",\ 
                                             "10 s",\ 
                                             "5 s",\ 
                                             "2 s",\ 
                                             "1 s",\ 
                                             "500 ms",\ 
                                             "200 ms",\ 
                                             "100 ms"
tmbf/processor/h/DAC_MMS_SOURCE_S->description: "Source of min/max/sum data"
tmbf/processor/h/DAC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                               "After FIR"
tmbf/processor/h/DAC_MMS_STD->description: "DAC standard deviation per bunch"
tmbf/processor/h/DAC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
tmbf/processor/h/DAC_MMS_STD_MEAN->archive_abs_change: -1e-06,\ 
                                                       1e-06
tmbf/processor/h/DAC_MMS_STD_MEAN->archive_period: 3600000
tmbf/processor/h/DAC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
tmbf/processor/h/DAC_MMS_STD_MEAN->event_period: 1234
tmbf/processor/h/DAC_MMS_STD_MEAN->format: %.6f
tmbf/processor/h/DAC_MMS_STD_MEAN->max_value: 1.0
tmbf/processor/h/DAC_MMS_STD_MEAN->min_value: 0.0
tmbf/processor/h/DAC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
tmbf/processor/h/DAC_MMS_STD_MEAN_DB->format: %.1f
tmbf/processor/h/DAC_MMS_STD_MEAN_DB->unit: dB
tmbf/processor/h/DAC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
tmbf/processor/h/DAC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
tmbf/processor/h/DAC_MMS_TURNS->description: "Number of turns in this sample"
tmbf/processor/h/DAC_MUX_OVF->description: "DAC output overflow"
tmbf/processor/h/DAC_MUX_OVF->EnumLabels: Ok,\ 
                                          Overflow
tmbf/processor/h/DAC_OVF->description: "DAC overflow"
tmbf/processor/h/DAC_OVF->EnumLabels: Ok,\ 
                                      Overflow
tmbf/processor/h/DET_0_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/h/DET_0_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/DET_0_COUNT->description: "Number of enabled bunches"
tmbf/processor/h/DET_0_ENABLE->description: "Current detector enable state"
tmbf/processor/h/DET_0_ENABLE->EnumLabels: Disabled,\ 
                                           Enabled
tmbf/processor/h/DET_0_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/h/DET_0_ENABLE_S->EnumLabels: Disabled,\ 
                                             Enabled
tmbf/processor/h/DET_0_I->description: "Detector I"
tmbf/processor/h/DET_0_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/h/DET_0_MAX_POWER->unit: dB
tmbf/processor/h/DET_0_OUT_OVF->description: "Output overflow"
tmbf/processor/h/DET_0_OUT_OVF->EnumLabels: Ok,\ 
                                            Overflow
tmbf/processor/h/DET_0_PHASE->description: "Detector Phase"
tmbf/processor/h/DET_0_POWER->description: "Detector Power"
tmbf/processor/h/DET_0_Q->description: "Detector Q"
tmbf/processor/h/DET_0_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/h/DET_0_SCALING_S->description: "Readout scaling"
tmbf/processor/h/DET_0_SCALING_S->EnumLabels: 0dB,\ 
                                              -48dB
tmbf/processor/h/DET_0_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/DET_0_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/h/DET_1_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/h/DET_1_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/DET_1_COUNT->description: "Number of enabled bunches"
tmbf/processor/h/DET_1_ENABLE->description: "Current detector enable state"
tmbf/processor/h/DET_1_ENABLE->EnumLabels: Disabled,\ 
                                           Enabled
tmbf/processor/h/DET_1_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/h/DET_1_ENABLE_S->EnumLabels: Disabled,\ 
                                             Enabled
tmbf/processor/h/DET_1_I->description: "Detector I"
tmbf/processor/h/DET_1_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/h/DET_1_MAX_POWER->unit: dB
tmbf/processor/h/DET_1_OUT_OVF->description: "Output overflow"
tmbf/processor/h/DET_1_OUT_OVF->EnumLabels: Ok,\ 
                                            Overflow
tmbf/processor/h/DET_1_PHASE->description: "Detector Phase"
tmbf/processor/h/DET_1_POWER->description: "Detector Power"
tmbf/processor/h/DET_1_Q->description: "Detector Q"
tmbf/processor/h/DET_1_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/h/DET_1_SCALING_S->description: "Readout scaling"
tmbf/processor/h/DET_1_SCALING_S->EnumLabels: 0dB,\ 
                                              -48dB
tmbf/processor/h/DET_1_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/DET_1_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/h/DET_2_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/h/DET_2_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/DET_2_COUNT->description: "Number of enabled bunches"
tmbf/processor/h/DET_2_ENABLE->description: "Current detector enable state"
tmbf/processor/h/DET_2_ENABLE->EnumLabels: Disabled,\ 
                                           Enabled
tmbf/processor/h/DET_2_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/h/DET_2_ENABLE_S->EnumLabels: Disabled,\ 
                                             Enabled
tmbf/processor/h/DET_2_I->description: "Detector I"
tmbf/processor/h/DET_2_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/h/DET_2_MAX_POWER->unit: dB
tmbf/processor/h/DET_2_OUT_OVF->description: "Output overflow"
tmbf/processor/h/DET_2_OUT_OVF->EnumLabels: Ok,\ 
                                            Overflow
tmbf/processor/h/DET_2_PHASE->description: "Detector Phase"
tmbf/processor/h/DET_2_POWER->description: "Detector Power"
tmbf/processor/h/DET_2_Q->description: "Detector Q"
tmbf/processor/h/DET_2_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/h/DET_2_SCALING_S->description: "Readout scaling"
tmbf/processor/h/DET_2_SCALING_S->EnumLabels: 0dB,\ 
                                              -48dB
tmbf/processor/h/DET_2_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/DET_2_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/h/DET_3_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/h/DET_3_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/DET_3_COUNT->description: "Number of enabled bunches"
tmbf/processor/h/DET_3_ENABLE->description: "Current detector enable state"
tmbf/processor/h/DET_3_ENABLE->EnumLabels: Disabled,\ 
                                           Enabled
tmbf/processor/h/DET_3_ENABLE_S->description: "Enable use of this detector"
tmbf/processor/h/DET_3_ENABLE_S->EnumLabels: Disabled,\ 
                                             Enabled
tmbf/processor/h/DET_3_I->description: "Detector I"
tmbf/processor/h/DET_3_MAX_POWER->description: "Percentage full scale of maximum power"
tmbf/processor/h/DET_3_MAX_POWER->unit: dB
tmbf/processor/h/DET_3_OUT_OVF->description: "Output overflow"
tmbf/processor/h/DET_3_OUT_OVF->EnumLabels: Ok,\ 
                                            Overflow
tmbf/processor/h/DET_3_PHASE->description: "Detector Phase"
tmbf/processor/h/DET_3_POWER->description: "Detector Power"
tmbf/processor/h/DET_3_Q->description: "Detector Q"
tmbf/processor/h/DET_3_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/h/DET_3_SCALING_S->description: "Readout scaling"
tmbf/processor/h/DET_3_SCALING_S->EnumLabels: 0dB,\ 
                                              -48dB
tmbf/processor/h/DET_3_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/DET_3_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/h/DET_FILL_WAVEFORM_S->description: "Treatment of truncated waveforms"
tmbf/processor/h/DET_FILL_WAVEFORM_S->EnumLabels: Truncated,\ 
                                                  Filled
tmbf/processor/h/DET_FIR_DELAY_S->description: "FIR nominal group delay"
tmbf/processor/h/DET_FIR_DELAY_S->format: %4.1f
tmbf/processor/h/DET_FIR_DELAY_S->unit: turns
tmbf/processor/h/DET_SAMPLES->description: "Number of captured samples"
tmbf/processor/h/DET_SCALE->description: "Scale for frequency sweep"
tmbf/processor/h/DET_SELECT_S->description: "Select detector source"
tmbf/processor/h/DET_SELECT_S->EnumLabels: ADC,\ 
                                           FIR,\ 
                                           "ADC no fill"
tmbf/processor/h/DET_TIMEBASE->description: "Timebase for frequency sweep"
tmbf/processor/h/DET_UNDERRUN->description: "Data output underrun"
tmbf/processor/h/DET_UNDERRUN->EnumLabels: Ok,\ 
                                           Underrun
tmbf/processor/h/DET_UPDATE_DONE_S->description: "UPDATE processing done"
tmbf/processor/h/DET_UPDATE_SCALE_DONE_S->description: "UPDATE_SCALE processing done"
tmbf/processor/h/DET_UPDATE_SCALE_TRIG->description: "UPDATE_SCALE processing trigger"
tmbf/processor/h/DET_UPDATE_TRIG->description: "UPDATE processing trigger"
tmbf/processor/h/FIR_0_CYCLES_S->description: "Cycles in filter"
tmbf/processor/h/FIR_0_CYCLES_S->format: %2d
tmbf/processor/h/FIR_0_CYCLES_S->max_value: 16.0
tmbf/processor/h/FIR_0_CYCLES_S->min_value: 1.0
tmbf/processor/h/FIR_0_LENGTH_S->description: "Length of filter"
tmbf/processor/h/FIR_0_LENGTH_S->format: %2d
tmbf/processor/h/FIR_0_LENGTH_S->max_value: 16.0
tmbf/processor/h/FIR_0_LENGTH_S->min_value: 2.0
tmbf/processor/h/FIR_0_PHASE_S->description: "FIR phase"
tmbf/processor/h/FIR_0_PHASE_S->format: %3.0f
tmbf/processor/h/FIR_0_PHASE_S->max_value: 360.0
tmbf/processor/h/FIR_0_PHASE_S->min_value: -360.0
tmbf/processor/h/FIR_0_RELOAD_S->description: "Reload filter"
tmbf/processor/h/FIR_0_TAPS->description: "Current waveform taps"
tmbf/processor/h/FIR_0_TAPS_S->description: "Set waveform taps"
tmbf/processor/h/FIR_0_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/h/FIR_0_USEWF_S->EnumLabels: Settings,\ 
                                            Waveform
tmbf/processor/h/FIR_1_CYCLES_S->description: "Cycles in filter"
tmbf/processor/h/FIR_1_CYCLES_S->format: %2d
tmbf/processor/h/FIR_1_CYCLES_S->max_value: 16.0
tmbf/processor/h/FIR_1_CYCLES_S->min_value: 1.0
tmbf/processor/h/FIR_1_LENGTH_S->description: "Length of filter"
tmbf/processor/h/FIR_1_LENGTH_S->format: %2d
tmbf/processor/h/FIR_1_LENGTH_S->max_value: 16.0
tmbf/processor/h/FIR_1_LENGTH_S->min_value: 2.0
tmbf/processor/h/FIR_1_PHASE_S->description: "FIR phase"
tmbf/processor/h/FIR_1_PHASE_S->format: %3.0f
tmbf/processor/h/FIR_1_PHASE_S->max_value: 360.0
tmbf/processor/h/FIR_1_PHASE_S->min_value: -360.0
tmbf/processor/h/FIR_1_RELOAD_S->description: "Reload filter"
tmbf/processor/h/FIR_1_TAPS->description: "Current waveform taps"
tmbf/processor/h/FIR_1_TAPS_S->description: "Set waveform taps"
tmbf/processor/h/FIR_1_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/h/FIR_1_USEWF_S->EnumLabels: Settings,\ 
                                            Waveform
tmbf/processor/h/FIR_2_CYCLES_S->description: "Cycles in filter"
tmbf/processor/h/FIR_2_CYCLES_S->format: %2d
tmbf/processor/h/FIR_2_CYCLES_S->max_value: 16.0
tmbf/processor/h/FIR_2_CYCLES_S->min_value: 1.0
tmbf/processor/h/FIR_2_LENGTH_S->description: "Length of filter"
tmbf/processor/h/FIR_2_LENGTH_S->format: %2d
tmbf/processor/h/FIR_2_LENGTH_S->max_value: 16.0
tmbf/processor/h/FIR_2_LENGTH_S->min_value: 2.0
tmbf/processor/h/FIR_2_PHASE_S->description: "FIR phase"
tmbf/processor/h/FIR_2_PHASE_S->format: %3.0f
tmbf/processor/h/FIR_2_PHASE_S->max_value: 360.0
tmbf/processor/h/FIR_2_PHASE_S->min_value: -360.0
tmbf/processor/h/FIR_2_RELOAD_S->description: "Reload filter"
tmbf/processor/h/FIR_2_TAPS->description: "Current waveform taps"
tmbf/processor/h/FIR_2_TAPS_S->description: "Set waveform taps"
tmbf/processor/h/FIR_2_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/h/FIR_2_USEWF_S->EnumLabels: Settings,\ 
                                            Waveform
tmbf/processor/h/FIR_3_CYCLES_S->description: "Cycles in filter"
tmbf/processor/h/FIR_3_CYCLES_S->format: %2d
tmbf/processor/h/FIR_3_CYCLES_S->max_value: 16.0
tmbf/processor/h/FIR_3_CYCLES_S->min_value: 1.0
tmbf/processor/h/FIR_3_LENGTH_S->description: "Length of filter"
tmbf/processor/h/FIR_3_LENGTH_S->format: %2d
tmbf/processor/h/FIR_3_LENGTH_S->max_value: 16.0
tmbf/processor/h/FIR_3_LENGTH_S->min_value: 2.0
tmbf/processor/h/FIR_3_PHASE_S->description: "FIR phase"
tmbf/processor/h/FIR_3_PHASE_S->format: %3.0f
tmbf/processor/h/FIR_3_PHASE_S->max_value: 360.0
tmbf/processor/h/FIR_3_PHASE_S->min_value: -360.0
tmbf/processor/h/FIR_3_RELOAD_S->description: "Reload filter"
tmbf/processor/h/FIR_3_TAPS->description: "Current waveform taps"
tmbf/processor/h/FIR_3_TAPS_S->description: "Set waveform taps"
tmbf/processor/h/FIR_3_USEWF_S->description: "Use direct waveform or settings"
tmbf/processor/h/FIR_3_USEWF_S->EnumLabels: Settings,\ 
                                            Waveform
tmbf/processor/h/FIR_GAIN_DN_S->description: "Decrease FIR gain"
tmbf/processor/h/FIR_GAIN_S->description: "FIR gain select"
tmbf/processor/h/FIR_GAIN_S->EnumLabels: 48dB,\ 
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
tmbf/processor/h/FIR_GAIN_S->values: 48dB,\ 
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
tmbf/processor/h/FIR_GAIN_UP_S->description: "Increase FIR gain"
tmbf/processor/h/FIR_OVF->description: "Overflow in X bunch-by-bunch filter"
tmbf/processor/h/FIR_OVF->EnumLabels: Ok,\ 
                                      Overflow
tmbf/processor/h/NCO_ENABLE_S->description: "Enable fixed NCO output"
tmbf/processor/h/NCO_ENABLE_S->EnumLabels: Off,\ 
                                           On
tmbf/processor/h/NCO_FREQ_S->description: "Fixed NCO frequency"
tmbf/processor/h/NCO_FREQ_S->format: %8.5f
tmbf/processor/h/NCO_GAIN_S->description: "Fixed NCO gain"
tmbf/processor/h/NCO_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/PLL_CTRL_KI_S->description: "Integral factor for controller"
tmbf/processor/h/PLL_CTRL_KP_S->description: "Proportional factor for controller"
tmbf/processor/h/PLL_CTRL_MAX_OFFSET_S->description: "Maximum frequency offset for feedback"
tmbf/processor/h/PLL_CTRL_MAX_OFFSET_S->format: %.7f
tmbf/processor/h/PLL_CTRL_MAX_OFFSET_S->unit: tune
tmbf/processor/h/PLL_CTRL_MIN_MAG_S->description: "Minimum magnitude for feedback"
tmbf/processor/h/PLL_CTRL_MIN_MAG_S->format: %1.5f
tmbf/processor/h/PLL_CTRL_MIN_MAG_S->max_value: 1.0
tmbf/processor/h/PLL_CTRL_MIN_MAG_S->min_value: 0.0
tmbf/processor/h/PLL_CTRL_START_S->description: "Start tune PLL"
tmbf/processor/h/PLL_CTRL_STATUS->description: "Tune PLL feedback status"
tmbf/processor/h/PLL_CTRL_STATUS->EnumLabels: Stopped,\ 
                                              Running
tmbf/processor/h/PLL_CTRL_STOP_DET_OVF->description: "Detector overflow"
tmbf/processor/h/PLL_CTRL_STOP_DET_OVF->EnumLabels: Ok,\ 
                                                    Overflow
tmbf/processor/h/PLL_CTRL_STOP_MAG_ERROR->description: "Magnitude error"
tmbf/processor/h/PLL_CTRL_STOP_MAG_ERROR->EnumLabels: Ok,\ 
                                                      "Too small"
tmbf/processor/h/PLL_CTRL_STOP_OFFSET_OVF->description: "Offset overflow"
tmbf/processor/h/PLL_CTRL_STOP_OFFSET_OVF->EnumLabels: Ok,\ 
                                                       Overflow
tmbf/processor/h/PLL_CTRL_STOP_S->description: "Stop tune PLL"
tmbf/processor/h/PLL_CTRL_STOP_STOP->description: "Stopped by user"
tmbf/processor/h/PLL_CTRL_STOP_STOP->EnumLabels: Ok,\ 
                                                 Stopped
tmbf/processor/h/PLL_CTRL_TARGET_S->description: "Target phase"
tmbf/processor/h/PLL_CTRL_TARGET_S->format: %3.2f
tmbf/processor/h/PLL_CTRL_TARGET_S->max_value: 180.0
tmbf/processor/h/PLL_CTRL_TARGET_S->min_value: -180.0
tmbf/processor/h/PLL_CTRL_UPDATE_STATUS_DONE_S->description: "UPDATE_STATUS processing done"
tmbf/processor/h/PLL_CTRL_UPDATE_STATUS_TRIG->description: "UPDATE_STATUS processing trigger"
tmbf/processor/h/PLL_DEBUG_ANGLE->description: "Tune PLL angle"
tmbf/processor/h/PLL_DEBUG_COMPENSATE_S->description: "Compensate debug readbacks"
tmbf/processor/h/PLL_DEBUG_COMPENSATE_S->EnumLabels: Raw,\ 
                                                     Compensated
tmbf/processor/h/PLL_DEBUG_ENABLE_S->description: "Enable debug readbacks"
tmbf/processor/h/PLL_DEBUG_ENABLE_S->EnumLabels: Off,\ 
                                                 On
tmbf/processor/h/PLL_DEBUG_FIFO_OVF->description: "Debug FIFO readout overrun"
tmbf/processor/h/PLL_DEBUG_FIFO_OVF->EnumLabels: Ok,\ 
                                                 Overflow
tmbf/processor/h/PLL_DEBUG_MAG->description: "Tune PLL magnitude"
tmbf/processor/h/PLL_DEBUG_READ_DONE_S->description: "READ processing done"
tmbf/processor/h/PLL_DEBUG_READ_TRIG->description: "READ processing trigger"
tmbf/processor/h/PLL_DEBUG_RSTD->description: "IQ relative standard deviation"
tmbf/processor/h/PLL_DEBUG_RSTD_ABS->description: "Magnitude relative standard deviation"
tmbf/processor/h/PLL_DEBUG_RSTD_ABS_DB->unit: dB
tmbf/processor/h/PLL_DEBUG_RSTD_DB->unit: dB
tmbf/processor/h/PLL_DEBUG_SELECT_S->description: "Select captured readback values"
tmbf/processor/h/PLL_DEBUG_SELECT_S->EnumLabels: IQ,\ 
                                                 CORDIC
tmbf/processor/h/PLL_DEBUG_WFI->description: "Tune PLL detector I"
tmbf/processor/h/PLL_DEBUG_WFQ->description: "Tune PLL detector Q"
tmbf/processor/h/PLL_DET_BLANKING_S->description: "Response to blanking trigger"
tmbf/processor/h/PLL_DET_BLANKING_S->EnumLabels: Ignore,\ 
                                                 Blanking
tmbf/processor/h/PLL_DET_BUNCHES_S->description: "Enable bunches for detector"
tmbf/processor/h/PLL_DET_BUNCH_SELECT_S->description: "Select bunch to set"
tmbf/processor/h/PLL_DET_COUNT->description: "Number of enabled bunches"
tmbf/processor/h/PLL_DET_DWELL_S->description: "Dwell time in turns"
tmbf/processor/h/PLL_DET_DWELL_S->format: %5d
tmbf/processor/h/PLL_DET_DWELL_S->max_value: 65536.0
tmbf/processor/h/PLL_DET_DWELL_S->min_value: 1.0
tmbf/processor/h/PLL_DET_RESET_SELECT_S->description: "Disable selected bunches"
tmbf/processor/h/PLL_DET_SCALING_S->description: "Readout scaling"
tmbf/processor/h/PLL_DET_SCALING_S->EnumLabels: 48dB,\ 
                                                12dB,\ 
                                                -24dB,\ 
                                                -60dB
tmbf/processor/h/PLL_DET_SELECT_S->description: "Select detector source"
tmbf/processor/h/PLL_DET_SELECT_S->EnumLabels: ADC,\ 
                                               FIR,\ 
                                               "ADC no fill"
tmbf/processor/h/PLL_DET_SELECT_STATUS->description: "Status of selection"
tmbf/processor/h/PLL_DET_SET_SELECT_S->description: "Enable selected bunches"
tmbf/processor/h/PLL_FILT_I->description: "Filtered Tune PLL detector I"
tmbf/processor/h/PLL_FILT_MAG->description: "Filtered Tune PLL detector magnitude"
tmbf/processor/h/PLL_FILT_MAG_DB->unit: dB
tmbf/processor/h/PLL_FILT_PHASE->description: "Filtered Tune PLL phase offset"
tmbf/processor/h/PLL_FILT_PHASE->unit: deg
tmbf/processor/h/PLL_FILT_Q->description: "Filtered Tune PLL detector Q"
tmbf/processor/h/PLL_NCO_ENABLE_S->description: "Enable Tune PLL NCO output"
tmbf/processor/h/PLL_NCO_ENABLE_S->EnumLabels: Off,\ 
                                               On
tmbf/processor/h/PLL_NCO_FIFO_OVF->description: "Offset FIFO readout overrun"
tmbf/processor/h/PLL_NCO_FIFO_OVF->EnumLabels: Ok,\ 
                                               Overflow
tmbf/processor/h/PLL_NCO_FREQ->description: "Tune PLL NCO frequency"
tmbf/processor/h/PLL_NCO_FREQ->unit: tune
tmbf/processor/h/PLL_NCO_FREQ_S->description: "Base Tune PLL NCO frequency"
tmbf/processor/h/PLL_NCO_FREQ_S->format: %.7f
tmbf/processor/h/PLL_NCO_FREQ_S->unit: tune
tmbf/processor/h/PLL_NCO_GAIN_S->description: "Tune PLL NCO gain"
tmbf/processor/h/PLL_NCO_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/PLL_NCO_MEAN_OFFSET->description: "Mean tune PLL offset"
tmbf/processor/h/PLL_NCO_MEAN_OFFSET->unit: tune
tmbf/processor/h/PLL_NCO_OFFSET->description: "Filtered frequency offset"
tmbf/processor/h/PLL_NCO_OFFSET->unit: tune
tmbf/processor/h/PLL_NCO_OFFSETWF->description: "Tune PLL offset"
tmbf/processor/h/PLL_NCO_READ_DONE_S->description: "READ processing done"
tmbf/processor/h/PLL_NCO_READ_TRIG->description: "READ processing trigger"
tmbf/processor/h/PLL_NCO_RESET_FIFO_S->description: "Reset FIFO readout to force fresh sample"
tmbf/processor/h/PLL_NCO_STD_OFFSET->description: "Standard deviation of offset"
tmbf/processor/h/PLL_NCO_STD_OFFSET->unit: tune
tmbf/processor/h/PLL_NCO_TUNE->description: "Measured tune frequency"
tmbf/processor/h/PLL_NCO_TUNE->unit: tune
tmbf/processor/h/PLL_POLL_S->description: "Poll Tune PLL readbacks"
tmbf/processor/h/PLL_STA_DET_OVF->description: "Detector overflow"
tmbf/processor/h/PLL_STA_DET_OVF->EnumLabels: Ok,\ 
                                              Overflow
tmbf/processor/h/PLL_STA_MAG_ERROR->description: "Magnitude error"
tmbf/processor/h/PLL_STA_MAG_ERROR->EnumLabels: Ok,\ 
                                                "Too small"
tmbf/processor/h/PLL_STA_OFFSET_OVF->description: "Offset overflow"
tmbf/processor/h/PLL_STA_OFFSET_OVF->EnumLabels: Ok,\ 
                                                 Overflow
tmbf/processor/h/SEQ_0_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_0_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_1_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_1_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_1_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_1_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_1_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_1_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_1_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_1_COUNT_S->format: %5d
tmbf/processor/h/SEQ_1_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_1_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_1_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_1_DWELL_S->format: %5d
tmbf/processor/h/SEQ_1_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_1_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_1_DWELL_S->unit: turns
tmbf/processor/h/SEQ_1_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_1_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_1_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_1_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_1_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_1_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_1_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_1_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_1_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_1_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_1_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_1_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_1_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_1_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_1_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_1_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_1_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_1_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_1_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_1_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_1_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_1_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_1_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_1_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_1_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_1_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_2_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_2_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_2_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_2_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_2_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_2_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_2_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_2_COUNT_S->format: %5d
tmbf/processor/h/SEQ_2_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_2_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_2_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_2_DWELL_S->format: %5d
tmbf/processor/h/SEQ_2_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_2_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_2_DWELL_S->unit: turns
tmbf/processor/h/SEQ_2_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_2_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_2_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_2_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_2_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_2_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_2_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_2_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_2_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_2_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_2_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_2_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_2_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_2_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_2_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_2_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_2_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_2_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_2_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_2_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_2_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_2_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_2_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_2_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_2_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_2_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_3_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_3_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_3_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_3_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_3_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_3_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_3_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_3_COUNT_S->format: %5d
tmbf/processor/h/SEQ_3_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_3_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_3_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_3_DWELL_S->format: %5d
tmbf/processor/h/SEQ_3_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_3_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_3_DWELL_S->unit: turns
tmbf/processor/h/SEQ_3_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_3_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_3_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_3_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_3_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_3_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_3_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_3_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_3_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_3_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_3_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_3_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_3_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_3_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_3_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_3_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_3_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_3_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_3_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_3_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_3_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_3_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_3_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_3_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_3_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_3_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_4_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_4_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_4_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_4_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_4_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_4_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_4_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_4_COUNT_S->format: %5d
tmbf/processor/h/SEQ_4_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_4_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_4_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_4_DWELL_S->format: %5d
tmbf/processor/h/SEQ_4_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_4_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_4_DWELL_S->unit: turns
tmbf/processor/h/SEQ_4_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_4_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_4_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_4_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_4_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_4_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_4_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_4_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_4_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_4_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_4_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_4_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_4_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_4_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_4_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_4_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_4_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_4_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_4_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_4_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_4_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_4_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_4_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_4_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_4_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_4_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_5_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_5_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_5_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_5_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_5_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_5_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_5_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_5_COUNT_S->format: %5d
tmbf/processor/h/SEQ_5_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_5_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_5_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_5_DWELL_S->format: %5d
tmbf/processor/h/SEQ_5_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_5_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_5_DWELL_S->unit: turns
tmbf/processor/h/SEQ_5_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_5_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_5_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_5_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_5_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_5_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_5_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_5_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_5_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_5_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_5_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_5_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_5_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_5_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_5_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_5_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_5_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_5_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_5_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_5_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_5_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_5_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_5_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_5_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_5_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_5_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_6_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_6_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_6_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_6_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_6_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_6_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_6_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_6_COUNT_S->format: %5d
tmbf/processor/h/SEQ_6_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_6_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_6_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_6_DWELL_S->format: %5d
tmbf/processor/h/SEQ_6_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_6_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_6_DWELL_S->unit: turns
tmbf/processor/h/SEQ_6_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_6_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_6_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_6_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_6_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_6_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_6_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_6_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_6_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_6_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_6_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_6_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_6_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_6_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_6_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_6_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_6_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_6_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_6_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_6_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_6_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_6_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_6_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_6_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_6_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_6_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_7_BANK_S->description: "Bunch bank selection"
tmbf/processor/h/SEQ_7_BANK_S->EnumLabels: "Bank 0",\ 
                                           "Bank 1",\ 
                                           "Bank 2",\ 
                                           "Bank 3"
tmbf/processor/h/SEQ_7_BLANK_S->description: "Detector blanking control"
tmbf/processor/h/SEQ_7_BLANK_S->EnumLabels: Off,\ 
                                            Blanking
tmbf/processor/h/SEQ_7_CAPTURE_S->description: "Enable data capture"
tmbf/processor/h/SEQ_7_CAPTURE_S->EnumLabels: Discard,\ 
                                              Capture
tmbf/processor/h/SEQ_7_COUNT_S->description: "Sweep count"
tmbf/processor/h/SEQ_7_COUNT_S->format: %5d
tmbf/processor/h/SEQ_7_COUNT_S->max_value: 65536.0
tmbf/processor/h/SEQ_7_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_7_DWELL_S->description: "Sweep dwell time"
tmbf/processor/h/SEQ_7_DWELL_S->format: %5d
tmbf/processor/h/SEQ_7_DWELL_S->max_value: 65536.0
tmbf/processor/h/SEQ_7_DWELL_S->min_value: 1.0
tmbf/processor/h/SEQ_7_DWELL_S->unit: turns
tmbf/processor/h/SEQ_7_ENABLE_S->description: "Enable Sweep NCO"
tmbf/processor/h/SEQ_7_ENABLE_S->EnumLabels: Off,\ 
                                             On
tmbf/processor/h/SEQ_7_END_FREQ_S->description: "Sweep NCO end frequency"
tmbf/processor/h/SEQ_7_END_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_7_END_FREQ_S->unit: tune
tmbf/processor/h/SEQ_7_ENWIN_S->description: "Enable detector window"
tmbf/processor/h/SEQ_7_ENWIN_S->EnumLabels: Disabled,\ 
                                            Windowed
tmbf/processor/h/SEQ_7_GAIN_S->description: "Sweep NCO gain"
tmbf/processor/h/SEQ_7_GAIN_S->EnumLabels: 0dB,\ 
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
tmbf/processor/h/SEQ_7_HOLDOFF_S->description: "Detector holdoff"
tmbf/processor/h/SEQ_7_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_7_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_7_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_7_START_FREQ_S->description: "Sweep NCO start frequency"
tmbf/processor/h/SEQ_7_START_FREQ_S->format: %8.5f
tmbf/processor/h/SEQ_7_START_FREQ_S->unit: tune
tmbf/processor/h/SEQ_7_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
tmbf/processor/h/SEQ_7_STATE_HOLDOFF_S->format: %5d
tmbf/processor/h/SEQ_7_STATE_HOLDOFF_S->max_value: 65535.0
tmbf/processor/h/SEQ_7_STATE_HOLDOFF_S->min_value: 0.0
tmbf/processor/h/SEQ_7_STEP_FREQ_S->description: "Sweep NCO step frequency"
tmbf/processor/h/SEQ_7_STEP_FREQ_S->format: %10.7f
tmbf/processor/h/SEQ_7_STEP_FREQ_S->unit: tune
tmbf/processor/h/SEQ_7_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
tmbf/processor/h/SEQ_7_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                               Follow
tmbf/processor/h/SEQ_7_UPDATE_END_S->description: "Update end frequency"
tmbf/processor/h/SEQ_BUSY->description: "Sequencer busy state"
tmbf/processor/h/SEQ_BUSY->EnumLabels: Idle,\ 
                                       Busy
tmbf/processor/h/SEQ_DURATION->description: "Raw capture duration"
tmbf/processor/h/SEQ_DURATION->unit: turns
tmbf/processor/h/SEQ_DURATION_S->description: "Capture duration"
tmbf/processor/h/SEQ_DURATION_S->format: %.3f
tmbf/processor/h/SEQ_DURATION_S->unit: s
tmbf/processor/h/SEQ_LENGTH->description: "Sequencer capture count"
tmbf/processor/h/SEQ_MODE->description: "Sequencer mode"
tmbf/processor/h/SEQ_PC->description: "Current sequencer state"
tmbf/processor/h/SEQ_PC_S->description: "Sequencer PC"
tmbf/processor/h/SEQ_PC_S->format: %1d
tmbf/processor/h/SEQ_PC_S->max_value: 7.0
tmbf/processor/h/SEQ_PC_S->min_value: 1.0
tmbf/processor/h/SEQ_RESET_S->description: "Halt sequencer if busy"
tmbf/processor/h/SEQ_RESET_WIN_S->description: "Reset detector window to Hamming"
tmbf/processor/h/SEQ_STATUS_READ_S->description: "Poll sequencer status"
tmbf/processor/h/SEQ_SUPER_COUNT->description: "Current super sequencer count"
tmbf/processor/h/SEQ_SUPER_COUNT->max_value: 1024.0
tmbf/processor/h/SEQ_SUPER_COUNT->min_value: 0.0
tmbf/processor/h/SEQ_SUPER_COUNT_S->description: "Super sequencer count"
tmbf/processor/h/SEQ_SUPER_COUNT_S->format: %4d
tmbf/processor/h/SEQ_SUPER_COUNT_S->max_value: 1024.0
tmbf/processor/h/SEQ_SUPER_COUNT_S->min_value: 1.0
tmbf/processor/h/SEQ_SUPER_OFFSET_S->description: "Frequency offsets for super sequencer"
tmbf/processor/h/SEQ_SUPER_OFFSET_S->format: %.5f
tmbf/processor/h/SEQ_SUPER_RESET_S->description: "Reset super sequencer offsets"
tmbf/processor/h/SEQ_TOTAL_DURATION->description: "Super sequence raw capture duration"
tmbf/processor/h/SEQ_TOTAL_DURATION->format: %.0f
tmbf/processor/h/SEQ_TOTAL_DURATION->unit: turns
tmbf/processor/h/SEQ_TOTAL_DURATION_S->description: "Super capture duration"
tmbf/processor/h/SEQ_TOTAL_DURATION_S->format: %.3f
tmbf/processor/h/SEQ_TOTAL_DURATION_S->unit: s
tmbf/processor/h/SEQ_TOTAL_LENGTH->description: "Super sequencer capture count"
tmbf/processor/h/SEQ_TOTAL_LENGTH->format: %.0f
tmbf/processor/h/SEQ_TRIGGER_S->description: "State to generate sequencer trigger"
tmbf/processor/h/SEQ_TRIGGER_S->format: %1d
tmbf/processor/h/SEQ_TRIGGER_S->max_value: 7.0
tmbf/processor/h/SEQ_TRIGGER_S->min_value: 0.0
tmbf/processor/h/SEQ_UPDATE_COUNT_S->description: "Internal sequencer state update"
tmbf/processor/h/SEQ_WINDOW_S->description: "Detector window"
tmbf/processor/h/STA_STATUS->description: "Axis X signal health"
tmbf/processor/h/TRG_SEQ_ADC0_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_ADC0_BL_S->EnumLabels: All,\ 
                                                Blanking
tmbf/processor/h/TRG_SEQ_ADC0_EN_S->description: "Enable Y ADC event input"
tmbf/processor/h/TRG_SEQ_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                Enable
tmbf/processor/h/TRG_SEQ_ADC0_HIT->description: "Y ADC event source"
tmbf/processor/h/TRG_SEQ_ADC0_HIT->EnumLabels: No,\ 
                                               Yes
tmbf/processor/h/TRG_SEQ_ADC1_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_ADC1_BL_S->EnumLabels: All,\ 
                                                Blanking
tmbf/processor/h/TRG_SEQ_ADC1_EN_S->description: "Enable X ADC event input"
tmbf/processor/h/TRG_SEQ_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                Enable
tmbf/processor/h/TRG_SEQ_ADC1_HIT->description: "X ADC event source"
tmbf/processor/h/TRG_SEQ_ADC1_HIT->EnumLabels: No,\ 
                                               Yes
tmbf/processor/h/TRG_SEQ_ARM_S->description: "Arm trigger"
tmbf/processor/h/TRG_SEQ_BL_S->description: "Write blanking"
tmbf/processor/h/TRG_SEQ_DELAY_S->description: "Trigger delay"
tmbf/processor/h/TRG_SEQ_DELAY_S->format: %3d
tmbf/processor/h/TRG_SEQ_DELAY_S->max_value: 65535.0
tmbf/processor/h/TRG_SEQ_DELAY_S->min_value: 0.0
tmbf/processor/h/TRG_SEQ_DISARM_S->description: "Disarm trigger"
tmbf/processor/h/TRG_SEQ_EN_S->description: "Write enables"
tmbf/processor/h/TRG_SEQ_EXT_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_EXT_BL_S->EnumLabels: All,\ 
                                               Blanking
tmbf/processor/h/TRG_SEQ_EXT_EN_S->description: "Enable External trigger input"
tmbf/processor/h/TRG_SEQ_EXT_EN_S->EnumLabels: Ignore,\ 
                                               Enable
tmbf/processor/h/TRG_SEQ_EXT_HIT->description: "External trigger source"
tmbf/processor/h/TRG_SEQ_EXT_HIT->EnumLabels: No,\ 
                                              Yes
tmbf/processor/h/TRG_SEQ_HIT->description: "Update source events"
tmbf/processor/h/TRG_SEQ_MODE_S->description: "Arming mode"
tmbf/processor/h/TRG_SEQ_MODE_S->EnumLabels: "One Shot",\ 
                                             Rearm,\ 
                                             Shared
tmbf/processor/h/TRG_SEQ_PM_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_PM_BL_S->EnumLabels: All,\ 
                                              Blanking
tmbf/processor/h/TRG_SEQ_PM_EN_S->description: "Enable Postmortem trigger input"
tmbf/processor/h/TRG_SEQ_PM_EN_S->EnumLabels: Ignore,\ 
                                              Enable
tmbf/processor/h/TRG_SEQ_PM_HIT->description: "Postmortem trigger source"
tmbf/processor/h/TRG_SEQ_PM_HIT->EnumLabels: No,\ 
                                             Yes
tmbf/processor/h/TRG_SEQ_SEQ0_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_SEQ0_BL_S->EnumLabels: All,\ 
                                                Blanking
tmbf/processor/h/TRG_SEQ_SEQ0_EN_S->description: "Enable Y SEQ event input"
tmbf/processor/h/TRG_SEQ_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                Enable
tmbf/processor/h/TRG_SEQ_SEQ0_HIT->description: "Y SEQ event source"
tmbf/processor/h/TRG_SEQ_SEQ0_HIT->EnumLabels: No,\ 
                                               Yes
tmbf/processor/h/TRG_SEQ_SEQ1_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_SEQ1_BL_S->EnumLabels: All,\ 
                                                Blanking
tmbf/processor/h/TRG_SEQ_SEQ1_EN_S->description: "Enable X SEQ event input"
tmbf/processor/h/TRG_SEQ_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                Enable
tmbf/processor/h/TRG_SEQ_SEQ1_HIT->description: "X SEQ event source"
tmbf/processor/h/TRG_SEQ_SEQ1_HIT->EnumLabels: No,\ 
                                               Yes
tmbf/processor/h/TRG_SEQ_SOFT_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/h/TRG_SEQ_SOFT_BL_S->EnumLabels: All,\ 
                                                Blanking
tmbf/processor/h/TRG_SEQ_SOFT_EN_S->description: "Enable Soft trigger input"
tmbf/processor/h/TRG_SEQ_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                Enable
tmbf/processor/h/TRG_SEQ_SOFT_HIT->description: "Soft trigger source"
tmbf/processor/h/TRG_SEQ_SOFT_HIT->EnumLabels: No,\ 
                                               Yes
tmbf/processor/h/TRG_SEQ_STATUS->description: "Trigger target status"
tmbf/processor/h/TRG_SEQ_STATUS->EnumLabels: Idle,\ 
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



# --- dserver/Tango2Epics/tmbf-h properties

dserver/Tango2Epics/tmbf-h->polling_threads_pool_conf: "tmbf/processor/h"
