-- Generates NCO output for sequencer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.dsp_defs.all;
use work.sequencer_defs.all;

entity sequencer_nco is
    generic (
        -- This is used to validate the processing delay, from configuration
        -- signals in, updated on turn_clock_i, to nco_data_o.  This delay is in
        -- DSP clock units.
        PROCESS_DELAY : natural
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        tune_pll_offset_i : in signed;
        enable_pll_i : in std_ulogic;
        nco_freq_i : in angle_t;
        reset_phase_i : in std_ulogic;
        nco_gain_i : in unsigned;

        nco_data_o : out dsp_nco_to_mux_t
    );
end;

architecture arch of sequencer_nco is
    signal nco_freq_in : angle_t;
    signal nco_freq : angle_t;
    signal reset_phase : std_ulogic;
    signal load_nco_gain : std_ulogic;
    signal nco_gain_out : nco_gain_t := (others => '0');

    -- Extra delay needed to align reset with frequency change.  This is needed
    -- to ensure that we correctly reset to phase 0 at the right time.
    constant PLL_OFFSET_DELAY : natural := 2;

    -- The following delays are needed to configure the sequencer so that the
    -- sweep output and other controls are aligned at the DAC output.
    --
    -- Delay from nco phase control to cos/sin output, validated by NCO core, in
    -- ADC clock units.
    constant NCO_PROCESS_DELAY : natural := 16;
    -- Delay settings for NCO
    constant NCO_IN_DELAY : natural := 1;       -- In DSP clocks
    constant NCO_OUT_DELAY : natural := 4;      -- In ADC clocks
    -- This is the delay needed on the NCO gain to align with NCO output, in
    -- DSP clock units.  We add 1 for the extra input nco_freq input register.
    constant NCO_GAIN_DELAY : natural :=
        NCO_PROCESS_DELAY/2 + NCO_IN_DELAY + NCO_OUT_DELAY/2 +
        PLL_OFFSET_DELAY + 1;

begin
    assert PROCESS_DELAY = NCO_GAIN_DELAY severity failure;

    -- Add offset to computed frequency if required
    add_offset : entity work.tune_pll_offset generic map (
        DELAY => PLL_OFFSET_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        freq_offset_i => tune_pll_offset_i,
        enable_i => enable_pll_i,
        freq_i => nco_freq_in,
        freq_o => nco_freq
    );

    -- Delay reset to align with frequency change
    delay_reset : entity work.dlyline generic map (
        DLY => PLL_OFFSET_DELAY + 1
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => reset_phase_i,
        data_o(0) => reset_phase
    );


    -- Swept NCO
    seq_nco : entity work.nco generic map (
        PROCESS_DELAY => NCO_PROCESS_DELAY,
        IN_DELAY => NCO_IN_DELAY,
        OUT_DELAY => NCO_OUT_DELAY
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        phase_advance_i => nco_freq,
        reset_phase_i => reset_phase,
        cos_sin_o => nco_data_o.nco
    );


    -- Delay gain to match NCO by delaying the turn clock instead.  Tricksy but
    -- saves some logic.
    gain_delay : entity work.dlyline generic map (
        DLY => NCO_GAIN_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => load_nco_gain
    );

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            nco_freq_in <= nco_freq_i;
            if load_nco_gain = '1' then
                nco_gain_out <= nco_gain_i;
            end if;
        end if;
    end process;
    nco_data_o.gain <= nco_gain_out;
end;
