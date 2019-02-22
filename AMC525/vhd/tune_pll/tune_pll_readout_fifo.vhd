-- FIFO for Tune PLL readout

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity tune_pll_readout_fifo is
    generic (
        READOUT_FIFO_BITS : natural := 10
    );
    port (
        clk_i : in std_ulogic;

        -- Simple read/write interface
        data_i : in std_ulogic_vector;
        write_i : in std_ulogic;
        -- Needed for overrun reset synchronisation when caller is writing
        -- multiple words in one transaction.
        start_i : in std_ulogic;

        -- Data is assumed to be valid at the time of reading
        data_o : out std_ulogic_vector;
        read_i : in std_ulogic;

        -- Status and control
        fifo_depth_o : out unsigned;
        overrun_o : out std_ulogic;
        reset_overrun_i : in std_ulogic;
        read_error_o : out std_ulogic := '0';
        reset_read_error_i : in std_ulogic;

        -- Interrupt management
        enable_interrupt_i : in std_ulogic;
        interrupt_o : out std_ulogic := '0'
    );
end;

architecture arch of tune_pll_readout_fifo is
    -- Writer interface
    signal write_valid : std_ulogic;
    signal write_ready : std_ulogic;
    type run_state_t is (RUNNING, OVERRUN, DELAY, STARTING);
    signal run_state : run_state_t := RUNNING;

    -- Reader interface
    signal read_valid : std_ulogic;
    signal read_ready : std_ulogic;

    -- Interrupt handling
    signal interrupt_enabled : std_ulogic := '0';

begin
    fifo : entity work.memory_fifo generic map (
        FIFO_BITS => READOUT_FIFO_BITS
    ) port map (
        clk_i => clk_i,
        -- Write interface
        write_valid_i => write_valid,
        write_ready_o => write_ready,
        write_data_i => data_i,
        -- Read interface
        read_valid_o => read_valid,
        read_ready_i => read_ready,
        read_data_o => data_o,
        -- Control and status
        reset_fifo_i => reset_overrun_i,
        fifo_depth_o => fifo_depth_o(READOUT_FIFO_BITS downto 0)
    );
    -- Fill-in for simulation only!
    fifo_depth_o(fifo_depth_o'LEFT downto READOUT_FIFO_BITS+1)
        <= (others => '0');

    -- Only attempt to start a write if the FIFO is already ready for us
    write_valid <= write_i and write_ready and
        to_std_ulogic(run_state = RUNNING or run_state = STARTING);

    -- Similarly, only attept a read if data is already available
    read_ready <= read_valid and read_i;

    process (clk_i) begin
        if rising_edge(clk_i) then
            case run_state is
                when RUNNING =>
                    if reset_overrun_i = '1' then
                        run_state <= DELAY;
                    elsif write_i = '1' and write_ready = '0' then
                        run_state <= OVERRUN;
                    end if;
                when OVERRUN =>
                    if reset_overrun_i = '1' then
                        run_state <= DELAY;
                    end if;
                when DELAY =>
                    run_state <= STARTING;
                when STARTING =>
                    if write_i = '1' then
                        run_state <= RUNNING;
                    end if;
            end case;

            -- Accumulate read errors until reset
            if read_i = '1' and read_valid = '0' then
                read_error_o <= '1';
            elsif reset_read_error_i = '1' then
                read_error_o <= '0';
            end if;

            -- Reset interrupt on read until re-enabled
            if read_i = '1' then
                interrupt_enabled <= '0';
            elsif enable_interrupt_i = '1' then
                interrupt_enabled <= '1';
            end if;
            interrupt_o <= interrupt_enabled and read_ready;
        end if;
    end process;

    overrun_o <= to_std_ulogic(run_state = OVERRUN);
end;
