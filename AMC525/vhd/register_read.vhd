-- Simple read from register file

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity register_read is
    port (
        clk_i : in std_logic;

        -- Read interface
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- Register array
        register_data_i : in reg_data_array_t(REG_ADDR_RANGE)
    );
end;

architecture register_read of register_read is
    signal register_address : REG_ADDR_RANGE;

begin
    register_address <= to_integer(unsigned(read_address_i));
    read_data_o <= register_data_i(register_address);
    read_ack_o <= '1';
end;
