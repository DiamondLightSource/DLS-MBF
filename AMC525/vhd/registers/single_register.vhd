-- A single register.  Is this really a sensible as a single entity?

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity single_register is
    port (
        clk_i : in std_logic;

        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        register_o : out reg_data_t := (others => '0')
    );
end;

architecture single_register of single_register is
    signal register_data : reg_data_t;
begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                register_data <= write_data_i;
            end if;
        end if;
    end process;

    write_ack_o <= '1';
    read_data_o <= register_data;
    read_ack_o <= '1';

    register_o <= register_data;
end;
