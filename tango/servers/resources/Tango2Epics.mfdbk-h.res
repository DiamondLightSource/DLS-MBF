#
# Resource backup , created Thu Jun 28 12:47:41 CEST 2018
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-h, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-h/DEVICE/Tango2Epics: "sr/d-mfdbk/utca-horizontal"


# --- sr/d-mfdbk/utca-horizontal properties

sr/d-mfdbk/utca-horizontal->Variables: SR-TMBF:X:ADC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_DRAM_SOURCE_S,\ 
                                       SR-TMBF:X:ADC:EVENT*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_EVENT,\ 
                                       SR-TMBF:X:ADC:EVENT_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*ADC_EVENT_LIMIT_S,\ 
                                       SR-TMBF:X:ADC:FILTER:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_FILTER_DELAY_S,\ 
                                       SR-TMBF:X:ADC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*ADC_FILTER_S,\ 
                                       SR-TMBF:X:ADC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_FIR_OVF,\ 
                                       SR-TMBF:X:ADC:INP_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_INP_OVF,\ 
                                       SR-TMBF:X:ADC:LOOPBACK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_LOOPBACK_S,\ 
                                       SR-TMBF:X:ADC:MMS:DELTA*Array:992*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_DELTA,\ 
                                       SR-TMBF:X:ADC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_FAN,\ 
                                       SR-TMBF:X:ADC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_FAN1,\ 
                                       SR-TMBF:X:ADC:MMS:MAX*Array:992*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MAX,\ 
                                       SR-TMBF:X:ADC:MMS:MEAN*Array:992*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MEAN,\ 
                                       SR-TMBF:X:ADC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MEAN_MEAN,\ 
                                       SR-TMBF:X:ADC:MMS:MIN*Array:992*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_MIN,\ 
                                       SR-TMBF:X:ADC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_MMS_OVERFLOW,\ 
                                       SR-TMBF:X:ADC:MMS:RESET_FAULT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_RESET_FAULT_S,\ 
                                       SR-TMBF:X:ADC:MMS:SCAN_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_SCAN_S,\ 
                                       SR-TMBF:X:ADC:MMS:SCAN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_MMS_SCAN_CMD,\ 
                                       SR-TMBF:X:ADC:MMS:STD*Array:992*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD,\ 
                                       SR-TMBF:X:ADC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN,\ 
                                       SR-TMBF:X:ADC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*ADC_MMS_STD_MEAN_DB,\ 
                                       SR-TMBF:X:ADC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*ADC_MMS_TURNS,\ 
                                       SR-TMBF:X:ADC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*ADC_MMS_SOURCE_S,\ 
                                       SR-TMBF:X:ADC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*ADC_OVF,\ 
                                       SR-TMBF:X:ADC:OVF_LIMIT_S*Scalar*Double*READ_WRITE*ATTRIBUTE*ADC_OVF_LIMIT_S,\ 
                                       SR-TMBF:X:BUN:0:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_FIRWF_STA,\ 
                                       SR-TMBF:X:BUN:0:FIRWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_0_FIRWF_S,\ 
                                       SR-TMBF:X:BUN:0:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_GAINWF_STA,\ 
                                       SR-TMBF:X:BUN:0:GAINWF_S*Array:992*Double*READ_WRITE*ATTRIBUTE*BUN_0_GAINWF_S,\ 
                                       SR-TMBF:X:BUN:0:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_0_OUTWF_STA,\ 
                                       SR-TMBF:X:BUN:0:OUTWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_0_OUTWF_S,\ 
                                       SR-TMBF:X:BUN:1:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_FIRWF_STA,\ 
                                       SR-TMBF:X:BUN:1:FIRWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_1_FIRWF_S,\ 
                                       SR-TMBF:X:BUN:1:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_GAINWF_STA,\ 
                                       SR-TMBF:X:BUN:1:GAINWF_S*Array:992*Double*READ_WRITE*ATTRIBUTE*BUN_1_GAINWF_S,\ 
                                       SR-TMBF:X:BUN:1:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_1_OUTWF_STA,\ 
                                       SR-TMBF:X:BUN:1:OUTWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_1_OUTWF_S,\ 
                                       SR-TMBF:X:BUN:2:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_FIRWF_STA,\ 
                                       SR-TMBF:X:BUN:2:FIRWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_2_FIRWF_S,\ 
                                       SR-TMBF:X:BUN:2:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_GAINWF_STA,\ 
                                       SR-TMBF:X:BUN:2:GAINWF_S*Array:992*Double*READ_WRITE*ATTRIBUTE*BUN_2_GAINWF_S,\ 
                                       SR-TMBF:X:BUN:2:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_2_OUTWF_STA,\ 
                                       SR-TMBF:X:BUN:2:OUTWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_2_OUTWF_S,\ 
                                       SR-TMBF:X:BUN:3:FIRWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_FIRWF_STA,\ 
                                       SR-TMBF:X:BUN:3:FIRWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_3_FIRWF_S,\ 
                                       SR-TMBF:X:BUN:3:GAINWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_GAINWF_STA,\ 
                                       SR-TMBF:X:BUN:3:GAINWF_S*Array:992*Double*READ_WRITE*ATTRIBUTE*BUN_3_GAINWF_S,\ 
                                       SR-TMBF:X:BUN:3:OUTWF:STA*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_3_OUTWF_STA,\ 
                                       SR-TMBF:X:BUN:3:OUTWF_S*Array:992*Int*READ_WRITE*ATTRIBUTE*BUN_3_OUTWF_S,\ 
                                       SR-TMBF:X:BUN:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*BUN_MODE,\ 
                                       SR-TMBF:X:DAC:BUN_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_BUN_OVF,\ 
                                       SR-TMBF:X:DAC:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_DELAY_S,\ 
                                       SR-TMBF:X:DAC:DRAM_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_DRAM_SOURCE_S,\ 
                                       SR-TMBF:X:DAC:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_ENABLE_S,\ 
                                       SR-TMBF:X:DAC:FILTER:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_FILTER_DELAY_S,\ 
                                       SR-TMBF:X:DAC:FILTER_S*Array:20*Double*READ_WRITE*ATTRIBUTE*DAC_FILTER_S,\ 
                                       SR-TMBF:X:DAC:FIR_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_FIR_OVF,\ 
                                       SR-TMBF:X:DAC:MMS:DELTA*Array:992*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_DELTA,\ 
                                       SR-TMBF:X:DAC:MMS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_FAN,\ 
                                       SR-TMBF:X:DAC:MMS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_FAN1,\ 
                                       SR-TMBF:X:DAC:MMS:MAX*Array:992*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MAX,\ 
                                       SR-TMBF:X:DAC:MMS:MEAN*Array:992*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MEAN,\ 
                                       SR-TMBF:X:DAC:MMS:MEAN_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MEAN_MEAN,\ 
                                       SR-TMBF:X:DAC:MMS:MIN*Array:992*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_MIN,\ 
                                       SR-TMBF:X:DAC:MMS:OVERFLOW*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_MMS_OVERFLOW,\ 
                                       SR-TMBF:X:DAC:MMS:RESET_FAULT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_RESET_FAULT_S,\ 
                                       SR-TMBF:X:DAC:MMS:SCAN_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_SCAN_S,\ 
                                       SR-TMBF:X:DAC:MMS:SCAN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_MMS_SCAN_CMD,\ 
                                       SR-TMBF:X:DAC:MMS:STD*Array:992*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD,\ 
                                       SR-TMBF:X:DAC:MMS:STD_MEAN*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN,\ 
                                       SR-TMBF:X:DAC:MMS:STD_MEAN_DB*Scalar*Double*READ_ONLY*ATTRIBUTE*DAC_MMS_STD_MEAN_DB,\ 
                                       SR-TMBF:X:DAC:MMS:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*DAC_MMS_TURNS,\ 
                                       SR-TMBF:X:DAC:MMS_SOURCE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DAC_MMS_SOURCE_S,\ 
                                       SR-TMBF:X:DAC:MUX_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_MUX_OVF,\ 
                                       SR-TMBF:X:DAC:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DAC_OVF,\ 
                                       SR-TMBF:X:DET:0:BUNCHES_S*Array:992*Int*READ_WRITE*ATTRIBUTE*DET_0_BUNCHES_S,\ 
                                       SR-TMBF:X:DET:0:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_0_COUNT,\ 
                                       SR-TMBF:X:DET:0:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_0_ENABLE_S,\ 
                                       SR-TMBF:X:DET:0:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_I,\ 
                                       SR-TMBF:X:DET:0:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_0_MAX_POWER,\ 
                                       SR-TMBF:X:DET:0:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_0_OUT_OVF,\ 
                                       SR-TMBF:X:DET:0:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_PHASE,\ 
                                       SR-TMBF:X:DET:0:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_POWER,\ 
                                       SR-TMBF:X:DET:0:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_0_Q,\ 
                                       SR-TMBF:X:DET:0:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_0_SCALING_S,\ 
                                       SR-TMBF:X:DET:1:BUNCHES_S*Array:992*Int*READ_WRITE*ATTRIBUTE*DET_1_BUNCHES_S,\ 
                                       SR-TMBF:X:DET:1:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_1_COUNT,\ 
                                       SR-TMBF:X:DET:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_1_ENABLE_S,\ 
                                       SR-TMBF:X:DET:1:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_I,\ 
                                       SR-TMBF:X:DET:1:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_1_MAX_POWER,\ 
                                       SR-TMBF:X:DET:1:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_1_OUT_OVF,\ 
                                       SR-TMBF:X:DET:1:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_PHASE,\ 
                                       SR-TMBF:X:DET:1:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_POWER,\ 
                                       SR-TMBF:X:DET:1:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_1_Q,\ 
                                       SR-TMBF:X:DET:1:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_1_SCALING_S,\ 
                                       SR-TMBF:X:DET:2:BUNCHES_S*Array:992*Int*READ_WRITE*ATTRIBUTE*DET_2_BUNCHES_S,\ 
                                       SR-TMBF:X:DET:2:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_2_COUNT,\ 
                                       SR-TMBF:X:DET:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_2_ENABLE_S,\ 
                                       SR-TMBF:X:DET:2:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_I,\ 
                                       SR-TMBF:X:DET:2:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_2_MAX_POWER,\ 
                                       SR-TMBF:X:DET:2:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_2_OUT_OVF,\ 
                                       SR-TMBF:X:DET:2:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_PHASE,\ 
                                       SR-TMBF:X:DET:2:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_POWER,\ 
                                       SR-TMBF:X:DET:2:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_2_Q,\ 
                                       SR-TMBF:X:DET:2:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_2_SCALING_S,\ 
                                       SR-TMBF:X:DET:3:BUNCHES_S*Array:992*Int*READ_WRITE*ATTRIBUTE*DET_3_BUNCHES_S,\ 
                                       SR-TMBF:X:DET:3:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_3_COUNT,\ 
                                       SR-TMBF:X:DET:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_3_ENABLE_S,\ 
                                       SR-TMBF:X:DET:3:I*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_I,\ 
                                       SR-TMBF:X:DET:3:MAX_POWER*Scalar*Double*READ_ONLY*ATTRIBUTE*DET_3_MAX_POWER,\ 
                                       SR-TMBF:X:DET:3:OUT_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_3_OUT_OVF,\ 
                                       SR-TMBF:X:DET:3:PHASE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_PHASE,\ 
                                       SR-TMBF:X:DET:3:POWER*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_POWER,\ 
                                       SR-TMBF:X:DET:3:Q*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_3_Q,\ 
                                       SR-TMBF:X:DET:3:SCALING_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_3_SCALING_S,\ 
                                       SR-TMBF:X:DET:FILL_WAVEFORM_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_FILL_WAVEFORM_S,\ 
                                       SR-TMBF:X:DET:FIR_DELAY_S*Scalar*Double*READ_WRITE*ATTRIBUTE*DET_FIR_DELAY_S,\ 
                                       SR-TMBF:X:DET:SAMPLES*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_SAMPLES,\ 
                                       SR-TMBF:X:DET:SCALE*Array:4096*Double*READ_ONLY*ATTRIBUTE*DET_SCALE,\ 
                                       SR-TMBF:X:DET:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*DET_SELECT_S,\ 
                                       SR-TMBF:X:DET:TIMEBASE*Array:4096*Int*READ_ONLY*ATTRIBUTE*DET_TIMEBASE,\ 
                                       SR-TMBF:X:DET:UNDERRUN*Scalar*Enum*READ_ONLY*ATTRIBUTE*DET_UNDERRUN,\ 
                                       SR-TMBF:X:DET:UPDATE:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_DONE_S,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*DET_UPDATE_TRIG,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN1,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG:FAN2*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN2,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG:FAN3*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN3,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG:FAN4*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN4,\ 
                                       SR-TMBF:X:DET:UPDATE:TRIG:FAN5*Scalar*Int*READ_WRITE*ATTRIBUTE*DET_UPDATE_TRIG_FAN5,\ 
                                       SR-TMBF:X:FIR:0:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_CYCLES_S,\ 
                                       SR-TMBF:X:FIR:0:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_LENGTH_S,\ 
                                       SR-TMBF:X:FIR:0:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_0_PHASE_S,\ 
                                       SR-TMBF:X:FIR:0:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_0_RELOAD_S,\ 
                                       SR-TMBF:X:FIR:0:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_0_TAPS,\ 
                                       SR-TMBF:X:FIR:0:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_0_TAPS_S,\ 
                                       SR-TMBF:X:FIR:0:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_0_USEWF_S,\ 
                                       SR-TMBF:X:FIR:1:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_CYCLES_S,\ 
                                       SR-TMBF:X:FIR:1:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_LENGTH_S,\ 
                                       SR-TMBF:X:FIR:1:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_1_PHASE_S,\ 
                                       SR-TMBF:X:FIR:1:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_1_RELOAD_S,\ 
                                       SR-TMBF:X:FIR:1:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_1_TAPS,\ 
                                       SR-TMBF:X:FIR:1:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_1_TAPS_S,\ 
                                       SR-TMBF:X:FIR:1:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_1_USEWF_S,\ 
                                       SR-TMBF:X:FIR:2:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_CYCLES_S,\ 
                                       SR-TMBF:X:FIR:2:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_LENGTH_S,\ 
                                       SR-TMBF:X:FIR:2:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_2_PHASE_S,\ 
                                       SR-TMBF:X:FIR:2:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_2_RELOAD_S,\ 
                                       SR-TMBF:X:FIR:2:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_2_TAPS,\ 
                                       SR-TMBF:X:FIR:2:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_2_TAPS_S,\ 
                                       SR-TMBF:X:FIR:2:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_2_USEWF_S,\ 
                                       SR-TMBF:X:FIR:3:CYCLES_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_CYCLES_S,\ 
                                       SR-TMBF:X:FIR:3:LENGTH_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_LENGTH_S,\ 
                                       SR-TMBF:X:FIR:3:PHASE_S*Scalar*Double*READ_WRITE*ATTRIBUTE*FIR_3_PHASE_S,\ 
                                       SR-TMBF:X:FIR:3:RELOAD_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_3_RELOAD_S,\ 
                                       SR-TMBF:X:FIR:3:TAPS*Array:16*Double*READ_ONLY*ATTRIBUTE*FIR_3_TAPS,\ 
                                       SR-TMBF:X:FIR:3:TAPS_S*Array:16*Double*READ_WRITE*ATTRIBUTE*FIR_3_TAPS_S,\ 
                                       SR-TMBF:X:FIR:3:USEWF_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_3_USEWF_S,\ 
                                       SR-TMBF:X:FIR:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*FIR_GAIN_S,\ 
                                       SR-TMBF:X:FIR:OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*FIR_OVF,\ 
                                       SR-TMBF:X:NCO:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*NCO_ENABLE_S,\ 
                                       SR-TMBF:X:NCO:FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*NCO_FREQ_S,\ 
                                       SR-TMBF:X:NCO:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*NCO_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:0:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_0_BANK_S,\ 
                                       SR-TMBF:X:SEQ:1:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_BANK_S,\ 
                                       SR-TMBF:X:SEQ:1:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:1:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:1:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:1:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:1:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:1:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:1:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:1:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_1_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:1:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:1:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:1:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_1_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:1:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_1_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:2:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_BANK_S,\ 
                                       SR-TMBF:X:SEQ:2:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:2:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:2:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:2:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:2:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:2:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:2:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:2:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_2_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:2:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:2:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:2:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_2_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:2:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_2_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:3:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_BANK_S,\ 
                                       SR-TMBF:X:SEQ:3:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:3:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:3:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:3:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:3:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:3:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:3:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:3:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_3_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:3:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:3:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:3:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_3_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:3:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_3_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:4:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_BANK_S,\ 
                                       SR-TMBF:X:SEQ:4:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:4:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:4:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:4:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:4:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:4:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:4:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:4:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_4_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:4:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:4:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:4:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_4_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:4:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_4_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:5:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_BANK_S,\ 
                                       SR-TMBF:X:SEQ:5:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:5:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:5:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:5:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:5:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:5:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:5:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:5:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_5_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:5:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:5:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:5:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_5_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:5:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_5_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:6:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_BANK_S,\ 
                                       SR-TMBF:X:SEQ:6:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:6:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:6:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:6:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:6:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:6:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:6:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:6:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_6_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:6:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:6:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:6:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_6_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:6:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_6_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:7:BANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_BANK_S,\ 
                                       SR-TMBF:X:SEQ:7:BLANK_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_BLANK_S,\ 
                                       SR-TMBF:X:SEQ:7:CAPTURE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_CAPTURE_S,\ 
                                       SR-TMBF:X:SEQ:7:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:7:DWELL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_DWELL_S,\ 
                                       SR-TMBF:X:SEQ:7:ENABLE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_ENABLE_S,\ 
                                       SR-TMBF:X:SEQ:7:END_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_END_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:7:ENWIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_ENWIN_S,\ 
                                       SR-TMBF:X:SEQ:7:GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*SEQ_7_GAIN_S,\ 
                                       SR-TMBF:X:SEQ:7:HOLDOFF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_HOLDOFF_S,\ 
                                       SR-TMBF:X:SEQ:7:START_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_START_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:7:STEP_FREQ_S*Scalar*Double*READ_WRITE*ATTRIBUTE*SEQ_7_STEP_FREQ_S,\ 
                                       SR-TMBF:X:SEQ:7:UPDATE_END_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_7_UPDATE_END_S,\ 
                                       SR-TMBF:X:SEQ:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*SEQ_BUSY,\ 
                                       SR-TMBF:X:SEQ:COUNT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_COUNT_FAN,\ 
                                       SR-TMBF:X:SEQ:DURATION*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_DURATION,\ 
                                       SR-TMBF:X:SEQ:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_DURATION_S,\ 
                                       SR-TMBF:X:SEQ:LENGTH*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_LENGTH,\ 
                                       SR-TMBF:X:SEQ:MODE*Scalar*String*READ_ONLY*ATTRIBUTE*SEQ_MODE,\ 
                                       SR-TMBF:X:SEQ:PC*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_PC,\ 
                                       SR-TMBF:X:SEQ:PC_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_PC_S,\ 
                                       SR-TMBF:X:SEQ:RESET_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_RESET_S,\ 
                                       SR-TMBF:X:SEQ:RESET_WIN_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_RESET_WIN_S,\ 
                                       SR-TMBF:X:SEQ:STATUS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_STATUS_FAN,\ 
                                       SR-TMBF:X:SEQ:STATUS:READ_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_STATUS_READ_S,\ 
                                       SR-TMBF:X:SEQ:SUPER:COUNT*Scalar*Int*READ_ONLY*ATTRIBUTE*SEQ_SUPER_COUNT,\ 
                                       SR-TMBF:X:SEQ:SUPER:COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_SUPER_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:SUPER:OFFSET_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*SEQ_SUPER_OFFSET_S,\ 
                                       SR-TMBF:X:SEQ:SUPER:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_SUPER_RESET_S,\ 
                                       SR-TMBF:X:SEQ:TOTAL:DURATION*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_DURATION,\ 
                                       SR-TMBF:X:SEQ:TOTAL:DURATION:S*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_DURATION_S,\ 
                                       SR-TMBF:X:SEQ:TOTAL:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_TOTAL_FAN,\ 
                                       SR-TMBF:X:SEQ:TOTAL:LENGTH*Scalar*Double*READ_ONLY*ATTRIBUTE*SEQ_TOTAL_LENGTH,\ 
                                       SR-TMBF:X:SEQ:TRIGGER_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_TRIGGER_S,\ 
                                       SR-TMBF:X:SEQ:UPDATE_COUNT_S*Scalar*Int*READ_WRITE*ATTRIBUTE*SEQ_UPDATE_COUNT_S,\ 
                                       SR-TMBF:X:SEQ:WINDOW_S*Array:1024*Double*READ_WRITE*ATTRIBUTE*SEQ_WINDOW_S,\ 
                                       SR-TMBF:X:STATUS*Scalar*Double*READ_ONLY*ATTRIBUTE*AXIS_STATUS,\ 
                                       SR-TMBF:X:TRG:SEQ:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC0_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC0_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_ADC0_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC1_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_ADC1_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_ADC1_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_ARM_S,\ 
                                       SR-TMBF:X:TRG:SEQ:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_DELAY_S,\ 
                                       SR-TMBF:X:TRG:SEQ:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_DISARM_S,\ 
                                       SR-TMBF:X:TRG:SEQ:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_EXT_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_EXT_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_EXT_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*TRG_SEQ_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_HIT_FAN,\ 
                                       SR-TMBF:X:TRG:SEQ:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SEQ_HIT_FAN1,\ 
                                       SR-TMBF:X:TRG:SEQ:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_MODE_S,\ 
                                       SR-TMBF:X:TRG:SEQ:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_PM_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_PM_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_PM_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ0_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ0_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SEQ0_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ1_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SEQ1_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SEQ1_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SOFT_BL_S,\ 
                                       SR-TMBF:X:TRG:SEQ:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_SEQ_SOFT_EN_S,\ 
                                       SR-TMBF:X:TRG:SEQ:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_SOFT_HIT,\ 
                                       SR-TMBF:X:TRG:SEQ:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ_STATUS

