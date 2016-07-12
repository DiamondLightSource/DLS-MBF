-- I/O register mux

-- Decodes register plus address read and write into appropriate strobes and
-- read data multiplexing.  Also routes read_ack signal properly.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity register_mux is
    port (
        -- Register read.
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- Multiplexed registers
        read_data_i : in reg_data_array_t;      -- Individual read registers
        read_strobe_o : out reg_strobe_t;       -- Individual read selects
        read_ack_i : in reg_strobe_t;           -- Individual read acknowlege

        -- Register write.
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;

        write_strobe_o : out reg_strobe_t
    );
end;

architecture register_mux of register_mux is
    signal read_address : natural;
    signal write_address : natural;

begin
    read_address  <= to_integer(read_address_i);
    write_address <= to_integer(write_address_i);

    read_data_o <= read_data_i(read_address);
    read_ack_o  <= read_ack_i(read_address);

    gen_strobe :
    for i in REG_ADDR_RANGE generate
        read_strobe_o(i)  <= read_strobe_i  when read_address  = i else '0';
        write_strobe_o(i) <= write_strobe_i when write_address = i else '0';
    end generate;
end;
