#
# Resource backup , created Tue Jul 09 15:21:57 CEST 2019
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-l, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-l/DEVICE/Tango2Epics: "sr/d-mfdbk/utca-longitudinal"


# --- sr/d-mfdbk/utca-longitudinal properties

sr/d-mfdbk/utca-longitudinal->ArrayAccessTimeout: 0.3
sr/d-mfdbk/utca-longitudinal->ScalarAccessTimeout: 0.2
sr/d-mfdbk/utca-longitudinal->SubscriptionCycle: 0.4
sr/d-mfdbk/utca-longitudinal->Variables: SR-LMBF:ADC:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_FAN,\ 
                                         SR-LMBF:ADC:EVENTS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_FAN1,\ 
                                         SR-LMBF:ADC:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_S,\ 
                                         SR-LMBF:DAC:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_FAN,\ 
                                         SR-LMBF:DAC:EVENTS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_FAN1,\ 
                                         SR-LMBF:DAC:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_S,\ 
                                         SR-LMBF:DLY:DAC:COARSE_DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_COARSE_DELAY_S,\ 
                                         SR-LMBF:DLY:DAC:DELAY_PS*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_DAC_DELAY_PS,\ 
                                         SR-LMBF:DLY:DAC:FIFO*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_DAC_FIFO,\ 
                                         SR-LMBF:DLY:DAC:FINE_DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_FINE_DELAY_S,\ 
                                         SR-LMBF:DLY:DAC:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_RESET_S,\ 
                                         SR-LMBF:DLY:DAC:STEP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_STEP_S,\ 
                                         SR-LMBF:DLY:STEP_SIZE*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_STEP_SIZE,\ 
                                         SR-LMBF:DLY:TURN:DELAY_PS*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_TURN_DELAY_PS,\ 
                                         SR-LMBF:DLY:TURN:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_DELAY_S,\ 
                                         SR-LMBF:DLY:TURN:ERRORS*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_TURN_ERRORS,\ 
                                         SR-LMBF:DLY:TURN:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_FAN,\ 
                                         SR-LMBF:DLY:TURN:OFFSET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_OFFSET_S,\ 
                                         SR-LMBF:DLY:TURN:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_POLL_S,\ 
                                         SR-LMBF:DLY:TURN:RATE*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_TURN_RATE,\ 
                                         SR-LMBF:DLY:TURN:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*DLY_TURN_STATUS,\ 
                                         SR-LMBF:DLY:TURN:SYNC_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_SYNC_S,\ 
                                         SR-LMBF:DLY:TURN:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_TURN_TURNS,\ 
                                         SR-LMBF:FIR:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_EVENTS_FAN,\ 
                                         SR-LMBF:FIR:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_EVENTS_S,\ 
                                         SR-LMBF:I:ADC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_ADC_DRAM_SOURCE_S,\ 
                                         SR-LMBF:I:ADC:EVENT*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_ADC_EVENT,\ 
                                         SR-LMBF:I:ADC:EVENT_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*I_ADC_EVENT_LIMIT_S,\ 
                                         SR-LMBF:I:ADC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*I_ADC_FILTER_S,\ 
                                         SR-LMBF:I:ADC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_ADC_FIR_OVF,\ 
                                         SR-LMBF:I:ADC:INP_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_ADC_INP_OVF,\ 
                                         SR-LMBF:I:ADC:LOOPBACK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_ADC_LOOPBACK_S,\ 
                                         SR-LMBF:I:ADC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_ADC_MMS_ARCHIVE_DONE_S,\ 
                                         SR-LMBF:I:ADC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*I_ADC_MMS_ARCHIVE_TRIG,\ 
                                         SR-LMBF:I:ADC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*I_ADC_MMS_ARCHIVE_TRIG_FAN,\ 
                                         SR-LMBF:I:ADC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_DELTA,\ 
                                         SR-LMBF:I:ADC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*I_ADC_MMS_FAN,\ 
                                         SR-LMBF:I:ADC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*I_ADC_MMS_FAN1,\ 
                                         SR-LMBF:I:ADC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_MAX,\ 
                                         SR-LMBF:I:ADC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_MEAN,\ 
                                         SR-LMBF:I:ADC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_MEAN_MEAN,\ 
                                         SR-LMBF:I:ADC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_MIN,\ 
                                         SR-LMBF:I:ADC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_ADC_MMS_OVERFLOW,\ 
                                         SR-LMBF:I:ADC:MMS:RESET_FAULT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_ADC_MMS_RESET_FAULT_S,\ 
                                         SR-LMBF:I:ADC:MMS:SCAN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_ADC_MMS_SCAN_S,\ 
                                         SR-LMBF:I:ADC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_STD,\ 
                                         SR-LMBF:I:ADC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_STD_MAX_WF,\ 
                                         SR-LMBF:I:ADC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_STD_MEAN,\ 
                                         SR-LMBF:I:ADC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_STD_MEAN_DB,\ 
                                         SR-LMBF:I:ADC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_STD_MEAN_WF,\ 
                                         SR-LMBF:I:ADC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*I_ADC_MMS_STD_MIN_WF,\ 
                                         SR-LMBF:I:ADC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*I_ADC_MMS_TURNS,\ 
                                         SR-LMBF:I:ADC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_ADC_MMS_SOURCE_S,\ 
                                         SR-LMBF:I:ADC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_ADC_OVF,\ 
                                         SR-LMBF:I:ADC:OVF_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*I_ADC_OVF_LIMIT_S,\ 
                                         SR-LMBF:I:ADC:REJECT_COUNT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_ADC_REJECT_COUNT_S,\ 
                                         SR-LMBF:I:DAC:BUN_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_DAC_BUN_OVF,\ 
                                         SR-LMBF:I:DAC:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_DELAY_S,\ 
                                         SR-LMBF:I:DAC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_DAC_DRAM_SOURCE_S,\ 
                                         SR-LMBF:I:DAC:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_DAC_ENABLE_S,\ 
                                         SR-LMBF:I:DAC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*I_DAC_FILTER_S,\ 
                                         SR-LMBF:I:DAC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_DAC_FIR_OVF,\ 
                                         SR-LMBF:I:DAC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_MMS_ARCHIVE_DONE_S,\ 
                                         SR-LMBF:I:DAC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*I_DAC_MMS_ARCHIVE_TRIG,\ 
                                         SR-LMBF:I:DAC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_MMS_ARCHIVE_TRIG_FAN,\ 
                                         SR-LMBF:I:DAC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_DELTA,\ 
                                         SR-LMBF:I:DAC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_MMS_FAN,\ 
                                         SR-LMBF:I:DAC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_MMS_FAN1,\ 
                                         SR-LMBF:I:DAC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_MAX,\ 
                                         SR-LMBF:I:DAC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_MEAN,\ 
                                         SR-LMBF:I:DAC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_MEAN_MEAN,\ 
                                         SR-LMBF:I:DAC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_MIN,\ 
                                         SR-LMBF:I:DAC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_DAC_MMS_OVERFLOW,\ 
                                         SR-LMBF:I:DAC:MMS:RESET_FAULT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_MMS_RESET_FAULT_S,\ 
                                         SR-LMBF:I:DAC:MMS:SCAN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*I_DAC_MMS_SCAN_S,\ 
                                         SR-LMBF:I:DAC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_STD,\ 
                                         SR-LMBF:I:DAC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_STD_MAX_WF,\ 
                                         SR-LMBF:I:DAC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_STD_MEAN,\ 
                                         SR-LMBF:I:DAC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_STD_MEAN_DB,\ 
                                         SR-LMBF:I:DAC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_STD_MEAN_WF,\ 
                                         SR-LMBF:I:DAC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*I_DAC_MMS_STD_MIN_WF,\ 
                                         SR-LMBF:I:DAC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*I_DAC_MMS_TURNS,\ 
                                         SR-LMBF:I:DAC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*I_DAC_MMS_SOURCE_S,\ 
                                         SR-LMBF:I:DAC:MUX_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_DAC_MUX_OVF,\ 
                                         SR-LMBF:I:DAC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_DAC_OVF,\ 
                                         SR-LMBF:I:FIR:0:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*I_FIR_0_TAPS,\ 
                                         SR-LMBF:I:FIR:0:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*I_FIR_0_TAPS_S,\ 
                                         SR-LMBF:I:FIR:1:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*I_FIR_1_TAPS,\ 
                                         SR-LMBF:I:FIR:1:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*I_FIR_1_TAPS_S,\ 
                                         SR-LMBF:I:FIR:2:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*I_FIR_2_TAPS,\ 
                                         SR-LMBF:I:FIR:2:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*I_FIR_2_TAPS_S,\ 
                                         SR-LMBF:I:FIR:3:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*I_FIR_3_TAPS,\ 
                                         SR-LMBF:I:FIR:3:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*I_FIR_3_TAPS_S,\ 
                                         SR-LMBF:I:FIR:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*I_FIR_OVF,\ 
                                         SR-LMBF:INFO:ADC_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_ADC_TAPS,\ 
                                         SR-LMBF:INFO:AXIS0*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_AXIS0,\ 
                                         SR-LMBF:INFO:AXIS1*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_AXIS1,\ 
                                         SR-LMBF:INFO:BUNCHES*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_BUNCHES,\ 
                                         SR-LMBF:INFO:BUNCH_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_BUNCH_TAPS,\ 
                                         SR-LMBF:INFO:DAC_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_DAC_TAPS,\ 
                                         SR-LMBF:INFO:DEVICE*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_DEVICE,\ 
                                         SR-LMBF:INFO:DRIVER_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_DRIVER_VERSION,\ 
                                         SR-LMBF:INFO:FPGA_GIT_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_FPGA_GIT_VERSION,\ 
                                         SR-LMBF:INFO:FPGA_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_FPGA_VERSION,\ 
                                         SR-LMBF:INFO:GIT_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_GIT_VERSION,\ 
                                         SR-LMBF:INFO:HOSTNAME*Array:256*Int*READ_ONLY*ATTRIBUTE*INFO_HOSTNAME,\ 
                                         SR-LMBF:INFO:MODE*Scalar*Enum*READ_ONLY*ATTRIBUTE*INFO_MODE,\ 
                                         SR-LMBF:INFO:SOCKET*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_SOCKET,\ 
                                         SR-LMBF:INFO:VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*INFO_VERSION,\ 
                                         SR-LMBF:IQ:ADC:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_ADC_FAN,\ 
                                         SR-LMBF:IQ:ADC:MAGNITUDE*Array:432*Double*READ_ONLY*ATTRIBUTE*IQ_ADC_MAGNITUDE,\ 
                                         SR-LMBF:IQ:ADC:MAGNITUDE_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_ADC_MAGNITUDE_MEAN,\ 
                                         SR-LMBF:IQ:ADC:PHASE*Array:432*Double*READ_ONLY*ATTRIBUTE*IQ_ADC_PHASE,\ 
                                         SR-LMBF:IQ:ADC:PHASE_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_ADC_PHASE_MEAN,\ 
                                         SR-LMBF:IQ:ADC:THRESHOLD_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_ADC_THRESHOLD_S,\ 
                                         SR-LMBF:IQ:ADC:TRIGGER_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_ADC_TRIGGER_S,\ 
                                         SR-LMBF:IQ:BUN:0:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_BUN_0_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:0:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_0_DAC_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:0:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_0_FIRWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:0:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_0_FIRWF_STA,\ 
                                         SR-LMBF:IQ:BUN:0:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_0_FIRWF_S,\ 
                                         SR-LMBF:IQ:BUN:0:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_0_FIR_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:0:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_0_GAINWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:0:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_0_GAINWF_STA,\ 
                                         SR-LMBF:IQ:BUN:0:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_0_GAINWF_S,\ 
                                         SR-LMBF:IQ:BUN:0:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_0_GAIN_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:0:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_0_OUTWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:0:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_0_OUTWF_STA,\ 
                                         SR-LMBF:IQ:BUN:0:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_0_OUTWF_S,\ 
                                         SR-LMBF:IQ:BUN:0:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_0_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:BUN:1:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_BUN_1_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:1:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_1_DAC_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:1:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_1_FIRWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:1:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_1_FIRWF_STA,\ 
                                         SR-LMBF:IQ:BUN:1:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_1_FIRWF_S,\ 
                                         SR-LMBF:IQ:BUN:1:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_1_FIR_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:1:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_1_GAINWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:1:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_1_GAINWF_STA,\ 
                                         SR-LMBF:IQ:BUN:1:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_1_GAINWF_S,\ 
                                         SR-LMBF:IQ:BUN:1:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_1_GAIN_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:1:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_1_OUTWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:1:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_1_OUTWF_STA,\ 
                                         SR-LMBF:IQ:BUN:1:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_1_OUTWF_S,\ 
                                         SR-LMBF:IQ:BUN:1:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_1_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:BUN:2:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_BUN_2_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:2:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_2_DAC_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:2:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_2_FIRWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:2:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_2_FIRWF_STA,\ 
                                         SR-LMBF:IQ:BUN:2:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_2_FIRWF_S,\ 
                                         SR-LMBF:IQ:BUN:2:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_2_FIR_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:2:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_2_GAINWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:2:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_2_GAINWF_STA,\ 
                                         SR-LMBF:IQ:BUN:2:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_2_GAINWF_S,\ 
                                         SR-LMBF:IQ:BUN:2:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_2_GAIN_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:2:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_2_OUTWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:2:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_2_OUTWF_STA,\ 
                                         SR-LMBF:IQ:BUN:2:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_2_OUTWF_S,\ 
                                         SR-LMBF:IQ:BUN:2:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_2_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:BUN:3:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_BUN_3_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:3:DAC_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_3_DAC_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:3:FIRWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_3_FIRWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:3:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_3_FIRWF_STA,\ 
                                         SR-LMBF:IQ:BUN:3:FIRWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_3_FIRWF_S,\ 
                                         SR-LMBF:IQ:BUN:3:FIR_SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_BUN_3_FIR_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:3:GAINWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_3_GAINWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:3:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_3_GAINWF_STA,\ 
                                         SR-LMBF:IQ:BUN:3:GAINWF_S*Array:432*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_3_GAINWF_S,\ 
                                         SR-LMBF:IQ:BUN:3:GAIN_SELECT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_BUN_3_GAIN_SELECT_S,\ 
                                         SR-LMBF:IQ:BUN:3:OUTWF:SET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_3_OUTWF_SET_S,\ 
                                         SR-LMBF:IQ:BUN:3:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_3_OUTWF_STA,\ 
                                         SR-LMBF:IQ:BUN:3:OUTWF_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_BUN_3_OUTWF_S,\ 
                                         SR-LMBF:IQ:BUN:3:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_3_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:BUN:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_BUN_MODE,\ 
                                         SR-LMBF:IQ:DET:0:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_DET_0_BUNCHES_S,\ 
                                         SR-LMBF:IQ:DET:0:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_DET_0_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:0:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_0_COUNT,\ 
                                         SR-LMBF:IQ:DET:0:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_0_ENABLE,\ 
                                         SR-LMBF:IQ:DET:0:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_0_ENABLE_S,\ 
                                         SR-LMBF:IQ:DET:0:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_0_I,\ 
                                         SR-LMBF:IQ:DET:0:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_DET_0_MAX_POWER,\ 
                                         SR-LMBF:IQ:DET:0:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_0_OUT_OVF,\ 
                                         SR-LMBF:IQ:DET:0:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_0_PHASE,\ 
                                         SR-LMBF:IQ:DET:0:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_0_POWER,\ 
                                         SR-LMBF:IQ:DET:0:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_0_Q,\ 
                                         SR-LMBF:IQ:DET:0:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_0_RESET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:0:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_0_SCALING_S,\ 
                                         SR-LMBF:IQ:DET:0:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_DET_0_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:DET:0:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_0_SET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:1:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_DET_1_BUNCHES_S,\ 
                                         SR-LMBF:IQ:DET:1:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_DET_1_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:1:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_1_COUNT,\ 
                                         SR-LMBF:IQ:DET:1:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_1_ENABLE,\ 
                                         SR-LMBF:IQ:DET:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_1_ENABLE_S,\ 
                                         SR-LMBF:IQ:DET:1:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_1_I,\ 
                                         SR-LMBF:IQ:DET:1:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_DET_1_MAX_POWER,\ 
                                         SR-LMBF:IQ:DET:1:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_1_OUT_OVF,\ 
                                         SR-LMBF:IQ:DET:1:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_1_PHASE,\ 
                                         SR-LMBF:IQ:DET:1:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_1_POWER,\ 
                                         SR-LMBF:IQ:DET:1:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_1_Q,\ 
                                         SR-LMBF:IQ:DET:1:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_1_RESET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:1:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_1_SCALING_S,\ 
                                         SR-LMBF:IQ:DET:1:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_DET_1_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:DET:1:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_1_SET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:2:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_DET_2_BUNCHES_S,\ 
                                         SR-LMBF:IQ:DET:2:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_DET_2_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:2:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_2_COUNT,\ 
                                         SR-LMBF:IQ:DET:2:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_2_ENABLE,\ 
                                         SR-LMBF:IQ:DET:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_2_ENABLE_S,\ 
                                         SR-LMBF:IQ:DET:2:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_2_I,\ 
                                         SR-LMBF:IQ:DET:2:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_DET_2_MAX_POWER,\ 
                                         SR-LMBF:IQ:DET:2:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_2_OUT_OVF,\ 
                                         SR-LMBF:IQ:DET:2:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_2_PHASE,\ 
                                         SR-LMBF:IQ:DET:2:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_2_POWER,\ 
                                         SR-LMBF:IQ:DET:2:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_2_Q,\ 
                                         SR-LMBF:IQ:DET:2:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_2_RESET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:2:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_2_SCALING_S,\ 
                                         SR-LMBF:IQ:DET:2:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_DET_2_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:DET:2:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_2_SET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:3:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_DET_3_BUNCHES_S,\ 
                                         SR-LMBF:IQ:DET:3:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_DET_3_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:3:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_3_COUNT,\ 
                                         SR-LMBF:IQ:DET:3:ENABLE*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_3_ENABLE,\ 
                                         SR-LMBF:IQ:DET:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_3_ENABLE_S,\ 
                                         SR-LMBF:IQ:DET:3:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_3_I,\ 
                                         SR-LMBF:IQ:DET:3:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_DET_3_MAX_POWER,\ 
                                         SR-LMBF:IQ:DET:3:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_3_OUT_OVF,\ 
                                         SR-LMBF:IQ:DET:3:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_3_PHASE,\ 
                                         SR-LMBF:IQ:DET:3:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_3_POWER,\ 
                                         SR-LMBF:IQ:DET:3:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_3_Q,\ 
                                         SR-LMBF:IQ:DET:3:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_3_RESET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:3:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_3_SCALING_S,\ 
                                         SR-LMBF:IQ:DET:3:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_DET_3_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:DET:3:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_3_SET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:FILL_WAVEFORM_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_FILL_WAVEFORM_S,\ 
                                         SR-LMBF:IQ:DET:FIR_DELAY_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_DET_FIR_DELAY_S,\ 
                                         SR-LMBF:IQ:DET:SAMPLES*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_SAMPLES,\ 
                                         SR-LMBF:IQ:DET:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_DET_SCALE,\ 
                                         SR-LMBF:IQ:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_DET_SELECT_S,\ 
                                         SR-LMBF:IQ:DET:TIMEBASE*Array:4096*Int*READ_ONLY*ATTRIBUTE*IQ_DET_TIMEBASE,\ 
                                         SR-LMBF:IQ:DET:UNDERRUN*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_DET_UNDERRUN,\ 
                                         SR-LMBF:IQ:DET:UPDATE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_DONE_S,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_UPDATE_TRIG,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_TRIG_FAN,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_TRIG_FAN1,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG:FAN2*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_TRIG_FAN2,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG:FAN3*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_TRIG_FAN3,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG:FAN4*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_TRIG_FAN4,\ 
                                         SR-LMBF:IQ:DET:UPDATE:TRIG:FAN5*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_TRIG_FAN5,\ 
                                         SR-LMBF:IQ:DET:UPDATE_SCALE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_SCALE_DONE_S,\ 
                                         SR-LMBF:IQ:DET:UPDATE_SCALE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_DET_UPDATE_SCALE_TRIG,\ 
                                         SR-LMBF:IQ:DET:UPDATE_SCALE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_DET_UPDATE_SCALE_TRIG_FAN,\ 
                                         SR-LMBF:IQ:FIR:0:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_0_CYCLES_S,\ 
                                         SR-LMBF:IQ:FIR:0:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_0_LENGTH_S,\ 
                                         SR-LMBF:IQ:FIR:0:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_FIR_0_PHASE_S,\ 
                                         SR-LMBF:IQ:FIR:0:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_0_RELOAD_S,\ 
                                         SR-LMBF:IQ:FIR:0:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_FIR_0_USEWF_S,\ 
                                         SR-LMBF:IQ:FIR:1:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_1_CYCLES_S,\ 
                                         SR-LMBF:IQ:FIR:1:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_1_LENGTH_S,\ 
                                         SR-LMBF:IQ:FIR:1:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_FIR_1_PHASE_S,\ 
                                         SR-LMBF:IQ:FIR:1:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_1_RELOAD_S,\ 
                                         SR-LMBF:IQ:FIR:1:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_FIR_1_USEWF_S,\ 
                                         SR-LMBF:IQ:FIR:2:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_2_CYCLES_S,\ 
                                         SR-LMBF:IQ:FIR:2:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_2_LENGTH_S,\ 
                                         SR-LMBF:IQ:FIR:2:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_FIR_2_PHASE_S,\ 
                                         SR-LMBF:IQ:FIR:2:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_2_RELOAD_S,\ 
                                         SR-LMBF:IQ:FIR:2:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_FIR_2_USEWF_S,\ 
                                         SR-LMBF:IQ:FIR:3:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_3_CYCLES_S,\ 
                                         SR-LMBF:IQ:FIR:3:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_3_LENGTH_S,\ 
                                         SR-LMBF:IQ:FIR:3:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_FIR_3_PHASE_S,\ 
                                         SR-LMBF:IQ:FIR:3:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_3_RELOAD_S,\ 
                                         SR-LMBF:IQ:FIR:3:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_FIR_3_USEWF_S,\ 
                                         SR-LMBF:IQ:FIR:DECIMATION_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_DECIMATION_S,\ 
                                         SR-LMBF:IQ:FIR:GAIN:DN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_GAIN_DN_S,\ 
                                         SR-LMBF:IQ:FIR:GAIN:UP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_FIR_GAIN_UP_S,\ 
                                         SR-LMBF:IQ:FIR:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_FIR_GAIN_S,\ 
                                         SR-LMBF:IQ:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_NCO_ENABLE_S,\ 
                                         SR-LMBF:IQ:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_NCO_FREQ_S,\ 
                                         SR-LMBF:IQ:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_NCO_GAIN_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:KI_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_KI_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:KP_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_KP_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:MAX_OFFSET_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_MAX_OFFSET_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:MIN_MAG_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_MIN_MAG_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:START_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_START_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_CTRL_STATUS,\ 
                                         SR-LMBF:IQ:PLL:CTRL:STOP:DET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_CTRL_STOP_DET_OVF,\ 
                                         SR-LMBF:IQ:PLL:CTRL:STOP:MAG_ERROR*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_CTRL_STOP_MAG_ERROR,\ 
                                         SR-LMBF:IQ:PLL:CTRL:STOP:OFFSET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_CTRL_STOP_OFFSET_OVF,\ 
                                         SR-LMBF:IQ:PLL:CTRL:STOP:STOP*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_CTRL_STOP_STOP,\ 
                                         SR-LMBF:IQ:PLL:CTRL:STOP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_STOP_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:TARGET_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_TARGET_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:UPDATE_STATUS:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_UPDATE_STATUS_DONE_S,\ 
                                         SR-LMBF:IQ:PLL:CTRL:UPDATE_STATUS:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_PLL_CTRL_UPDATE_STATUS_TRIG,\ 
                                         SR-LMBF:IQ:PLL:CTRL:UPDATE_STATUS:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_CTRL_UPDATE_STATUS_TRIG_FAN,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:ANGLE*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_ANGLE,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:COMPENSATE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_DEBUG_COMPENSATE_S,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_DEBUG_ENABLE_S,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:FIFO_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_FIFO_OVF,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:MAG*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_MAG,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:READ:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DEBUG_READ_DONE_S,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:READ:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_READ_TRIG,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:READ:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DEBUG_READ_TRIG_FAN,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:READ:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DEBUG_READ_TRIG_FAN1,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:RSTD*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_RSTD,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:RSTD_ABS*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_RSTD_ABS,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:RSTD_ABS_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_RSTD_ABS_DB,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:RSTD_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_RSTD_DB,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_DEBUG_SELECT_S,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:WFI*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_WFI,\ 
                                         SR-LMBF:IQ:PLL:DEBUG:WFQ*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_DEBUG_WFQ,\ 
                                         SR-LMBF:IQ:PLL:DET:BLANKING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_BLANKING_S,\ 
                                         SR-LMBF:IQ:PLL:DET:BUNCHES_S*Array:432*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_BUNCHES_S,\ 
                                         SR-LMBF:IQ:PLL:DET:BUNCH_SELECT_S*Scalar*String*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_BUNCH_SELECT_S,\ 
                                         SR-LMBF:IQ:PLL:DET:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_PLL_DET_COUNT,\ 
                                         SR-LMBF:IQ:PLL:DET:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_DWELL_S,\ 
                                         SR-LMBF:IQ:PLL:DET:RESET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_RESET_SELECT_S,\ 
                                         SR-LMBF:IQ:PLL:DET:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_SCALING_S,\ 
                                         SR-LMBF:IQ:PLL:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_SELECT_S,\ 
                                         SR-LMBF:IQ:PLL:DET:SELECT_STATUS*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_PLL_DET_SELECT_STATUS,\ 
                                         SR-LMBF:IQ:PLL:DET:SET_SELECT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_DET_SET_SELECT_S,\ 
                                         SR-LMBF:IQ:PLL:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_FAN,\ 
                                         SR-LMBF:IQ:PLL:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_FAN1,\ 
                                         SR-LMBF:IQ:PLL:FILT:I*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_FILT_I,\ 
                                         SR-LMBF:IQ:PLL:FILT:MAG*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_FILT_MAG,\ 
                                         SR-LMBF:IQ:PLL:FILT:MAG_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_FILT_MAG_DB,\ 
                                         SR-LMBF:IQ:PLL:FILT:PHASE*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_FILT_PHASE,\ 
                                         SR-LMBF:IQ:PLL:FILT:Q*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_FILT_Q,\ 
                                         SR-LMBF:IQ:PLL:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_NCO_ENABLE_S,\ 
                                         SR-LMBF:IQ:PLL:NCO:FIFO_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_FIFO_OVF,\ 
                                         SR-LMBF:IQ:PLL:NCO:FREQ*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_FREQ,\ 
                                         SR-LMBF:IQ:PLL:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_PLL_NCO_FREQ_S,\ 
                                         SR-LMBF:IQ:PLL:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_PLL_NCO_GAIN_S,\ 
                                         SR-LMBF:IQ:PLL:NCO:MEAN_OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_MEAN_OFFSET,\ 
                                         SR-LMBF:IQ:PLL:NCO:OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_OFFSET,\ 
                                         SR-LMBF:IQ:PLL:NCO:OFFSETWF*Array:4096*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_OFFSETWF,\ 
                                         SR-LMBF:IQ:PLL:NCO:READ:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_NCO_READ_DONE_S,\ 
                                         SR-LMBF:IQ:PLL:NCO:READ:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_READ_TRIG,\ 
                                         SR-LMBF:IQ:PLL:NCO:READ:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_NCO_READ_TRIG_FAN,\ 
                                         SR-LMBF:IQ:PLL:NCO:RESET_FIFO_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_NCO_RESET_FIFO_S,\ 
                                         SR-LMBF:IQ:PLL:NCO:STD_OFFSET*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_STD_OFFSET,\ 
                                         SR-LMBF:IQ:PLL:NCO:TUNE*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_PLL_NCO_TUNE,\ 
                                         SR-LMBF:IQ:PLL:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_PLL_POLL_S,\ 
                                         SR-LMBF:IQ:PLL:STA:DET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_STA_DET_OVF,\ 
                                         SR-LMBF:IQ:PLL:STA:MAG_ERROR*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_STA_MAG_ERROR,\ 
                                         SR-LMBF:IQ:PLL:STA:OFFSET_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_PLL_STA_OFFSET_OVF,\ 
                                         SR-LMBF:IQ:SEQ:0:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_0_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:1:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:1:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:1:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:1:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:1:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:1:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:1:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:1:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:1:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:1:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:1:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:1:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:1:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_1_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:2:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:2:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:2:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:2:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:2:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:2:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:2:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:2:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:2:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:2:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:2:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:2:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:2:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_2_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:3:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:3:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:3:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:3:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:3:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:3:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:3:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:3:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:3:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:3:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:3:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:3:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:3:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_3_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:4:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:4:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:4:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:4:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:4:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:4:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:4:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:4:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:4:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:4:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:4:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:4:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:4:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:4:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_4_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:5:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:5:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:5:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:5:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:5:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:5:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:5:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:5:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:5:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:5:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:5:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:5:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:5:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:5:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_5_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:6:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:6:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:6:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:6:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:6:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:6:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:6:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:6:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:6:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:6:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:6:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:6:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:6:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:6:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_6_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:7:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_BANK_S,\ 
                                         SR-LMBF:IQ:SEQ:7:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_BLANK_S,\ 
                                         SR-LMBF:IQ:SEQ:7:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_CAPTURE_S,\ 
                                         SR-LMBF:IQ:SEQ:7:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:7:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_DWELL_S,\ 
                                         SR-LMBF:IQ:SEQ:7:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_ENABLE_S,\ 
                                         SR-LMBF:IQ:SEQ:7:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_END_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:7:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_ENWIN_S,\ 
                                         SR-LMBF:IQ:SEQ:7:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_GAIN_S,\ 
                                         SR-LMBF:IQ:SEQ:7:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:7:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_START_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:7:STATE_HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_STATE_HOLDOFF_S,\ 
                                         SR-LMBF:IQ:SEQ:7:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_STEP_FREQ_S,\ 
                                         SR-LMBF:IQ:SEQ:7:TUNE_PLL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_SEQ_7_TUNE_PLL_S,\ 
                                         SR-LMBF:IQ:SEQ:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_SEQ_BUSY,\ 
                                         SR-LMBF:IQ:SEQ:COUNT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_COUNT_FAN,\ 
                                         SR-LMBF:IQ:SEQ:DURATION*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_SEQ_DURATION,\ 
                                         SR-LMBF:IQ:SEQ:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_SEQ_DURATION_S,\ 
                                         SR-LMBF:IQ:SEQ:LENGTH*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_SEQ_LENGTH,\ 
                                         SR-LMBF:IQ:SEQ:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*IQ_SEQ_MODE,\ 
                                         SR-LMBF:IQ:SEQ:PC*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_SEQ_PC,\ 
                                         SR-LMBF:IQ:SEQ:PC_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_PC_S,\ 
                                         SR-LMBF:IQ:SEQ:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_RESET_S,\ 
                                         SR-LMBF:IQ:SEQ:RESET_WIN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_RESET_WIN_S,\ 
                                         SR-LMBF:IQ:SEQ:STATUS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_STATUS_FAN,\ 
                                         SR-LMBF:IQ:SEQ:STATUS:READ_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_STATUS_READ_S,\ 
                                         SR-LMBF:IQ:SEQ:SUPER:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_SEQ_SUPER_COUNT,\ 
                                         SR-LMBF:IQ:SEQ:SUPER:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_SUPER_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:SUPER:OFFSET_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_SUPER_OFFSET_S,\ 
                                         SR-LMBF:IQ:SEQ:SUPER:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_SUPER_RESET_S,\ 
                                         SR-LMBF:IQ:SEQ:TOTAL:DURATION*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_SEQ_TOTAL_DURATION,\ 
                                         SR-LMBF:IQ:SEQ:TOTAL:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_SEQ_TOTAL_DURATION_S,\ 
                                         SR-LMBF:IQ:SEQ:TOTAL:LENGTH*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_SEQ_TOTAL_LENGTH,\ 
                                         SR-LMBF:IQ:SEQ:TRIGGER_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_TRIGGER_S,\ 
                                         SR-LMBF:IQ:SEQ:UPDATE_COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_SEQ_UPDATE_COUNT_S,\ 
                                         SR-LMBF:IQ:SEQ:WINDOW_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*IQ_SEQ_WINDOW_S,\ 
                                         SR-LMBF:IQ:STA:STATUS*Scalar*Double*READ_ONLY*ATTRIBUTE*IQ_STA_STATUS,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_ADC0_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_ADC0_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_ADC0_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_ADC1_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_ADC1_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_ADC1_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:ARM_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_ARM_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_DELAY_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:DISARM_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_DISARM_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_EXT_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_EXT_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_EXT_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_HIT_FAN,\ 
                                         SR-LMBF:IQ:TRG:SEQ:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_HIT_FAN1,\ 
                                         SR-LMBF:IQ:TRG:SEQ:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_MODE_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_PM_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_PM_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_PM_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_SEQ0_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_SEQ0_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_SEQ0_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_SEQ1_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_SEQ1_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_SEQ1_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_SOFT_BL_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*IQ_TRG_SEQ_SOFT_EN_S,\ 
                                         SR-LMBF:IQ:TRG:SEQ:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_SOFT_HIT,\ 
                                         SR-LMBF:IQ:TRG:SEQ:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*IQ_TRG_SEQ_STATUS,\ 
                                         SR-LMBF:MEM:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_BUSY,\ 
                                         SR-LMBF:MEM:CAPTURE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_CAPTURE_S,\ 
                                         SR-LMBF:MEM:FIR0_GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_FIR0_GAIN_S,\ 
                                         SR-LMBF:MEM:FIR0_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_FIR0_OVF,\ 
                                         SR-LMBF:MEM:FIR1_GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_FIR1_GAIN_S,\ 
                                         SR-LMBF:MEM:FIR1_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_FIR1_OVF,\ 
                                         SR-LMBF:MEM:OFFSET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_OFFSET_S,\ 
                                         SR-LMBF:MEM:READ:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READ_FAN,\ 
                                         SR-LMBF:MEM:READOUT:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READOUT_DONE_S,\ 
                                         SR-LMBF:MEM:READOUT:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*MEM_READOUT_TRIG,\ 
                                         SR-LMBF:MEM:READOUT:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READOUT_TRIG_FAN,\ 
                                         SR-LMBF:MEM:READ_OVF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READ_OVF_S,\ 
                                         SR-LMBF:MEM:RUNOUT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_RUNOUT_S,\ 
                                         SR-LMBF:MEM:SEL0_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SEL0_S,\ 
                                         SR-LMBF:MEM:SEL1_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SEL1_S,\ 
                                         SR-LMBF:MEM:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SELECT_S,\ 
                                         SR-LMBF:MEM:WF0*Array:16384*Int*READ_ONLY*ATTRIBUTE*MEM_WF0,\ 
                                         SR-LMBF:MEM:WF1*Array:16384*Int*READ_ONLY*ATTRIBUTE*MEM_WF1,\ 
                                         SR-LMBF:MEM:WRITE_GAIN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_WRITE_GAIN_S,\ 
                                         SR-LMBF:Q:ADC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_ADC_DRAM_SOURCE_S,\ 
                                         SR-LMBF:Q:ADC:EVENT*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_ADC_EVENT,\ 
                                         SR-LMBF:Q:ADC:EVENT_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*Q_ADC_EVENT_LIMIT_S,\ 
                                         SR-LMBF:Q:ADC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*Q_ADC_FILTER_S,\ 
                                         SR-LMBF:Q:ADC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_ADC_FIR_OVF,\ 
                                         SR-LMBF:Q:ADC:INP_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_ADC_INP_OVF,\ 
                                         SR-LMBF:Q:ADC:LOOPBACK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_ADC_LOOPBACK_S,\ 
                                         SR-LMBF:Q:ADC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_ARCHIVE_DONE_S,\ 
                                         SR-LMBF:Q:ADC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_ARCHIVE_TRIG,\ 
                                         SR-LMBF:Q:ADC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_ARCHIVE_TRIG_FAN,\ 
                                         SR-LMBF:Q:ADC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_DELTA,\ 
                                         SR-LMBF:Q:ADC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_FAN,\ 
                                         SR-LMBF:Q:ADC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_FAN1,\ 
                                         SR-LMBF:Q:ADC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_MAX,\ 
                                         SR-LMBF:Q:ADC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_MEAN,\ 
                                         SR-LMBF:Q:ADC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_MEAN_MEAN,\ 
                                         SR-LMBF:Q:ADC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_MIN,\ 
                                         SR-LMBF:Q:ADC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_OVERFLOW,\ 
                                         SR-LMBF:Q:ADC:MMS:RESET_FAULT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_RESET_FAULT_S,\ 
                                         SR-LMBF:Q:ADC:MMS:SCAN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_SCAN_S,\ 
                                         SR-LMBF:Q:ADC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_STD,\ 
                                         SR-LMBF:Q:ADC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_STD_MAX_WF,\ 
                                         SR-LMBF:Q:ADC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_STD_MEAN,\ 
                                         SR-LMBF:Q:ADC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_STD_MEAN_DB,\ 
                                         SR-LMBF:Q:ADC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_STD_MEAN_WF,\ 
                                         SR-LMBF:Q:ADC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_STD_MIN_WF,\ 
                                         SR-LMBF:Q:ADC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*Q_ADC_MMS_TURNS,\ 
                                         SR-LMBF:Q:ADC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_ADC_MMS_SOURCE_S,\ 
                                         SR-LMBF:Q:ADC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_ADC_OVF,\ 
                                         SR-LMBF:Q:ADC:OVF_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*Q_ADC_OVF_LIMIT_S,\ 
                                         SR-LMBF:Q:ADC:REJECT_COUNT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_ADC_REJECT_COUNT_S,\ 
                                         SR-LMBF:Q:DAC:BUN_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_DAC_BUN_OVF,\ 
                                         SR-LMBF:Q:DAC:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_DELAY_S,\ 
                                         SR-LMBF:Q:DAC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_DAC_DRAM_SOURCE_S,\ 
                                         SR-LMBF:Q:DAC:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_DAC_ENABLE_S,\ 
                                         SR-LMBF:Q:DAC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*Q_DAC_FILTER_S,\ 
                                         SR-LMBF:Q:DAC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_DAC_FIR_OVF,\ 
                                         SR-LMBF:Q:DAC:MMS:ARCHIVE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_ARCHIVE_DONE_S,\ 
                                         SR-LMBF:Q:DAC:MMS:ARCHIVE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_ARCHIVE_TRIG,\ 
                                         SR-LMBF:Q:DAC:MMS:ARCHIVE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_ARCHIVE_TRIG_FAN,\ 
                                         SR-LMBF:Q:DAC:MMS:DELTA*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_DELTA,\ 
                                         SR-LMBF:Q:DAC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_FAN,\ 
                                         SR-LMBF:Q:DAC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_FAN1,\ 
                                         SR-LMBF:Q:DAC:MMS:MAX*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_MAX,\ 
                                         SR-LMBF:Q:DAC:MMS:MEAN*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_MEAN,\ 
                                         SR-LMBF:Q:DAC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_MEAN_MEAN,\ 
                                         SR-LMBF:Q:DAC:MMS:MIN*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_MIN,\ 
                                         SR-LMBF:Q:DAC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_OVERFLOW,\ 
                                         SR-LMBF:Q:DAC:MMS:RESET_FAULT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_RESET_FAULT_S,\ 
                                         SR-LMBF:Q:DAC:MMS:SCAN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_SCAN_S,\ 
                                         SR-LMBF:Q:DAC:MMS:STD*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_STD,\ 
                                         SR-LMBF:Q:DAC:MMS:STD_MAX_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_STD_MAX_WF,\ 
                                         SR-LMBF:Q:DAC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_STD_MEAN,\ 
                                         SR-LMBF:Q:DAC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_STD_MEAN_DB,\ 
                                         SR-LMBF:Q:DAC:MMS:STD_MEAN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_STD_MEAN_WF,\ 
                                         SR-LMBF:Q:DAC:MMS:STD_MIN_WF*Array:432*Double*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_STD_MIN_WF,\ 
                                         SR-LMBF:Q:DAC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*Q_DAC_MMS_TURNS,\ 
                                         SR-LMBF:Q:DAC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*Q_DAC_MMS_SOURCE_S,\ 
                                         SR-LMBF:Q:DAC:MUX_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_DAC_MUX_OVF,\ 
                                         SR-LMBF:Q:DAC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_DAC_OVF,\ 
                                         SR-LMBF:Q:FIR:0:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*Q_FIR_0_TAPS,\ 
                                         SR-LMBF:Q:FIR:0:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*Q_FIR_0_TAPS_S,\ 
                                         SR-LMBF:Q:FIR:1:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*Q_FIR_1_TAPS,\ 
                                         SR-LMBF:Q:FIR:1:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*Q_FIR_1_TAPS_S,\ 
                                         SR-LMBF:Q:FIR:2:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*Q_FIR_2_TAPS,\ 
                                         SR-LMBF:Q:FIR:2:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*Q_FIR_2_TAPS_S,\ 
                                         SR-LMBF:Q:FIR:3:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*Q_FIR_3_TAPS,\ 
                                         SR-LMBF:Q:FIR:3:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*Q_FIR_3_TAPS_S,\ 
                                         SR-LMBF:Q:FIR:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*Q_FIR_OVF,\ 
                                         SR-LMBF:STA:CLOCK*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_CLOCK,\ 
                                         SR-LMBF:STA:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*STA_FAN,\ 
                                         SR-LMBF:STA:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*STA_POLL_S,\ 
                                         SR-LMBF:STA:VCO*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_VCO,\ 
                                         SR-LMBF:STA:VCXO*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_VCXO,\ 
                                         SR-LMBF:TRG:ADC0:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_ADC0_IN,\ 
                                         SR-LMBF:TRG:ADC1:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_ADC1_IN,\ 
                                         SR-LMBF:TRG:ARM_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_ARM_S,\ 
                                         SR-LMBF:TRG:BLANKING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_BLANKING_S,\ 
                                         SR-LMBF:TRG:BLNK:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_BLNK_IN,\ 
                                         SR-LMBF:TRG:DISARM_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_DISARM_S,\ 
                                         SR-LMBF:TRG:EXT:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_EXT_IN,\ 
                                         SR-LMBF:TRG:IN:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_FAN,\ 
                                         SR-LMBF:TRG:IN:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_FAN1,\ 
                                         SR-LMBF:TRG:IN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_S,\ 
                                         SR-LMBF:TRG:MEM:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC0_BL_S,\ 
                                         SR-LMBF:TRG:MEM:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC0_EN_S,\ 
                                         SR-LMBF:TRG:MEM:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_ADC0_HIT,\ 
                                         SR-LMBF:TRG:MEM:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC1_BL_S,\ 
                                         SR-LMBF:TRG:MEM:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC1_EN_S,\ 
                                         SR-LMBF:TRG:MEM:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_ADC1_HIT,\ 
                                         SR-LMBF:TRG:MEM:ARM_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_ARM_S,\ 
                                         SR-LMBF:TRG:MEM:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_BL_S,\ 
                                         SR-LMBF:TRG:MEM:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_DELAY_S,\ 
                                         SR-LMBF:TRG:MEM:DISARM_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_DISARM_S,\ 
                                         SR-LMBF:TRG:MEM:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_EN_S,\ 
                                         SR-LMBF:TRG:MEM:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_EXT_BL_S,\ 
                                         SR-LMBF:TRG:MEM:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_EXT_EN_S,\ 
                                         SR-LMBF:TRG:MEM:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_EXT_HIT,\ 
                                         SR-LMBF:TRG:MEM:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*TRG_MEM_HIT,\ 
                                         SR-LMBF:TRG:MEM:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_HIT_FAN,\ 
                                         SR-LMBF:TRG:MEM:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_HIT_FAN1,\ 
                                         SR-LMBF:TRG:MEM:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_MODE_S,\ 
                                         SR-LMBF:TRG:MEM:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_PM_BL_S,\ 
                                         SR-LMBF:TRG:MEM:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_PM_EN_S,\ 
                                         SR-LMBF:TRG:MEM:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_PM_HIT,\ 
                                         SR-LMBF:TRG:MEM:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ0_BL_S,\ 
                                         SR-LMBF:TRG:MEM:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ0_EN_S,\ 
                                         SR-LMBF:TRG:MEM:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SEQ0_HIT,\ 
                                         SR-LMBF:TRG:MEM:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ1_BL_S,\ 
                                         SR-LMBF:TRG:MEM:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ1_EN_S,\ 
                                         SR-LMBF:TRG:MEM:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SEQ1_HIT,\ 
                                         SR-LMBF:TRG:MEM:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SOFT_BL_S,\ 
                                         SR-LMBF:TRG:MEM:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SOFT_EN_S,\ 
                                         SR-LMBF:TRG:MEM:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SOFT_HIT,\ 
                                         SR-LMBF:TRG:MEM:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_STATUS,\ 
                                         SR-LMBF:TRG:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MODE_S,\ 
                                         SR-LMBF:TRG:PM:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_PM_IN,\ 
                                         SR-LMBF:TRG:SEQ0:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ0_IN,\ 
                                         SR-LMBF:TRG:SEQ1:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ1_IN,\ 
                                         SR-LMBF:TRG:SHARED*Scalar*String*READ_ONLY*ATTRIBUTE*TRG_SHARED,\ 
                                         SR-LMBF:TRG:SOFT:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SOFT_IN,\ 
                                         SR-LMBF:TRG:SOFT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SOFT_S,\ 
                                         SR-LMBF:TRG:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_STATUS

