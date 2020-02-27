#
# Resource backup , created Tue Feb 11 12:09:51 CET 2020
#

#---------------------------------------------------------
# SERVER Tango2Epics/tmbf-global, Tango2Epics device declaration
#---------------------------------------------------------

Tango2Epics/tmbf-global/DEVICE/Tango2Epics: "tmbf/processor/global"


# --- tmbf/processor/global properties

tmbf/processor/global->ArrayAccessTimeout: 0.3
tmbf/processor/global->HelperApplication: "atkpanel tmbf/processor/global"
tmbf/processor/global->polled_attr: dly_turn_errors,\ 
                                    1000,\ 
                                    sta_vcxo,\ 
                                    1000,\ 
                                    state,\ 
                                    3000,\ 
                                    status,\ 
                                    3000
tmbf/processor/global->ScalarAccessTimeout: 0.2
tmbf/processor/global->SubscriptionCycle: 0.4
tmbf/processor/global->Variables: T-TMBF:ADC:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_FAN,\ 
                                  T-TMBF:ADC:EVENTS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_FAN1,\ 
                                  T-TMBF:ADC:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*ADC_EVENTS_S,\ 
                                  T-TMBF:DAC:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_FAN,\ 
                                  T-TMBF:DAC:EVENTS:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_FAN1,\ 
                                  T-TMBF:DAC:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DAC_EVENTS_S,\ 
                                  T-TMBF:DLY:DAC:COARSE_DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_COARSE_DELAY_S,\ 
                                  T-TMBF:DLY:DAC:DELAY_PS*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_DAC_DELAY_PS,\ 
                                  T-TMBF:DLY:DAC:FIFO*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_DAC_FIFO,\ 
                                  T-TMBF:DLY:DAC:FINE_DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_FINE_DELAY_S,\ 
                                  T-TMBF:DLY:DAC:RESET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_RESET_S,\ 
                                  T-TMBF:DLY:DAC:STEP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_DAC_STEP_S,\ 
                                  T-TMBF:DLY:STEP_SIZE*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_STEP_SIZE,\ 
                                  T-TMBF:DLY:TURN:DELAY_PS*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_TURN_DELAY_PS,\ 
                                  T-TMBF:DLY:TURN:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_DELAY_S,\ 
                                  T-TMBF:DLY:TURN:ERRORS*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_TURN_ERRORS,\ 
                                  T-TMBF:DLY:TURN:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_FAN,\ 
                                  T-TMBF:DLY:TURN:OFFSET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_OFFSET_S,\ 
                                  T-TMBF:DLY:TURN:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_POLL_S,\ 
                                  T-TMBF:DLY:TURN:RATE*Scalar*Double*READ_ONLY*ATTRIBUTE*DLY_TURN_RATE,\ 
                                  T-TMBF:DLY:TURN:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*DLY_TURN_STATUS,\ 
                                  T-TMBF:DLY:TURN:SYNC_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*DLY_TURN_SYNC_S,\ 
                                  T-TMBF:DLY:TURN:TURNS*Scalar*Int*READ_ONLY*ATTRIBUTE*DLY_TURN_TURNS,\ 
                                  T-TMBF:FIR:EVENTS:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_EVENTS_FAN,\ 
                                  T-TMBF:FIR:EVENTS_S*Scalar*Int*READ_WRITE*ATTRIBUTE*FIR_EVENTS_S,\ 
                                  T-TMBF:INFO:ADC_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_ADC_TAPS,\ 
                                  T-TMBF:INFO:AXIS0*Scalar*String*READ_ONLY*ATTRIBUTE*AXIS0,\ 
                                  T-TMBF:INFO:AXIS1*Scalar*String*READ_ONLY*ATTRIBUTE*AXIS1,\ 
                                  T-TMBF:INFO:BUNCHES*Scalar*Int*READ_ONLY*ATTRIBUTE*BUNCHES,\ 
                                  T-TMBF:INFO:BUNCH_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*BUNCH_TAPS,\ 
                                  T-TMBF:INFO:DAC_TAPS*Scalar*Int*READ_ONLY*ATTRIBUTE*INFO_DAC_TAPS,\ 
                                  T-TMBF:INFO:DEVICE*Scalar*String*READ_ONLY*ATTRIBUTE*DEVICE,\ 
                                  T-TMBF:INFO:DRIVER_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*DRIVER_VERSION,\ 
                                  T-TMBF:INFO:FPGA_GIT_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*FPGA_GIT_VERSION,\ 
                                  T-TMBF:INFO:FPGA_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*FPGA_VERSION,\ 
                                  T-TMBF:INFO:GIT_VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*GIT_VERSION,\ 
                                  T-TMBF:INFO:HOSTNAME*Array:256*Int*READ_ONLY*ATTRIBUTE*HOSTNAME,\ 
                                  T-TMBF:INFO:MODE*Scalar*Enum*READ_ONLY*ATTRIBUTE*MODE,\ 
                                  T-TMBF:INFO:SOCKET*Scalar*Int*READ_ONLY*ATTRIBUTE*SOCKET,\ 
                                  T-TMBF:INFO:VERSION*Scalar*String*READ_ONLY*ATTRIBUTE*VERSION,\ 
                                  T-TMBF:MEM:BUSY*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_BUSY,\ 
                                  T-TMBF:MEM:CAPTURE_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_CAPTURE_S,\ 
                                  T-TMBF:MEM:FIR0_GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_FIR0_GAIN_S,\ 
                                  T-TMBF:MEM:FIR0_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_FIR0_OVF,\ 
                                  T-TMBF:MEM:FIR1_GAIN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_FIR1_GAIN_S,\ 
                                  T-TMBF:MEM:FIR1_OVF*Scalar*Enum*READ_ONLY*ATTRIBUTE*MEM_FIR1_OVF,\ 
                                  T-TMBF:MEM:OFFSET_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_OFFSET_S,\ 
                                  T-TMBF:MEM:READ:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READ_FAN,\ 
                                  T-TMBF:MEM:READOUT:DONE_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READOUT_DONE_S,\ 
                                  T-TMBF:MEM:READOUT:TRIG*Scalar*Int*READ_ONLY*ATTRIBUTE*MEM_READOUT_TRIG,\ 
                                  T-TMBF:MEM:READOUT:TRIG:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READOUT_TRIG_FAN,\ 
                                  T-TMBF:MEM:READ_OVF_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_READ_OVF_S,\ 
                                  T-TMBF:MEM:RUNOUT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_RUNOUT_S,\ 
                                  T-TMBF:MEM:SEL0_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SEL0_S,\ 
                                  T-TMBF:MEM:SEL1_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SEL1_S,\ 
                                  T-TMBF:MEM:SELECT_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*MEM_SELECT_S,\ 
                                  T-TMBF:MEM:WF0*Array:16384*Int*READ_ONLY*ATTRIBUTE*MEM_WF0,\ 
                                  T-TMBF:MEM:WF1*Array:16384*Int*READ_ONLY*ATTRIBUTE*MEM_WF1,\ 
                                  T-TMBF:MEM:WRITE_GAIN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*MEM_WRITE_GAIN_S,\ 
                                  T-TMBF:PLL:CTRL:START_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_START_S,\ 
                                  T-TMBF:PLL:CTRL:STOP_S*Scalar*Int*READ_WRITE*ATTRIBUTE*PLL_CTRL_STOP_S,\ 
                                  T-TMBF:STA:CLOCK*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_CLOCK,\ 
                                  T-TMBF:STA:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*STA_FAN,\ 
                                  T-TMBF:STA:POLL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*STA_POLL_S,\ 
                                  T-TMBF:STA:VCO*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_VCO,\ 
                                  T-TMBF:STA:VCXO*Scalar*Enum*READ_ONLY*ATTRIBUTE*STA_VCXO,\ 
                                  T-TMBF:TRG:ADC0:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_ADC0_IN,\ 
                                  T-TMBF:TRG:ADC1:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_ADC1_IN,\ 
                                  T-TMBF:TRG:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_ARM_S,\ 
                                  T-TMBF:TRG:BLANKING_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_BLANKING_S,\ 
                                  T-TMBF:TRG:BLNK:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_BLNK_IN,\ 
                                  T-TMBF:TRG:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_DISARM_S,\ 
                                  T-TMBF:TRG:EXT:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_EXT_IN,\ 
                                  T-TMBF:TRG:IN:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_FAN,\ 
                                  T-TMBF:TRG:IN:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_FAN1,\ 
                                  T-TMBF:TRG:IN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_IN_S,\ 
                                  T-TMBF:TRG:MEM:ADC0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC0_BL_S,\ 
                                  T-TMBF:TRG:MEM:ADC0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC0_EN_S,\ 
                                  T-TMBF:TRG:MEM:ADC0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_ADC0_HIT,\ 
                                  T-TMBF:TRG:MEM:ADC1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC1_BL_S,\ 
                                  T-TMBF:TRG:MEM:ADC1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_ADC1_EN_S,\ 
                                  T-TMBF:TRG:MEM:ADC1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_ADC1_HIT,\ 
                                  T-TMBF:TRG:MEM:ARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_ARM_S,\ 
                                  T-TMBF:TRG:MEM:BL_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_BL_S,\ 
                                  T-TMBF:TRG:MEM:DELAY_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_DELAY_S,\ 
                                  T-TMBF:TRG:MEM:DISARM_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_DISARM_S,\ 
                                  T-TMBF:TRG:MEM:EN_S*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_EN_S,\ 
                                  T-TMBF:TRG:MEM:EXT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_EXT_BL_S,\ 
                                  T-TMBF:TRG:MEM:EXT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_EXT_EN_S,\ 
                                  T-TMBF:TRG:MEM:EXT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_EXT_HIT,\ 
                                  T-TMBF:TRG:MEM:HIT*Scalar*Int*READ_ONLY*ATTRIBUTE*TRG_MEM_HIT,\ 
                                  T-TMBF:TRG:MEM:HIT:FAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_HIT_FAN,\ 
                                  T-TMBF:TRG:MEM:HIT:FAN1*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_MEM_HIT_FAN1,\ 
                                  T-TMBF:TRG:MEM:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_MODE_S,\ 
                                  T-TMBF:TRG:MEM:PM:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_PM_BL_S,\ 
                                  T-TMBF:TRG:MEM:PM:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_PM_EN_S,\ 
                                  T-TMBF:TRG:MEM:PM:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_PM_HIT,\ 
                                  T-TMBF:TRG:MEM:SEQ0:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ0_BL_S,\ 
                                  T-TMBF:TRG:MEM:SEQ0:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ0_EN_S,\ 
                                  T-TMBF:TRG:MEM:SEQ0:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SEQ0_HIT,\ 
                                  T-TMBF:TRG:MEM:SEQ1:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ1_BL_S,\ 
                                  T-TMBF:TRG:MEM:SEQ1:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SEQ1_EN_S,\ 
                                  T-TMBF:TRG:MEM:SEQ1:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SEQ1_HIT,\ 
                                  T-TMBF:TRG:MEM:SOFT:BL_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SOFT_BL_S,\ 
                                  T-TMBF:TRG:MEM:SOFT:EN_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MEM_SOFT_EN_S,\ 
                                  T-TMBF:TRG:MEM:SOFT:HIT*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_SOFT_HIT,\ 
                                  T-TMBF:TRG:MEM:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_MEM_STATUS,\ 
                                  T-TMBF:TRG:MODE_S*Scalar*Enum*READ_WRITE*ATTRIBUTE*TRG_MODE_S,\ 
                                  T-TMBF:TRG:PM:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_PM_IN,\ 
                                  T-TMBF:TRG:SEQ0:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ0_IN,\ 
                                  T-TMBF:TRG:SEQ1:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SEQ1_IN,\ 
                                  T-TMBF:TRG:SHARED*Scalar*String*READ_ONLY*ATTRIBUTE*TRG_SHARED,\ 
                                  T-TMBF:TRG:SOFT:IN*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_SOFT_IN,\ 
                                  T-TMBF:TRG:SOFT_S.PROC*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SOFT_CMD,\ 
                                  T-TMBF:TRG:SOFT_S.SCAN*Scalar*Int*READ_WRITE*ATTRIBUTE*TRG_SOFT_S,\ 
                                  T-TMBF:TRG:STATUS*Scalar*Enum*READ_ONLY*ATTRIBUTE*TRG_STATUS

