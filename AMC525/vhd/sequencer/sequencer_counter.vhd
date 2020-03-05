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
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;
        reset_i : in std_ulogic;

        freq_base_i : in angle_t;
        seq_state_i : in seq_state_t;
        last_turn_i : in std_ulogic;     -- Dwell is in its last turn
        tune_pll_offset_i : in signed(31 downto 0);

        state_end_o : out std_ulogic := '0';  -- Set during last turn of state

        enable_pll_o : out std_ulogic;
        nco_freq_o : out angle_t := (others => '0'); -- Output frequency
        nco_reset_o : out std_ulogic := '0'
    );
end;

architecture arch of sequencer_counter is
    -- Frequency generator output and capture count: advance the frequency and
    -- count a capture on a successful completion of a dwell.  On a reset force
    -- the capture counter to zero.
    signal capture_cntr : capture_count_t := (others => '0');
    signal nco_freq : angle_t := (others => '0');
    signal nco_reset : std_ulogic := '0';

    signal next_nco_freq : angle_t;
    signal next_capture_cntr : capture_count_t;
    signal capture_cntr_zero : std_ulogic;   -- Set when capture_cntr is zero

    signal turn_clock_delay : std_ulogic;

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            capture_cntr_zero <= to_std_ulogic(capture_cntr = 0);

            -- Because most of the state transitions happen on turn_clock_i and
            -- most of the state has already been stable for a while before that
            -- we can precompute a number of values.
            if capture_cntr_zero = '1' then
                next_capture_cntr <= seq_state_i.capture_count;
                if seq_state_i.disable_super then
                    next_nco_freq <= seq_state_i.start_freq;
                else
                    next_nco_freq <= seq_state_i.start_freq + freq_base_i;
                end if;
            else
                next_capture_cntr <= capture_cntr - 1;
                next_nco_freq <= nco_freq + seq_state_i.delta_freq;
            end if;

            if turn_clock_i = '1' then
                if reset_i = '1' then
                    capture_cntr <= (others => '0');
                elsif last_turn_i = '1' then
                    capture_cntr <= next_capture_cntr;
                    nco_freq <= next_nco_freq;
                    enable_pll_o <= seq_state_i.enable_tune_pll;
                end if;
            end if;

            -- Emit state_end_o during last turn of last state.
            turn_clock_delay <= turn_clock_i;
            if turn_clock_i = '1' or turn_clock_delay = '1' then
                state_end_o <= '0';
            else
                state_end_o <= last_turn_i and capture_cntr_zero;
            end if;

            nco_reset <=
                seq_state_i.reset_phase and turn_clock_i and state_end_o;
        end if;
    end process;

    nco_freq_o <= nco_freq;
    nco_reset_o <= nco_reset;
end;
