-- Support for an array of register data written through a streamed interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity register_block is
    port (
        clk_i : in std_logic;

        -- Register interface (write only)
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic := '0';
        -- Write start
        write_start_i : in std_logic;

        -- The register array
        registers_o : out reg_data_array_t
    );
end;

architecture register_block of register_block is
    constant COUNT : natural := registers_o'LENGTH;
    constant COUNT_BITS : natural := bits(COUNT-1);

    signal register_file : reg_data_array_t(registers_o'RANGE) :=
        (others => (others => '0'));
    signal write_ptr : unsigned(COUNT_BITS-1 downto 0);

begin
    assert registers_o'LEFT = 0;

    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                write_ptr <= write_ptr + 1;
                register_file(to_integer(write_ptr)) <= write_data_i;
            elsif write_start_i = '1' then
                write_ptr <= (others => '0');
            end if;
        end if;
    end process;

    write_ack_o <= '1';
    registers_o <= register_file;
end;