# --- sr/d-mfdbk/utca-horizontal attribute properties

sr/d-mfdbk/utca-horizontal/ADC_DRAM_SOURCE_S->description: "Source of memory data"
sr/d-mfdbk/utca-horizontal/ADC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                          "After FIR"
sr/d-mfdbk/utca-horizontal/ADC_EVENT->description: "ADC min/max event"
sr/d-mfdbk/utca-horizontal/ADC_EVENT->EnumLabels: No,\ 
                                                  Yes
sr/d-mfdbk/utca-horizontal/ADC_EVENT_LIMIT_S->description: "ADC min/max event threshold"
sr/d-mfdbk/utca-horizontal/ADC_EVENT_LIMIT_S->format: %5.4f
sr/d-mfdbk/utca-horizontal/ADC_EVENT_LIMIT_S->max_value: 1.0
sr/d-mfdbk/utca-horizontal/ADC_EVENT_LIMIT_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/ADC_FILTER_DELAY_S->description: "Compensation filter group delay"
sr/d-mfdbk/utca-horizontal/ADC_FILTER_DELAY_S->max_value: 7.0
sr/d-mfdbk/utca-horizontal/ADC_FILTER_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/ADC_FILTER_S->description: "Input compensation filter"
sr/d-mfdbk/utca-horizontal/ADC_FIR_OVF->description: "ADC FIR overflow"
sr/d-mfdbk/utca-horizontal/ADC_FIR_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-horizontal/ADC_INP_OVF->description: "ADC input overflow"
sr/d-mfdbk/utca-horizontal/ADC_INP_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-horizontal/ADC_LOOPBACK_S->description: "Enable DAC -> ADC loopback"
sr/d-mfdbk/utca-horizontal/ADC_LOOPBACK_S->EnumLabels: Normal,\ 
                                                       Loopback