# --- tmbf/processor/global attribute properties

tmbf/processor/global/ADC_EVENTS_S->description: "ADC event detect scan"
tmbf/processor/global/ADC_TAPS->description: "Length of ADC compensation filter"
tmbf/processor/global/AXIS0->description: "Name of first axis"
tmbf/processor/global/AXIS1->description: "Name of second axis"
tmbf/processor/global/BUNCHES->description: "Number of bunches per revolution"
tmbf/processor/global/BUNCH_TAPS->description: "Length of bunch-by-bunch feedback filter"
tmbf/processor/global/DAC_EVENTS_S->description: "DAC event detect scan"
tmbf/processor/global/DAC_TAPS->description: "Length of DAC pre-emphasis filter"
tmbf/processor/global/DEVICE->description: "Name of AMC525 device"
tmbf/processor/global/DLY_DAC_COARSE_DELAY_S->description: "DAC clock coarse delay"
tmbf/processor/global/DLY_DAC_COARSE_DELAY_S->format: %3d
tmbf/processor/global/DLY_DAC_DELAY_PS->unit: ps
tmbf/processor/global/DLY_DAC_FIFO->description: "DAC output FIFO depth"
tmbf/processor/global/DLY_DAC_FINE_DELAY_S->description: "DAC clock fine delay"
tmbf/processor/global/DLY_DAC_FINE_DELAY_S->format: %2d
tmbf/processor/global/DLY_DAC_FINE_DELAY_S->max_value: 23.0
tmbf/processor/global/DLY_DAC_FINE_DELAY_S->min_value: 0.0
tmbf/processor/global/DLY_DAC_HALF_STEP_S->description: "DAC clock half step control"
tmbf/processor/global/DLY_DAC_HALF_STEP_S->EnumLabels: 0,\ 
                                                       -0.5
