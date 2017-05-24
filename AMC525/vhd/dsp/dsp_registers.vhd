-- Registers mapping for top level DSP control.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;

entity dsp_registers is
    port (
        dsp_clk_i : in std_logic;

        -- DSP general control registers
        write_strobe_i : in std_logic_vector(DSP_MISC_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(DSP_MISC_REGS);
        read_strobe_i : in std_logic_vector(DSP_MISC_REGS);
        read_data_o : out reg_data_array_t(DSP_MISC_REGS);
        read_ack_o : out std_logic_vector(DSP_MISC_REGS);

        -- Processed registers
        strobed_bits_o : out reg_data_t;    -- Single clock control events
        pulsed_bits_i : in reg_data_t;      -- Captured single clock events
        nco_0_frequency_o : out angle_t
    );
end;

architecture arch of dsp_registers is
    signal nco0_frequency : reg_data_t;

begin
    -- Strobed bits for single clock control
    strobed_bits : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_MISC_STROBE_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_MISC_STROBE_REG_W),
        strobed_bits_o => strobed_bits_o
    );


    -- Capture of single clock events
    pulsed_bits : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(DSP_MISC_PULSED_REG_R),
        read_data_o => read_data_o(DSP_MISC_PULSED_REG_R),
        read_ack_o => read_ack_o(DSP_MISC_PULSED_REG_R),
        pulsed_bits_i => pulsed_bits_i
    );


    -- Fixed register
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_MISC_NCO0_FREQ_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_MISC_NCO0_FREQ_REG),
        register_data_o(0) => nco0_frequency
    );
    read_data_o(DSP_MISC_NCO0_FREQ_REG) <= nco0_frequency;
    read_ack_o(DSP_MISC_NCO0_FREQ_REG) <= '1';

    nco_0_frequency_o <= angle_t(nco0_frequency);
end;
