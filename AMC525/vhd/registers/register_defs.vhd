-- Definitions for registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

package register_defs is
--     -- Register data is in blocks of 32-bits
--     constant REG_DATA_WIDTH : natural := 32;
--     subtype reg_data_t is std_logic_vector(REG_DATA_WIDTH-1 downto 0);
--     type reg_data_array_t is array(natural range <>) of reg_data_t;

    -- System registers
    -- These occupy addresses 0x0000..0x0FFF
    -- Used for top level hardware management
    subtype SYS_REGS_RANGE is natural range 0 to 7;
        constant SYS_VERSION_REG : natural := 0;
        constant SYS_STATUS_REG : natural := 1;
        constant SYS_CONTROL_REG : natural := 2;
        constant SYS_ADC_IDELAY_REG : natural := 3;
        constant SYS_FMC_SPI_REG : natural := 4;
        subtype SYS_DAC_TEST_REGS is natural range 5 to 6;
        constant SYS_REV_IDELAY_REG : natural := 7;

    -- Control registers
    -- These occupy addresses 0x2000..02x7FF
    -- Used for shared DSP control
    subtype CTRL_REGS_RANGE is natural range 0 to 15;
        constant CTRL_PULSED_REG : natural := 0;
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
            constant CTRL_TRG_CONTROL_REG_W : natural := 6;
            constant CTRL_TRG_PULSED_REG_R : natural := 6;
            subtype CTRL_TRG_READBACK_REGS is natural range 7 to 8;
                constant CTRL_TRG_READBACK_REG_STATUS : natural := 7;
                constant CTRL_TRG_READBACK_REG_SOURCES : natural := 8;
            subtype CTRL_TRG_CONFIG_REGS is natural range 9 to 15;
                constant CTRL_TRG_CONFIG_REG_TURN_SETUP : natural := 9;
                constant CTRL_TRG_CONFIG_REG_BLANKING : natural := 10;
                constant CTRL_TRG_CONFIG_REG_DELAY_SEQ_0 : natural := 11;
                constant CTRL_TRG_CONFIG_REG_DELAY_SEQ_1 : natural := 12;
                constant CTRL_TRG_CONFIG_REG_DELAY_DRAM : natural := 13;
                constant CTRL_TRG_CONFIG_REG_TRIG_SEQ : natural := 14;
                constant CTRL_TRG_CONFIG_REG_TRIG_DRAM : natural := 15;

    -- DSP registers
    -- These occupy addresses 0x3000..0x37FF and 0x3800..3FFF
    -- Used for channel specific DSP control
    subtype DSP_REGS_RANGE is natural range 0 to 13;
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
            -- 10   R   31:9    Read and reset MMS bunch entries
            --  9   W   9:0     Configure DAC output delay
            --  9   W  105:12   NCO 0 gain
            --  9   W  109:16   NCO 1 gain
            --  9   W   24:20   FIR gain
            --  9   W   25      FIR enable
            --  9   W   26      NCO 0 enable
            --  9   W   27      NCO10 enable
            -- 10   W   31:7    Write FIR taps
            subtype DSP_DAC_MMS_REGS_R is natural range 9 to 10;
            constant DSP_DAC_CONFIG_REG_W : natural := 9;
            constant DSP_DAC_TAPS_REG_W : natural := 10;
        subtype DSP_HACK_REGS is natural range 11 to 13;


end;
