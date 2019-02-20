-- Supports Tune PLL readback

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.detector_defs.all;

entity tune_pll_readout is
    generic (
        READOUT_IIR_SHIFT : unsigned;
        READOUT_IIR_CLOCK_BITS : natural
    );
    port (
        clk_i : in std_ulogic;

        -- Detector output
        detector_done_i : in std_ulogic;
        iq_i : in cos_sin_32_t;
        filtered_iq_o : out cos_sin_32_t;

        -- CORDIC output
        cordic_done_i : in std_ulogic;
        phase_i : in signed;
        magnitude_i : in unsigned;
        filtered_phase_o : out signed;
        filtered_magnitude_o : out signed;

        -- Feedback output
        feedback_done_i : in std_ulogic;
        frequency_offset_i : in signed;
        filtered_frequency_offset_o : out signed
    );
end;

architecture arch of tune_pll_readout is
    signal iir_clock_counter :
        unsigned(READOUT_IIR_CLOCK_BITS-1 downto 0) := (others => '0');
    signal iir_clock : std_ulogic := '0';

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            iir_clock_counter <= iir_clock_counter + 1;
            iir_clock <= to_std_ulogic(iir_clock_counter = 0);
        end if;
    end process;


    -- Simple filters for the direct readbacks

    cos_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => iq_i.cos,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_iq_o.cos,
        done_o => open
    );

    sin_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => iq_i.sin,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_iq_o.sin,
        done_o => open
    );

    magnitude_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => signed('0' & magnitude_i(31 downto 1)),
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_magnitude_o,
        done_o => open
    );

    phase_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => phase_i,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_phase_o,
        done_o => open
    );

    offset_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => frequency_offset_i,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_frequency_offset_o,
        done_o => open
    );


end;
