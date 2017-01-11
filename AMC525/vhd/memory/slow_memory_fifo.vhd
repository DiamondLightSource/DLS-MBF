-- FIFO with AXI style handshaking.  The valid signal is asserted by the
-- producer when data is available to be transferred, and the ready signal is
-- asserted when the receiver is ready: transfer happens on the clock cycle when
-- ready and valid are asserted.  Two further AXI rules are followed: when valid
-- is asserted it must remain asserted until ready is seen; and the assertion of
-- valid must be independent of the state of ready.

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
    -- The FIFO is structured into four parts: INPUT, OUTPUT, STORE, STATE.

    -- STORE where the fifo data is stored.
    signal in_ptr  : unsigned(FIFO_BITS-1 downto 0) := (others => '0');
    signal out_ptr : unsigned(FIFO_BITS-1 downto 0) := (others => '0');
    signal fifo : vector_array(0 to 2**FIFO_BITS-1)(write_data_i'RANGE);

    -- STATE: we detect both "full" and "nearly full" conditions, and so it
    -- turns out that the logic is simpler if we use a full flip-flop to
    -- distinguish between empty and full states.
    signal full : boolean := false;
    signal nearly_full : boolean;
    signal empty : boolean;

    -- INPUT: we register the incoming data and the write ready state.
    signal write_data_valid : boolean := false;
    signal write_ready : boolean := true;
    signal write_data : write_data_i'SUBTYPE;
    signal do_write : boolean;
    signal write_enable : boolean;

    -- OUTPUT: register read valid state
    signal read_valid : boolean := false;
    signal do_read : boolean;

begin
    -- STATE
    nearly_full <= in_ptr + 1 = out_ptr;
    empty <= in_ptr = out_ptr and not full;

    -- INPUT
    write_enable <= write_ready and write_valid_i = '1';
    do_write <= write_data_valid and not full;

    -- OUTPUT
    do_read <= not empty and (read_ready_i = '1' or not read_valid);


    process (clk_i) begin
        if rising_edge(clk_i) then
            -- STORE
            if do_write then
                fifo(to_integer(in_ptr)) <= write_data;
                in_ptr <= in_ptr + 1;
            end if;

            if do_read then
                read_data_o <= fifo(to_integer(out_ptr));
                out_ptr <= out_ptr + 1;
            end if;

            -- STATE
            if nearly_full and do_write and not do_read then
                full <= true;
            elsif do_read then
                full <= false;
            end if;

            -- INPUT
            write_ready <= not (full or nearly_full);
            if write_enable then
                write_data_valid <= true;
                write_data <= write_data_i;
            elsif do_write then
                write_data_valid <= false;
            end if;

            -- OUTPUT
            if do_read then
                read_valid <= true;
            elsif read_ready_i = '1' and not do_read then
                read_valid <= false;
            end if;
        end if;
    end process;

    write_ready_o <= to_std_logic(write_ready);
    read_valid_o  <= to_std_logic(read_valid);
end;