# --- sr/d-mfdbk/utca-longitudinal attribute properties

sr/d-mfdbk/utca-longitudinal/ADC_EVENTS_S->description: "ADC event detect scan"
sr/d-mfdbk/utca-longitudinal/DAC_EVENTS_S->description: "DAC event detect scan"
sr/d-mfdbk/utca-longitudinal/DLY_DAC_COARSE_DELAY_S->description: "DAC clock coarse delay"
sr/d-mfdbk/utca-longitudinal/DLY_DAC_DELAY_PS->unit: ps
sr/d-mfdbk/utca-longitudinal/DLY_DAC_FIFO->description: "DAC output FIFO depth"
sr/d-mfdbk/utca-longitudinal/DLY_DAC_FINE_DELAY_S->description: "DAC clock fine delay"
sr/d-mfdbk/utca-longitudinal/DLY_DAC_FINE_DELAY_S->format: %2d
sr/d-mfdbk/utca-longitudinal/DLY_DAC_FINE_DELAY_S->max_value: 23.0
sr/d-mfdbk/utca-longitudinal/DLY_DAC_FINE_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/DLY_DAC_RESET_S->description: "Reset coarse delay"
sr/d-mfdbk/utca-longitudinal/DLY_DAC_STEP_S->description: "Advance coarse delay"
sr/d-mfdbk/utca-longitudinal/DLY_STEP_SIZE->description: "Duration of coarse step"
sr/d-mfdbk/utca-longitudinal/DLY_STEP_SIZE->unit: ps
sr/d-mfdbk/utca-longitudinal/DLY_TURN_DELAY_PS->unit: ps
sr/d-mfdbk/utca-longitudinal/DLY_TURN_DELAY_S->description: "Turn clock input delay"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_DELAY_S->format: %2d
sr/d-mfdbk/utca-longitudinal/DLY_TURN_DELAY_S->max_value: 31.0
sr/d-mfdbk/utca-longitudinal/DLY_TURN_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/DLY_TURN_ERRORS->description: "Turn clock errors"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_OFFSET_S->description: "Turn clock offset"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_POLL_S->description: "Update turn status"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_RATE->description: "Clock error rate"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_STATUS->description: "Turn clock status"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_STATUS->EnumLabels: Armed,\ 
                                                          Synced,\ 
                                                          "Sync Errors"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_SYNC_S->description: "Synchronise turn clock"
