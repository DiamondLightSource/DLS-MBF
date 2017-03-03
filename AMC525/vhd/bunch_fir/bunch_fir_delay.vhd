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
    --
    -- The figure below shows the data flow:
    --          |     |     |     |     |     | ... |     |     |
    -- bi_i    --X A   X-------------------------------------------
    -- ra      --------X A   X-------------------------------------
    -- do      --------------------X MA  X-------------------------
    -- do_o    --------------------------X MA  X-------------------
    -- di_i    --------------------------------- ... X P   X-------
    -- di      ---------------------------------     ------X P   X-
    -- wa      --------------------------------- ... ------X A   X-
    --                 |                 |<--- D --->|     |
    -- WRITE_DELAY     |  1  .  2  .  3  .    ...    .  4  |
    --
    -- bi_i = bunch_index_i, A = incoming address, ra = read_addr,
    -- do = data_out, do_o = data_o, MA = stored data at address A,
    -- D = PROCESS_DELAY
    constant WRITE_DELAY : natural := PROCESS_DELAY + 4;

    signal write_strobe : std_logic;
    signal data_in : data_i'SUBTYPE;
    signal data_out : data_o'SUBTYPE;
    signal read_addr : bunch_index_i'SUBTYPE;
    signal write_addr : bunch_index_i'SUBTYPE;

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;

    -- Extra input register to help with timing
    process (clk_i) begin
        if rising_edge(clk_i) then
            write_strobe <= write_strobe_i;
            data_in <= data_i;
            read_addr <= bunch_index_i;
            data_o <= data_out;
        end if;
    end process;

    -- Delay line
    memory_inst : entity work.block_memory generic map (
        ADDR_BITS => bunch_index_i'LENGTH,
        DATA_BITS => data_i'LENGTH
    ) port map (
        read_clk_i => clk_i,
        read_addr_i => read_addr,
        signed(read_data_o) => data_out,

        write_clk_i => clk_i,
        write_strobe_i => write_strobe,
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
