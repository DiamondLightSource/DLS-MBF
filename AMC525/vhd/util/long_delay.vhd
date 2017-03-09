-- Programmable long delay.  This delay uses block ram.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

architecture arch of long_delay is
    constant ADDR_BITS : natural := delay_i'LENGTH;
    subtype address_t is unsigned(ADDR_BITS-1 downto 0);

    signal write_addr : address_t := (others => '0');
    signal read_addr : address_t := (others => '0');

begin
    memory_inst : entity work.block_memory generic map (
        ADDR_BITS => ADDR_BITS,
        DATA_BITS => WIDTH
    ) port map (
        read_clk_i => clk_i,
        read_addr_i => read_addr,
        read_data_o => data_o,
        write_clk_i => clk_i,
        write_strobe_i => '1',
        write_addr_i => write_addr,
        write_data_i => data_i
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            write_addr <= write_addr + 1;
            read_addr <= write_addr - delay_i;
        end if;
    end process;
end;
