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
    port (
        clk_i : in std_logic;

        phase_advance_i : in angle_t;
        reset_i : in std_logic;

        cos_sin_o : out cos_sin_18_t  -- 18 bit unscaled cos/sin
    );
end;

architecture nco of nco is
    constant IN_DELAY : natural := 4;
    constant OUT_DELAY : natural := 8;

    signal phase_advance : angle_t;
    signal reset : std_logic;
    signal cos_sin : cos_sin_18_t;

begin
    phase_dly : entity work.dlyreg generic map (
        DLY => IN_DELAY,
        DW => phase_advance_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(phase_advance_i),
        unsigned(data_o) => phase_advance
    );

    reset_dly : entity work.dlyreg generic map (
        DLY => IN_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => reset_i,
        data_o(0) => reset
    );


    nco_core : entity work.nco_core port map (
        clk_i => clk_i,
        phase_advance_i => phase_advance,
        reset_i => reset,
        cos_sin_o => cos_sin
    );


    cos_dly : entity work.dlyreg generic map (
        DLY => OUT_DELAY,
        DW => 18
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(cos_sin.cos),
        signed(data_o) => cos_sin_o.cos
    );

    sin_dly : entity work.dlyreg generic map (
        DLY => OUT_DELAY,
        DW => 18
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(cos_sin.sin),
        signed(data_o) => cos_sin_o.sin
    );
end;
