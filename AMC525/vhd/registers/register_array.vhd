-- Support for an array of register data written through a streamed interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity register_array is
    generic (
        COUNT : natural
    );
    port (
        clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;
        -- Read and write resets
        write_reset_i : in std_logic;
        read_reset_i : in std_logic;

        -- The register array
        registers_o : out reg_data_array_t(0 to COUNT-1)
    );
end;

architecture register_array of register_array is
    constant COUNT_BITS : natural := bits(COUNT-1);
    signal registers : reg_data_array_t(0 to COUNT-1);
    signal write_ptr : unsigned(COUNT_BITS-1 downto 0);
    signal read_ptr : unsigned(COUNT_BITS-1 downto 0);

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_reset_i = '1' then
                write_ptr <= (others => '0');
            elsif write_strobe_i = '1' then
                registers(to_integer(write_ptr)) <= write_data_i;
                write_ptr <= write_ptr + 1;
            end if;

            if read_reset_i = '1' then
                read_ptr <= (others => '0');
            elsif read_strobe_i = '1' then
                read_data_o <= registers(to_integer(read_ptr));
                read_ptr <= read_ptr + 1;
            end if;
        end if;
    end process;
    write_ack_o <= '1';
    read_ack_o <= '1';

    registers_o <= registers;
end;