sr/d-mfdbk/utca-longitudinal/DLY_TURN_TURNS->description: "Turns sampled"
sr/d-mfdbk/utca-longitudinal/FIR_EVENTS_S->description: "FIR event detect scan"
sr/d-mfdbk/utca-longitudinal/INFO_ADC_TAPS->description: "Length of ADC compensation filter"
sr/d-mfdbk/utca-longitudinal/INFO_AXIS0->description: "Name of first axis"
sr/d-mfdbk/utca-longitudinal/INFO_AXIS1->description: "Name of second axis"
sr/d-mfdbk/utca-longitudinal/INFO_BUNCHES->description: "Number of bunches per revolution"
sr/d-mfdbk/utca-longitudinal/INFO_BUNCH_TAPS->description: "Length of bunch-by-bunch feedback filter"
sr/d-mfdbk/utca-longitudinal/INFO_DAC_TAPS->description: "Length of DAC pre-emphasis filter"
sr/d-mfdbk/utca-longitudinal/INFO_DEVICE->description: "Name of AMC525 device"
sr/d-mfdbk/utca-longitudinal/INFO_DRIVER_VERSION->description: "Kernel driver version"
sr/d-mfdbk/utca-longitudinal/INFO_FPGA_GIT_VERSION->description: "Firmware git version"
sr/d-mfdbk/utca-longitudinal/INFO_FPGA_VERSION->description: "Firmware version"
sr/d-mfdbk/utca-longitudinal/INFO_GIT_VERSION->description: "Software git version"
sr/d-mfdbk/utca-longitudinal/INFO_HOSTNAME->description: "Host name of MBF IOC"
sr/d-mfdbk/utca-longitudinal/INFO_MODE->description: "Operational mode"
sr/d-mfdbk/utca-longitudinal/INFO_MODE->EnumLabels: TMBF,\ 
                                                    LMBF
