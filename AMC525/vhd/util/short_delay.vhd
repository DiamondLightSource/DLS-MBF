-- Programmable short delay.  This delay fits into distributed memory.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity short_delay is
    generic (
        WIDTH : natural
    );
    port (
        clk_i : in std_logic;

        delay_i : in unsigned;
        data_i : in std_logic_vector(WIDTH-1 downto 0);
        data_o : out std_logic_vector(WIDTH-1 downto 0) := (others => '0')
    );
end;

architecture short_delay of short_delay is
    constant DELAY_BITS : natural := delay_i'LENGTH;
    constant MAX_DELAY : natural := 2**DELAY_BITS-1;

    subtype data_t is std_logic_vector(WIDTH-1 downto 0);
    type delay_line_t is array(0 to MAX_DELAY) of data_t;
    signal delay_line : delay_line_t := (others => (others => '0'));

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Shift register implementation of delay line maps nicely to
            -- distributed RAM in configurable logic blocks
            for i in 1 to MAX_DELAY loop
                delay_line(i) <= delay_line(i-1);
            end loop;
            delay_line(0) <= data_i;
            data_o <= delay_line(to_integer(delay_i));
        end if;
    end process;
end;
