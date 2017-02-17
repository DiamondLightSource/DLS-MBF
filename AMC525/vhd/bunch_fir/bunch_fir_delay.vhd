-- Delay line for bunch by bunch

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir_delay is
    generic (
        PROCESS_DELAY : natural
    );
    port (
        clk_i : in std_logic;
        bunch_index_i : in unsigned;
        write_strobe_i : in std_logic;
        data_i : in signed;
        data_o : out signed
    );
end;

architecture bunch_fir_delay of bunch_fir_delay is
    constant ADDR_BITS : natural := bunch_index_i'LENGTH;
    -- Delay the write address by the external processing duration, together
    -- with a compensation for the block memory delay
    constant WRITE_DELAY : natural := PROCESS_DELAY + 2;

    signal write_addr : unsigned(ADDR_BITS-1 downto 0);

begin
    assert data_i'LENGTH = data_o'LENGTH;

    -- Delay line
    memory_inst : entity work.block_memory generic map (
        ADDR_BITS => ADDR_BITS,
        DATA_BITS => data_i'LENGTH
    ) port map (
        read_clk_i => clk_i,
        read_addr_i => bunch_index_i,
        signed(read_data_o) => data_o,

        write_clk_i => clk_i,
        write_strobe_i => write_strobe_i,
        write_addr_i => write_addr,
        write_data_i => std_logic_vector(data_i)
    );

    -- Delay the write address relative to the read address
    delayline_inst : entity work.dlyline generic map (
        DLY => WRITE_DELAY,
        DW  => ADDR_BITS
    ) port map (
       clk_i => clk_i,
       data_i => std_logic_vector(bunch_index_i),
       unsigned(data_o) => write_addr
    );
end;
