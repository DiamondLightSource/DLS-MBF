-- FIFO for Tune PLL readout

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity tune_pll_readout_fifo is
    port (
        clk_i : in std_ulogic;

        -- Simple read/write interface
        data_i : in std_ulogic_vector;
        write_i : in std_ulogic;

        -- Data is assumed to be valid at the time of reading
        data_o : out std_ulogic_vector;
        read_i : in std_ulogic;

        -- Status and control
        fifo_depth_o : out unsigned;
        overrun_o : out std_ulogic;
        read_error_o : out std_ulogic := '0';
        reset_i : in std_ulogic;

        -- Interrupt management
        enable_interrupt_i : in std_ulogic;
        interrupt_o : out std_ulogic := '0'
    );
end;

architecture arch of tune_pll_readout_fifo is
    constant FIFO_BITS : natural := 2;      -- Should be 10!

    -- Writer interface
    signal write_valid : std_ulogic;
    signal write_ready : std_ulogic;
    signal overrun : std_ulogic := '0';

    -- Reader interface
    signal read_valid : std_ulogic;
    signal read_ready : std_ulogic;

    -- Interrupt handling
    signal interrupt_enabled : std_ulogic := '0';

begin
    fifo : entity work.memory_fifo generic map (
        FIFO_BITS => FIFO_BITS
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
        reset_fifo_i => reset_i,
        fifo_depth_o => fifo_depth_o(FIFO_BITS downto 0)
    );
    -- Fill-in for simulation only!
    fifo_depth_o(fifo_depth_o'LEFT downto FIFO_BITS+1) <= (others => '0');

    -- Only attempt to start a write if the FIFO is already ready for us
    write_valid <= write_i and write_ready and not overrun;

    -- Similarly, only attept a read if data is already available
    read_ready <= read_valid and read_i;

    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_i = '1' and write_ready = '0' then
                overrun <= '1';
            elsif reset_i = '1' then
                overrun <= '0';
            end if;

            read_error_o <= read_i and not read_valid;

            -- Reset interrupt on read until re-enabled
            if read_i = '1' then
                interrupt_enabled <= '0';
            elsif enable_interrupt_i = '1' then
                interrupt_enabled <= '1';
            end if;
            interrupt_o <= interrupt_enabled and read_ready;
        end if;
    end process;

    overrun_o <= overrun;
end;
