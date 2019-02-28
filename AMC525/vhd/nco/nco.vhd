-- Numerically Controlled Oscillator
--
-- Runs at ADC clock rate, generates both cosine and sine outputs, both scaled
-- and unscaled as appropriate.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco is
    generic (
        IN_DELAY : natural := 4;        -- Input pipeline
        OUT_DELAY : natural := 4        -- Output pipeline
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        phase_advance_i : in angle_t;
        reset_phase_i : in std_ulogic;
        cos_sin_o : out cos_sin_18_t  -- 18 bit unscaled cos/sin
    );
end;

architecture arch of nco is
    signal phase_advance : angle_t;
    signal reset_phase : std_ulogic;
    signal cos_sin : cos_sin_18_t;

begin
    phase_dly : entity work.dlyreg generic map (
        DLY => IN_DELAY,
        DW => phase_advance_i'LENGTH
    ) port map (
        clk_i => dsp_clk_i,
        data_i => std_ulogic_vector(phase_advance_i),
        unsigned(data_o) => phase_advance
    );


    reset_dly : entity work.dlyreg generic map (
        DLY => IN_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => reset_phase_i,
        data_o(0) => reset_phase
    );


    nco_core : entity work.nco_core port map (
        clk_i => adc_clk_i,
        phase_advance_i => phase_advance,
        reset_phase_i => reset_phase,
        cos_sin_o => cos_sin
    );


    cos_sin_dly : entity work.nco_delay generic map (
        DELAY => OUT_DELAY
    ) port map (
        clk_i => adc_clk_i,
        cos_sin_i => cos_sin,
        cos_sin_o => cos_sin_o
    );
end;
