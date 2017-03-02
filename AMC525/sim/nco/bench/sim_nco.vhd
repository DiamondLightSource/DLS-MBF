-- Simulates NCO using real arithmetic for comparison with the implementation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

use ieee.math_real.all;

entity sim_nco is
    port (
        clk_i : in std_logic;

        phase_advance_i : in angle_t;
        reset_i : in std_logic;

        cos_sin_o : out cos_sin_18_t  -- 18 bit unscaled cos/sin
    );
end;

architecture arch of sim_nco is
    -- Do floating point sin/cos
    signal int_phase : angle_t;
    signal phase : real;
    signal cosine : real;
    signal sine : real;

    signal cos_sin : cos_sin_18_t;

    -- This delay must match the NCO core delay.  This is the sum of
    -- LOOKUP_DELAY and REFINE_DELAY defined in nco_core plus any delay added
    -- by nco_cos_sin_prepare and nco_cos_sin_octant.
    constant OUT_DELAY : natural := 14;

begin
    -- Use the hardware phase calculation
    nco_phase : entity work.nco_phase port map (
        clk_i => clk_i,
        phase_advance_i => phase_advance_i,
        reset_i => reset_i,
        phase_o => int_phase
    );

    phase <= 2.0 * MATH_PI * real(to_integer(int_phase)) / 2.0**32;
    cosine <= cos(phase);
    sine <= sin(phase);

    cos_sin.cos <= to_signed(integer(cosine * real(16#1FFFC#)), 18);
    cos_sin.sin <= to_signed(integer(sine   * real(16#1FFFC#)), 18);

    -- Delay result to match hardware
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
