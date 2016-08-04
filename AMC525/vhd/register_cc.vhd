-- Register clock crossing.
--
-- Transports a single block of registers across the clock domain between the
-- AXI and DSP clocks.  An extra complication: if the DSP clock is inactive then
-- the transaction is completed anyway!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity register_cc is
    port (
        -- Clocks
        axi_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        dsp_rst_n_i : in std_logic;

        -- Write interface
        axi_write_strobe_i : in std_logic;
        axi_write_ack_o : out std_logic;

        dsp_write_strobe_o : out std_logic;
        dsp_write_ack_i : in std_logic;

        -- Read interface
        axi_read_strobe_i : in std_logic;
        axi_read_data_o : out reg_data_t;
        axi_read_ack_o : out std_logic;

        dsp_read_strobe_o : out std_logic;
        dsp_read_data_i : in reg_data_t;
        dsp_read_ack_i : in std_logic
    );
end;

architecture register_cc of register_cc is
    signal reading : std_logic;
    signal dsp_read_strobe : std_logic;
    signal read_pending : std_logic := '0';

begin

    -- Read data needs to be latched across the clock domain crossing, all the
    -- other signals have the required lifetime.
    --   So that we follow the read semantics precisely (read_ack can be
    -- asserted in the same clock as read_strobe and so the data can be a single
    -- cycle read) we need to keep track of the reading state so that we latch
    -- the read data at the right time.
    reading <= dsp_read_strobe or read_pending;
    process (dsp_clk_i, dsp_rst_n_i) begin
        if dsp_rst_n_i = '0' then
            read_pending <= '0';
        elsif rising_edge(dsp_clk_i) then
            if reading = '1' and dsp_read_ack_i = '1' then
                axi_read_data_o <= dsp_read_data_i;
                read_pending <= '0';
            elsif dsp_read_strobe = '1' then
                read_pending <= '1';
            end if;
        end if;
    end process;

    read_cc_inst : entity work.register_strobe_cc port map (
        axi_clk_i => axi_clk_i,
        dsp_clk_i => dsp_clk_i,
        dsp_rst_n_i => dsp_rst_n_i,
        axi_strobe_i => axi_read_strobe_i,
        dsp_strobe_o => dsp_read_strobe,
        dsp_ack_i => dsp_read_ack_i,
        axi_ack_o => axi_read_ack_o
    );
    dsp_read_strobe_o <= dsp_read_strobe;

    write_cc_inst : entity work.register_strobe_cc port map (
        axi_clk_i => axi_clk_i,
        dsp_clk_i => dsp_clk_i,
        dsp_rst_n_i => dsp_rst_n_i,
        axi_strobe_i => axi_write_strobe_i,
        dsp_strobe_o => dsp_write_strobe_o,
        dsp_ack_i => dsp_write_ack_i,
        axi_ack_o => axi_write_ack_o
    );

end;
