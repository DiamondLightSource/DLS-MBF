#
# Resource backup , created Tue Sep 18 17:49:20 CEST 2018
#

#---------------------------------------------------------
# SERVER Tango2Epics/mfdbk-global, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/mfdbk-global/DEVICE/Tango2Epics: "sr/d-mfdbk/utca-global"


# --- sr/d-mfdbk/utca-global properties

sr/d-mfdbk/utca-global->polled_attr: dly_turn_errors,\ 
                                     1000,\ 
                                     sta_vcxo,\ 
                                     1000,\ 
                                     git_version,\ 
                                     10000,\ 
                                     fpga_git_version,\ 
                                     1000
sr/d-mfdbk/utca-global->Variables: SR-TMBF:ADC:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_FAN,\ 
                                   SR-TMBF:ADC:EVENTS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_FAN1,\ 
                                   SR-TMBF:ADC:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_S,\ 
                                   SR-TMBF:ADC_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*ADC_TAPS,\ 
                                   SR-TMBF:INFO:AXIS0*Scalar*String*READ_ONLY*ATTRIBUTE*AXIS0,\ 
                                   SR-TMBF:INFO:AXIS1*Scalar*String*READ_ONLY*ATTRIBUTE*AXIS1,\ 
                                   SR-TMBF:INFO:BUNCHES*Scalar*Int*READ_ONLY*ATTRIBUTE*BUNCHES,\ 
                                   SR-TMBF:INFO:BUNCH_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*BUNCH_TAPS,\ 
                                   SR-TMBF:DAC:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_S,\ 
                                   SR-TMBF:DAC:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_FAN,\ 
                                   SR-TMBF:DAC:EVENTS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_FAN1,\ 
                                   SR-TMBF:DAC_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*DAC_TAPS,\ 
                                   SR-TMBF:INFO:DEVICE*Scalar*String*READ_ONLY*ATTRIBUTE*DEVICE,\ 
                                   SR-TMBF:DLY:DAC:COARSE_DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_COARSE_DELAY_S,\ 
                                   SR-TMBF:DLY:DAC:DELAY_PS*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_DAC_DELAY_PS,\ 
                                   SR-TMBF:DLY:DAC:FIFO*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_DAC_FIFO,\ 
                                   SR-TMBF:DLY:DAC:FINE_DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_FINE_DELAY_S,\ 
                                   SR-TMBF:DLY:DAC:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_RESET_S,\ 
                                   SR-TMBF:DLY:DAC:STEP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_STEP_S,\ 
                                   SR-TMBF:DLY:STEP_SIZE*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_STEP_SIZE,\ 
                                   SR-TMBF:DLY:TURN:DELAY_PS*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_TURN_DELAY_PS,\ 
                                   SR-TMBF:DLY:TURN:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_DELAY_S,\ 
                                   SR-TMBF:DLY:TURN:ERRORS*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_TURN_ERRORS,\ 
                                   SR-TMBF:DLY:TURN:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_FAN,\ 
                                   SR-TMBF:DLY:TURN:OFFSET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_OFFSET_S,\ 
                                   SR-TMBF:DLY:TURN:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_POLL_S,\ 
                                   SR-TMBF:DLY:TURN:RATE*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_TURN_RATE,\ 
                                   SR-TMBF:DLY:TURN:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*DLY_TURN_STATUS,\ 
                                   SR-TMBF:DLY:TURN:SYNC_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_SYNC_S,\ 
                                   SR-TMBF:DLY:TURN:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_TURN_TURNS,\ 
                                   SR-TMBF:INFO:DRIVER_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*DRIVER_VERSION,\ 
                                   SR-TMBF:FIR:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_EVENTS_FAN,\ 
                                   SR-TMBF:FIR:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_EVENTS_S,\ 
                                   SR-TMBF:INFO:FPGA_GIT_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*FPGA_GIT_VERSION,\ 
                                   SR-TMBF:INFO:FPGA_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*FPGA_VERSION,\ 
                                   SR-TMBF:INFO:GIT_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*GIT_VERSION,\ 
                                   SR-TMBF:INFO:HOSTNAME*Scalar*String*READ_ONLY*ATTRIBUTE*HOSTNAME,\ 
                                   SR-TMBF:MEM:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_BUSY,\ 
                                   SR-TMBF:MEM:CAPTURE_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_CAPTURE_S,\ 
                                   SR-TMBF:MEM:FIR0_GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_FIR0_GAIN_S,\ 
                                   SR-TMBF:MEM:FIR0_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_FIR0_OVF,\ 
                                   SR-TMBF:MEM:FIR1_GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_FIR1_GAIN_S,\ 
                                   SR-TMBF:MEM:FIR1_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_FIR1_OVF,\ 
                                   SR-TMBF:MEM:OFFSET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_OFFSET_S,\ 
                                   SR-TMBF:MEM:READ:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READ_FAN,\ 
                                   SR-TMBF:MEM:READOUT:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READOUT_DONE_S,\ 
                                   SR-TMBF:MEM:READOUT:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*MEM_READOUT_TRIG,\ 
                                   SR-TMBF:MEM:READOUT:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READOUT_TRIG_FAN,\ 
                                   SR-TMBF:MEM:READ_OVF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READ_OVF_S,\ 
                                   SR-TMBF:MEM:RUNOUT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_RUNOUT_S,\ 
                                   SR-TMBF:MEM:SEL0_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SEL0_S,\ 
                                   SR-TMBF:MEM:SEL1_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SEL1_S,\ 
                                   SR-TMBF:MEM:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SELECT_S,\ 
                                   SR-TMBF:MEM:WF0*Array:16384*Int*READ_ONLY*ATTRIBUTE*MEM_WF0,\ 
                                   SR-TMBF:MEM:WF1*Array:16384*Int*READ_ONLY*ATTRIBUTE*MEM_WF1,\ 
                                   SR-TMBF:MEM:WRITE_GAIN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_WRITE_GAIN_S,\ 
                                   SR-TMBF:INFO:MODE*Scalar*Enum*READ_ONLY*ATTRIBUTE*MODE,\ 
                                   SR-TMBF:INFO:SOCKET*Scalar*Int*READ_ONLY*ATTRIBUTE*SOCKET,\ 
                                   SR-TMBF:STA:CLOCK*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_CLOCK,\ 
                                   SR-TMBF:STA:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*STA_FAN,\ 
                                   SR-TMBF:STA:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*STA_POLL_S,\ 
                                   SR-TMBF:STA:VCO*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_VCO,\ 
                                   SR-TMBF:STA:VCXO*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_VCXO,\ 
                                   SR-TMBF:TRG:ADC0:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_ADC0_IN,\ 
                                   SR-TMBF:TRG:ADC1:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_ADC1_IN,\ 
                                   SR-TMBF:TRG:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_ARM_S,\ 
                                   SR-TMBF:TRG:BLANKING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_BLANKING_S,\ 
                                   SR-TMBF:TRG:BLNK:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_BLNK_IN,\ 
                                   SR-TMBF:TRG:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_DISARM_S,\ 
                                   SR-TMBF:TRG:EXT:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_EXT_IN,\ 
                                   SR-TMBF:TRG:IN:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_FAN,\ 
                                   SR-TMBF:TRG:IN:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_FAN1,\ 
                                   SR-TMBF:TRG:IN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_S,\ 
                                   SR-TMBF:TRG:MEM:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC0_BL_S,\ 
                                   SR-TMBF:TRG:MEM:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC0_EN_S,\ 
                                   SR-TMBF:TRG:MEM:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_ADC0_HIT,\ 
                                   SR-TMBF:TRG:MEM:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC1_BL_S,\ 
                                   SR-TMBF:TRG:MEM:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC1_EN_S,\ 
                                   SR-TMBF:TRG:MEM:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_ADC1_HIT,\ 
                                   SR-TMBF:TRG:MEM:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_ARM_S,\ 
                                   SR-TMBF:TRG:MEM:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_BL_S,\ 
                                   SR-TMBF:TRG:MEM:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_DELAY_S,\ 
                                   SR-TMBF:TRG:MEM:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_DISARM_S,\ 
                                   SR-TMBF:TRG:MEM:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_EN_S,\ 
                                   SR-TMBF:TRG:MEM:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_EXT_BL_S,\ 
                                   SR-TMBF:TRG:MEM:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_EXT_EN_S,\ 
                                   SR-TMBF:TRG:MEM:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_EXT_HIT,\ 
                                   SR-TMBF:TRG:MEM:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*TRG_MEM_HIT,\ 
                                   SR-TMBF:TRG:MEM:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_HIT_FAN,\ 
                                   SR-TMBF:TRG:MEM:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_HIT_FAN1,\ 
                                   SR-TMBF:TRG:MEM:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_MODE_S,\ 
                                   SR-TMBF:TRG:MEM:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_PM_BL_S,\ 
                                   SR-TMBF:TRG:MEM:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_PM_EN_S,\ 
                                   SR-TMBF:TRG:MEM:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_PM_HIT,\ 
                                   SR-TMBF:TRG:MEM:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ0_BL_S,\ 
                                   SR-TMBF:TRG:MEM:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ0_EN_S,\ 
                                   SR-TMBF:TRG:MEM:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SEQ0_HIT,\ 
                                   SR-TMBF:TRG:MEM:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ1_BL_S,\ 
                                   SR-TMBF:TRG:MEM:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ1_EN_S,\ 
                                   SR-TMBF:TRG:MEM:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SEQ1_HIT,\ 
                                   SR-TMBF:TRG:MEM:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SOFT_BL_S,\ 
                                   SR-TMBF:TRG:MEM:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SOFT_EN_S,\ 
                                   SR-TMBF:TRG:MEM:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SOFT_HIT,\ 
                                   SR-TMBF:TRG:MEM:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_STATUS,\ 
                                   SR-TMBF:TRG:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MODE_S,\ 
                                   SR-TMBF:TRG:PM:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_PM_IN,\ 
                                   SR-TMBF:TRG:SEQ0:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ0_IN,\ 
                                   SR-TMBF:TRG:SEQ1:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ1_IN,\ 
                                   SR-TMBF:TRG:SHARED*Scalar*String*READ_ONLY*ATTRIBUTE*TRG_SHARED,\ 
                                   SR-TMBF:TRG:SOFT:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SOFT_IN,\ 
                                   SR-TMBF:TRG:SOFT_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SOFT_S,\ 
                                   SR-TMBF:TRG:SOFT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SOFT_CMD,\ 
                                   SR-TMBF:TRG:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_STATUS,\ 
                                   SR-TMBF:INFO:VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*VERSION

