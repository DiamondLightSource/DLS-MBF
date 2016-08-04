-- One element of register strobe -> ack clock domain crossing
-- The algorithm used here is taken from the paper
--  "Fourteen Ways to Fool Your Synchronizer", Ran Ginosar, ASYNC '03
-- with modification to ensure that when the DSP is in reset we force an
-- acknowledge, to avoid lockup of the AXI bus.

library ieee;
use ieee.std_logic_1164.all;

use work.support.all;

entity register_strobe_cc is
    port (
        -- Clocks plus reset for DSP
        axi_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        dsp_rst_n_i : in std_logic;

        -- Strobe from AXI to DSP clock
        axi_strobe_i : in std_logic;
        dsp_strobe_o : out std_logic;

        -- Acknowledge from DSP to AXI clock
        dsp_ack_i : in std_logic;
        axi_ack_o : out std_logic
    );
end;

architecture register_strobe_cc of register_strobe_cc is
    -- AXI clock
    signal axi_request : std_logic;
    signal axi_response : std_logic;
    signal axi_ack : std_logic;
    signal axi_dsp_rst_n : std_logic;
    signal dsp_reset : boolean;
    type axi_state_t is (AXI_IDLE, AXI_BUSY, AXI_DONE);
    signal axi_state : axi_state_t := AXI_IDLE;

    -- DSP clock
    signal dsp_request : std_logic;
    signal dsp_response : std_logic;
    type dsp_state_t is (DSP_IDLE, DSP_BUSY, DSP_DONE);
    signal dsp_state : dsp_state_t := DSP_IDLE;

begin
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- AXI clock domain

    sync_reset_inst : entity work.sync_bit port map (
        clk_i => axi_clk_i,
        bit_i => dsp_rst_n_i,
        bit_o => axi_dsp_rst_n
    );

    sync_response_inst : entity work.sync_bit port map (
        clk_i => axi_clk_i,
        bit_i => dsp_response,
        bit_o => axi_response
    );

    process (axi_clk_i) begin
        if rising_edge(axi_clk_i) then
            case axi_state is
                when AXI_IDLE =>
                    if axi_strobe_i = '1' then
                        axi_state <= AXI_BUSY;
                    end if;
                when AXI_BUSY =>
                    if axi_response = '1' or dsp_reset then
                        axi_state <= AXI_DONE;
                    end if;
                when AXI_DONE =>
                    if axi_response = '0' or dsp_reset then
                        axi_state <= AXI_IDLE;
                    end if;
            end case;

            -- Ensure we only come out of dsp reset in idle state.
            if axi_dsp_rst_n = '0' then
                dsp_reset <= true;
            elsif axi_dsp_rst_n = '1' and axi_state = AXI_IDLE then
                dsp_reset <= false;
            end if;
        end if;
    end process;
    axi_request <= to_std_logic(axi_state = AXI_BUSY);
    axi_ack     <= to_std_logic(axi_state = AXI_IDLE);

    axi_ack_inst : entity work.edge_detect port map (
        clk_i => axi_clk_i,
        data_i => axi_ack,
        edge_o => axi_ack_o
    );


    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- DSP clock domain

    sync_request_inst : entity work.sync_bit port map (
        clk_i => dsp_clk_i,
        bit_i => axi_request,
        bit_o => dsp_request
    );

    process (dsp_clk_i, dsp_reset) begin
        if dsp_reset then
            dsp_state <= DSP_IDLE;
        elsif rising_edge(dsp_clk_i) then
            case dsp_state is
                when DSP_IDLE =>
                    if dsp_request = '1' then
                        dsp_state <= DSP_BUSY;
                    end if;
                when DSP_BUSY =>
                    if dsp_ack_i = '1' then
                        dsp_state <= DSP_DONE;
                    end if;
                when DSP_DONE =>
                    if dsp_request = '0' then
                        dsp_state <= DSP_IDLE;
                    end if;
            end case;
        end if;
    end process;
    dsp_response <= to_std_logic(dsp_state = DSP_DONE);

    dsp_strobe_inst : entity work.edge_detect port map (
        clk_i => dsp_clk_i,
        data_i => dsp_request,
        edge_o => dsp_strobe_o
    );
end;
