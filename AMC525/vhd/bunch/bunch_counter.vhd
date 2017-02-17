-- Bunch counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity bunch_counter is
    port (
        clk_i : in std_logic;
        turn_clock_i : in std_logic;
        bunch_index_o : out bunch_count_t   -- Current bunch number
    );
end;

architecture bunch_counter of bunch_counter is
    signal bunch_index : bunch_count_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if turn_clock_i = '1' then
                bunch_index <= (others => '0');
            else
                bunch_index <= bunch_index + 1;
            end if;
        end if;
    end process;
    bunch_index_o <= bunch_index;
end;