# --- sr/d-mfdbk/utca-global attribute properties

sr/d-mfdbk/utca-global/ADC_EVENTS_S->description: "ADC event detect scan"
sr/d-mfdbk/utca-global/ADC_TAPS->description: "Length of ADC compensation filter"
sr/d-mfdbk/utca-global/AXIS0->description: "Name of first axis"
sr/d-mfdbk/utca-global/AXIS1->description: "Name of second axis"
sr/d-mfdbk/utca-global/BUNCHES->description: "Number of bunches per revolution"
sr/d-mfdbk/utca-global/BUNCH_TAPS->description: "Length of bunch-by-bunch feedback filter"
sr/d-mfdbk/utca-global/DAC_EVENTS_S->description: "DAC event detect scan"
sr/d-mfdbk/utca-global/DAC_TAPS->description: "Length of DAC pre-emphasis filter"
sr/d-mfdbk/utca-global/DEVICE->description: "Name of AMC525 device"
sr/d-mfdbk/utca-global/DLY_DAC_COARSE_DELAY_S->description: "DAC clock coarse delay"
sr/d-mfdbk/utca-global/DLY_DAC_COARSE_DELAY_S->format: %3d
sr/d-mfdbk/utca-global/DLY_DAC_DELAY_PS->unit: ps
sr/d-mfdbk/utca-global/DLY_DAC_FIFO->description: "DAC output FIFO depth"
sr/d-mfdbk/utca-global/DLY_DAC_FINE_DELAY_S->description: "DAC clock fine delay"
sr/d-mfdbk/utca-global/DLY_DAC_FINE_DELAY_S->format: %2d
sr/d-mfdbk/utca-global/DLY_DAC_FINE_DELAY_S->max_value: 23.0
sr/d-mfdbk/utca-global/DLY_DAC_FINE_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-global/DLY_DAC_HALF_STEP_S->description: "DAC clock half step control"
sr/d-mfdbk/utca-global/DLY_DAC_HALF_STEP_S->EnumLabels: 0,\ 
                                                        -0.5