sr/d-mfdbk/utca-horizontal/ADC_MMS_DELTA->description: "Max ADC values per bunch"
sr/d-mfdbk/utca-horizontal/ADC_MMS_MAX->description: "Max ADC values per bunch"
sr/d-mfdbk/utca-horizontal/ADC_MMS_MEAN->description: "Mean ADC values per bunch"
sr/d-mfdbk/utca-horizontal/ADC_MMS_MEAN_MEAN->description: "Mean position"
sr/d-mfdbk/utca-horizontal/ADC_MMS_MEAN_MEAN->format: %.6f
sr/d-mfdbk/utca-horizontal/ADC_MMS_MEAN_MEAN->max_value: 1.0
sr/d-mfdbk/utca-horizontal/ADC_MMS_MEAN_MEAN->min_value: -1.0
sr/d-mfdbk/utca-horizontal/ADC_MMS_MIN->description: "Min ADC values per bunch"
sr/d-mfdbk/utca-horizontal/ADC_MMS_OVERFLOW->description: "MMS capture overflow status"
sr/d-mfdbk/utca-horizontal/ADC_MMS_OVERFLOW->EnumLabels: "Ok (NO_ALARM)",\ 
                                                         "Turns Overflow (MAJOR)",\ 
                                                         "Sum Overflow (MAJOR)",\ 
                                                         "Turns+Sum Overflow (MAJOR)",\ 
                                                         "Sum2 Overflow (MAJOR)",\ 
                                                         "Turns+Sum2 Overflow (MAJOR)",\ 
                                                         "Sum+Sum2 Overflow (MAJOR)",\ 
                                                         "Turns+Sum+Sum2 Overflow (MAJOR)"