sr/d-mfdbk/utca-longitudinal/INFO_SOCKET->description: "Socket number for data server"
sr/d-mfdbk/utca-longitudinal/INFO_VERSION->description: "Software version"
sr/d-mfdbk/utca-longitudinal/IQ_ADC_MAGNITUDE->description: "Bunch magnitude"
sr/d-mfdbk/utca-longitudinal/IQ_ADC_MAGNITUDE_MEAN->description: "Average bunch magnitude"
sr/d-mfdbk/utca-longitudinal/IQ_ADC_PHASE->description: "Bunch phase"
sr/d-mfdbk/utca-longitudinal/IQ_ADC_PHASE->unit: deg
sr/d-mfdbk/utca-longitudinal/IQ_ADC_PHASE_MEAN->description: "Average bunch phase"
sr/d-mfdbk/utca-longitudinal/IQ_ADC_PHASE_MEAN->unit: deg
sr/d-mfdbk/utca-longitudinal/IQ_ADC_THRESHOLD_S->description: "Magnitude phase threshold"
sr/d-mfdbk/utca-longitudinal/IQ_ADC_THRESHOLD_S->format: %1.3f
sr/d-mfdbk/utca-longitudinal/IQ_ADC_THRESHOLD_S->max_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_ADC_THRESHOLD_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_ADC_TRIGGER_S->description: "Update bunch phase"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_DAC_SELECT_S->description: "Select DAC output"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_DAC_SELECT_S->EnumLabels: Off,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_FIRWF_S->description: "Set 0 FIR bank select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_FIRWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_FIRWF_STA->description: "Bank 0 FIRWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_FIR_SELECT_S->description: "Select FIR setting"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                                "FIR 1",\ 
                                                                "FIR 2",\ 
                                                                "FIR 3"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_GAINWF_S->description: "Set 0 DAC output gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_GAINWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_GAINWF_STA->description: "Bank 0 GAINWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_GAIN_SELECT_S->description: "Select bunch gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_GAIN_SELECT_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_OUTWF_S->description: "Set 0 DAC output select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_OUTWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_OUTWF_STA->description: "Bank 0 OUTWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_0_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_DAC_SELECT_S->description: "Select DAC output"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_DAC_SELECT_S->EnumLabels: Off,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_FIRWF_S->description: "Set 1 FIR bank select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_FIRWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_FIRWF_STA->description: "Bank 1 FIRWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_FIR_SELECT_S->description: "Select FIR setting"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                                "FIR 1",\ 
                                                                "FIR 2",\ 
                                                                "FIR 3"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_GAINWF_S->description: "Set 1 DAC output gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_GAINWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_GAINWF_STA->description: "Bank 1 GAINWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_GAIN_SELECT_S->description: "Select bunch gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_GAIN_SELECT_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_OUTWF_S->description: "Set 1 DAC output select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_OUTWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_OUTWF_STA->description: "Bank 1 OUTWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_1_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_DAC_SELECT_S->description: "Select DAC output"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_DAC_SELECT_S->EnumLabels: Off,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_FIRWF_S->description: "Set 2 FIR bank select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_FIRWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_FIRWF_STA->description: "Bank 2 FIRWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_FIR_SELECT_S->description: "Select FIR setting"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                                "FIR 1",\ 
                                                                "FIR 2",\ 
                                                                "FIR 3"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_GAINWF_S->description: "Set 2 DAC output gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_GAINWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_GAINWF_STA->description: "Bank 2 GAINWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_GAIN_SELECT_S->description: "Select bunch gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_GAIN_SELECT_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_OUTWF_S->description: "Set 2 DAC output select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_OUTWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_OUTWF_STA->description: "Bank 2 OUTWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_2_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_DAC_SELECT_S->description: "Select DAC output"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_DAC_SELECT_S->EnumLabels: Off,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_FIRWF_S->description: "Set 3 FIR bank select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_FIRWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_FIRWF_STA->description: "Bank 3 FIRWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_FIR_SELECT_S->description: "Select FIR setting"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_FIR_SELECT_S->EnumLabels: "FIR 0",\ 
                                                                "FIR 1",\ 
                                                                "FIR 2",\ 
                                                                "FIR 3"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_GAINWF_S->description: "Set 3 DAC output gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_GAINWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_GAINWF_STA->description: "Bank 3 GAINWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_GAIN_SELECT_S->description: "Select bunch gain"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_GAIN_SELECT_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_OUTWF_S->description: "Set 3 DAC output select"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_OUTWF_SET_S->description: "Set selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_OUTWF_STA->description: "Bank 3 OUTWF status"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_3_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_BUN_MODE->description: "Feedback mode"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_ENABLE->description: "Current detector enable state"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_ENABLE->EnumLabels: Disabled,\ 
                                                          Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_ENABLE_S->EnumLabels: Disabled,\ 
                                                            Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_I->description: "Detector I"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_MAX_POWER->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_OUT_OVF->EnumLabels: Ok,\ 
                                                           Overflow
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_POWER->description: "Detector Power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_Q->description: "Detector Q"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_RESET_SELECT_S->description: "Disable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_SCALING_S->EnumLabels: 0dB,\ 
                                                             -48dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_DET_0_SET_SELECT_S->description: "Enable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_ENABLE->description: "Current detector enable state"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_ENABLE->EnumLabels: Disabled,\ 
                                                          Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_ENABLE_S->EnumLabels: Disabled,\ 
                                                            Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_I->description: "Detector I"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_MAX_POWER->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_OUT_OVF->EnumLabels: Ok,\ 
                                                           Overflow
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_POWER->description: "Detector Power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_Q->description: "Detector Q"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_RESET_SELECT_S->description: "Disable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_SCALING_S->EnumLabels: 0dB,\ 
                                                             -48dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_DET_1_SET_SELECT_S->description: "Enable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_ENABLE->description: "Current detector enable state"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_ENABLE->EnumLabels: Disabled,\ 
                                                          Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_ENABLE_S->EnumLabels: Disabled,\ 
                                                            Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_I->description: "Detector I"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_MAX_POWER->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_OUT_OVF->EnumLabels: Ok,\ 
                                                           Overflow
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_POWER->description: "Detector Power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_Q->description: "Detector Q"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_RESET_SELECT_S->description: "Disable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_SCALING_S->EnumLabels: 0dB,\ 
                                                             -48dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_DET_2_SET_SELECT_S->description: "Enable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_ENABLE->description: "Current detector enable state"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_ENABLE->EnumLabels: Disabled,\ 
                                                          Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_ENABLE_S->EnumLabels: Disabled,\ 
                                                            Enabled
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_I->description: "Detector I"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_MAX_POWER->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_OUT_OVF->EnumLabels: Ok,\ 
                                                           Overflow
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_POWER->description: "Detector Power"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_Q->description: "Detector Q"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_RESET_SELECT_S->description: "Disable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_SCALING_S->EnumLabels: 0dB,\ 
                                                             -48dB
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_DET_3_SET_SELECT_S->description: "Enable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_DET_FILL_WAVEFORM_S->description: "Treatment of truncated waveforms"
sr/d-mfdbk/utca-longitudinal/IQ_DET_FILL_WAVEFORM_S->EnumLabels: Truncated,\ 
                                                                 Filled
