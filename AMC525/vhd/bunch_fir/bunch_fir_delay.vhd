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
    -- Delay the write address by the external processing duration, together
    -- with a compensation for the block memory delay
    constant WRITE_DELAY : natural := PROCESS_DELAY + 3;

    signal data_in : data_i'SUBTYPE;
    signal read_addr : bunch_index_i'SUBTYPE;
    signal write_addr : bunch_index_i'SUBTYPE;

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;

    -- Extra input register to help with timing
    process (clk_i) begin
        if rising_edge(clk_i) then
            data_in <= data_i;
            read_addr <= bunch_index_i;
        end if;
    end process;

    -- Delay line
    memory_inst : entity work.block_memory generic map (
        ADDR_BITS => bunch_index_i'LENGTH,
        DATA_BITS => data_i'LENGTH
    ) port map (
        read_clk_i => clk_i,
        read_addr_i => read_addr,
        signed(read_data_o) => data_o,

        write_clk_i => clk_i,
        write_strobe_i => write_strobe_i,
        write_addr_i => write_addr,
        write_data_i => std_logic_vector(data_in)
    );

    -- Delay the write address relative to the read address
    delayline_inst : entity work.dlyline generic map (
        DLY => WRITE_DELAY,
        DW  => bunch_index_i'LENGTH
    ) port map (
       clk_i => clk_i,
       data_i => std_logic_vector(read_addr),
       unsigned(data_o) => write_addr
    );
end;