sr/d-mfdbk/utca-horizontal/ADC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
sr/d-mfdbk/utca-horizontal/ADC_MMS_SCAN_S->description: "ADC min/max scanning"
sr/d-mfdbk/utca-horizontal/ADC_MMS_SCAN_S->EnumLabels: Passive,\ 
                                                       Event,\ 
                                                       "I/O Intr",\ 
                                                       "10 s",\ 
                                                       "5 s",\ 
                                                       "2 s",\ 
                                                       "1 s",\ 
                                                       "500 ms",\ 
                                                       "200 ms",\ 
                                                       "100 ms"
sr/d-mfdbk/utca-horizontal/ADC_MMS_SOURCE_S->description: "Source of min/max/sum data"
sr/d-mfdbk/utca-horizontal/ADC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                         "After FIR"
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD->description: "ADC standard deviation per bunch"
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN->format: %.6f
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN->max_value: 1.0
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN->min_value: 0.0
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN_DB->format: %.1f
sr/d-mfdbk/utca-horizontal/ADC_MMS_STD_MEAN_DB->unit: dB
sr/d-mfdbk/utca-horizontal/ADC_MMS_TURNS->description: "Number of turns in this sample"
sr/d-mfdbk/utca-horizontal/ADC_OVF->description: "ADC overflow"
sr/d-mfdbk/utca-horizontal/ADC_OVF->EnumLabels: Ok,\ 
                                                Overflow
