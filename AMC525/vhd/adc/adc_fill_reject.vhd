-- ADC fill pattern rejection filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fill_reject is
    port (
        clk_i : in std_ulogic;

        shift_i : in unsigned(3 downto 0);

        data_i : in signed;
        data_o : out signed
    );
end;

architecture arch of adc_fill_reject is
begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            data_o <= shift_right(data_i, to_integer(shift_i));
        end if;
    end process;
end;
