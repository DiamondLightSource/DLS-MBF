-- Programmable long delay.  This delay uses block ram.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity long_delay is
    generic (
        WIDTH : natural
    );
    port (
        clk_i : in std_logic;

        delay_i : in unsigned;
        data_i : in std_logic_vector(WIDTH-1 downto 0);
        data_o : out std_logic_vector(WIDTH-1 downto 0)
    );
end;

architecture long_delay of long_delay is
    constant DELAY_BITS : natural := delay_i'LENGTH;
    constant MAX_DELAY : natural := 2**DELAY_BITS-1;

    subtype address_t is unsigned(WIDTH-1 downto 0);
    subtype data_t is std_logic_vector(WIDTH-1 downto 0);

    type delay_mem_t is array(0 to MAX_DELAY) of data_t;
    signal delay_mem : delay_mem_t;
    attribute ram_style : string;
    attribute ram_style of delay_mem : signal is "BLOCK";

    signal write_addr : address_t := (others => '0');
    signal read_addr : address_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            delay_mem(to_integer(write_addr)) <= data_i;
            data_o <= delay_mem(to_integer(read_addr));

            write_addr <= write_addr + 1;
            read_addr <= write_addr - delay_i;
        end if;
    end process;
end;
