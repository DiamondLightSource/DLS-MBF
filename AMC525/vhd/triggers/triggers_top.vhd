-- Trigger handling and revolution clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity triggers_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector(0 to 3);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 3);
        read_strobe_i : in std_logic_vector(0 to 3);
        read_data_o : out reg_data_array_t(0 to 3);
        read_ack_o : out std_logic_vector(0 to 3);

        -- External trigger sources
        revolution_clock_i : in std_logic;
        event_trigger_i : in std_logic;
        postmortem_trigger_i : in std_logic;
        blanking_trigger_i : in std_logic;

        -- Internal trigger sources
        adc_trigger_i : in std_logic_vector(CHANNELS);
        seq_trigger_i : in std_logic_vector(CHANNELS);

        -- Trigger outputs
        turn_clock_o : out std_logic_vector(CHANNELS);
        seq_start_o : out std_logic_vector(CHANNELS);
        dram0_trigger_o : out std_logic
    );
end;

architecture triggers_top of triggers_top is
    subtype TURN_CLOCK_REGS is natural range 0 to 3;

begin
    turn_clock_inst : entity work.triggers_turn_clock port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        write_strobe_i => write_strobe_i(TURN_CLOCK_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(TURN_CLOCK_REGS),
        read_strobe_i => read_strobe_i(TURN_CLOCK_REGS),
        read_data_o => read_data_o(TURN_CLOCK_REGS),
        read_ack_o => read_ack_o(TURN_CLOCK_REGS),

        revolution_clock_i => revolution_clock_i,
        turn_clock_o => turn_clock_o
    );

    seq_start_o <= (others => '0');
    dram0_trigger_o <= '0';
end;