sr/d-mfdbk/utca-horizontal/ADC_OVF_LIMIT_S->description: "Overflow limit threshold"
sr/d-mfdbk/utca-horizontal/ADC_OVF_LIMIT_S->format: %5.4f
sr/d-mfdbk/utca-horizontal/ADC_OVF_LIMIT_S->max_value: 1.0
sr/d-mfdbk/utca-horizontal/ADC_OVF_LIMIT_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/AXIS_STATUS->description: "Axis X signal health"
sr/d-mfdbk/utca-horizontal/BUN_0_FIRWF_S->description: "Set 0 FIR bank select"
sr/d-mfdbk/utca-horizontal/BUN_0_FIRWF_STA->description: "Bank 0 FIRWF status"
sr/d-mfdbk/utca-horizontal/BUN_0_GAINWF_S->description: "Set 0 DAC output gain"
sr/d-mfdbk/utca-horizontal/BUN_0_GAINWF_STA->description: "Bank 0 GAINWF status"
sr/d-mfdbk/utca-horizontal/BUN_0_OUTWF_S->description: "Set 0 DAC output select"
sr/d-mfdbk/utca-horizontal/BUN_0_OUTWF_STA->description: "Bank 0 OUTWF status"
sr/d-mfdbk/utca-horizontal/BUN_1_FIRWF_S->description: "Set 1 FIR bank select"
sr/d-mfdbk/utca-horizontal/BUN_1_FIRWF_STA->description: "Bank 1 FIRWF status"
sr/d-mfdbk/utca-horizontal/BUN_1_GAINWF_S->description: "Set 1 DAC output gain"
sr/d-mfdbk/utca-horizontal/BUN_1_GAINWF_STA->description: "Bank 1 GAINWF status"
sr/d-mfdbk/utca-horizontal/BUN_1_OUTWF_S->description: "Set 1 DAC output select"
sr/d-mfdbk/utca-horizontal/BUN_1_OUTWF_STA->description: "Bank 1 OUTWF status"
sr/d-mfdbk/utca-horizontal/BUN_2_FIRWF_S->description: "Set 2 FIR bank select"
sr/d-mfdbk/utca-horizontal/BUN_2_FIRWF_STA->description: "Bank 2 FIRWF status"
sr/d-mfdbk/utca-horizontal/BUN_2_GAINWF_S->description: "Set 2 DAC output gain"
sr/d-mfdbk/utca-horizontal/BUN_2_GAINWF_STA->description: "Bank 2 GAINWF status"
sr/d-mfdbk/utca-horizontal/BUN_2_OUTWF_S->description: "Set 2 DAC output select"
sr/d-mfdbk/utca-horizontal/BUN_2_OUTWF_STA->description: "Bank 2 OUTWF status"
sr/d-mfdbk/utca-horizontal/BUN_3_FIRWF_S->description: "Set 3 FIR bank select"
sr/d-mfdbk/utca-horizontal/BUN_3_FIRWF_STA->description: "Bank 3 FIRWF status"
sr/d-mfdbk/utca-horizontal/BUN_3_GAINWF_S->description: "Set 3 DAC output gain"
sr/d-mfdbk/utca-horizontal/BUN_3_GAINWF_STA->description: "Bank 3 GAINWF status"
sr/d-mfdbk/utca-horizontal/BUN_3_OUTWF_S->description: "Set 3 DAC output select"
sr/d-mfdbk/utca-horizontal/BUN_3_OUTWF_STA->description: "Bank 3 OUTWF status"
sr/d-mfdbk/utca-horizontal/BUN_MODE->description: "Feedback mode"
sr/d-mfdbk/utca-horizontal/DAC_BUN_OVF->description: "Bunch FIR overflow"
sr/d-mfdbk/utca-horizontal/DAC_BUN_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-horizontal/DAC_DELAY_S->description: "DAC output delay"
sr/d-mfdbk/utca-horizontal/DAC_DRAM_SOURCE_S->description: "Source of memory data"
sr/d-mfdbk/utca-horizontal/DAC_DRAM_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                          "After FIR"
sr/d-mfdbk/utca-horizontal/DAC_ENABLE_S->description: "DAC output enable"
sr/d-mfdbk/utca-horizontal/DAC_ENABLE_S->EnumLabels: Off,\ 
                                                     On
sr/d-mfdbk/utca-horizontal/DAC_FILTER_DELAY_S->description: "Preemphasis filter group delay"
sr/d-mfdbk/utca-horizontal/DAC_FILTER_DELAY_S->max_value: 7.0
sr/d-mfdbk/utca-horizontal/DAC_FILTER_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/DAC_FILTER_S->description: "Output preemphasis filter"
sr/d-mfdbk/utca-horizontal/DAC_FIR_OVF->description: "DAC FIR overflow"
sr/d-mfdbk/utca-horizontal/DAC_FIR_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-horizontal/DAC_MMS_DELTA->description: "Max DAC values per bunch"
sr/d-mfdbk/utca-horizontal/DAC_MMS_MAX->description: "Max DAC values per bunch"
sr/d-mfdbk/utca-horizontal/DAC_MMS_MEAN->description: "Mean DAC values per bunch"
sr/d-mfdbk/utca-horizontal/DAC_MMS_MEAN_MEAN->description: "Mean position"
sr/d-mfdbk/utca-horizontal/DAC_MMS_MEAN_MEAN->format: %.6f
sr/d-mfdbk/utca-horizontal/DAC_MMS_MEAN_MEAN->max_value: 1.0
sr/d-mfdbk/utca-horizontal/DAC_MMS_MEAN_MEAN->min_value: -1.0
sr/d-mfdbk/utca-horizontal/DAC_MMS_MIN->description: "Min DAC values per bunch"
sr/d-mfdbk/utca-horizontal/DAC_MMS_OVERFLOW->description: "MMS capture overflow status"
sr/d-mfdbk/utca-horizontal/DAC_MMS_OVERFLOW->EnumLabels: "Ok (NO_ALARM)",\ 
                                                         "Turns Overflow (MAJOR)",\ 
                                                         "Sum Overflow (MAJOR)",\ 
                                                         "Turns+Sum Overflow (MAJOR)",\ 
                                                         "Sum2 Overflow (MAJOR)",\ 
                                                         "Turns+Sum2 Overflow (MAJOR)",\ 
                                                         "Sum+Sum2 Overflow (MAJOR)",\ 
                                                         "Turns+Sum+Sum2 Overflow (MAJOR)"
sr/d-mfdbk/utca-horizontal/DAC_MMS_RESET_FAULT_S->description: "Resets MMS fault accumulation"
sr/d-mfdbk/utca-horizontal/DAC_MMS_SCAN_S->description: "DAC min/max scanning"
sr/d-mfdbk/utca-horizontal/DAC_MMS_SCAN_S->EnumLabels: Passive,\ 
                                                       Event,\ 
                                                       "I/O Intr",\ 
                                                       "10 s",\ 
                                                       "5 s",\ 
                                                       "2 s",\ 
                                                       "1 s",\ 
                                                       "500 ms",\ 
                                                       "200 ms",\ 
                                                       "100 ms"
sr/d-mfdbk/utca-horizontal/DAC_MMS_SOURCE_S->description: "Source of min/max/sum data"
sr/d-mfdbk/utca-horizontal/DAC_MMS_SOURCE_S->EnumLabels: "Before FIR",\ 
                                                         "After FIR"
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD->description: "DAC standard deviation per bunch"
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN->description: "Mean MMS standard deviation"
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN->format: %.6f
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN->max_value: 1.0
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN->min_value: 0.0
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN_DB->description: "Mean MMS deviation in dB"
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN_DB->format: %.1f
sr/d-mfdbk/utca-horizontal/DAC_MMS_STD_MEAN_DB->unit: dB
sr/d-mfdbk/utca-horizontal/DAC_MMS_TURNS->description: "Number of turns in this sample"
sr/d-mfdbk/utca-horizontal/DAC_MUX_OVF->description: "DAC output overflow"
sr/d-mfdbk/utca-horizontal/DAC_MUX_OVF->EnumLabels: Ok,\ 
                                                    Overflow
sr/d-mfdbk/utca-horizontal/DAC_OVF->description: "DAC overflow"
sr/d-mfdbk/utca-horizontal/DAC_OVF->EnumLabels: Ok,\ 
                                                Overflow
