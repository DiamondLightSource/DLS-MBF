-- A single register.  Is this really a sensible as a single entity?

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity single_register is
    port (
        clk_i : in std_logic;

        register_o : out reg_data_t := (others => '0');

        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t
    );
end;

architecture single_register of single_register is
begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                register_o <= write_data_i;
            end if;
        end if;
    end process;
end;
