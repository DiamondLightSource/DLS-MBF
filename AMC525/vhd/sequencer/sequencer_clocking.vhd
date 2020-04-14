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

        detector_window_dsp_i : in signed;
        detector_window_adc_o : out signed;

        bunch_bank_i : in unsigned;
        bunch_bank_o : out unsigned
    );
end;

architecture arch of sequencer_clocking is
    signal turn_clock_adc : std_ulogic;

begin
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

    -- Simultaneously delay and reclock bunch_bank
    bank_delay : entity work.dlyline generic map (
        DLY => 2,
        DW => bunch_bank_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(bunch_bank_i),
        unsigned(data_o) => bunch_bank_o
    );

    -- Reclock the detector window
    window_delay : entity work.dlyline generic map (
        DLY => 1,
        DW => detector_window_dsp_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(detector_window_dsp_i),
        signed(data_o) => detector_window_adc_o
    );
end;