tmbf/processor/global/DLY_DAC_RESET_S->description: "Reset coarse delay"
tmbf/processor/global/DLY_DAC_STEP_S->description: "Advance coarse delay"
tmbf/processor/global/DLY_STEP_SIZE->description: "Duration of coarse step"
tmbf/processor/global/DLY_STEP_SIZE->unit: ps
tmbf/processor/global/DLY_TURN_DELAY_PS->unit: ps
tmbf/processor/global/DLY_TURN_DELAY_S->description: "Turn clock input delay"
tmbf/processor/global/DLY_TURN_DELAY_S->format: %2d
tmbf/processor/global/DLY_TURN_DELAY_S->max_value: 31.0
tmbf/processor/global/DLY_TURN_DELAY_S->min_value: 0.0
tmbf/processor/global/DLY_TURN_ERRORS->archive_abs_change: -1,\ 
                                                           1
tmbf/processor/global/DLY_TURN_ERRORS->archive_period: 3600000
tmbf/processor/global/DLY_TURN_ERRORS->description: "Turn clock errors"
tmbf/processor/global/DLY_TURN_OFFSET_S->description: "Turn clock offset"
tmbf/processor/global/DLY_TURN_OFFSET_S->format: %3d
tmbf/processor/global/DLY_TURN_POLL_S->description: "Update turn status"
tmbf/processor/global/DLY_TURN_RATE->description: "Clock error rate"
tmbf/processor/global/DLY_TURN_RATE->format: %.3f
tmbf/processor/global/DLY_TURN_STATUS->description: "Turn clock status"
tmbf/processor/global/DLY_TURN_STATUS->EnumLabels: Armed,\ 
                                                   Synced,\ 
                                                   "Sync Errors"
