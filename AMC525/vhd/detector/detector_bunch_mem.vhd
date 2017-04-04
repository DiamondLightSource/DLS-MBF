-- Block ram with 32-bit wide writes and 1-bit wide reads.
--
-- In principle this structure can be directly supported by a block ram, but its
-- not inferrable, and hardly seems worth explicitly instantiating.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity detector_bunch_mem is
    port (
        write_clk_i : in std_logic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;
        write_strobe_i : in std_logic;

        read_clk_i : in std_logic;
        read_addr_i : in unsigned;
        read_data_o : out std_logic
    );
end;

architecture arch of detector_bunch_mem is
    constant ADDR_BITS : natural := write_addr_i'LENGTH;

    type memory_t is array(0 to 2**ADDR_BITS-1) of reg_data_t;
    signal memory : memory_t;
    attribute ram_style : string;
    attribute ram_style of memory : signal is "block";

    signal read_addr_word : unsigned(ADDR_BITS-1 downto 0);
    signal read_addr_bit_0 : unsigned(4 downto 0);
    signal read_addr_bit_1 : unsigned(4 downto 0);
    signal read_addr_bit_2 : unsigned(4 downto 0);

    signal read_word_0 : reg_data_t;
    signal read_word_1 : reg_data_t;
    signal read_word_2 : reg_data_t;

begin
    assert read_addr_i'LENGTH = write_addr_i'LENGTH + 5 severity failure;

    process (write_clk_i) begin
        if rising_edge(write_clk_i) then
            if write_strobe_i = '1' then
                memory(to_integer(write_addr_i)) <= write_data_i;
            end if;
        end if;
    end process;

    read_addr_word <= read_addr_i(read_addr_i'LEFT downto 5);
    read_addr_bit_0 <= read_addr_i(4 downto 0);

    process (read_clk_i) begin
        if rising_edge(read_clk_i) then
            read_word_0 <= memory(to_integer(read_addr_word));
            read_word_1 <= read_word_0;
            read_word_2 <= read_word_1;

            read_addr_bit_1 <= read_addr_bit_0;
            read_addr_bit_2 <= read_addr_bit_1;

            read_data_o <= read_word_2(to_integer(read_addr_bit_2));
        end if;
    end process;
end;