sr/d-mfdbk/utca-global/DLY_DAC_RESET_S->description: "Reset coarse delay"
sr/d-mfdbk/utca-global/DLY_DAC_STEP_S->description: "Advance coarse delay"
sr/d-mfdbk/utca-global/DLY_STEP_SIZE->description: "Duration of coarse step"
sr/d-mfdbk/utca-global/DLY_STEP_SIZE->unit: ps
sr/d-mfdbk/utca-global/DLY_TURN_DELAY_PS->unit: ps
sr/d-mfdbk/utca-global/DLY_TURN_DELAY_S->description: "Turn clock input delay"
sr/d-mfdbk/utca-global/DLY_TURN_DELAY_S->format: %2d
sr/d-mfdbk/utca-global/DLY_TURN_DELAY_S->max_value: 31.0
sr/d-mfdbk/utca-global/DLY_TURN_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-global/DLY_TURN_ERRORS->archive_abs_change: -1,\ 
                                                            1
sr/d-mfdbk/utca-global/DLY_TURN_ERRORS->archive_period: 3600000
sr/d-mfdbk/utca-global/DLY_TURN_ERRORS->description: "Turn clock errors"
sr/d-mfdbk/utca-global/DLY_TURN_OFFSET_S->description: "Turn clock offset"
sr/d-mfdbk/utca-global/DLY_TURN_OFFSET_S->format: %3d
sr/d-mfdbk/utca-global/DLY_TURN_POLL_S->description: "Update turn status"
sr/d-mfdbk/utca-global/DLY_TURN_RATE->description: "Clock error rate"
sr/d-mfdbk/utca-global/DLY_TURN_RATE->format: %.3f
sr/d-mfdbk/utca-global/DLY_TURN_STATUS->description: "Turn clock synchronisation status"
sr/d-mfdbk/utca-global/DLY_TURN_STATUS->EnumLabels: Armed,\ 
                                                    Synced,\ 
                                                    "Sync Errors"