tmbf/processor/global/DLY_TURN_SYNC_S->description: "Synchronise turn clock"
tmbf/processor/global/DLY_TURN_TURNS->description: "Turns sampled"
tmbf/processor/global/DRIVER_VERSION->description: "Kernel driver version"
tmbf/processor/global/FIR_EVENTS_S->description: "FIR event detect scan"
tmbf/processor/global/FPGA_GIT_VERSION->archive_period: 86400000
tmbf/processor/global/FPGA_GIT_VERSION->description: "Firmware git version"
tmbf/processor/global/FPGA_VERSION->description: "Firmware version"
tmbf/processor/global/GIT_VERSION->archive_period: 86400000
tmbf/processor/global/GIT_VERSION->description: "Software git version"
tmbf/processor/global/HOSTNAME->description: "Host name of MBF IOC"
tmbf/processor/global/INFO_ADC_TAPS->description: "Length of ADC compensation filter"
tmbf/processor/global/INFO_DAC_TAPS->description: "Length of DAC pre-emphasis filter"
tmbf/processor/global/MEM_BUSY->description: "Capture status"
tmbf/processor/global/MEM_BUSY->EnumLabels: Ready,\ 
                                            Busy
tmbf/processor/global/MEM_CAPTURE_S->description: "Untriggered immediate capture"
tmbf/processor/global/MEM_FIR0_GAIN_S->description: "FIR 0 capture gain"
tmbf/processor/global/MEM_FIR0_GAIN_S->EnumLabels: +54dB,\ 
                                                   0dB
