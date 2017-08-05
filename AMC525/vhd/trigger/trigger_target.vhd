-- Trigger target handler
--
-- Generates a trigger handler associated with a set of trigger sources together
-- with control and status bits for each trigger source.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity trigger_target is
    port (
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        triggers_i : in std_logic_vector;   -- Active in
        blanking_window_i : in std_logic;   -- Set if blanking active

        arm_i : in std_logic;
        disarm_i : in std_logic;
        delay_i : in unsigned;
        enables_i : in std_logic_vector;    -- Enables
        blanking_i : in std_logic_vector;   -- Blanking

        armed_o : out std_logic;
        source_o : out std_logic_vector;    -- Seen

        trigger_o : out std_logic
    );
end;

architecture arch of trigger_target is
    -- Trigger detect and report.  enables_i selects a mask of possible
    -- trigger sources and blanking_i selects which of these are to be ignored
    -- during the blanking pulse.  When a trigger is detected we latch the
    -- corresponding trigger source into source_o.
    signal blanking_mask : blanking_i'SUBTYPE;
    signal trigger_sources : triggers_i'SUBTYPE;
    signal trigger_in : std_logic;

    -- When trigger accepted by trigger handler latch the sources active at that
    -- instant, and reset the sources when rearming or soft triggering.
    signal trigger_seen : std_logic;

begin
    assert triggers_i'LENGTH = enables_i'LENGTH severity failure;
    assert enables_i'LENGTH = blanking_i'LENGTH severity failure;
    assert blanking_i'LENGTH = source_o'LENGTH severity failure;

    blanking_mask <=
        blanking_i when blanking_window_i = '1' else (others => '0');
    trigger_in <= vector_or(trigger_sources);

    trigger_handler : entity work.trigger_handler port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,
        trigger_i => trigger_in,
        arm_i => arm_i,
        disarm_i => disarm_i,
        delay_i => delay_i,
        trigger_o => trigger_o,
        armed_o => armed_o,
        trigger_seen_o => trigger_seen
    );

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Capture current trigger sources
            trigger_sources <= triggers_i and enables_i and not blanking_mask;

            if trigger_seen = '1' then
                source_o <= trigger_sources;
            elsif arm_i = '1' then
                source_o <= (source_o'RANGE => '0');
            end if;
        end if;
    end process;
end;