sr/d-mfdbk/utca-longitudinal/IQ_DET_FIR_DELAY_S->description: "FIR nominal group delay"
sr/d-mfdbk/utca-longitudinal/IQ_DET_FIR_DELAY_S->format: %.1f
sr/d-mfdbk/utca-longitudinal/IQ_DET_FIR_DELAY_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_DET_SAMPLES->description: "Number of captured samples"
sr/d-mfdbk/utca-longitudinal/IQ_DET_SCALE->description: "Scale for frequency sweep"
sr/d-mfdbk/utca-longitudinal/IQ_DET_SELECT_S->description: "Select detector source"
sr/d-mfdbk/utca-longitudinal/IQ_DET_SELECT_S->EnumLabels: ADC,\ 
                                                          FIR,\ 
                                                          "ADC no fill"
sr/d-mfdbk/utca-longitudinal/IQ_DET_TIMEBASE->description: "Timebase for frequency sweep"
sr/d-mfdbk/utca-longitudinal/IQ_DET_UNDERRUN->description: "Data output underrun"
sr/d-mfdbk/utca-longitudinal/IQ_DET_UNDERRUN->EnumLabels: Ok,\ 
                                                          Underrun
sr/d-mfdbk/utca-longitudinal/IQ_DET_UPDATE_DONE_S->description: "UPDATE processing done"
sr/d-mfdbk/utca-longitudinal/IQ_DET_UPDATE_SCALE_DONE_S->description: "UPDATE_SCALE processing done"
sr/d-mfdbk/utca-longitudinal/IQ_DET_UPDATE_SCALE_TRIG->description: "UPDATE_SCALE processing trigger"
sr/d-mfdbk/utca-longitudinal/IQ_DET_UPDATE_TRIG->description: "UPDATE processing trigger"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_CYCLES_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_LENGTH_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_0_USEWF_S->EnumLabels: Settings,\ 
                                                           Waveform
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_CYCLES_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_LENGTH_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_1_USEWF_S->EnumLabels: Settings,\ 
                                                           Waveform
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_CYCLES_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_LENGTH_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_2_USEWF_S->EnumLabels: Settings,\ 
                                                           Waveform
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_CYCLES_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_LENGTH_S->format: %2d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_3_USEWF_S->EnumLabels: Settings,\ 
                                                           Waveform
