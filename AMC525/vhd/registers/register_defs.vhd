-- Definitions for registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

package register_defs is
    -- The control register address space consists of 16384 32-bit words
    -- organised into four active banks with the following addressing:
    --
    --  Address         Alias   Controlled bank
    --  =============== ======= ============================================
    --  0x0000..0x0FFF  SYS     System registers: top level hardware control
    --  0x2000..0x27FF  CTRL    DSP master control
    --  0x2800..0x2FFF          (unused)
    --  0x3000..0x37FF  DSP0    DSP 0 control
    --  0x3800..0x3FFF  DSP1    DSP 1 control
    --
    -- The active registers in each bank are identified and named below.

    -- System registers
    -- These occupy addresses 0x0000..0x0FFF
    -- Used for top level hardware management
    subtype SYS_REGS_RANGE is natural range 0 to 7;
        constant SYS_VERSION_REG : natural := 0;
        -- R   1       Status register
        -- R   1[0]        Set if DSP clock is currently good
        -- R   1[1]        Set during capture to DDR0
        -- R   1[2]        FMC500 VCXO power ok
        -- R   1[3]        FMC500 ADC power ok
        -- R   1[4]        FMC500 DAC power ok
        -- R   1[5]        FMC500 PLL status LD1: VCXO locked
        -- R   1[6]        FMC500 PLL status LD2: VCO locked
        -- R   1[7]        FMC500 DAC interrupt request
        -- R   1[8]        FMC500 temperature alert
        constant SYS_STATUS_REG : natural := 1;
        -- RW  2       Control register
        -- RW  2[3]        FMC500 PLL clkin sel0
        -- RW  2[4]        FMC500 PLL clkin sel1
        -- RW  2[5]        FMC500 PLL sync
        -- RW  2[6]        ADC power down (leave at 0 for normal operation)
        -- RW  2[7]        DAC reset (leave at 0 for normal operation)
        -- RW  2[8]        Enable DAC test data generation
        constant SYS_CONTROL_REG : natural := 2;
        -- RW  3       ADC DCO IDELAY control
        -- W   3[4:0]      IDELAY value
        -- W   3[8]        Enable write to IDELAY, so write number of form 0x1xx
        -- W   3[12]       Enable increment or decrement of IDELAY
        -- W   3[13]       Increment if 1, decrement if 0
        -- W   3[31]       Force reset of ADC PLL
        -- R   3[4:0]      Current IDELAY setting
        -- R   3[31]       Set if ADC PLL not locked
        constant SYS_ADC_IDELAY_REG : natural := 3;
        -- RW  4       FMC500 SPI control
        constant SYS_FMC_SPI_REG : natural := 4;
        -- RW  5,6     DAC test data pattern
        subtype SYS_DAC_TEST_REGS is natural range 5 to 6;
        -- RW  7       Revolution clock IDELAY control
        -- W   7[4:0]      IDELAY value
        -- W   7[8]        Enable write to IDELAY, so write number of form 0x1xx
        -- W   7[12]       Enable increment or decrement of IDELAY
        -- W   7[13]       Increment if 1, decrement if 0
        -- R   7[4:0]      Current IDELAY setting
        constant SYS_REV_IDELAY_REG : natural := 7;

    -- Control registers
    -- These occupy addresses 0x2000..02x7FF
    -- Used for shared DSP control
    subtype CTRL_REGS_RANGE is natural range 0 to 15;
        -- RW  0   Captures single clock pulsed events.  Write a bit pattern
        --         to reset those bits and latch the current state.
        -- RW  0[0]        Set if DRAM0 data error detected
        -- RW  0[1]        Set if DRAM0 address error detected
        -- RW  0[2]        Set if DRAM0 write error detected
        -- RW  0[3]        Set if DRAM1 write error detected
        constant CTRL_PULSED_REG : natural := 0;
        -- RW  1   Miscellaneous control
        -- RW  1[0]    ADC mux: if set channel 0 has copy of channel 1 ADC
        -- RW  1[1]    NCO0 mux: if set channel 0 has sin data from channel 1
        -- RW  1[2]    NCO1 mux: if set channel 0 has sin data from channel 1
        constant CTRL_CONTROL_REG : natural := 1;
        subtype CTRL_MEM_REGS is natural range 2 to 5;
            -- Control and readout registers
            subtype CTRL_MEM_CONFIG_REGS is natural range 2 to 3;
                constant CTRL_MEM_CONFIG_REG : natural := 2;
                constant CTRL_MEM_COUNT_REG : natural := 3;
            -- Overlay pulse command and address readback registers
            constant CTRL_MEM_COMMAND_REG_W : natural := 4;
            constant CTRL_MEM_ADDRESS_REG_R : natural := 4;
            constant CTRL_MEM_STATUS_REG : natural := 5;
        subtype CTRL_TRIGGER_REGS is natural range 6 to 15;
            -- W   6       Pulsed trigger control events
            --     6[0]        Start turn clock synchronisation
            --     6[1]        Request turn clock sample
            --     6[2]        Arm sequencer 0 trigger
            --     6[3]        Disarm sequencer 0 trigger
            --     6[4]        Arm sequencer 1 trigger
            --     6[5]        Disarm sequencer 1 trigger
            --     6[6]        Arm DRAM0 trigger
            --     6[7]        Disarm DRAM0 trigger
            --     6[8]        Generate soft trigger event
            constant CTRL_TRG_CONTROL_REG_W : natural := 6;
            -- R   6       Capture trigger events
            --     6[0]        Soft trigger
            --     6[1]        External event trigger
            --     6[2]        Postmortem trigger
            --     6[3]        ADC 0 motion trigger
            --     6[4]        ADC 1 motion trigger
            --     6[5]        State 0 trigger
            --     6[6]        State 1 trigger
            constant CTRL_TRG_PULSED_REG_R : natural := 6;
            subtype CTRL_TRG_READBACK_REGS is natural range 7 to 8;
                -- R   7       Trigger status readbacks
                --     7[0]        Start clock synchronisation busy
                --     7[1]        ADC clock phase after turn synchronisation
                --     7[2]        Synchronisation error detected
                --     7[3]        Waiting for turn clock sample
                --     7[4]        ADC clock phase after sample
                --     7[5]        Sequencer 0 trigger armed
                --     7[6]        Sequencer 1 trigger armed
                --     7[7]        DRAM0 trigger armed
                --     7[25:16]    Turn clock counter captured by sample
                constant CTRL_TRG_READBACK_REG_STATUS : natural := 7;
                -- R   8       Trigger event sources.
                --     8[6:0]      Sequencer 0 trigger source mask
                --     8[14:8]     Sequencer 1 trigger source mask
                --     8[22:16]    DRAM0 trigger source mask
                constant CTRL_TRG_READBACK_REG_SOURCES : natural := 8;
            subtype CTRL_TRG_CONFIG_REGS is natural range 9 to 15;
                -- RW  9       Turn clock configuration setup
                --     9[9:0]      Maximum bunch count
                --     9[19:10]    DSP 0 turn clock offset
                --     9[29:20]    DSP 1 turn clock offset
                constant CTRL_TRG_CONFIG_REG_TURN_SETUP : natural := 9;
                -- RW  10      Blanking windows
                --     10[15:0]    DSP 0 blanking window (in turns)
                --     10[31:16]   DSP 1 blanking window (in turns)
                constant CTRL_TRG_CONFIG_REG_BLANKING : natural := 10;
                -- RW  11[23:0]    Sequencer 0 trigger delay
                constant CTRL_TRG_CONFIG_REG_DELAY_SEQ_0 : natural := 11;
                -- RW  12[23:0]    Sequencer 1 trigger delay
                constant CTRL_TRG_CONFIG_REG_DELAY_SEQ_1 : natural := 12;
                -- RW  13[23:0]    DRAM0 trigger delay
                constant CTRL_TRG_CONFIG_REG_DELAY_DRAM : natural := 13;
                -- RW  14      Sequencer trigger configuration
                --     14[6:0]     Sequencer 0 trigger enable mask
                --     14[14:8]    Sequencer 0 blanking enable mask
                --     14[22:16]   Sequencer 1 trigger enable mask
                --     14[30:24]   Sequencer 1 blanking enable mask
                constant CTRL_TRG_CONFIG_REG_TRIG_SEQ : natural := 14;
                -- RW  15      DRAM0 trigger configuration
                --     15[6:0]     DRAM trigger enable mask
                --     15[14:8]    DRAM blanking enable mask
                --     15[16]      DRAM turn clock selection
                --     15[18:17]   DRAM blanking pulse selection mask
                constant CTRL_TRG_CONFIG_REG_TRIG_DRAM : natural := 15;

    -- DSP registers
    -- These occupy addresses 0x3000..0x37FF and 0x3800..3FFF
    -- Used for channel specific DSP control
    subtype DSP_REGS_RANGE is natural range 0 to 15;
        subtype DSP_GENERAL_REGS is natural range 0 to 1;
            --  0       W   Strobed bits
            --  0       R   General status bits
            --  1       RW  Latched pulsed events
            constant DSP_STROBE_REG_W : natural := 0;
            constant DSP_STATUS_REG_R : natural := 0;
            constant DSP_PULSED_REG : natural := 1;
        subtype DSP_ADC_REGS is natural range 2 to 3;
            --  2   R   31:0    Read MMS count and switch banks
            --  3   R   31:0    Read and reset MMS bunch entries
            --  2   W   13:0    Configure data input limit
            --  2   W   15      Configure ADC fine delay
            --  2   W   31:16   Configure MMS event limit
            --  3   W   31:7    Write FIR taps
            subtype DSP_ADC_MMS_REGS_R is natural range 2 to 3;
            constant DSP_ADC_LIMIT_REG_W : natural := 2;
            constant DSP_ADC_TAPS_REG_W : natural := 3;
        subtype DSP_BUNCH_REGS is natural range 4 to 5;
            --  4   W  1:0      Determines bunch bank to be written
            --  5   W           Configure selected bank
            constant DSP_BUNCH_CONFIG_REG : natural := 4;
            constant DSP_BUNCH_BANK_REG_W : natural := 5;
        constant DSP_SLOW_MEM_REG : natural := 6;
        subtype DSP_B_FIR_REGS is natural range 7 to 8;
            constant DSP_FIR_CONFIG_REG : natural := 7;
            constant DSP_FIR_TAPS_REG : natural := 8;
        subtype DSP_DAC_REGS is natural range 9 to 10;
            --  9   R   31:0    Read MMS count and switch banks
            --  9   W   9:0     Configure DAC output delay
            --  9   W  105:12   NCO 0 gain
            --  9   W  109:16   NCO 1 gain
            --  9   W   24:20   FIR gain
            --  9   W   25      FIR enable
            --  9   W   26      NCO 0 enable
            --  9   W   27      NCO10 enable
            -- 10   R   31:9    Read and reset MMS bunch entries
            -- 10   W   31:7    Write FIR taps
            subtype DSP_DAC_MMS_REGS_R is natural range 9 to 10;
            constant DSP_DAC_CONFIG_REG_W : natural := 9;
            constant DSP_DAC_TAPS_REG_W : natural := 10;
        subtype DSP_SEQ_REGS is natural range 11 to 13;
            -- 11   W   0       Abort sequencer if running
            -- 11   W   1       Initiate block memory write sequence
            constant DSP_SEQ_COMMAND_W : natural := 11;
            -- 11   R   2:0     Current sequencer program counter
            -- 11   R   4       Set if sequencer busy
            -- 11   R   17:8    Current super sequencer state
            constant DSP_SEQ_STATUS_R : natural := 11;
            -- 12   RW  2:0     Target sequencer program counter
            -- 12   RW  6:4     Sequencer state to generate event
            -- 12   RW  17:8    Target super sequencer state
            -- 12   RW  29:28   Block memory to write
            --                  0 => sequencer program memory
            --                  1 => detector window memory
            --                  2 => super sequencer memory
            constant DSP_SEQ_CONFIG : natural := 12;
            constant DSP_SEQ_WRITE : natural := 13;
        subtype DSP_HACK_REGS is natural range 14 to 15;
            constant DSP_HACK_REG0 : natural := 14;
            constant DSP_HACK_REG1 : natural := 15;
end;
