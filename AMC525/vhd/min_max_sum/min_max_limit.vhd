-- Event detection based on current bunch delta

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity min_max_limit is
    port (
        dsp_clk_i : in std_logic;
        adc_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- The incoming delta is on the ADC clock
        delta_i : in unsigned;

        limit_i : in unsigned;
        reset_event_i : in std_logic;

        limit_event_o : out std_logic := '0'
    );
end;

architecture min_max_limit of min_max_limit is
    signal limit_detect_adc : std_logic := '0';
    signal limit_detect : std_logic := '0';
    signal limit_event : std_logic := '0';
    signal limit_event_edge : std_logic;

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            limit_detect_adc <= to_std_logic(delta_i > limit_i);
            if adc_phase_i = '0' then
                limit_detect <= limit_detect_adc;
            else
                limit_detect <= limit_detect or limit_detect_adc;
            end if;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if reset_event_i = '1' then
                limit_event <= '0';
            elsif limit_detect = '1' then
                limit_event <= '1';
            end if;

            limit_event_o <= limit_event_edge;
        end if;
    end process;

    -- Convert detection of event into a single pulse
    edge_detect_inst : entity work.edge_detect port map (
        clk_i => dsp_clk_i,
        data_i => limit_event,
        edge_o => limit_event_edge
    );
end;