sr/d-mfdbk/utca-longitudinal/IQ_FIR_DECIMATION_S->description: "Bunch by bunch decimation"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_DECIMATION_S->format: %3d
sr/d-mfdbk/utca-longitudinal/IQ_FIR_DECIMATION_S->max_value: 128.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_DECIMATION_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_FIR_GAIN_DN_S->description: "Decrease FIR gain"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_GAIN_S->description: "FIR gain select"
sr/d-mfdbk/utca-longitudinal/IQ_FIR_GAIN_S->EnumLabels: 48dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_FIR_GAIN_UP_S->description: "Increase FIR gain"
sr/d-mfdbk/utca-longitudinal/IQ_NCO_ENABLE_S->description: "Enable fixed NCO output"
sr/d-mfdbk/utca-longitudinal/IQ_NCO_ENABLE_S->EnumLabels: Off,\ 
                                                          On
sr/d-mfdbk/utca-longitudinal/IQ_NCO_FREQ_S->description: "Fixed NCO frequency"
sr/d-mfdbk/utca-longitudinal/IQ_NCO_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_NCO_GAIN_S->description: "Fixed NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_NCO_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_KI_S->description: "Integral factor for controller"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_KP_S->description: "Proportional factor for controller"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MAX_OFFSET_S->description: "Maximum frequency offset for feedback"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MAX_OFFSET_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MAX_OFFSET_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MIN_MAG_S->description: "Minimum magnitude for feedback"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MIN_MAG_S->format: %1.5f
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MIN_MAG_S->max_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_MIN_MAG_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_START_S->description: "Start tune PLL"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STATUS->description: "Tune PLL feedback status"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STATUS->EnumLabels: Stopped,\ 
                                                             Running
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_DET_OVF->description: "Detector overflow"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_DET_OVF->EnumLabels: Ok,\ 
                                                                   Overflow
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_MAG_ERROR->description: "Magnitude error"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_MAG_ERROR->EnumLabels: Ok,\ 
                                                                     "Too small"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_OFFSET_OVF->description: "Offset overflow"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_OFFSET_OVF->EnumLabels: Ok,\ 
                                                                      Overflow
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_S->description: "Stop tune PLL"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_STOP->description: "Stopped by user"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_STOP_STOP->EnumLabels: Ok,\ 
                                                                Stopped
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_TARGET_S->description: "Target phase"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_TARGET_S->format: %3.2f
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_TARGET_S->max_value: 180.0
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_TARGET_S->min_value: -180.0
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_UPDATE_STATUS_DONE_S->description: "UPDATE_STATUS processing done"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_CTRL_UPDATE_STATUS_TRIG->description: "UPDATE_STATUS processing trigger"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_ANGLE->description: "Tune PLL angle"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_COMPENSATE_S->description: "Compensate debug readbacks"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_COMPENSATE_S->EnumLabels: Raw,\ 
                                                                    Compensated
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_ENABLE_S->description: "Enable debug readbacks"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_ENABLE_S->EnumLabels: Off,\ 
                                                                On
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_FIFO_OVF->description: "Debug FIFO readout overrun"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_FIFO_OVF->EnumLabels: Ok,\ 
                                                                Overflow
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_MAG->description: "Tune PLL magnitude"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_READ_DONE_S->description: "READ processing done"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_READ_TRIG->description: "READ processing trigger"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_RSTD->description: "IQ relative standard deviation"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_RSTD_ABS->description: "Magnitude relative standard deviation"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_RSTD_ABS_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_RSTD_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_SELECT_S->description: "Select captured readback values"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_SELECT_S->EnumLabels: IQ,\ 
                                                                CORDIC
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_WFI->description: "Tune PLL detector I"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DEBUG_WFQ->description: "Tune PLL detector Q"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_BLANKING_S->description: "Response to blanking trigger"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_BLANKING_S->EnumLabels: Ignore,\ 
                                                                Blanking
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_BUNCH_SELECT_S->description: "Select bunch to set"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_DWELL_S->description: "Dwell time in turns"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_RESET_SELECT_S->description: "Disable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_SCALING_S->EnumLabels: 48dB,\ 
                                                               12dB,\ 
                                                               -24dB,\ 
                                                               -60dB
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_SELECT_S->description: "Select detector source"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_SELECT_S->EnumLabels: ADC,\ 
                                                              FIR,\ 
                                                              "ADC no fill"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_SELECT_STATUS->description: "Status of selection"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_DET_SET_SELECT_S->description: "Enable selected bunches"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_FILT_I->description: "Filtered Tune PLL detector I"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_FILT_MAG->description: "Filtered Tune PLL detector magnitude"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_FILT_MAG_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/IQ_PLL_FILT_PHASE->description: "Filtered Tune PLL phase offset"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_FILT_PHASE->unit: deg
sr/d-mfdbk/utca-longitudinal/IQ_PLL_FILT_Q->description: "Filtered Tune PLL detector Q"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_ENABLE_S->description: "Enable Tune PLL NCO output"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_ENABLE_S->EnumLabels: Off,\ 
                                                              On
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FIFO_OVF->description: "Offset FIFO readout overrun"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FIFO_OVF->EnumLabels: Ok,\ 
                                                              Overflow
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FREQ->description: "Tune PLL NCO frequency"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FREQ->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FREQ_S->description: "Base Tune PLL NCO frequency"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_GAIN_S->description: "Tune PLL NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_MEAN_OFFSET->description: "Mean tune PLL offset"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_MEAN_OFFSET->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_OFFSET->description: "Filtered frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_OFFSET->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_OFFSETWF->description: "Tune PLL offset"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_READ_DONE_S->description: "READ processing done"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_READ_TRIG->description: "READ processing trigger"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_RESET_FIFO_S->description: "Reset FIFO readout to force fresh sample"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_STD_OFFSET->description: "Standard deviation of offset"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_STD_OFFSET->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_TUNE->description: "Measured tune frequency"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_NCO_TUNE->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_PLL_POLL_S->description: "Poll Tune PLL readbacks"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_STA_DET_OVF->description: "Detector overflow"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_STA_DET_OVF->EnumLabels: Ok,\ 
                                                             Overflow
sr/d-mfdbk/utca-longitudinal/IQ_PLL_STA_MAG_ERROR->description: "Magnitude error"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_STA_MAG_ERROR->EnumLabels: Ok,\ 
                                                               "Too small"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_STA_OFFSET_OVF->description: "Offset overflow"
sr/d-mfdbk/utca-longitudinal/IQ_PLL_STA_OFFSET_OVF->EnumLabels: Ok,\ 
                                                                Overflow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_0_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_0_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_1_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_2_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_3_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_4_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_5_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_6_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_BANK_S->EnumLabels: "Bank 0",\ 
                                                          "Bank 1",\ 
                                                          "Bank 2",\ 
                                                          "Bank 3"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_BLANK_S->EnumLabels: Off,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_CAPTURE_S->EnumLabels: Discard,\ 
                                                             Capture
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_COUNT_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_DWELL_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_DWELL_S->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_ENABLE_S->EnumLabels: Off,\ 
                                                            On
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_END_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_ENWIN_S->EnumLabels: Disabled,\ 
                                                           Windowed
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_START_FREQ_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STATE_HOLDOFF_S->description: "Single holdoff on entry to state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STATE_HOLDOFF_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STATE_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STATE_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STEP_FREQ_S->format: %.7f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_TUNE_PLL_S->description: "Track Tune PLL frequency offset"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_7_TUNE_PLL_S->EnumLabels: Ignore,\ 
                                                              Follow
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_BUSY->description: "Sequencer busy state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_BUSY->EnumLabels: Idle,\ 
                                                      Busy
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_DURATION->description: "Raw capture duration"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_DURATION->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_DURATION_S->description: "Capture duration"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_DURATION_S->unit: s
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_LENGTH->description: "Sequencer capture count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_MODE->description: "Sequencer mode"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_PC->description: "Current sequencer state"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_PC_S->description: "Sequencer PC"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_PC_S->format: %1d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_PC_S->max_value: 7.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_PC_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_RESET_S->description: "Halt sequencer if busy"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_RESET_WIN_S->description: "Reset detector window to Hamming"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_STATUS_READ_S->description: "Poll sequencer status"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_COUNT->description: "Current super sequencer count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_COUNT_S->description: "Super sequencer count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_COUNT_S->format: %4d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_COUNT_S->max_value: 1024.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_OFFSET_S->description: "Frequency offsets for super sequencer"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_OFFSET_S->format: %.5f
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_SUPER_RESET_S->description: "Reset super sequencer offsets"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TOTAL_DURATION->description: "Super sequence raw capture duration"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TOTAL_DURATION->unit: turns
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TOTAL_DURATION_S->description: "Super capture duration"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TOTAL_DURATION_S->unit: s
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TOTAL_LENGTH->description: "Super sequencer capture count"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TRIGGER_S->description: "State to generate sequencer trigger"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TRIGGER_S->format: %1d
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TRIGGER_S->max_value: 7.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_TRIGGER_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_UPDATE_COUNT_S->description: "Internal sequencer state update"
sr/d-mfdbk/utca-longitudinal/IQ_SEQ_WINDOW_S->description: "Detector window"
sr/d-mfdbk/utca-longitudinal/IQ_STA_STATUS->description: "Axis IQ signal health"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC0_BL_S->EnumLabels: All,\ 
                                                               Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC0_EN_S->description: "Enable I ADC event input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                               Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC0_HIT->description: "I ADC event source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC0_HIT->EnumLabels: No,\ 
                                                              Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC1_BL_S->EnumLabels: All,\ 
                                                               Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC1_EN_S->description: "Enable Q ADC event input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                               Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC1_HIT->description: "Q ADC event source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ADC1_HIT->EnumLabels: No,\ 
                                                              Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_ARM_S->description: "Arm trigger"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_BL_S->description: "Write blanking"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_DELAY_S->description: "Trigger delay"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_DELAY_S->format: %5d
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_DELAY_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_DISARM_S->description: "Disarm trigger"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EN_S->description: "Write enables"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EXT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EXT_BL_S->EnumLabels: All,\ 
                                                              Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EXT_EN_S->description: "Enable External trigger input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EXT_EN_S->EnumLabels: Ignore,\ 
                                                              Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EXT_HIT->description: "External trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_EXT_HIT->EnumLabels: No,\ 
                                                             Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_HIT->description: "Update source events"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_MODE_S->description: "Arming mode"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_MODE_S->EnumLabels: "One Shot",\ 
                                                            Rearm,\ 
                                                            Shared
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_PM_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_PM_BL_S->EnumLabels: All,\ 
                                                             Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_PM_EN_S->description: "Enable Postmortem trigger input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_PM_EN_S->EnumLabels: Ignore,\ 
                                                             Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_PM_HIT->description: "Postmortem trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_PM_HIT->EnumLabels: No,\ 
                                                            Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ0_BL_S->EnumLabels: All,\ 
                                                               Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ0_EN_S->description: "Enable I SEQ event input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                               Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ0_HIT->description: "I SEQ event source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ0_HIT->EnumLabels: No,\ 
                                                              Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ1_BL_S->EnumLabels: All,\ 
                                                               Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ1_EN_S->description: "Enable Q SEQ event input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                               Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ1_HIT->description: "Q SEQ event source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SEQ1_HIT->EnumLabels: No,\ 
                                                              Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SOFT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SOFT_BL_S->EnumLabels: All,\ 
                                                               Blanking
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SOFT_EN_S->description: "Enable Soft trigger input"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                               Enable
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SOFT_HIT->description: "Soft trigger source"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_SOFT_HIT->EnumLabels: No,\ 
                                                              Yes
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_STATUS->description: "Trigger target status"
sr/d-mfdbk/utca-longitudinal/IQ_TRG_SEQ_STATUS->EnumLabels: Idle,\ 
                                                            Armed,\ 
                                                            Busy,\ 
                                                            Locked