tmbf/processor/global/MEM_FIR0_OVF->description: "FIR 0 capture will overflow"
tmbf/processor/global/MEM_FIR0_OVF->EnumLabels: Ok,\ 
                                                Overflow
tmbf/processor/global/MEM_FIR1_GAIN_S->description: "FIR 1 capture gain"
tmbf/processor/global/MEM_FIR1_GAIN_S->EnumLabels: +54dB,\ 
                                                   0dB
tmbf/processor/global/MEM_FIR1_OVF->description: "FIR 1 capture will overflow"
tmbf/processor/global/MEM_FIR1_OVF->EnumLabels: Ok,\ 
                                                Overflow
tmbf/processor/global/MEM_OFFSET_S->description: "Offset of readout"
tmbf/processor/global/MEM_OFFSET_S->max_value: 5.36870911E8
tmbf/processor/global/MEM_OFFSET_S->min_value: -5.36870912E8
tmbf/processor/global/MEM_OFFSET_S->unit: turns
tmbf/processor/global/MEM_READOUT_DONE_S->description: "READOUT processing done"
tmbf/processor/global/MEM_READOUT_TRIG->description: "READOUT processing trigger"
tmbf/processor/global/MEM_READ_OVF_S->description: "Poll overflow events"
tmbf/processor/global/MEM_RUNOUT_S->description: "Post trigger capture count"
tmbf/processor/global/MEM_RUNOUT_S->EnumLabels: 12.5%,\ 
                                                25%,\ 
                                                50%,\ 
                                                75%,\ 
                                                99.5%
tmbf/processor/global/MEM_SEL0_S->description: "Channel 0 capture selection"
tmbf/processor/global/MEM_SEL0_S->EnumLabels: ADC0,\ 
                                              FIR0,\ 
                                              DAC0,\ 
                                              ADC1,\ 
                                              FIR1,\ 
                                              DAC1
tmbf/processor/global/MEM_SEL1_S->description: "Channel 1 capture selection"
tmbf/processor/global/MEM_SEL1_S->EnumLabels: ADC0,\ 
                                              FIR0,\ 
                                              DAC0,\ 
                                              ADC1,\ 
                                              FIR1,\ 
                                              DAC1
tmbf/processor/global/MEM_SELECT_S->description: "Control memory capture selection"
tmbf/processor/global/MEM_SELECT_S->EnumLabels: "ADC0/ADC1",\ 
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
tmbf/processor/global/MEM_WF0->description: "Capture waveform #0"
tmbf/processor/global/MEM_WF1->description: "Capture waveform #1"
tmbf/processor/global/MEM_WRITE_GAIN_S->description: "Write FIR gain"
tmbf/processor/global/MODE->description: "Operational mode"
tmbf/processor/global/MODE->EnumLabels: TMBF,\ 
                                        LMBF
tmbf/processor/global/PLL_CTRL_START_S->description: "Start tune PLL"
tmbf/processor/global/PLL_CTRL_STOP_S->description: "Stop tune PLL"
tmbf/processor/global/SOCKET->description: "Socket number for data server"
tmbf/processor/global/STA_CLOCK->description: "ADC clock status"
tmbf/processor/global/STA_CLOCK->EnumLabels: Unlocked,\ 
                                             Locked
tmbf/processor/global/STA_POLL_S->description: "Poll system status"
tmbf/processor/global/STA_VCO->description: "VCO clock status"
tmbf/processor/global/STA_VCO->EnumLabels: Unlocked,\ 
                                           Locked,\ 
                                           Passthrough
tmbf/processor/global/STA_VCXO->archive_abs_change: -1,\ 
                                                    1
tmbf/processor/global/STA_VCXO->archive_period: 3600000
tmbf/processor/global/STA_VCXO->description: "VCXO clock status"
tmbf/processor/global/STA_VCXO->EnumLabels: Unlocked,\ 
                                            Locked,\ 
                                            Passthrough
tmbf/processor/global/TRG_ADC0_IN->description: "Y ADC event input"
tmbf/processor/global/TRG_ADC0_IN->EnumLabels: No,\ 
                                               Yes
tmbf/processor/global/TRG_ADC1_IN->description: "X ADC event input"
tmbf/processor/global/TRG_ADC1_IN->EnumLabels: No,\ 
                                               Yes