sr/d-mfdbk/utca-global/DLY_TURN_SYNC_S->description: "Synchronise turn clock"
sr/d-mfdbk/utca-global/DLY_TURN_TURNS->description: "Turns sampled"
sr/d-mfdbk/utca-global/DRIVER_VERSION->description: "Kernel driver version"
sr/d-mfdbk/utca-global/FIR_EVENTS_S->description: "FIR event detect scan"
sr/d-mfdbk/utca-global/FPGA_GIT_VERSION->archive_period: 86400000
sr/d-mfdbk/utca-global/FPGA_GIT_VERSION->description: "Firmware git version"
sr/d-mfdbk/utca-global/FPGA_VERSION->description: "Firmware version"
sr/d-mfdbk/utca-global/GIT_VERSION->archive_period: 86400000
sr/d-mfdbk/utca-global/GIT_VERSION->description: "Software git version"
sr/d-mfdbk/utca-global/HOSTNAME->description: "Host name of MBF IOC"
sr/d-mfdbk/utca-global/MEM_BUSY->description: "Capture status"
sr/d-mfdbk/utca-global/MEM_BUSY->EnumLabels: Ready,\ 
                                             Busy
sr/d-mfdbk/utca-global/MEM_CAPTURE_S->description: "Untriggered immediate capture"
sr/d-mfdbk/utca-global/MEM_FIR0_GAIN_S->description: "FIR 0 capture gain"
sr/d-mfdbk/utca-global/MEM_FIR0_GAIN_S->EnumLabels: +54dB,\ 
                                                    0dB
sr/d-mfdbk/utca-global/MEM_FIR0_OVF->description: "FIR 0 capture will overflow"
sr/d-mfdbk/utca-global/MEM_FIR0_OVF->EnumLabels: Ok,\ 
                                                 Overflow
sr/d-mfdbk/utca-global/MEM_FIR1_GAIN_S->description: "FIR 1 capture gain"
sr/d-mfdbk/utca-global/MEM_FIR1_GAIN_S->EnumLabels: +54dB,\ 
                                                    0dB
sr/d-mfdbk/utca-global/MEM_FIR1_OVF->description: "FIR 1 capture will overflow"
sr/d-mfdbk/utca-global/MEM_FIR1_OVF->EnumLabels: Ok,\ 
                                                 Overflow