sr/d-mfdbk/utca-longitudinal/I_ADC_DRAM_SOURCE_S->description: "Source of memory data"
sr/d-mfdbk/utca-longitudinal/I_ADC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                              "After FIR",\ 
                                                              "FIR no fill"
sr/d-mfdbk/utca-longitudinal/I_ADC_EVENT->description: "ADC min/max event"
sr/d-mfdbk/utca-longitudinal/I_ADC_EVENT->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/I_ADC_EVENT_LIMIT_S->description: "ADC min/max event threshold"
sr/d-mfdbk/utca-longitudinal/I_ADC_EVENT_LIMIT_S->format: %1.4f
sr/d-mfdbk/utca-longitudinal/I_ADC_EVENT_LIMIT_S->max_value: 2.0
sr/d-mfdbk/utca-longitudinal/I_ADC_EVENT_LIMIT_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/I_ADC_FILTER_S->description: "Input compensation filter"
sr/d-mfdbk/utca-longitudinal/I_ADC_FIR_OVF->description: "ADC FIR overflow"
sr/d-mfdbk/utca-longitudinal/I_ADC_FIR_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/I_ADC_INP_OVF->description: "ADC input overflow"
sr/d-mfdbk/utca-longitudinal/I_ADC_INP_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/I_ADC_LOOPBACK_S->description: "Enable DAC -> ADC loopback"
sr/d-mfdbk/utca-longitudinal/I_ADC_LOOPBACK_S->EnumLabels: Normal,\ 
                                                           Loopback
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_DELTA->description: "Max ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_MAX->description: "Max ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_MEAN->description: "Mean ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_MEAN_MEAN->description: "Mean position"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_MIN->description: "Min ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_OVERFLOW->description: "MMS capture overflow status"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                                             "Turns Overflow",\ 
                                                             "Sum Overflow",\ 
                                                             "Turns+Sum Overflow",\ 
                                                             "Sum2 Overflow",\ 
                                                             "Turns+Sum2 Overflow",\ 
                                                             "Sum+Sum2 Overflow",\ 
                                                             "Turns+Sum+Sum2 Overflow"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_SCAN_S->description: "ADC min/max scanning"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_SOURCE_S->description: "Source of min/max/sum data"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                             "After FIR",\ 
                                                             "FIR no fill"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD->description: "ADC standard deviation per bunch"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD_MEAN_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
sr/d-mfdbk/utca-longitudinal/I_ADC_MMS_TURNS->description: "Number of turns in this sample"
sr/d-mfdbk/utca-longitudinal/I_ADC_OVF->description: "ADC overflow"
sr/d-mfdbk/utca-longitudinal/I_ADC_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-longitudinal/I_ADC_OVF_LIMIT_S->description: "Overflow limit threshold"
sr/d-mfdbk/utca-longitudinal/I_ADC_OVF_LIMIT_S->format: %1.4f
sr/d-mfdbk/utca-longitudinal/I_ADC_OVF_LIMIT_S->max_value: 1.0
sr/d-mfdbk/utca-longitudinal/I_ADC_OVF_LIMIT_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/I_ADC_REJECT_COUNT_S->description: "Samples in fill pattern reject filter"
sr/d-mfdbk/utca-longitudinal/I_ADC_REJECT_COUNT_S->EnumLabels: "1 turns",\ 
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
sr/d-mfdbk/utca-longitudinal/I_DAC_BUN_OVF->description: "Bunch FIR overflow"
sr/d-mfdbk/utca-longitudinal/I_DAC_BUN_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/I_DAC_DELAY_S->description: "DAC output delay"
sr/d-mfdbk/utca-longitudinal/I_DAC_DRAM_SOURCE_S->description: "Source of memory data"
sr/d-mfdbk/utca-longitudinal/I_DAC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                              "After FIR"
sr/d-mfdbk/utca-longitudinal/I_DAC_ENABLE_S->description: "DAC output enable"
sr/d-mfdbk/utca-longitudinal/I_DAC_ENABLE_S->EnumLabels: Off,\ 
                                                         On
sr/d-mfdbk/utca-longitudinal/I_DAC_FILTER_S->description: "Output preemphasis filter"
sr/d-mfdbk/utca-longitudinal/I_DAC_FIR_OVF->description: "DAC FIR overflow"
sr/d-mfdbk/utca-longitudinal/I_DAC_FIR_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_DELTA->description: "Max DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_MAX->description: "Max DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_MEAN->description: "Mean DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_MEAN_MEAN->description: "Mean position"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_MIN->description: "Min DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_OVERFLOW->description: "MMS capture overflow status"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                                             "Turns Overflow",\ 
                                                             "Sum Overflow",\ 
                                                             "Turns+Sum Overflow",\ 
                                                             "Sum2 Overflow",\ 
                                                             "Turns+Sum2 Overflow",\ 
                                                             "Sum+Sum2 Overflow",\ 
                                                             "Turns+Sum+Sum2 Overflow"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_SCAN_S->description: "DAC min/max scanning"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_SOURCE_S->description: "Source of min/max/sum data"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                             "After FIR"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD->description: "DAC standard deviation per bunch"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD_MEAN_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
sr/d-mfdbk/utca-longitudinal/I_DAC_MMS_TURNS->description: "Number of turns in this sample"
sr/d-mfdbk/utca-longitudinal/I_DAC_MUX_OVF->description: "DAC output overflow"
sr/d-mfdbk/utca-longitudinal/I_DAC_MUX_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/I_DAC_OVF->description: "DAC overflow"
sr/d-mfdbk/utca-longitudinal/I_DAC_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-longitudinal/I_FIR_0_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_0_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_1_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_1_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_2_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_2_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_3_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_3_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/I_FIR_OVF->description: "Overflow in I bunch-by-bunch filter"
sr/d-mfdbk/utca-longitudinal/I_FIR_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-longitudinal/MEM_BUSY->description: "Capture status"
sr/d-mfdbk/utca-longitudinal/MEM_BUSY->EnumLabels: Ready,\ 
                                                   Busy
sr/d-mfdbk/utca-longitudinal/MEM_CAPTURE_S->description: "Untriggered immediate capture"
sr/d-mfdbk/utca-longitudinal/MEM_FIR0_GAIN_S->description: "FIR 0 capture gain"
sr/d-mfdbk/utca-longitudinal/MEM_FIR0_GAIN_S->EnumLabels: +54dB,\ 
                                                          0dB
sr/d-mfdbk/utca-longitudinal/MEM_FIR0_OVF->description: "FIR 0 capture will overflow"
sr/d-mfdbk/utca-longitudinal/MEM_FIR0_OVF->EnumLabels: Ok,\ 
                                                       Overflow
sr/d-mfdbk/utca-longitudinal/MEM_FIR1_GAIN_S->description: "FIR 1 capture gain"
sr/d-mfdbk/utca-longitudinal/MEM_FIR1_GAIN_S->EnumLabels: +54dB,\ 
                                                          0dB
sr/d-mfdbk/utca-longitudinal/MEM_FIR1_OVF->description: "FIR 1 capture will overflow"
sr/d-mfdbk/utca-longitudinal/MEM_FIR1_OVF->EnumLabels: Ok,\ 
                                                       Overflow
sr/d-mfdbk/utca-longitudinal/MEM_OFFSET_S->description: "Offset of readout"
sr/d-mfdbk/utca-longitudinal/MEM_OFFSET_S->unit: turns
sr/d-mfdbk/utca-longitudinal/MEM_READOUT_DONE_S->description: "READOUT processing done"
sr/d-mfdbk/utca-longitudinal/MEM_READOUT_TRIG->description: "READOUT processing trigger"
sr/d-mfdbk/utca-longitudinal/MEM_READ_OVF_S->description: "Poll overflow events"
sr/d-mfdbk/utca-longitudinal/MEM_RUNOUT_S->description: "Post trigger capture count"
sr/d-mfdbk/utca-longitudinal/MEM_RUNOUT_S->EnumLabels: 12.5%,\ 
                                                       25%,\ 
                                                       50%,\ 
                                                       75%,\ 
                                                       99.5%
sr/d-mfdbk/utca-longitudinal/MEM_SEL0_S->description: "Channel 0 capture selection"
sr/d-mfdbk/utca-longitudinal/MEM_SEL0_S->EnumLabels: ADC0,\ 
                                                     FIR0,\ 
                                                     DAC0,\ 
                                                     ADC1,\ 
                                                     FIR1,\ 
                                                     DAC1
sr/d-mfdbk/utca-longitudinal/MEM_SEL1_S->description: "Channel 1 capture selection"
sr/d-mfdbk/utca-longitudinal/MEM_SEL1_S->EnumLabels: ADC0,\ 
                                                     FIR0,\ 
                                                     DAC0,\ 
                                                     ADC1,\ 
                                                     FIR1,\ 
                                                     DAC1
sr/d-mfdbk/utca-longitudinal/MEM_SELECT_S->description: "Control memory capture selection"
sr/d-mfdbk/utca-longitudinal/MEM_SELECT_S->EnumLabels: "ADC0/ADC1",\ 
                                                       "ADC0/FIR1",\ 
                                                       "ADC0/DAC1",\ 
                                                       "ADC0/FIR0",\ 
                                                       "FIR0/ADC1",\ 
                                                       "FIR0/FIR1",\ 
                                                       "FIR0/DAC1",\ 
                                                       "FIR0/DAC0",\ 
                                                       "DAC0/ADC1",\ 
                                                       "DAC0/FIR1",\ 
                                                       "DAC0/DAC1",\ 
                                                       "ADC0/DAC0",\ 
                                                       "ADC1/FIR1",\ 
                                                       "FIR1/DAC1",\ 
                                                       "ADC1/DAC1"
sr/d-mfdbk/utca-longitudinal/MEM_WF0->description: "Capture waveform #0"
sr/d-mfdbk/utca-longitudinal/MEM_WF1->description: "Capture waveform #1"
sr/d-mfdbk/utca-longitudinal/MEM_WRITE_GAIN_S->description: "Write FIR gain"
sr/d-mfdbk/utca-longitudinal/Q_ADC_DRAM_SOURCE_S->description: "Source of memory data"
sr/d-mfdbk/utca-longitudinal/Q_ADC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                              "After FIR",\ 
                                                              "FIR no fill"
