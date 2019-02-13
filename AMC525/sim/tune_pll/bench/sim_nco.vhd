-- Simulated NCO using real arithmetic

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

entity sim_nco is
    port (
        clk_i : in std_ulogic;
        nco_freq_i : in angle_t;
        gain_i : in natural;
        cos_sin_o : out cos_sin_t
    );
end;

architecture arch of sim_nco is
    constant BITS_OUT : natural := cos_sin_o.cos'LENGTH;

    signal nco_phase : angle_t := (others => '0');

    signal real_phase : real;
    signal cosine : real;
    signal sine : real;

    -- This incredibly ugly syntax is required because of a combination of both
    -- VHDL and QuestaSim misfeatures.
    signal cos_sin_out : cos_sin_t(
        cos(cos_sin_o.cos'RANGE), sin(cos_sin_o.sin'RANGE))
        := (others => (others => '0'));

begin
    real_phase <= 2.0 * MATH_PI *
        real(to_integer(nco_phase(47 downto 17))) / 2.0**31;
    cosine <= cos(real_phase) * real(gain_i);
    sine   <= sin(real_phase) * real(gain_i);

    process (clk_i) begin
        if rising_edge(clk_i) then
            nco_phase <= nco_phase + nco_freq_i;

            cos_sin_out.cos <= to_signed(integer(cosine), BITS_OUT);
            cos_sin_out.sin <= to_signed(integer(sine), BITS_OUT);
        end if;
    end process;

    cos_sin_o <= cos_sin_out;
end;
