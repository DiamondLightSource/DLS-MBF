-- Simple two-pole resonator for Tune PLL simulation testing

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;

entity sim_resonator is
    port (
        clk_i : in std_ulogic;

        centre_freq_i : in real;
        width_i : in real;
        gain_i : in real;

        data_i : in signed;
        data_o : out signed
    );
end;

architecture arch of sim_resonator is
    signal data_in : real := 0.0;
    signal data_out : real := 0.0;
    signal data_out_1 : real := 0.0;

    signal b_1 : real := 0.0;
    signal a_1 : real := 0.0;
    signal a_2 : real := 0.0;
    signal r : real := 1.0;

begin
    -- Compute filter parameters
    r <= 1.0 - width_i;
    a_1 <= 2.0 * r * cos(centre_freq_i);
    a_2 <= - r * r;
    -- Scale result so that gain is unity at resonance
    b_1 <= width_i * sqrt(1.0 - 2.0 * r * cos(2.0 * centre_freq_i) + r * r);

    -- Filter body
    data_in <= real(to_integer(data_i));
    process (clk_i) begin
        if rising_edge(clk_i) then
            data_out <= b_1 * data_in + a_1 * data_out + a_2 * data_out_1;
            data_out_1 <= data_out;
        end if;
    end process;
    data_o <= to_signed(integer(gain_i * data_out), data_o'LENGTH);
end;
