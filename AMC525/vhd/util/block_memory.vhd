-- Memory mapped into Block RAM.  We double buffer the read data to ensure that
-- the BRAM is fully registered.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity block_memory is
    generic (
        ADDR_BITS : natural;
        DATA_BITS : natural
    );
    port (
        clk_i : in std_logic;

        -- Read interface
        read_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        read_data_o : out std_logic_vector(DATA_BITS-1 downto 0);

        -- Write interface
        write_strobe_i : in std_logic;
        write_addr_i : in unsigned(ADDR_BITS-1 downto 0);
        write_data_i : in std_logic_vector(DATA_BITS-1 downto 0)
    );
end;

architecture block_memory of block_memory is
    -- Block RAM
    subtype data_t is std_logic_vector(DATA_BITS-1 downto 0);
    type memory_t is array(0 to 2**ADDR_BITS-1) of data_t;
    signal memory : memory_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of memory : signal is "BLOCK";

    signal read_addr : unsigned(ADDR_BITS-1 downto 0);

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            read_addr <= read_addr_i;
            read_data_o <= memory(to_integer(read_addr));
            if write_strobe_i = '1' then
                memory(to_integer(write_addr_i)) <= write_data_i;
            end if;
        end if;
    end process;
end;