sr/d-mfdbk/utca-global/MEM_OFFSET_S->description: "Offset of readout"
sr/d-mfdbk/utca-global/MEM_OFFSET_S->max_value: 5.36870911E8
sr/d-mfdbk/utca-global/MEM_OFFSET_S->min_value: -5.36870912E8
sr/d-mfdbk/utca-global/MEM_OFFSET_S->unit: turns
sr/d-mfdbk/utca-global/MEM_READOUT_DONE_S->description: "READOUT processing done"
sr/d-mfdbk/utca-global/MEM_READOUT_TRIG->description: "READOUT processing trigger"
sr/d-mfdbk/utca-global/MEM_READ_OVF_S->description: "Poll overflow events"
sr/d-mfdbk/utca-global/MEM_RUNOUT_S->description: "Post trigger capture count"
sr/d-mfdbk/utca-global/MEM_RUNOUT_S->EnumLabels: 12.5%,\ 
                                                 25%,\ 
                                                 50%,\ 
                                                 75%,\ 
                                                 99.5%
sr/d-mfdbk/utca-global/MEM_SEL0_S->description: "Channel 0 capture selection"
sr/d-mfdbk/utca-global/MEM_SEL0_S->EnumLabels: ADC0,\ 
                                               FIR0,\ 
                                               DAC0,\ 
                                               ADC1,\ 
                                               FIR1,\ 
                                               DAC1
sr/d-mfdbk/utca-global/MEM_SEL1_S->description: "Channel 1 capture selection"
sr/d-mfdbk/utca-global/MEM_SEL1_S->EnumLabels: ADC0,\ 
                                               FIR0,\ 
                                               DAC0,\ 
                                               ADC1,\ 
                                               FIR1,\ 
                                               DAC1
sr/d-mfdbk/utca-global/MEM_SELECT_S->description: "Control memory capture selection"
sr/d-mfdbk/utca-global/MEM_SELECT_S->EnumLabels: "ADC0/ADC1",\ 
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
sr/d-mfdbk/utca-global/MEM_WF0->description: "Capture waveform #0"
sr/d-mfdbk/utca-global/MEM_WF1->description: "Capture waveform #1"
sr/d-mfdbk/utca-global/MEM_WRITE_GAIN_S->description: "Write FIR gain"
sr/d-mfdbk/utca-global/MODE->description: "Operational mode"
sr/d-mfdbk/utca-global/MODE->EnumLabels: TMBF,\ 
                                         LMBF
sr/d-mfdbk/utca-global/SOCKET->description: "Socket number for data server"
sr/d-mfdbk/utca-global/STA_CLOCK->description: "ADC clock status"
sr/d-mfdbk/utca-global/STA_CLOCK->EnumLabels: Unlocked,\ 
                                              Locked
sr/d-mfdbk/utca-global/STA_POLL_S->description: "Poll system status"
sr/d-mfdbk/utca-global/STA_VCO->description: "VCO clock status"
sr/d-mfdbk/utca-global/STA_VCO->EnumLabels: "Unlocked (MAJOR)",\ 
                                            Locked,\ 
                                            Passthrough
sr/d-mfdbk/utca-global/STA_VCXO->archive_abs_change: -1,\ 
                                                     1
sr/d-mfdbk/utca-global/STA_VCXO->archive_period: 3600000
sr/d-mfdbk/utca-global/STA_VCXO->description: "VCXO clock status"
sr/d-mfdbk/utca-global/STA_VCXO->EnumLabels: "Unlocked (MAJOR)",\ 
                                             Locked,\ 
                                             Passthrough
sr/d-mfdbk/utca-global/TRG_ADC0_IN->description: "Y ADC event input"
sr/d-mfdbk/utca-global/TRG_ADC0_IN->EnumLabels: No,\ 
                                                Yes
sr/d-mfdbk/utca-global/TRG_ADC1_IN->description: "X ADC event input"
sr/d-mfdbk/utca-global/TRG_ADC1_IN->EnumLabels: No,\ 
                                                Yes
sr/d-mfdbk/utca-global/TRG_ARM_S->description: "Arm all shared targets"
sr/d-mfdbk/utca-global/TRG_BLANKING_S->description: "Blanking duration"
sr/d-mfdbk/utca-global/TRG_BLANKING_S->format: %5d
sr/d-mfdbk/utca-global/TRG_BLANKING_S->max_value: 65535.0
sr/d-mfdbk/utca-global/TRG_BLANKING_S->min_value: 0.0
sr/d-mfdbk/utca-global/TRG_BLANKING_S->unit: turns
sr/d-mfdbk/utca-global/TRG_BLNK_IN->description: "Blanking event"
sr/d-mfdbk/utca-global/TRG_BLNK_IN->EnumLabels: No,\ 
                                                Yes