tmbf/processor/global/TRG_ARM_S->description: "Arm all shared targets"
tmbf/processor/global/TRG_BLANKING_S->description: "Blanking duration"
tmbf/processor/global/TRG_BLANKING_S->format: %5d
tmbf/processor/global/TRG_BLANKING_S->max_value: 65535.0
tmbf/processor/global/TRG_BLANKING_S->min_value: 0.0
tmbf/processor/global/TRG_BLANKING_S->unit: turns
tmbf/processor/global/TRG_BLNK_IN->description: "Blanking event"
tmbf/processor/global/TRG_BLNK_IN->EnumLabels: No,\ 
                                               Yes
tmbf/processor/global/TRG_DISARM_S->description: "Disarm all shared targets"
tmbf/processor/global/TRG_EXT_IN->description: "External trigger input"
tmbf/processor/global/TRG_EXT_IN->EnumLabels: No,\ 
                                              Yes
tmbf/processor/global/TRG_IN_S->description: "Scan input events"
tmbf/processor/global/TRG_MEM_ADC0_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_ADC0_BL_S->EnumLabels: All,\ 
                                                     Blanking
tmbf/processor/global/TRG_MEM_ADC0_EN_S->description: "Enable Y ADC event input"
tmbf/processor/global/TRG_MEM_ADC0_EN_S->EnumLabels: Ignore,\ 
                                                     Enable
tmbf/processor/global/TRG_MEM_ADC0_HIT->description: "Y ADC event source"
tmbf/processor/global/TRG_MEM_ADC0_HIT->EnumLabels: No,\ 
                                                    Yes
tmbf/processor/global/TRG_MEM_ADC1_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_ADC1_BL_S->EnumLabels: All,\ 
                                                     Blanking
tmbf/processor/global/TRG_MEM_ADC1_EN_S->description: "Enable X ADC event input"
tmbf/processor/global/TRG_MEM_ADC1_EN_S->EnumLabels: Ignore,\ 
                                                     Enable
tmbf/processor/global/TRG_MEM_ADC1_HIT->description: "X ADC event source"
tmbf/processor/global/TRG_MEM_ADC1_HIT->EnumLabels: No,\ 
                                                    Yes
tmbf/processor/global/TRG_MEM_ARM_S->description: "Arm trigger"
tmbf/processor/global/TRG_MEM_BL_S->description: "Write blanking"
tmbf/processor/global/TRG_MEM_DELAY_S->description: "Trigger delay"
tmbf/processor/global/TRG_MEM_DELAY_S->format: %5d
tmbf/processor/global/TRG_MEM_DELAY_S->max_value: 65535.0
tmbf/processor/global/TRG_MEM_DELAY_S->min_value: 0.0
tmbf/processor/global/TRG_MEM_DISARM_S->description: "Disarm trigger"
tmbf/processor/global/TRG_MEM_EN_S->description: "Write enables"
tmbf/processor/global/TRG_MEM_EXT_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_EXT_BL_S->EnumLabels: All,\ 
                                                    Blanking
tmbf/processor/global/TRG_MEM_EXT_EN_S->description: "Enable External trigger input"
tmbf/processor/global/TRG_MEM_EXT_EN_S->EnumLabels: Ignore,\ 
                                                    Enable
tmbf/processor/global/TRG_MEM_EXT_HIT->description: "External trigger source"
tmbf/processor/global/TRG_MEM_EXT_HIT->EnumLabels: No,\ 
                                                   Yes
tmbf/processor/global/TRG_MEM_HIT->description: "Update source events"
tmbf/processor/global/TRG_MEM_MODE_S->description: "Arming mode"
tmbf/processor/global/TRG_MEM_MODE_S->EnumLabels: "One Shot",\ 
                                                  Rearm,\ 
                                                  Shared
tmbf/processor/global/TRG_MEM_PM_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_PM_BL_S->EnumLabels: All,\ 
                                                   Blanking
tmbf/processor/global/TRG_MEM_PM_EN_S->description: "Enable Postmortem trigger input"
tmbf/processor/global/TRG_MEM_PM_EN_S->EnumLabels: Ignore,\ 
                                                   Enable
tmbf/processor/global/TRG_MEM_PM_HIT->description: "Postmortem trigger source"
tmbf/processor/global/TRG_MEM_PM_HIT->EnumLabels: No,\ 
                                                  Yes
