-- Simple FIFO.  Writing to a full FIFO will make it empty, unless the write is
-- simultaneous with a read.  Reading from an empty FIFO will return old data
-- and refill the FIFO.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity slow_memory_fifo is
    generic (
        FIFO_BITS : natural := 5            -- log2 FIFO depth
    );
    port (
        clk_i : in std_logic;

        write_valid_i : in std_logic;
        write_ready_o : out std_logic;
        write_data_i : in std_logic_vector;

        read_valid_o : out std_logic;
        read_ready_i : in std_logic;
        read_data_o : out std_logic_vector
    );
end;

architecture slow_memory_fifo of slow_memory_fifo is
    signal in_ptr  : unsigned(FIFO_BITS-1 downto 0) := (others => '0');
    signal out_ptr : unsigned(FIFO_BITS-1 downto 0) := (others => '0');
    signal fifo : vector_array(0 to 2**FIFO_BITS-1)(write_data_i'RANGE);

    signal write_ready : boolean;
    signal do_read : boolean;

    type buffer_state_t is (IDLE, BUSY);
    signal buffer_state : buffer_state_t := IDLE;

begin
    write_ready <= in_ptr + 1 /= out_ptr;
    -- We replenish the output buffer when we can: when the data has been taken
    -- and we have data to write.
    do_read <=
        in_ptr /= out_ptr and (buffer_state = IDLE or read_ready_i = '1');

    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_valid_i = '1' and write_ready then
                fifo(to_integer(in_ptr)) <= write_data_i;
                in_ptr <= in_ptr + 1;
            end if;

            if do_read then
                read_data_o <= fifo(to_integer(out_ptr));
                out_ptr <= out_ptr + 1;
            end if;

            case buffer_state is
                when IDLE =>
                    if do_read then
                        buffer_state <= BUSY;
                    end if;
                when BUSY =>
                    if read_ready_i = '1' and not do_read then
                        buffer_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    write_ready_o <= to_std_logic(write_ready);
    read_valid_o  <= to_std_logic(buffer_state = BUSY);
end;