sr/d-mfdbk/utca-global/TRG_DISARM_S->description: "Disarm all shared targets"
sr/d-mfdbk/utca-global/TRG_EXT_IN->description: "External trigger input"
sr/d-mfdbk/utca-global/TRG_EXT_IN->EnumLabels: No,\ 
                                               Yes
sr/d-mfdbk/utca-global/TRG_IN_S->description: "Scan input events"
sr/d-mfdbk/utca-global/TRG_MEM_ADC0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_ADC0_BL_S->EnumLabels: All,\ 
                                                      Blanking
sr/d-mfdbk/utca-global/TRG_MEM_ADC0_EN_S->description: "Enable Y ADC event input"
sr/d-mfdbk/utca-global/TRG_MEM_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                      Enable
sr/d-mfdbk/utca-global/TRG_MEM_ADC0_HIT->description: "Y ADC event source"
sr/d-mfdbk/utca-global/TRG_MEM_ADC0_HIT->EnumLabels: No,\ 
                                                     Yes
sr/d-mfdbk/utca-global/TRG_MEM_ADC1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_ADC1_BL_S->EnumLabels: All,\ 
                                                      Blanking
sr/d-mfdbk/utca-global/TRG_MEM_ADC1_EN_S->description: "Enable X ADC event input"
sr/d-mfdbk/utca-global/TRG_MEM_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                      Enable
sr/d-mfdbk/utca-global/TRG_MEM_ADC1_HIT->description: "X ADC event source"
sr/d-mfdbk/utca-global/TRG_MEM_ADC1_HIT->EnumLabels: No,\ 
                                                     Yes
sr/d-mfdbk/utca-global/TRG_MEM_ARM_S->description: "Arm trigger"
sr/d-mfdbk/utca-global/TRG_MEM_BL_S->description: "Write blanking"
sr/d-mfdbk/utca-global/TRG_MEM_DELAY_S->description: "Trigger delay"
sr/d-mfdbk/utca-global/TRG_MEM_DELAY_S->max_value: 65535.0
sr/d-mfdbk/utca-global/TRG_MEM_DELAY_S->min_value: 0.0
sr/d-mfdbk/utca-global/TRG_MEM_DISARM_S->description: "Disarm trigger"
sr/d-mfdbk/utca-global/TRG_MEM_EN_S->description: "Write enables"
sr/d-mfdbk/utca-global/TRG_MEM_EXT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_EXT_BL_S->EnumLabels: All,\ 
                                                     Blanking
sr/d-mfdbk/utca-global/TRG_MEM_EXT_EN_S->description: "Enable External trigger input"
sr/d-mfdbk/utca-global/TRG_MEM_EXT_EN_S->EnumLabels: Ignore,\ 
                                                     Enable
sr/d-mfdbk/utca-global/TRG_MEM_EXT_HIT->description: "External trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_EXT_HIT->EnumLabels: No,\ 
                                                    Yes
sr/d-mfdbk/utca-global/TRG_MEM_HIT->description: "Update source events"
sr/d-mfdbk/utca-global/TRG_MEM_MODE_S->description: "Arming mode"
sr/d-mfdbk/utca-global/TRG_MEM_MODE_S->EnumLabels: "One Shot",\ 
                                                   Rearm,\ 
                                                   Shared
sr/d-mfdbk/utca-global/TRG_MEM_PM_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_PM_BL_S->EnumLabels: All,\ 
                                                    Blanking
sr/d-mfdbk/utca-global/TRG_MEM_PM_EN_S->description: "Enable Postmortem trigger input"
sr/d-mfdbk/utca-global/TRG_MEM_PM_EN_S->EnumLabels: Ignore,\ 
                                                    Enable
sr/d-mfdbk/utca-global/TRG_MEM_PM_HIT->description: "Postmortem trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_PM_HIT->EnumLabels: No,\ 
                                                   Yes
sr/d-mfdbk/utca-global/TRG_MEM_SEQ0_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_SEQ0_BL_S->EnumLabels: All,\ 
                                                      Blanking
