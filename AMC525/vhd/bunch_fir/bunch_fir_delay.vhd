-- Delay line for bunch by bunch

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity bunch_fir_delay is
    generic (
        PROCESS_DELAY : natural
    );
    port (
        clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;
        write_strobe_i : in std_ulogic;
        data_i : in signed;
        data_o : out signed
    );
end;

architecture arch of bunch_fir_delay is
    -- Delay the write address by the external processing duration, together
    -- with a compensation for the block memory delay
    --
    -- The figure below shows the data flow:
    --           |     |     |     |    ...    |     |     |     |
    -- ra      --X A   X------------------------------------------
    -- do_o    --------------X MA  X------------------------------
    -- wa      ---------------------   ...    -X A   X------------
    -- di_i    ---------------------   ...    -X P   X------------
    --           |<--- R --->|<------ D ------>|
    --
    -- A = incoming address, ra = read_addr, do_o = data_o,
    -- MA = stored data at address A, wa = write_addr, da_i = data_i,
    -- P = processed data, R = READ_DELAY, D = PROCESS_DELAY
    constant READ_DELAY : natural := 2;
    constant WRITE_DELAY : natural := PROCESS_DELAY + READ_DELAY;

    signal turn_clock : std_ulogic;
    signal read_addr : bunch_count_t := (others => '0');
    signal write_addr : bunch_count_t;

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;
    assert WRITE_DELAY >= 0 severity failure;

    -- Delay the turn clock to help with distribution
    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );

    -- Read address
    process (clk_i) begin
        if rising_edge(clk_i) then
            if turn_clock = '1' then
                read_addr <= (others => '0');
            else
                read_addr <= read_addr + 1;
            end if;
        end if;
    end process;

    -- Delay the write address relative to the read address
    delayline_inst : entity work.dlyline generic map (
        DLY => WRITE_DELAY,
        DW  => bunch_count_t'LENGTH
    ) port map (
       clk_i => clk_i,
       data_i => std_ulogic_vector(read_addr),
       unsigned(data_o) => write_addr
    );

    -- Delay line
    memory_inst : entity work.block_memory generic map (
        ADDR_BITS => bunch_count_t'LENGTH,
        DATA_BITS => data_i'LENGTH,
        READ_DELAY => READ_DELAY
    ) port map (
        read_clk_i => clk_i,
        read_addr_i => read_addr,
        signed(read_data_o) => data_o,

        write_clk_i => clk_i,
        write_strobe_i => write_strobe_i,
        write_addr_i => write_addr,
        write_data_i => std_ulogic_vector(data_i)
    );
end;
