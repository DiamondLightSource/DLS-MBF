-- Simple register file

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity register_file is
    port (
        clk_i : in std_logic;

        -- Write interface
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;

        -- Register array
        register_data_o : out reg_data_array_t(REG_ADDR_RANGE)
    );
end;

architecture register_file of register_file is
    signal register_file : reg_data_array_t(REG_ADDR_RANGE) :=
        (others => (others => '0'));
    signal register_address : REG_ADDR_RANGE;

begin
    register_address <= to_integer(unsigned(write_address_i));
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                register_file(register_address) <= write_data_i;
            end if;
        end if;
    end process;

    -- Single cycle writes to registers don't need acknowledge
    write_ack_o <= '1';
    register_data_o <= register_file;
end;
