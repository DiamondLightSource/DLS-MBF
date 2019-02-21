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

entity memory_fifo is
    generic (
        FIFO_BITS : natural := 5            -- log2 FIFO depth
    );
    port (
        clk_i : in std_ulogic;

        -- Write interface
        write_valid_i : in std_ulogic;
        write_ready_o : out std_ulogic;
        write_data_i : in std_ulogic_vector;

        -- Read interface
        read_valid_o : out std_ulogic;
        read_ready_i : in std_ulogic;
        read_data_o : out std_ulogic_vector;

        -- Control and status
        reset_fifo_i : in std_ulogic;
        fifo_depth_o : out unsigned(FIFO_BITS downto 0) := (others => '0')
    );
end;

architecture arch of memory_fifo is
    -- We store both data and address together in the FIFO.
    constant DATA_WIDTH : natural := write_data_i'LENGTH;
    subtype DATA_RANGE is natural range DATA_WIDTH-1 downto 0;

    -- The FIFO is structured into four parts: INPUT, OUTPUT, STORE, STATE.

    -- STORE where the fifo data is stored.
    signal in_ptr  : unsigned(FIFO_BITS-1 downto 0) := (others => '0');
    signal out_ptr : unsigned(FIFO_BITS-1 downto 0) := (others => '0');
    signal fifo : vector_array(0 to 2**FIFO_BITS-1)(DATA_RANGE);

    -- STATE: we detect both "full" and "nearly full" conditions, and so it
    -- turns out that the logic is simpler if we use a full flip-flop to
    -- distinguish between empty and full states.
    signal full : boolean := false;
    signal nearly_full : boolean;
    signal empty : boolean;

    -- INPUT: we register the incoming data and the write ready state.
    signal write_data_valid : boolean := false;
    signal write_ready : boolean := true;
    signal write_data : std_ulogic_vector(DATA_RANGE);
    signal do_write : boolean;
    signal write_enable : boolean;

    -- OUTPUT: register read valid state
    signal read_valid : boolean := false;
    signal do_read : boolean;
    signal read_data : std_ulogic_vector(DATA_RANGE);

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
            if reset_fifo_i = '1' then
                in_ptr <= (others => '0');
            elsif do_write then
                fifo(to_integer(in_ptr)) <= write_data;
                in_ptr <= in_ptr + 1;
            end if;

            if reset_fifo_i = '1' then
                out_ptr <= (others => '0');
            elsif do_read then
                read_data <= fifo(to_integer(out_ptr));
                out_ptr <= out_ptr + 1;
            end if;

            -- STATE
            if reset_fifo_i = '1' then
                full <= false;
            elsif nearly_full and do_write and not do_read then
                full <= true;
            elsif do_read then
                full <= false;
            end if;

            -- INPUT
            if reset_fifo_i = '1' then
                write_ready <= false;
                write_data_valid <= false;
            else
                write_ready <= not (full or nearly_full);
                if write_enable then
                    write_data_valid <= true;
                    write_data <= write_data_i;
                elsif do_write then
                    write_data_valid <= false;
                end if;
            end if;

            -- OUTPUT
            if reset_fifo_i = '1' then
                read_valid <= false;
            elsif do_read then
                read_valid <= true;
            elsif read_ready_i = '1' and not do_read then
                read_valid <= false;
            end if;

            -- Readout of FIFO depth
            -- Calculating the depth is surprisingly tricky, as we have to
            -- account for an extra value in the output buffer
            fifo_depth_o <=
                (to_std_ulogic(full) & (in_ptr - out_ptr)) + read_valid_o;
        end if;
    end process;

    write_ready_o <= to_std_ulogic(write_ready);
    read_valid_o  <= to_std_ulogic(read_valid);
    read_data_o <= read_data;
end;
