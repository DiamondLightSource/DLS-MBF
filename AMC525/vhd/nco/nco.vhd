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
    -- Delay from lookup valud to cos_sin_raw valid
    constant LOOKUP_DELAY : natural := 4;
    -- Delay from cos_sin_raw to cos_sin_refined
    constant REFINE_DELAY : natural := 3;

    signal phase_advance : angle_t;
    signal phase : angle_t;

    -- Lookup table
    signal lookup : lookup_t;
    signal cos_sin_raw : cos_sin_19_t;

    -- Refinement
    signal residue : residue_t;
    signal cos_sin_refined : cos_sin_18_t;
    signal cos_sin_out : cos_sin_18_t;

begin
    -- Delay line for phase advance
    phase_dly : entity work.dlyreg generic map (
        DLY => 4,
        DW => phase_advance_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(phase_advance_i),
        unsigned(data_o) => phase_advance
    );

    -- Phase advance computation for NCO
    nco_phase_inst : entity work.nco_phase port map (
        clk_i => clk_i,
        phase_advance_i => phase_advance,
        reset_i => reset_i,
        phase_o => phase
    );

    -- Split angle into octant, lookup and residue, and recombine the
    -- result according to the incoming octant.
    nco_cos_sin_inst : entity work.nco_cos_sin_octant generic map (
        LOOKUP_DELAY => LOOKUP_DELAY,
        REFINE_DELAY => REFINE_DELAY
    ) port map (
        clk_i => clk_i,
        angle_i => phase,

        lookup_o => lookup,
        residue_o => residue,

        cos_sin_i => cos_sin_refined,
        cos_sin_o => cos_sin_out
    );

    -- Lookup table
    nco_cos_sin_table_inst : entity work.nco_cos_sin_table generic map (
        LOOKUP_DELAY => LOOKUP_DELAY
    ) port map (
        clk_i => clk_i,
        addr_i => lookup,
        cos_sin_o => cos_sin_raw
    );

    -- Refine the lookup by linear interpolation
    refine_inst : entity work.nco_cos_sin_refine generic map (
        LOOKUP_DELAY => LOOKUP_DELAY,
        REFINE_DELAY => REFINE_DELAY
    ) port map (
        clk_i => clk_i,
        residue_i => residue,
        cos_sin_i => cos_sin_raw,
        cos_sin_o => cos_sin_refined
    );

    -- Delay line for NCO output
    cos_dly : entity work.dlyreg generic map (
        DLY => 4,
        DW => 18
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(cos_sin_out.cos),
        signed(data_o) => cos_sin_o.cos
    );
    sin_dly : entity work.dlyreg generic map (
        DLY => 4,
        DW => 18
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(cos_sin_out.sin),
        signed(data_o) => cos_sin_o.sin
    );
end;