sr/d-mfdbk/utca-longitudinal/Q_ADC_EVENT->description: "ADC min/max event"
sr/d-mfdbk/utca-longitudinal/Q_ADC_EVENT->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/Q_ADC_EVENT_LIMIT_S->description: "ADC min/max event threshold"
sr/d-mfdbk/utca-longitudinal/Q_ADC_EVENT_LIMIT_S->format: %1.4f
sr/d-mfdbk/utca-longitudinal/Q_ADC_EVENT_LIMIT_S->max_value: 2.0
sr/d-mfdbk/utca-longitudinal/Q_ADC_EVENT_LIMIT_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/Q_ADC_FILTER_S->description: "Input compensation filter"
sr/d-mfdbk/utca-longitudinal/Q_ADC_FIR_OVF->description: "ADC FIR overflow"
sr/d-mfdbk/utca-longitudinal/Q_ADC_FIR_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/Q_ADC_INP_OVF->description: "ADC input overflow"
sr/d-mfdbk/utca-longitudinal/Q_ADC_INP_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/Q_ADC_LOOPBACK_S->description: "Enable DAC -> ADC loopback"
sr/d-mfdbk/utca-longitudinal/Q_ADC_LOOPBACK_S->EnumLabels: Normal,\ 
                                                           Loopback
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_DELTA->description: "Max ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_MAX->description: "Max ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_MEAN->description: "Mean ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_MEAN_MEAN->description: "Mean position"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_MIN->description: "Min ADC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_OVERFLOW->description: "MMS capture overflow status"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                                             "Turns Overflow",\ 
                                                             "Sum Overflow",\ 
                                                             "Turns+Sum Overflow",\ 
                                                             "Sum2 Overflow",\ 
                                                             "Turns+Sum2 Overflow",\ 
                                                             "Sum+Sum2 Overflow",\ 
                                                             "Turns+Sum+Sum2 Overflow"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_SCAN_S->description: "ADC min/max scanning"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_SOURCE_S->description: "Source of min/max/sum data"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                             "After FIR",\ 
                                                             "FIR no fill"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD->description: "ADC standard deviation per bunch"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD_MEAN_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_ADC_MMS_TURNS->description: "Number of turns in this sample"
sr/d-mfdbk/utca-longitudinal/Q_ADC_OVF->description: "ADC overflow"
sr/d-mfdbk/utca-longitudinal/Q_ADC_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-longitudinal/Q_ADC_OVF_LIMIT_S->description: "Overflow limit threshold"
sr/d-mfdbk/utca-longitudinal/Q_ADC_OVF_LIMIT_S->format: %1.4f
sr/d-mfdbk/utca-longitudinal/Q_ADC_OVF_LIMIT_S->max_value: 1.0
sr/d-mfdbk/utca-longitudinal/Q_ADC_OVF_LIMIT_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/Q_ADC_REJECT_COUNT_S->description: "Samples in fill pattern reject filter"
sr/d-mfdbk/utca-longitudinal/Q_ADC_REJECT_COUNT_S->EnumLabels: "1 turns",\ 
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
sr/d-mfdbk/utca-longitudinal/Q_DAC_BUN_OVF->description: "Bunch FIR overflow"
sr/d-mfdbk/utca-longitudinal/Q_DAC_BUN_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/Q_DAC_DELAY_S->description: "DAC output delay"
sr/d-mfdbk/utca-longitudinal/Q_DAC_DRAM_SOURCE_S->description: "Source of memory data"
sr/d-mfdbk/utca-longitudinal/Q_DAC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                              "After FIR"
sr/d-mfdbk/utca-longitudinal/Q_DAC_ENABLE_S->description: "DAC output enable"
sr/d-mfdbk/utca-longitudinal/Q_DAC_ENABLE_S->EnumLabels: Off,\ 
                                                         On
sr/d-mfdbk/utca-longitudinal/Q_DAC_FILTER_S->description: "Output preemphasis filter"
sr/d-mfdbk/utca-longitudinal/Q_DAC_FIR_OVF->description: "DAC FIR overflow"
sr/d-mfdbk/utca-longitudinal/Q_DAC_FIR_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_ARCHIVE_DONE_S->description: "ARCHIVE processing done"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_ARCHIVE_TRIG->description: "ARCHIVE processing trigger"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_DELTA->description: "Max DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_MAX->description: "Max DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_MEAN->description: "Mean DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_MEAN_MEAN->description: "Mean position"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_MIN->description: "Min DAC values per bunch"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_OVERFLOW->description: "MMS capture overflow status"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_OVERFLOW->EnumLabels: Ok,\ 
                                                             "Turns Overflow",\ 
                                                             "Sum Overflow",\ 
                                                             "Turns+Sum Overflow",\ 
                                                             "Sum2 Overflow",\ 
                                                             "Turns+Sum2 Overflow",\ 
                                                             "Sum+Sum2 Overflow",\ 
                                                             "Turns+Sum+Sum2 Overflow"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_SCAN_S->description: "DAC min/max scanning"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_SOURCE_S->description: "Source of min/max/sum data"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                             "After FIR"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD->description: "DAC standard deviation per bunch"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD_MAX_WF->description: "Maximum of standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD_MEAN_DB->unit: dB
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD_MEAN_WF->description: "Power average of standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_STD_MIN_WF->description: "Minimum of standard deviation"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MMS_TURNS->description: "Number of turns in this sample"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MUX_OVF->description: "DAC output overflow"
sr/d-mfdbk/utca-longitudinal/Q_DAC_MUX_OVF->EnumLabels: Ok,\ 
                                                        Overflow
sr/d-mfdbk/utca-longitudinal/Q_DAC_OVF->description: "DAC overflow"
sr/d-mfdbk/utca-longitudinal/Q_DAC_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-longitudinal/Q_FIR_0_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_0_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_1_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_1_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_2_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_2_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_3_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_3_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-longitudinal/Q_FIR_OVF->description: "Overflow in Q bunch-by-bunch filter"
sr/d-mfdbk/utca-longitudinal/Q_FIR_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-longitudinal/STA_CLOCK->description: "ADC clock status"
sr/d-mfdbk/utca-longitudinal/STA_CLOCK->EnumLabels: Unlocked,\ 
                                                    Locked
sr/d-mfdbk/utca-longitudinal/STA_POLL_S->description: "Poll system status"
sr/d-mfdbk/utca-longitudinal/STA_VCO->description: "VCO clock status"
sr/d-mfdbk/utca-longitudinal/STA_VCO->EnumLabels: Unlocked,\ 
                                                  Locked,\ 
                                                  Passthrough
sr/d-mfdbk/utca-longitudinal/STA_VCXO->description: "VCXO clock status"
sr/d-mfdbk/utca-longitudinal/STA_VCXO->EnumLabels: Unlocked,\ 
                                                   Locked,\ 
                                                   Passthrough
sr/d-mfdbk/utca-longitudinal/TRG_ADC0_IN->description: "I ADC event input"
sr/d-mfdbk/utca-longitudinal/TRG_ADC0_IN->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/TRG_ADC1_IN->description: "Q ADC event input"
sr/d-mfdbk/utca-longitudinal/TRG_ADC1_IN->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/TRG_ARM_S->description: "Arm all shared targets"
sr/d-mfdbk/utca-longitudinal/TRG_BLANKING_S->description: "Blanking duration"
sr/d-mfdbk/utca-longitudinal/TRG_BLANKING_S->format: %5d
sr/d-mfdbk/utca-longitudinal/TRG_BLANKING_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/TRG_BLANKING_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/TRG_BLANKING_S->unit: turns
sr/d-mfdbk/utca-longitudinal/TRG_BLNK_IN->description: "Blanking event"
sr/d-mfdbk/utca-longitudinal/TRG_BLNK_IN->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/TRG_DISARM_S->description: "Disarm all shared targets"
sr/d-mfdbk/utca-longitudinal/TRG_EXT_IN->description: "External trigger input"
sr/d-mfdbk/utca-longitudinal/TRG_EXT_IN->EnumLabels: No,\ 
                                                     Yes
sr/d-mfdbk/utca-longitudinal/TRG_IN_S->description: "Scan input events"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC0_BL_S->EnumLabels: All,\ 
                                                            Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC0_EN_S->description: "Enable I ADC event input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                            Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC0_HIT->description: "I ADC event source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC0_HIT->EnumLabels: No,\ 
                                                           Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC1_BL_S->EnumLabels: All,\ 
                                                            Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC1_EN_S->description: "Enable Q ADC event input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                            Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC1_HIT->description: "Q ADC event source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ADC1_HIT->EnumLabels: No,\ 
                                                           Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_ARM_S->description: "Arm trigger"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_BL_S->description: "Write blanking"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_DELAY_S->description: "Trigger delay"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_DELAY_S->format: %5d
sr/d-mfdbk/utca-longitudinal/TRG_MEM_DELAY_S->max_value: 65535.0
sr/d-mfdbk/utca-longitudinal/TRG_MEM_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-longitudinal/TRG_MEM_DISARM_S->description: "Disarm trigger"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EN_S->description: "Write enables"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EXT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EXT_BL_S->EnumLabels: All,\ 
                                                           Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EXT_EN_S->description: "Enable External trigger input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EXT_EN_S->EnumLabels: Ignore,\ 
                                                           Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EXT_HIT->description: "External trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_EXT_HIT->EnumLabels: No,\ 
                                                          Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_HIT->description: "Update source events"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_MODE_S->description: "Arming mode"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_MODE_S->EnumLabels: "One Shot",\ 
                                                         Rearm,\ 
                                                         Shared
sr/d-mfdbk/utca-longitudinal/TRG_MEM_PM_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_PM_BL_S->EnumLabels: All,\ 
                                                          Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_PM_EN_S->description: "Enable Postmortem trigger input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_PM_EN_S->EnumLabels: Ignore,\ 
                                                          Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_PM_HIT->description: "Postmortem trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_PM_HIT->EnumLabels: No,\ 
                                                         Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ0_BL_S->EnumLabels: All,\ 
                                                            Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ0_EN_S->description: "Enable I SEQ event input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                            Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ0_HIT->description: "I SEQ event source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ0_HIT->EnumLabels: No,\ 
                                                           Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ1_BL_S->EnumLabels: All,\ 
                                                            Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ1_EN_S->description: "Enable Q SEQ event input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                            Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ1_HIT->description: "Q SEQ event source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SEQ1_HIT->EnumLabels: No,\ 
                                                           Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SOFT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SOFT_BL_S->EnumLabels: All,\ 
                                                            Blanking
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SOFT_EN_S->description: "Enable Soft trigger input"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                            Enable
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SOFT_HIT->description: "Soft trigger source"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_SOFT_HIT->EnumLabels: No,\ 
                                                           Yes
sr/d-mfdbk/utca-longitudinal/TRG_MEM_STATUS->description: "Trigger target status"
sr/d-mfdbk/utca-longitudinal/TRG_MEM_STATUS->EnumLabels: Idle,\ 
                                                         Armed,\ 
                                                         Busy,\ 
                                                         Locked
sr/d-mfdbk/utca-longitudinal/TRG_MODE_S->description: "Shared trigger mode"
sr/d-mfdbk/utca-longitudinal/TRG_MODE_S->EnumLabels: "One Shot",\ 
                                                     Rearm
sr/d-mfdbk/utca-longitudinal/TRG_PM_IN->description: "Postmortem trigger input"
sr/d-mfdbk/utca-longitudinal/TRG_PM_IN->EnumLabels: No,\ 
                                                    Yes
sr/d-mfdbk/utca-longitudinal/TRG_SEQ0_IN->description: "I SEQ event input"
sr/d-mfdbk/utca-longitudinal/TRG_SEQ0_IN->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/TRG_SEQ1_IN->description: "Q SEQ event input"
sr/d-mfdbk/utca-longitudinal/TRG_SEQ1_IN->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/TRG_SHARED->description: "List of shared targets"
sr/d-mfdbk/utca-longitudinal/TRG_SOFT_IN->description: "Soft trigger input"
sr/d-mfdbk/utca-longitudinal/TRG_SOFT_IN->EnumLabels: No,\ 
                                                      Yes
sr/d-mfdbk/utca-longitudinal/TRG_SOFT_S->description: "Soft trigger"
sr/d-mfdbk/utca-longitudinal/TRG_STATUS->description: "Shared trigger target status"
sr/d-mfdbk/utca-longitudinal/TRG_STATUS->EnumLabels: Idle,\ 
                                                     Armed,\ 
                                                     Locked,\ 
                                                     Busy,\ 
                                                     Mixed,\ 
                                                     Invalid

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


