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
        write_clk_i : in std_ulogic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;
        write_strobe_i : in std_ulogic;

        read_clk_i : in std_ulogic;
        read_addr_i : in unsigned;
        read_data_o : out std_ulogic := '0'
    );
end;

architecture arch of detector_bunch_mem is
    constant ADDR_BITS : natural := write_addr_i'LENGTH;
    signal read_addr_word : write_addr_i'SUBTYPE;
    signal read_addr_bit_in : unsigned(4 downto 0);
    signal read_addr_bit : unsigned(4 downto 0);
    signal read_word : reg_data_t;
    signal read_word_bits : reg_data_t := (others => '0');

    -- Delay read_addr =(2)=> read_word
    constant READ_WORD_DELAY : natural := 2;
    -- Delay read_addr
    --  =(2)=> read_word
    --  => read_word_bits
    constant READ_BIT_DELAY : natural := READ_WORD_DELAY + 1;

begin
    assert read_addr_i'LENGTH = write_addr_i'LENGTH + 5 severity failure;

    memory : entity work.block_memory generic map (
        ADDR_BITS => ADDR_BITS,
        DATA_BITS => reg_data_t'LENGTH,
        READ_DELAY => READ_WORD_DELAY
    ) port map (
        read_clk_i => read_clk_i,
        read_addr_i => read_addr_word,
        read_data_o => read_word,

        write_clk_i => write_clk_i,
        write_strobe_i => write_strobe_i,
        write_addr_i => write_addr_i,
        write_data_i => write_data_i
    );

    delay : entity work.dlyline generic map (
        DLY => READ_BIT_DELAY,
        DW => read_addr_bit'LENGTH
    ) port map (
        clk_i => read_clk_i,
        data_i => std_ulogic_vector(read_addr_bit_in),
        unsigned(data_o) => read_addr_bit
    );

    read_addr_word <= read_addr_i(read_addr_i'LEFT downto 5);
    read_addr_bit_in <= read_addr_i(4 downto 0);

    process (read_clk_i) begin
        if rising_edge(read_clk_i) then
            read_word_bits <= read_word;
            read_data_o <= read_word_bits(to_integer(read_addr_bit));
        end if;
    end process;
end;
