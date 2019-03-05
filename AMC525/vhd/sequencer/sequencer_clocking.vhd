-- Transfers between ADC and DSP clocking domains for those signals that need
-- special handling

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity sequencer_clocking is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        turn_clock_adc_i : in std_ulogic;
        turn_clock_dsp_o : out std_ulogic;

        seq_start_dsp_i : in std_ulogic;
        seq_start_adc_o : out std_ulogic;

        seq_write_dsp_i : in std_ulogic;
        seq_write_adc_o : out std_ulogic;

        hom_gain_dsp_i : in unsigned;
        hom_enable_dsp_i : in std_ulogic;
        hom_gain_adc_o : out unsigned;
        hom_enable_adc_o : out std_ulogic;

        hom_window_dsp_i : in signed;
        hom_window_adc_o : out signed;

        bunch_bank_i : in unsigned;
        bunch_bank_o : out unsigned
    );
end;

architecture arch of sequencer_clocking is
    signal bunch_bank : bunch_bank_o'SUBTYPE;
    signal turn_clock_adc : std_ulogic;

    -- Local declarations just so we can assign default values of zero
    signal hom_gain_adc_out : hom_gain_adc_o'SUBTYPE := (others => '0');
    signal hom_enable_adc_out : hom_enable_adc_o'SUBTYPE := '0';
    signal hom_window_adc_out : hom_window_adc_o'SUBTYPE := (others => '0');
    signal bunch_bank_out : bunch_bank_o'SUBTYPE := (others => '0');

begin
    -- Delay line on bunch bank to relax timing before clock domain crossing
    bank_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => bunch_bank_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(bunch_bank_i),
        unsigned(data_o) => bunch_bank
    );

    -- Delay line on turn clock
    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock_adc_i,
        data_o(0) => turn_clock_adc
    );

    turn_clock : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => turn_clock_adc,
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
            hom_gain_adc_out <= hom_gain_dsp_i;
            hom_enable_adc_out <= hom_enable_dsp_i;
            hom_window_adc_out <= hom_window_dsp_i;
            bunch_bank_out <= bunch_bank;
        end if;
    end process;
    hom_gain_adc_o <= hom_gain_adc_out;
    hom_enable_adc_o <= hom_enable_adc_out;
    hom_window_adc_o <= hom_window_adc_out;
    bunch_bank_o <= bunch_bank_out;
end;
