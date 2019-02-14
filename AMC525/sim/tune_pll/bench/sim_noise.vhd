-- Simple noise source

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;

entity sim_noise is
    port (
        clk_i : in std_ulogic;
        gain_i : in real;
        data_o : out signed
    );
end;

architecture arch of sim_noise is
begin
    process (clk_i)
        variable seed1 : positive := 1;
        variable seed2 : positive := 1;
        variable noise : real;
    begin
        uniform(seed1, seed2, noise);
        if rising_edge(clk_i) then
            data_o <= to_signed(integer(noise * gain_i), data_o'LENGTH);
        end if;
    end process;
end;

