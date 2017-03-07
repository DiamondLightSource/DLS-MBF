-- Dwell clock generator
--
-- Generates capture clock outputs for a single dwell.  The output first_turn_o
-- is pulsed for one clock immediately after turn_clock_i on the first turn of a
-- data capture dwell, and last_turn_o is held high for the entire duration of
-- the last turn of capture except for the clock immediately after turn_clock_i
-- when last_turn_o is held low.  Note that last_turn_o is valid for the
-- preceding turn during turn_clock_i.
--
--                    . Dwell     . Holdoff   . Two turn dwell        .
--                    _           _           _           _           _
--  turn_clock_i    _/ \_________/ \_________/ \_________/ \_________/ \__
--                      _                       _
--  first_turn_o    ___/ \_____________________/ \________________________
--                        _________                           _________
--  last_turn_o     _____/         \_________________________/         \__
--
-- Note that the presence of blanking_i can complicate things: in this case it
-- is possible for first_turn_o to be generated repeatedly, but an invalid
-- last_turn_o is never generated.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.sequencer_defs.all;

entity sequencer_dwell is
    port (
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;
        reset_i : in std_logic;

        dwell_count_i : in dwell_count_t;   -- Dwell duration
        holdoff_count_i : in dwell_count_t; -- Holdoff duration
        blanking_i : in std_logic;          -- Forces blanking if set

        first_turn_o : out std_logic := '0'; -- Start capture and reset detector
        last_turn_o : out std_logic := '0'  -- Set during last turn of a dwell
    );
end;

architecture sequencer_dwell of sequencer_dwell is
    -- Set during holdoff period
    signal in_holdoff : std_logic := '0';
    -- Counts turns during holdoff
    signal holdoff_ctr : dwell_count_t := (others => '0');
    -- Counts turns during normal dwell
    signal dwell_ctr : dwell_count_t := (others => '0');

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if turn_clock_i = '1' then
                if reset_i = '1' then
                    in_holdoff <= '1';
                    holdoff_ctr <= (others => '0');
                elsif blanking_i = '1' then
                    -- Cancel the dwell by forcing a holdoff.  Note we
                    -- deliberately add one to the default holdoff which forces
                    -- a sensible holdoff time.
                    in_holdoff <= '1';
                    holdoff_ctr <= holdoff_count_i;
                elsif in_holdoff = '1' then
                    -- Holdoff interval at start of dwell: count down the
                    -- holdoff counter before starting the dwell proper
                    if holdoff_ctr = 0 then
                        in_holdoff <= '0';
                        dwell_ctr <= dwell_count_i;
                        first_turn_o <= '1';
                    else
                        holdoff_ctr <= holdoff_ctr - 1;
                    end if;
                elsif dwell_ctr = 0 then
                    -- End of normal dwell
                    -- Either go into holdoff or straight into dwell
                    if holdoff_count_i = 0 then
                        dwell_ctr <= dwell_count_i;
                        first_turn_o <= '1';
                    else
                        in_holdoff <= '1';
                        holdoff_ctr <= holdoff_count_i - 1;
                    end if;
                else
                    -- Count down normal dwell.
                    dwell_ctr <= dwell_ctr - 1;
                end if;
            else
                first_turn_o <= '0';
            end if;

            -- Last turn detection.
            if turn_clock_i = '1' then
                last_turn_o <= '0';
            else
                last_turn_o <= not in_holdoff and to_std_logic(dwell_ctr = 0);
            end if;
        end if;
    end process;
end;