sr/d-mfdbk/utca-horizontal/DET_0_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-horizontal/DET_0_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-horizontal/DET_0_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-horizontal/DET_0_ENABLE_S->EnumLabels: Disabled,\ 
                                                       Enabled
sr/d-mfdbk/utca-horizontal/DET_0_I->description: "Detector I"
sr/d-mfdbk/utca-horizontal/DET_0_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-horizontal/DET_0_MAX_POWER->unit: dB
sr/d-mfdbk/utca-horizontal/DET_0_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-horizontal/DET_0_OUT_OVF->EnumLabels: Ok,\ 
                                                      Overflow
sr/d-mfdbk/utca-horizontal/DET_0_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-horizontal/DET_0_POWER->description: "Detector Power"
sr/d-mfdbk/utca-horizontal/DET_0_Q->description: "Detector Q"
sr/d-mfdbk/utca-horizontal/DET_0_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-horizontal/DET_0_SCALING_S->EnumLabels: 0dB,\ 
                                                        -48dB
sr/d-mfdbk/utca-horizontal/DET_1_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-horizontal/DET_1_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-horizontal/DET_1_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-horizontal/DET_1_ENABLE_S->EnumLabels: Disabled,\ 
                                                       Enabled
sr/d-mfdbk/utca-horizontal/DET_1_I->description: "Detector I"
sr/d-mfdbk/utca-horizontal/DET_1_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-horizontal/DET_1_MAX_POWER->unit: dB
sr/d-mfdbk/utca-horizontal/DET_1_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-horizontal/DET_1_OUT_OVF->EnumLabels: Ok,\ 
                                                      Overflow
sr/d-mfdbk/utca-horizontal/DET_1_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-horizontal/DET_1_POWER->description: "Detector Power"
sr/d-mfdbk/utca-horizontal/DET_1_Q->description: "Detector Q"
sr/d-mfdbk/utca-horizontal/DET_1_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-horizontal/DET_1_SCALING_S->EnumLabels: 0dB,\ 
                                                        -48dB
sr/d-mfdbk/utca-horizontal/DET_2_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-horizontal/DET_2_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-horizontal/DET_2_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-horizontal/DET_2_ENABLE_S->EnumLabels: Disabled,\ 
                                                       Enabled
sr/d-mfdbk/utca-horizontal/DET_2_I->description: "Detector I"
sr/d-mfdbk/utca-horizontal/DET_2_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-horizontal/DET_2_MAX_POWER->unit: dB
sr/d-mfdbk/utca-horizontal/DET_2_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-horizontal/DET_2_OUT_OVF->EnumLabels: Ok,\ 
                                                      Overflow
sr/d-mfdbk/utca-horizontal/DET_2_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-horizontal/DET_2_POWER->description: "Detector Power"
sr/d-mfdbk/utca-horizontal/DET_2_Q->description: "Detector Q"
sr/d-mfdbk/utca-horizontal/DET_2_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-horizontal/DET_2_SCALING_S->EnumLabels: 0dB,\ 
                                                        -48dB
sr/d-mfdbk/utca-horizontal/DET_3_BUNCHES_S->description: "Enable bunches for detector"
sr/d-mfdbk/utca-horizontal/DET_3_COUNT->description: "Number of enabled bunches"
sr/d-mfdbk/utca-horizontal/DET_3_ENABLE_S->description: "Enable use of this detector"
sr/d-mfdbk/utca-horizontal/DET_3_ENABLE_S->EnumLabels: Disabled,\ 
                                                       Enabled
sr/d-mfdbk/utca-horizontal/DET_3_I->description: "Detector I"
sr/d-mfdbk/utca-horizontal/DET_3_MAX_POWER->description: "Percentage full scale of maximum power"
sr/d-mfdbk/utca-horizontal/DET_3_MAX_POWER->unit: dB
sr/d-mfdbk/utca-horizontal/DET_3_OUT_OVF->description: "Output overflow"
sr/d-mfdbk/utca-horizontal/DET_3_OUT_OVF->EnumLabels: Ok,\ 
                                                      Overflow
sr/d-mfdbk/utca-horizontal/DET_3_PHASE->description: "Detector Phase"
sr/d-mfdbk/utca-horizontal/DET_3_POWER->description: "Detector Power"
sr/d-mfdbk/utca-horizontal/DET_3_Q->description: "Detector Q"
sr/d-mfdbk/utca-horizontal/DET_3_SCALING_S->description: "Readout scaling"
sr/d-mfdbk/utca-horizontal/DET_3_SCALING_S->EnumLabels: 0dB,\ 
                                                        -48dB
sr/d-mfdbk/utca-horizontal/DET_FILL_WAVEFORM_S->description: "Treatment of truncated waveforms"
sr/d-mfdbk/utca-horizontal/DET_FILL_WAVEFORM_S->EnumLabels: Truncated,\ 
                                                            Filled
sr/d-mfdbk/utca-horizontal/DET_FIR_DELAY_S->description: "FIR nominal group delay"
sr/d-mfdbk/utca-horizontal/DET_FIR_DELAY_S->format: %4.1f
sr/d-mfdbk/utca-horizontal/DET_FIR_DELAY_S->unit: turns
sr/d-mfdbk/utca-horizontal/DET_SAMPLES->description: "Number of captured samples"
sr/d-mfdbk/utca-horizontal/DET_SCALE->description: "Scale for frequency sweep"
sr/d-mfdbk/utca-horizontal/DET_SELECT_S->description: "Select detector source"
sr/d-mfdbk/utca-horizontal/DET_SELECT_S->EnumLabels: ADC,\ 
                                                     FIR
sr/d-mfdbk/utca-horizontal/DET_TIMEBASE->description: "Timebase for frequency sweep"
sr/d-mfdbk/utca-horizontal/DET_UNDERRUN->description: "Data output underrun"
sr/d-mfdbk/utca-horizontal/DET_UNDERRUN->EnumLabels: Ok,\ 
                                                     Underrun
sr/d-mfdbk/utca-horizontal/DET_UPDATE_DONE_S->description: "UPDATE processing done"
sr/d-mfdbk/utca-horizontal/DET_UPDATE_TRIG->description: "UPDATE processing trigger"
sr/d-mfdbk/utca-horizontal/FIR_0_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-horizontal/FIR_0_CYCLES_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_0_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_0_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/FIR_0_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-horizontal/FIR_0_LENGTH_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_0_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_0_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-horizontal/FIR_0_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-horizontal/FIR_0_PHASE_S->format: %3.0f
sr/d-mfdbk/utca-horizontal/FIR_0_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-horizontal/FIR_0_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-horizontal/FIR_0_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-horizontal/FIR_0_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_0_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_0_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-horizontal/FIR_0_USEWF_S->EnumLabels: Settings,\ 
                                                      Waveform
