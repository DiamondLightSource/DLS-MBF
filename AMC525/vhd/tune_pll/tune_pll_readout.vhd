-- Supports Tune PLL readback

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.detector_defs.all;

entity tune_pll_readout is
    port (
        clk_i : in std_ulogic;

        -- Detector output
        detector_done_i : in std_ulogic;
        iq_i : in cos_sin_32_t;

        -- CORDIC output
        cordic_done_i : in std_ulogic;
        phase_i : in signed;
        magnitude_i : in unsigned;
        cordic_filter_shift_i : in unsigned;
        filtered_phase_o : out signed;
        filtered_magnitude_o : out signed;

        -- Feedback output
        feedback_done_i : in std_ulogic;
        frequency_offset_i : in signed;
        feedback_filter_shift_i : in unsigned;
        filtered_frequency_offset_o : out signed
    );
end;

architecture arch of tune_pll_readout is
    signal cordic_done : std_ulogic;

begin
    -- Delay cordic_done_i a trifle so that shift_i is valid.
    cordic_delay : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => clk_i,
        data_i(0) => cordic_done_i,
        data_o(0) => cordic_done
    );

    -- Simple filters for the direct readbacks
    magnitude_filter : entity work.one_pole_iir generic map (
        SHIFT_STEP => 2
    ) port map (
        clk_i => clk_i,
        data_i => signed('0' & magnitude_i(31 downto 1)),
        iir_shift_i => cordic_filter_shift_i,
        start_i => cordic_done,
        data_o => filtered_magnitude_o,
        done_o => open
    );

    phase_filter : entity work.one_pole_iir generic map (
        SHIFT_STEP => 2
    ) port map (
        clk_i => clk_i,
        data_i => phase_i,
        iir_shift_i => cordic_filter_shift_i,
        start_i => cordic_done,
        data_o => filtered_phase_o,
        done_o => open
    );

    offset_filter : entity work.one_pole_iir generic map (
        SHIFT_STEP => 2
    ) port map (
        clk_i => clk_i,
        data_i => frequency_offset_i,
        iir_shift_i => feedback_filter_shift_i,
        start_i => feedback_done_i,
        data_o => filtered_frequency_offset_o,
        done_o => open
    );


end;
