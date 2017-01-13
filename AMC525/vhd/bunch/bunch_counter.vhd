-- Bunch counter and revolution clock generator.
--
-- This module generates the current bunch number and a revolution clock
-- synchronised to bunch 0.  The target number of bunches is configured by
-- bunch_count_i, and when sync_trigger_i is pulsed the bunch number is set to
-- bunch_zero_i.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.bunch_defs.all;

entity bunch_counter is
    port (
        dsp_clk_i : in std_logic;

        sync_trigger_i : in std_logic;      -- Bunch synch trigger
        bunch_zero_i : in bunch_count_t;    -- Bunch zero offset on sync
        max_bunch_i : in bunch_count_t;     -- Maximum bunch number

        bunch_index_o : out bunch_count_t;  -- Current bunch number
        turn_clock_o : out std_logic        -- Revolution clock
    );
end;

architecture bunch_counter of bunch_counter is
    -- Bunch counter
    signal bunch_index : bunch_count_t := (others => '0');
    signal bunch_index_out : bunch_count_t := (others => '0');
    signal last_bunch : boolean := false;

    signal turn_clock : boolean := false;

    -- Used to suppress first turn_clk after synch
    signal bunch_synched : boolean := false;

begin
    last_bunch <= bunch_index = max_bunch_i;
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Bunch counter.  Normally increments modulo bunch count, or can
            -- be reset on appropriate trigger
            if sync_trigger_i = '1' then
                bunch_index <= bunch_zero_i;
            elsif last_bunch then
                bunch_index <= (others => '0');
                turn_clock <= bunch_synched;
            else
                bunch_index <= bunch_index + 1;
                turn_clock <= false;
            end if;

            -- Immediately after bunch synchronisation suppress one turn_clk.
            -- This ensures that we don't get turn_clock events too close
            -- together, which might disturb the operation of the sequencer.
            if sync_trigger_i = '1' then
                bunch_synched <= false;
            elsif last_bunch then
                bunch_synched <= true;
            end if;

            bunch_index_out <= bunch_index;
        end if;
    end process;

    bunch_index_o <= bunch_index_out;
    turn_clock_o <= to_std_logic(turn_clock);
end;
