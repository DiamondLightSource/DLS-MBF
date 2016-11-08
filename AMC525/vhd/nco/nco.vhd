-- Numerically Controlled Oscillator
--
-- Runs at DSP clock rate, generates both cosine and sine outputs, both scaled
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

        cos_sin_o : out cos_sin_18_channels_t  -- 18 bit unscaled cos/sin
    );
end;

architecture nco of nco is
    -- Delay from lookup valud to cos_sin_raw valid
    constant LOOKUP_DELAY : natural := 2;
    -- Delay from cos_sin_raw to cos_sin_refined
    constant REFINE_DELAY : natural := 3;

    signal phase : angle_channels_t;

    -- Lookup table
    signal lookup : lookup_channels_t;
    signal cos_sin_raw : cos_sin_19_channels_t;

    -- Refinement
    signal residue : residue_channels_t;
    signal cos_sin_refined : cos_sin_18_channels_t;

begin
    -- Phase advance computation for NCO
    nco_phase_inst : entity work.nco_phase port map (
        clk_i => clk_i,
        phase_advance_i => phase_advance_i,
        reset_i => reset_i,
        phase_o => phase
    );

    -- Shared lookup table
    nco_cos_sin_table_inst : entity work.nco_cos_sin_table port map (
        clk_i => clk_i,
        addr_a_i => lookup(0),
        addr_b_i => lookup(1),
        cos_sin_a_o => cos_sin_raw(0),
        cos_sin_b_o => cos_sin_raw(1)
    );

    nco_gen : for c in CHANNELS generate
        -- Split angle into octant, lookup and residue, and recombine the
        -- result according to the incoming octant.
        nco_cos_sin_inst : entity work.nco_cos_sin_octant generic map (
            LOOKUP_DELAY => LOOKUP_DELAY,
            REFINE_DELAY => REFINE_DELAY
        ) port map (
            clk_i => clk_i,
            angle_i => phase(c),

            lookup_o => lookup(c),
            residue_o => residue(c),
            cos_sin_i => cos_sin_refined(c),

            cos_sin_o => cos_sin_o(c)
        );

        -- Refine the lookup by linear interpolation
        refine_inst : entity work.nco_cos_sin_refine generic map (
            LOOKUP_DELAY => LOOKUP_DELAY,
            REFINE_DELAY => REFINE_DELAY
        ) port map (
            clk_i => clk_i,
            residue_i => residue(c),
            cos_sin_i => cos_sin_raw(c),
            cos_sin_o => cos_sin_refined(c)
        );
    end generate;
end;
