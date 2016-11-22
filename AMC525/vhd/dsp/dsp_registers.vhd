-- Registers mapping for top level DSP control.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity dsp_registers is
    port (
        dsp_clk_i : in std_logic;

        -- DSP general control registers
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        -- Processed registers
        strobed_bits_o : out reg_data_t;    -- Single clock control events
        status_bits_i : in reg_data_t;      -- General purpose read register
        pulsed_bits_i : in reg_data_t       -- Captured single clock events
    );
end;

architecture dsp_registers of dsp_registers is
    -- Register map:
    --  0       W   Strobed bits
    --  0       R   General status bits
    --  1       RW  Latched pulsed events
    constant STROBE_REG_W : natural := 0;
    constant STATUS_REG_R : natural := 0;
    constant PULSED_REG : natural := 1;

begin
    -- Strobed bits for single clock control
    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(STROBE_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(STROBE_REG_W),
        strobed_bits_o => strobed_bits_o
    );

    -- Miscellaneous status bits etc
    read_data_o(STATUS_REG_R) <= status_bits_i;
    read_ack_o(STATUS_REG_R) <= '1';

    -- Capture of single clock events
    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(PULSED_REG),
        read_strobe_i => read_strobe_i(PULSED_REG),
        read_data_o => read_data_o(PULSED_REG),
        read_ack_o => read_ack_o(PULSED_REG),

        pulsed_bits_i => pulsed_bits_i
    );
end;
