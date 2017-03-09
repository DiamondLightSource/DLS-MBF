-- Sequencer counter and frequency generator
--
-- Counts through the evolution of a single sequencer state and generates the
-- end of state needed for the master controller.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.sequencer_defs.all;

entity sequencer_counter is
    port (
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;
        reset_i : in std_logic;

        freq_base_i : in angle_t;       -- Frequency base
        start_freq_i : in angle_t;      -- Initial output frequency
        delta_freq_i : in angle_t;      -- Output frequency step
        capture_count_i : in capture_count_t;   -- Number of dwells to generate
        last_turn_i : in std_logic;     -- Dwell is in its last turn

        state_end_o : out std_logic;    -- Set during last turn of state
        hom_freq_o : out angle_t        -- Output frequency
    );
end;

architecture arch of sequencer_counter is
    -- Frequency generator output and capture count: advance the frequency and
    -- count a capture on a successful completion of a dwell.  On a reset force
    -- the capture counter to zero.
    signal capture_cntr : capture_count_t := (others => '0');
    signal hom_freq : angle_t := (others => '0');

    signal next_hom_freq : angle_t;
    signal next_capture_cntr : capture_count_t;
    signal capture_cntr_zero : std_logic;   -- Set when capture_cntr is zero

    signal turn_clock_delay : std_logic;

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            capture_cntr_zero <= to_std_logic(capture_cntr = 0);

            -- Because most of the state transitions happen on turn_clock_i and
            -- most of the state has already been stable for a while before that
            -- we can precompute a number of values.
            if capture_cntr_zero = '1' then
                next_capture_cntr <= capture_count_i;
                next_hom_freq <= start_freq_i + freq_base_i;
            else
                next_capture_cntr <= capture_cntr - 1;
                next_hom_freq <= hom_freq + delta_freq_i;
            end if;

            if turn_clock_i = '1' then
                if reset_i = '1' then
                    capture_cntr <= (others => '0');
                elsif last_turn_i = '1' then
                    capture_cntr <= next_capture_cntr;
                    hom_freq <= next_hom_freq;
                end if;
            end if;

            -- Emit state_end_o during last turn of last state.
            turn_clock_delay <= turn_clock_i;
            if turn_clock_i = '1' or turn_clock_delay = '1' then
                state_end_o <= '0';
            else
                state_end_o <= last_turn_i and capture_cntr_zero;
            end if;

            hom_freq_o <= hom_freq;
        end if;
    end process;
end;