sr/d-mfdbk/utca-global/TRG_MEM_SEQ0_EN_S->description: "Enable Y SEQ event input"
sr/d-mfdbk/utca-global/TRG_MEM_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                      Enable
sr/d-mfdbk/utca-global/TRG_MEM_SEQ0_HIT->description: "Y SEQ event source"
sr/d-mfdbk/utca-global/TRG_MEM_SEQ0_HIT->EnumLabels: No,\ 
                                                     Yes
sr/d-mfdbk/utca-global/TRG_MEM_SEQ1_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_SEQ1_BL_S->EnumLabels: All,\ 
                                                      Blanking
sr/d-mfdbk/utca-global/TRG_MEM_SEQ1_EN_S->description: "Enable X SEQ event input"
sr/d-mfdbk/utca-global/TRG_MEM_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                      Enable
sr/d-mfdbk/utca-global/TRG_MEM_SEQ1_HIT->description: "X SEQ event source"
sr/d-mfdbk/utca-global/TRG_MEM_SEQ1_HIT->EnumLabels: No,\ 
                                                     Yes
sr/d-mfdbk/utca-global/TRG_MEM_SOFT_BL_S->description: "Enable blanking for trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_SOFT_BL_S->EnumLabels: All,\ 
                                                      Blanking
sr/d-mfdbk/utca-global/TRG_MEM_SOFT_EN_S->description: "Enable Soft trigger input"
sr/d-mfdbk/utca-global/TRG_MEM_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                      Enable
sr/d-mfdbk/utca-global/TRG_MEM_SOFT_HIT->description: "Soft trigger source"
sr/d-mfdbk/utca-global/TRG_MEM_SOFT_HIT->EnumLabels: No,\ 
                                                     Yes
sr/d-mfdbk/utca-global/TRG_MEM_STATUS->description: "Trigger target status"
sr/d-mfdbk/utca-global/TRG_MEM_STATUS->EnumLabels: Idle,\ 
                                                   Armed,\ 
                                                   Busy,\ 
                                                   Locked
sr/d-mfdbk/utca-global/TRG_MODE_S->description: "Shared trigger mode"
sr/d-mfdbk/utca-global/TRG_MODE_S->EnumLabels: "One Shot",\ 
                                               Rearm
sr/d-mfdbk/utca-global/TRG_PM_IN->description: "Postmortem trigger input"
sr/d-mfdbk/utca-global/TRG_PM_IN->EnumLabels: No,\ 
                                              Yes
sr/d-mfdbk/utca-global/TRG_SEQ0_IN->description: "Y SEQ event input"
sr/d-mfdbk/utca-global/TRG_SEQ0_IN->EnumLabels: No,\ 
                                                Yes
sr/d-mfdbk/utca-global/TRG_SEQ1_IN->description: "X SEQ event input"
sr/d-mfdbk/utca-global/TRG_SEQ1_IN->EnumLabels: No,\ 
                                                Yes
sr/d-mfdbk/utca-global/TRG_SHARED->description: "List of shared targets"
sr/d-mfdbk/utca-global/TRG_SOFT_IN->description: "Soft trigger input"
sr/d-mfdbk/utca-global/TRG_SOFT_IN->EnumLabels: No,\ 
                                                Yes
sr/d-mfdbk/utca-global/TRG_SOFT_S->description: "Soft trigger"
sr/d-mfdbk/utca-global/TRG_SOFT_S->EnumLabels: Passive,\ 
                                               Event,\ 
                                               "I/O Intr",\ 
                                               "10 s",\ 
                                               "5 s",\ 
                                               "2 s",\ 
                                               "1 s",\ 
                                               "500 ms",\ 
                                               "200 ms",\ 
                                               "100 ms"
sr/d-mfdbk/utca-global/TRG_STATUS->description: "Shared trigger target status"
sr/d-mfdbk/utca-global/TRG_STATUS->EnumLabels: Idle,\ 
                                               Armed,\ 
                                               Locked,\ 
                                               Busy,\ 
                                               Mixed,\ 
                                               Invalid
sr/d-mfdbk/utca-global/VERSION->description: "Software version"

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



# --- dserver/Tango2Epics/mfdbk-global properties

dserver/Tango2Epics/mfdbk-global->polling_threads_pool_conf: "sr/d-mfdbk/utca-global"