sr/d-mfdbk/utca-horizontal/FIR_1_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-horizontal/FIR_1_CYCLES_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_1_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_1_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/FIR_1_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-horizontal/FIR_1_LENGTH_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_1_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_1_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-horizontal/FIR_1_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-horizontal/FIR_1_PHASE_S->format: %3.0f
sr/d-mfdbk/utca-horizontal/FIR_1_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-horizontal/FIR_1_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-horizontal/FIR_1_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-horizontal/FIR_1_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_1_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_1_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-horizontal/FIR_1_USEWF_S->EnumLabels: Settings,\ 
                                                      Waveform
sr/d-mfdbk/utca-horizontal/FIR_2_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-horizontal/FIR_2_CYCLES_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_2_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_2_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/FIR_2_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-horizontal/FIR_2_LENGTH_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_2_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_2_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-horizontal/FIR_2_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-horizontal/FIR_2_PHASE_S->format: %3.0f
sr/d-mfdbk/utca-horizontal/FIR_2_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-horizontal/FIR_2_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-horizontal/FIR_2_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-horizontal/FIR_2_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_2_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_2_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-horizontal/FIR_2_USEWF_S->EnumLabels: Settings,\ 
                                                      Waveform
sr/d-mfdbk/utca-horizontal/FIR_3_CYCLES_S->description: "Cycles in filter"
sr/d-mfdbk/utca-horizontal/FIR_3_CYCLES_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_3_CYCLES_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_3_CYCLES_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/FIR_3_LENGTH_S->description: "Length of filter"
sr/d-mfdbk/utca-horizontal/FIR_3_LENGTH_S->format: %2d
sr/d-mfdbk/utca-horizontal/FIR_3_LENGTH_S->max_value: 16.0
sr/d-mfdbk/utca-horizontal/FIR_3_LENGTH_S->min_value: 2.0
sr/d-mfdbk/utca-horizontal/FIR_3_PHASE_S->description: "FIR phase"
sr/d-mfdbk/utca-horizontal/FIR_3_PHASE_S->format: %3.0f
sr/d-mfdbk/utca-horizontal/FIR_3_PHASE_S->max_value: 360.0
sr/d-mfdbk/utca-horizontal/FIR_3_PHASE_S->min_value: -360.0
sr/d-mfdbk/utca-horizontal/FIR_3_RELOAD_S->description: "Reload filter"
sr/d-mfdbk/utca-horizontal/FIR_3_TAPS->description: "Current waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_3_TAPS_S->description: "Set waveform taps"
sr/d-mfdbk/utca-horizontal/FIR_3_USEWF_S->description: "Use direct waveform or settings"
sr/d-mfdbk/utca-horizontal/FIR_3_USEWF_S->EnumLabels: Settings,\ 
                                                      Waveform
sr/d-mfdbk/utca-horizontal/FIR_GAIN_S->description: "FIR gain select"
sr/d-mfdbk/utca-horizontal/FIR_GAIN_S->EnumLabels: 48dB,\ 
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
sr/d-mfdbk/utca-horizontal/FIR_OVF->description: "Overflow in X bunch-by-bunch filter"
sr/d-mfdbk/utca-horizontal/FIR_OVF->EnumLabels: Ok,\ 
                                                Overflow
sr/d-mfdbk/utca-horizontal/NCO_ENABLE_S->description: "Enable fixed NCO output"
sr/d-mfdbk/utca-horizontal/NCO_ENABLE_S->EnumLabels: Off,\ 
                                                     On
sr/d-mfdbk/utca-horizontal/NCO_FREQ_S->description: "Fixed NCO frequency"
sr/d-mfdbk/utca-horizontal/NCO_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/NCO_GAIN_S->description: "Fixed NCO gain"
sr/d-mfdbk/utca-horizontal/NCO_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_0_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_0_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_1_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_1_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_1_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_1_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_1_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_1_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_1_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_1_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_1_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_1_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_1_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_1_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_1_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_1_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_1_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_1_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_1_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_1_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_1_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_1_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_1_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_1_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_1_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_1_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_1_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_1_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_1_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_1_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_1_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_1_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_1_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_1_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_2_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_2_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_2_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_2_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_2_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_2_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_2_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_2_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_2_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_2_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_2_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_2_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_2_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_2_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_2_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_2_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_2_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_2_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_2_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_2_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_2_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_2_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_2_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_2_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_2_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_2_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_2_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_2_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_2_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_2_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_2_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_2_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_3_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_3_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_3_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_3_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_3_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_3_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_3_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_3_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_3_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_3_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_3_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_3_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_3_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_3_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_3_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_3_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_3_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_3_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_3_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_3_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_3_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_3_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_3_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_3_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_3_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_3_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_3_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_3_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_3_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_3_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_3_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_3_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_4_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_4_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_4_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_4_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_4_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_4_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_4_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_4_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_4_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_4_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_4_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_4_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_4_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_4_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_4_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_4_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_4_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_4_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_4_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_4_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_4_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_4_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_4_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_4_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_4_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_4_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_4_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_4_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_4_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_4_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_4_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_4_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_5_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_5_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_5_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_5_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_5_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_5_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_5_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_5_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_5_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_5_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_5_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_5_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_5_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_5_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_5_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_5_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_5_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_5_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_5_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_5_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_5_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_5_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_5_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_5_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_5_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_5_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_5_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_5_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_5_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_5_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_5_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_5_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_6_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_6_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_6_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_6_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_6_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_6_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_6_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_6_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_6_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_6_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_6_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_6_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_6_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_6_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_6_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_6_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_6_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_6_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_6_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_6_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_6_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_6_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_6_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_6_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_6_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_6_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_6_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_6_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_6_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_6_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_6_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_6_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_7_BANK_S->description: "Bunch bank selection"
sr/d-mfdbk/utca-horizontal/SEQ_7_BANK_S->EnumLabels: "Bank 0",\ 
                                                     "Bank 1",\ 
                                                     "Bank 2",\ 
                                                     "Bank 3"
sr/d-mfdbk/utca-horizontal/SEQ_7_BLANK_S->description: "Detector blanking control"
sr/d-mfdbk/utca-horizontal/SEQ_7_BLANK_S->EnumLabels: Off,\ 
                                                      Blanking
sr/d-mfdbk/utca-horizontal/SEQ_7_CAPTURE_S->description: "Enable data capture"
sr/d-mfdbk/utca-horizontal/SEQ_7_CAPTURE_S->EnumLabels: Discard,\ 
                                                        Capture
sr/d-mfdbk/utca-horizontal/SEQ_7_COUNT_S->description: "Sweep count"
sr/d-mfdbk/utca-horizontal/SEQ_7_COUNT_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_7_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_7_DWELL_S->description: "Sweep dwell time"
sr/d-mfdbk/utca-horizontal/SEQ_7_DWELL_S->max_value: 65536.0
sr/d-mfdbk/utca-horizontal/SEQ_7_DWELL_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_7_DWELL_S->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_7_ENABLE_S->description: "Enable Sweep NCO"
sr/d-mfdbk/utca-horizontal/SEQ_7_ENABLE_S->EnumLabels: Off,\ 
                                                       On
sr/d-mfdbk/utca-horizontal/SEQ_7_END_FREQ_S->description: "Sweep NCO end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_7_END_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_7_END_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_7_ENWIN_S->description: "Enable detector window"
sr/d-mfdbk/utca-horizontal/SEQ_7_ENWIN_S->EnumLabels: Disabled,\ 
                                                      Windowed
