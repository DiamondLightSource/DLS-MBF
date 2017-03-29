-- Registers mapping for top level DSP control.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;

entity dsp_registers is
    port (
        dsp_clk_i : in std_logic;

        -- DSP general control registers
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Processed registers
        strobed_bits_o : out reg_data_t;    -- Single clock control events
        status_bits_i : in reg_data_t;      -- General purpose read register
        pulsed_bits_i : in reg_data_t       -- Captured single clock events
    );
end;

architecture arch of dsp_registers is
begin
    -- Strobed bits for single clock control
    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_GENERAL_STROBE_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_GENERAL_STROBE_REG_W),
        strobed_bits_o => strobed_bits_o
    );

    -- Miscellaneous status bits etc
    read_data_o(DSP_GENERAL_STATUS_REG_R) <= status_bits_i;
    read_ack_o(DSP_GENERAL_STATUS_REG_R) <= '1';

    -- Capture of single clock events
    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_GENERAL_PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_GENERAL_PULSED_REG),
        read_strobe_i => read_strobe_i(DSP_GENERAL_PULSED_REG),
        read_data_o => read_data_o(DSP_GENERAL_PULSED_REG),
        read_ack_o => read_ack_o(DSP_GENERAL_PULSED_REG),

        pulsed_bits_i => pulsed_bits_i
    );
end;
