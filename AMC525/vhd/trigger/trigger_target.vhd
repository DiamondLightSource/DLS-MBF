-- Trigger target handler
--
-- Generates a trigger handler associated with a set of trigger sources together
-- with control and status bits for each trigger source.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.trigger_defs.all;

entity trigger_target is
    port (
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        triggers_i : in std_logic_vector;   -- Active in
        blanking_window_i : in std_logic;   -- Set if blanking active
        setup_i : in trigger_setup_t;

        readback_o : out trigger_readback_t;
        trigger_o : out std_logic
    );
end;

architecture arch of trigger_target is
    -- Trigger detect and report.  setup_i.enables selects a mask of possible
    -- trigger sources and setup_i.blanking selects which of these are to be
    -- ignored during the blanking pulse.  When a trigger is detected we latch
    -- the corresponding trigger source into readback_o.source.
    signal blanking_mask : setup_i.blanking'SUBTYPE;
    signal trigger_sources : triggers_i'SUBTYPE;
    signal trigger_in : std_logic;

    -- When trigger accepted by trigger handler latch the sources active at that
    -- instant, and reset the sources when rearming or soft triggering.
    signal trigger_seen : std_logic;

begin
    assert triggers_i'LENGTH = setup_i.enables'LENGTH severity failure;
    assert setup_i.enables'LENGTH = setup_i.blanking'LENGTH severity failure;
    assert setup_i.blanking'LENGTH = readback_o.source'LENGTH severity failure;

    blanking_mask <=
        setup_i.blanking when blanking_window_i = '1' else (others => '0');
    trigger_in <= vector_or(trigger_sources);

    trigger_handler : entity work.trigger_handler port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,
        trigger_i => trigger_in,
        arm_i => setup_i.arm,
        disarm_i => setup_i.disarm,
        delay_i => setup_i.delay,
        trigger_o => trigger_o,
        armed_o => readback_o.armed,
        trigger_seen_o => trigger_seen
    );

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Capture current trigger sources
            trigger_sources <=
                triggers_i and setup_i.enables and not blanking_mask;

            if trigger_seen = '1' then
                readback_o.source <= trigger_sources;
            elsif setup_i.arm = '1' then
                readback_o.source <= (readback_o.source'RANGE => '0');
            end if;
        end if;
    end process;
end;
