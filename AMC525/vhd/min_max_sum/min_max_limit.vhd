-- Event detection based on current bunch delta

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity min_max_limit is
    port (
        dsp_clk_i : in std_logic;

        delta_i : in unsigned_array;
        limit_i : in unsigned;
        reset_event_i : in std_logic;

        limit_event_o : out std_logic
    );
end;

architecture min_max_limit of min_max_limit is
    signal limit_detect : std_logic_vector(CHANNELS) := (others => '0');
    signal limit_detect_any : std_logic;
    signal limit_event : std_logic := '0';

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            for c in CHANNELS loop
                limit_detect(c) <= to_std_logic(delta_i(c) > limit_i);
            end loop;

            if reset_event_i = '1' then
                limit_event <= '0';
            elsif limit_detect_any = '1' then
                limit_event <= '1';
            end if;
        end if;
    end process;

    limit_detect_any <= vector_or(limit_detect);

    -- Convert detection of event into a single pulse
    edge_detect_inst : entity work.edge_detect port map (
        clk_i => dsp_clk_i,
        data_i => limit_event,
        edge_o => limit_event_o
    );
end;
