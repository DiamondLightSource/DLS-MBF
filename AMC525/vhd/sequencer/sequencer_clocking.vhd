-- Transfers between ADC and DSP clocking domains for those signals that need
-- special handling

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity sequencer_clocking is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        turn_clock_adc_i : in std_logic;
        turn_clock_dsp_o : out std_logic;

        seq_start_dsp_i : in std_logic;
        seq_start_adc_o : out std_logic;

        seq_write_dsp_i : in std_logic;
        seq_write_adc_o : out std_logic;

        hom_gain_dsp_i : in unsigned;
        hom_gain_adc_o : out unsigned;

        hom_window_dsp_i : in signed;
        hom_window_adc_o : out signed
    );
end;

architecture arch of sequencer_clocking is
begin
    turn_clock : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => turn_clock_adc_i,
        pulse_o => turn_clock_dsp_o
    );

    seq_start : entity work.pulse_dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => seq_start_dsp_i,
        pulse_o => seq_start_adc_o
    );

    seq_write : entity work.pulse_dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => seq_write_dsp_i,
        pulse_o => seq_write_adc_o
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            hom_gain_adc_o <= hom_gain_dsp_i;
            hom_window_adc_o <= hom_window_dsp_i;
        end if;
    end process;
end;
