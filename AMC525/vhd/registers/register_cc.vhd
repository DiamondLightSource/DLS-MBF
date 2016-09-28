-- Register clock crossing.
--
-- Transports a single block of registers across the clock domain between the
-- REG and output clocks.  An extra complication: if the output clock is
-- inactive then the transaction is completed anyway!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity register_cc is
    port (
        -- Clocks
        reg_clk_i : in std_logic;       -- Incoming register clock
        out_clk_i : in std_logic;       -- Converted clock
        out_clk_ok_i : in std_logic;

        -- Write interface
        reg_write_strobe_i : in std_logic;
        reg_write_ack_o : out std_logic;

        out_write_strobe_o : out std_logic;
        out_write_ack_i : in std_logic;

        -- Read interface
        reg_read_strobe_i : in std_logic;
        reg_read_data_o : out reg_data_t;
        reg_read_ack_o : out std_logic;

        out_read_strobe_o : out std_logic;
        out_read_data_i : in reg_data_t;
        out_read_ack_i : in std_logic
    );
end;

architecture register_cc of register_cc is
    signal reading : std_logic;
    signal out_read_strobe : std_logic;
    signal read_pending : std_logic := '0';

begin

    -- Read data needs to be latched across the clock domain crossing, all the
    -- other signals have the required lifetime.
    --   So that we follow the read semantics precisely (read_ack can be
    -- asserted in the same clock as read_strobe and so the data can be a single
    -- cycle read) we need to keep track of the reading state so that we latch
    -- the read data at the right time.
    reading <= out_read_strobe or read_pending;
    process (out_clk_i, out_clk_ok_i) begin
        if out_clk_ok_i = '0' then
            read_pending <= '0';
        elsif rising_edge(out_clk_i) then
            if reading = '1' and out_read_ack_i = '1' then
                reg_read_data_o <= out_read_data_i;
                read_pending <= '0';
            elsif out_read_strobe = '1' then
                read_pending <= '1';
            end if;
        end if;
    end process;

    read_cc_inst : entity work.register_strobe_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => out_clk_i,
        out_clk_ok_i => out_clk_ok_i,
        reg_strobe_i => reg_read_strobe_i,
        out_strobe_o => out_read_strobe,
        out_ack_i => out_read_ack_i,
        reg_ack_o => reg_read_ack_o
    );
    out_read_strobe_o <= out_read_strobe;

    write_cc_inst : entity work.register_strobe_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => out_clk_i,
        out_clk_ok_i => out_clk_ok_i,
        reg_strobe_i => reg_write_strobe_i,
        out_strobe_o => out_write_strobe_o,
        out_ack_i => out_write_ack_i,
        reg_ack_o => reg_write_ack_o
    );

end;
