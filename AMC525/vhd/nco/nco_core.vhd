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

entity nco_core is
    port (
        clk_i : in std_logic;
        phase_advance_i : in angle_t;
        cos_sin_o : out cos_sin_18_t  -- 18 bit unscaled cos/sin
    );
end;

architecture arch of nco_core is
    -- Delay from lookup valid to cos_sin_raw valid
    constant LOOKUP_DELAY : natural := 4;
    -- Delay from cos_sin_raw to cos_sin_refined
    constant REFINE_DELAY : natural := 6;

    signal phase : angle_t;

    -- Lookup table
    signal lookup : lookup_t;
    signal cos_sin_raw : cos_sin_19_t;

    -- Refinement
    signal octant : octant_t;
    signal residue : residue_t;
    signal cos_sin_refined : cos_sin_18_t;

begin
    -- Phase advance computation for NCO
    nco_phase : entity work.nco_phase port map (
        clk_i => clk_i,
        phase_advance_i => phase_advance_i,
        phase_o => phase
    );

    -- Split angle into octant, lookup and residue.  The returned octant is
    -- delayed as appropriate for the final correction.
    prepare : entity work.nco_cos_sin_prepare generic map (
        LOOKUP_DELAY => LOOKUP_DELAY,
        REFINE_DELAY => REFINE_DELAY
    ) port map (
        clk_i => clk_i,
        angle_i => phase,
        lookup_o => lookup,
        residue_o => residue,
        octant_o => octant
    );

    -- Lookup table
    lookup_table : entity work.nco_cos_sin_table generic map (
        LOOKUP_DELAY => LOOKUP_DELAY
    ) port map (
        clk_i => clk_i,
        addr_i => lookup,
        cos_sin_o => cos_sin_raw
    );

    -- Refine the lookup by linear interpolation
    refine : entity work.nco_cos_sin_refine generic map (
        LOOKUP_DELAY => LOOKUP_DELAY,
        REFINE_DELAY => REFINE_DELAY
    ) port map (
        clk_i => clk_i,
        residue_i => residue,
        cos_sin_i => cos_sin_raw,
        cos_sin_o => cos_sin_refined
    );

    -- Flip the final result into place according to the original octant
    fixup_octant : entity work.nco_cos_sin_octant port map (
        clk_i => clk_i,
        octant_i => octant,
        cos_sin_i => cos_sin_refined,
        cos_sin_o => cos_sin_o
    );
end;