sr/d-mfdbk/utca-horizontal/SEQ_7_GAIN_S->description: "Sweep NCO gain"
sr/d-mfdbk/utca-horizontal/SEQ_7_GAIN_S->EnumLabels: 0dB,\ 
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
sr/d-mfdbk/utca-horizontal/SEQ_7_HOLDOFF_S->description: "Detector holdoff"
sr/d-mfdbk/utca-horizontal/SEQ_7_HOLDOFF_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/SEQ_7_HOLDOFF_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_7_START_FREQ_S->description: "Sweep NCO start frequency"
sr/d-mfdbk/utca-horizontal/SEQ_7_START_FREQ_S->format: %8.5f
sr/d-mfdbk/utca-horizontal/SEQ_7_START_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_7_STEP_FREQ_S->description: "Sweep NCO step frequency"
sr/d-mfdbk/utca-horizontal/SEQ_7_STEP_FREQ_S->format: %10.7f
sr/d-mfdbk/utca-horizontal/SEQ_7_STEP_FREQ_S->unit: tune
sr/d-mfdbk/utca-horizontal/SEQ_7_UPDATE_END_S->description: "Update end frequency"
sr/d-mfdbk/utca-horizontal/SEQ_BUSY->description: "Sequencer busy state"
sr/d-mfdbk/utca-horizontal/SEQ_BUSY->EnumLabels: Idle,\ 
                                                 Busy
sr/d-mfdbk/utca-horizontal/SEQ_DURATION->description: "Raw capture duration"
sr/d-mfdbk/utca-horizontal/SEQ_DURATION->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_DURATION_S->description: "Capture duration"
sr/d-mfdbk/utca-horizontal/SEQ_DURATION_S->format: %.3f
sr/d-mfdbk/utca-horizontal/SEQ_DURATION_S->unit: s
sr/d-mfdbk/utca-horizontal/SEQ_LENGTH->description: "Sequencer capture count"
sr/d-mfdbk/utca-horizontal/SEQ_MODE->description: "Sequencer mode"
sr/d-mfdbk/utca-horizontal/SEQ_PC->description: "Current sequencer state"
sr/d-mfdbk/utca-horizontal/SEQ_PC_S->description: "Sequencer PC"
sr/d-mfdbk/utca-horizontal/SEQ_PC_S->format: %1d
sr/d-mfdbk/utca-horizontal/SEQ_PC_S->max_value: 7.0
sr/d-mfdbk/utca-horizontal/SEQ_PC_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_RESET_S->description: "Halt sequencer if busy"
sr/d-mfdbk/utca-horizontal/SEQ_RESET_WIN_S->description: "Reset detector window to Hamming"
sr/d-mfdbk/utca-horizontal/SEQ_STATUS_READ_S->description: "Poll sequencer status"
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT->description: "Current super sequencer count"
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT->max_value: 1024.0
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT_S->description: "Super sequencer count"
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT_S->format: %4d
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT_S->max_value: 1024.0
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_COUNT_S->min_value: 1.0
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_OFFSET_S->description: "Frequency offsets for super sequencer"
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_OFFSET_S->format: %.5f
sr/d-mfdbk/utca-horizontal/SEQ_SUPER_RESET_S->description: "Reset super sequencer offsets"
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_DURATION->description: "Super sequence raw capture duration"
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_DURATION->format: %.0f
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_DURATION->unit: turns
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_DURATION_S->description: "Super capture duration"
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_DURATION_S->format: %.3f
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_DURATION_S->unit: s
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_LENGTH->description: "Super sequencer capture count"
sr/d-mfdbk/utca-horizontal/SEQ_TOTAL_LENGTH->format: %.0f
sr/d-mfdbk/utca-horizontal/SEQ_TRIGGER_S->description: "State to generate sequencer trigger"
sr/d-mfdbk/utca-horizontal/SEQ_TRIGGER_S->format: %1d
sr/d-mfdbk/utca-horizontal/SEQ_TRIGGER_S->max_value: 7.0
sr/d-mfdbk/utca-horizontal/SEQ_TRIGGER_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/SEQ_UPDATE_COUNT_S->description: "Internal sequencer state update"
sr/d-mfdbk/utca-horizontal/SEQ_WINDOW_S->description: "Detector window"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC0_BL_S->EnumLabels: All,\ 
                                                          Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC0_EN_S->description: "Enable Y ADC event input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                          Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC0_HIT->description: "Y ADC event source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC0_HIT->EnumLabels: No,\ 
                                                         Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC1_BL_S->EnumLabels: All,\ 
                                                          Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC1_EN_S->description: "Enable X ADC event input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                          Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC1_HIT->description: "X ADC event source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ADC1_HIT->EnumLabels: No,\ 
                                                         Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_ARM_S->description: "Arm trigger"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_BL_S->description: "Write blanking"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_DELAY_S->description: "Trigger delay"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_DELAY_S->format: %3d
sr/d-mfdbk/utca-horizontal/TRG_SEQ_DELAY_S->max_value: 65535.0
sr/d-mfdbk/utca-horizontal/TRG_SEQ_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-horizontal/TRG_SEQ_DISARM_S->description: "Disarm trigger"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EN_S->description: "Write enables"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EXT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EXT_BL_S->EnumLabels: All,\ 
                                                         Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EXT_EN_S->description: "Enable External trigger input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EXT_EN_S->EnumLabels: Ignore,\ 
                                                         Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EXT_HIT->description: "External trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_EXT_HIT->EnumLabels: No,\ 
                                                        Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_HIT->description: "Update source events"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_MODE_S->description: "Arming mode"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_MODE_S->EnumLabels: "One Shot",\ 
                                                       Rearm,\ 
                                                       Shared
sr/d-mfdbk/utca-horizontal/TRG_SEQ_PM_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_PM_BL_S->EnumLabels: All,\ 
                                                        Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_PM_EN_S->description: "Enable Postmortem trigger input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_PM_EN_S->EnumLabels: Ignore,\ 
                                                        Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_PM_HIT->description: "Postmortem trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_PM_HIT->EnumLabels: No,\ 
                                                       Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ0_BL_S->EnumLabels: All,\ 
                                                          Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ0_EN_S->description: "Enable Y SEQ event input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                          Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ0_HIT->description: "Y SEQ event source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ0_HIT->EnumLabels: No,\ 
                                                         Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ1_BL_S->EnumLabels: All,\ 
                                                          Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ1_EN_S->description: "Enable X SEQ event input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                          Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ1_HIT->description: "X SEQ event source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SEQ1_HIT->EnumLabels: No,\ 
                                                         Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SOFT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SOFT_BL_S->EnumLabels: All,\ 
                                                          Blanking
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SOFT_EN_S->description: "Enable Soft trigger input"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                          Enable
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SOFT_HIT->description: "Soft trigger source"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_SOFT_HIT->EnumLabels: No,\ 
                                                         Yes
sr/d-mfdbk/utca-horizontal/TRG_SEQ_STATUS->description: "Trigger target status"
sr/d-mfdbk/utca-horizontal/TRG_SEQ_STATUS->EnumLabels: Idle,\ 
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