tmbf/processor/global/TRG_MEM_SEQ0_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_SEQ0_BL_S->EnumLabels: All,\ 
                                                     Blanking
tmbf/processor/global/TRG_MEM_SEQ0_EN_S->description: "Enable Y SEQ event input"
tmbf/processor/global/TRG_MEM_SEQ0_EN_S->EnumLabels: Ignore,\ 
                                                     Enable
tmbf/processor/global/TRG_MEM_SEQ0_HIT->description: "Y SEQ event source"
tmbf/processor/global/TRG_MEM_SEQ0_HIT->EnumLabels: No,\ 
                                                    Yes
tmbf/processor/global/TRG_MEM_SEQ1_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_SEQ1_BL_S->EnumLabels: All,\ 
                                                     Blanking
tmbf/processor/global/TRG_MEM_SEQ1_EN_S->description: "Enable X SEQ event input"
tmbf/processor/global/TRG_MEM_SEQ1_EN_S->EnumLabels: Ignore,\ 
                                                     Enable
tmbf/processor/global/TRG_MEM_SEQ1_HIT->description: "X SEQ event source"
tmbf/processor/global/TRG_MEM_SEQ1_HIT->EnumLabels: No,\ 
                                                    Yes
tmbf/processor/global/TRG_MEM_SOFT_BL_S->description: "Enable blanking for trigger source"
tmbf/processor/global/TRG_MEM_SOFT_BL_S->EnumLabels: All,\ 
                                                     Blanking
tmbf/processor/global/TRG_MEM_SOFT_EN_S->description: "Enable Soft trigger input"
tmbf/processor/global/TRG_MEM_SOFT_EN_S->EnumLabels: Ignore,\ 
                                                     Enable
tmbf/processor/global/TRG_MEM_SOFT_HIT->description: "Soft trigger source"
tmbf/processor/global/TRG_MEM_SOFT_HIT->EnumLabels: No,\ 
                                                    Yes
tmbf/processor/global/TRG_MEM_STATUS->description: "Trigger target status"
tmbf/processor/global/TRG_MEM_STATUS->EnumLabels: Idle,\ 
                                                  Armed,\ 
                                                  Busy,\ 
                                                  Locked
tmbf/processor/global/TRG_MODE_S->description: "Shared trigger mode"
tmbf/processor/global/TRG_MODE_S->EnumLabels: "One Shot",\ 
                                              Rearm
tmbf/processor/global/TRG_PM_IN->description: "Postmortem trigger input"
tmbf/processor/global/TRG_PM_IN->EnumLabels: No,\ 
                                             Yes
tmbf/processor/global/TRG_SEQ0_IN->description: "Y SEQ event input"
tmbf/processor/global/TRG_SEQ0_IN->EnumLabels: No,\ 
                                               Yes
tmbf/processor/global/TRG_SEQ1_IN->description: "X SEQ event input"
tmbf/processor/global/TRG_SEQ1_IN->EnumLabels: No,\ 
                                               Yes
tmbf/processor/global/TRG_SHARED->description: "List of shared targets"
tmbf/processor/global/TRG_SOFT_CMD->description: "Soft trigger"
tmbf/processor/global/TRG_SOFT_IN->description: "Soft trigger input"
tmbf/processor/global/TRG_SOFT_IN->EnumLabels: No,\ 
                                               Yes
tmbf/processor/global/TRG_SOFT_S->description: "Soft trigger"
tmbf/processor/global/TRG_SOFT_S->EnumLabels: Passive,\ 
                                              Event,\ 
                                              "I/O Intr",\ 
                                              "10 s",\ 
                                              "5 s",\ 
                                              "2 s",\ 
                                              "1 s",\ 
                                              "500 ms",\ 
                                              "200 ms",\ 
                                              "100 ms"
tmbf/processor/global/TRG_STATUS->description: "Shared trigger target status"
tmbf/processor/global/TRG_STATUS->EnumLabels: Idle,\ 
                                              Armed,\ 
                                              Locked,\ 
                                              Busy,\ 
                                              Mixed,\ 
                                              Invalid
tmbf/processor/global/VERSION->description: "Software version"

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



# --- dserver/Tango2Epics/tmbf-global properties

dserver/Tango2Epics/tmbf-global->polling_threads_pool_conf: "tmbf/processor/global"
