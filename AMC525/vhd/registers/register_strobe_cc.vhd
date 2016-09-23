-- One element of register strobe -> ack clock domain crossing
-- The algorithm used here is taken from the paper
--  "Fourteen Ways to Fool Your Synchronizer", Ran Ginosar, ASYNC '03
-- with modification to ensure that when the output clock is in reset we force
-- an acknowledge, to avoid lockup of the REG bus.

library ieee;
use ieee.std_logic_1164.all;

use work.support.all;

entity register_strobe_cc is
    port (
        -- Clocks plus reset for out clock
        reg_clk_i : in std_logic;
        out_clk_i : in std_logic;
        out_rst_n_i : in std_logic;

        -- Strobe from REG to OUT clock
        reg_strobe_i : in std_logic;
        out_strobe_o : out std_logic;

        -- Acknowledge from OUT to REG clock
        out_ack_i : in std_logic;
        reg_ack_o : out std_logic
    );
end;

architecture register_strobe_cc of register_strobe_cc is
    -- REG clock
    signal reg_request : std_logic;
    signal reg_response : std_logic;
    signal reg_ack : std_logic;
    signal reg_dsp_rst_n : std_logic;
    signal reg_dsp_reset_n : std_logic;
    type reg_state_t is (REG_IDLE, REG_BUSY, REG_DONE);
    signal reg_state : reg_state_t := REG_IDLE;

    -- OUT clock
    signal out_reset_n : std_logic;
    signal out_request : std_logic;
    signal out_response : std_logic;
    type out_state_t is (OUT_IDLE, OUT_BUSY, OUT_DONE);
    signal out_state : out_state_t := OUT_IDLE;

begin
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- REG clock domain

    sync_reset_inst : entity work.sync_bit port map (
        clk_i => reg_clk_i,
        bit_i => out_rst_n_i,
        bit_o => reg_dsp_rst_n
    );

    sync_response_inst : entity work.sync_bit port map (
        clk_i => reg_clk_i,
        bit_i => out_response,
        bit_o => reg_response
    );

    process (reg_clk_i) begin
        if rising_edge(reg_clk_i) then
            case reg_state is
                when REG_IDLE =>
                    if reg_strobe_i = '1' then
                        reg_state <= REG_BUSY;
                    end if;
                when REG_BUSY =>
                    if reg_response = '1' or reg_dsp_reset_n = '0' then
                        reg_state <= REG_DONE;
                    end if;
                when REG_DONE =>
                    if reg_response = '0' or reg_dsp_reset_n = '0' then
                        reg_state <= REG_IDLE;
                    end if;
            end case;

            -- Ensure we only come out of dsp reset in idle state.
            if reg_dsp_rst_n = '0' then
                reg_dsp_reset_n <= '0';
            elsif reg_dsp_rst_n = '1' and reg_state = REG_IDLE then
                reg_dsp_reset_n <= '1';
            end if;
        end if;
    end process;
    reg_request <= to_std_logic(reg_state = REG_BUSY);
    reg_ack     <= to_std_logic(reg_state = REG_IDLE);

    reg_ack_inst : entity work.edge_detect port map (
        clk_i => reg_clk_i,
        data_i => reg_ack,
        edge_o => reg_ack_o
    );


    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- OUT clock domain

    sync_request_inst : entity work.sync_bit port map (
        clk_i => out_clk_i,
        bit_i => reg_request,
        bit_o => out_request
    );

    out_reset_inst : entity work.sync_reset port map (
        clk_i => out_clk_i,
        clk_ok_i => reg_dsp_reset_n,
        sync_clk_ok_o => out_reset_n
    );

    process (out_clk_i, out_reset_n) begin
        if out_reset_n = '0' then
            out_state <= OUT_IDLE;
        elsif rising_edge(out_clk_i) then
            case out_state is
                when OUT_IDLE =>
                    if out_request = '1' then
                        out_state <= OUT_BUSY;
                    end if;
                when OUT_BUSY =>
                    if out_ack_i = '1' then
                        out_state <= OUT_DONE;
                    end if;
                when OUT_DONE =>
                    if out_request = '0' then
                        out_state <= OUT_IDLE;
                    end if;
            end case;
        end if;
    end process;
    out_response <= to_std_logic(out_state = OUT_DONE);

    out_strobe_inst : entity work.edge_detect port map (
        clk_i => out_clk_i,
        data_i => out_request,
        edge_o => out_strobe_o
    );
end;
