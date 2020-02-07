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

        freq_base_i : in angle_t;       -- Frequency base
        start_freq_i : in angle_t;      -- Initial output frequency
        delta_freq_i : in angle_t;      -- Output frequency step
        capture_count_i : in capture_count_t;   -- Number of dwells to generate
        reset_phase_i : in std_ulogic;  -- Reset phase at start of sweep
        add_pll_freq_i : in std_ulogic; -- Option to add Tune PLL frequency
        last_turn_i : in std_ulogic;     -- Dwell is in its last turn
        tune_pll_offset_i : in signed(31 downto 0);

        state_end_o : out std_ulogic := '0';  -- Set during last turn of state
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

    signal next_nco_freq : angle_t;
    signal next_capture_cntr : capture_count_t;
    signal capture_cntr_zero : std_ulogic;   -- Set when capture_cntr is zero

    signal turn_clock_delay : std_ulogic;

    signal nco_reset : std_ulogic := '0';
    signal add_pll_freq : std_ulogic := '0';

    -- Extra delay neede dto align reset with frequency change.  This is needed
    -- to ensure that we correctly reset to phase 0 at the right time.
    constant RESET_DELAY : natural := 2;

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            capture_cntr_zero <= to_std_ulogic(capture_cntr = 0);

            -- Because most of the state transitions happen on turn_clock_i and
            -- most of the state has already been stable for a while before that
            -- we can precompute a number of values.
            if capture_cntr_zero = '1' then
                next_capture_cntr <= capture_count_i;
                next_nco_freq <= start_freq_i + freq_base_i;
            else
                next_capture_cntr <= capture_cntr - 1;
                next_nco_freq <= nco_freq + delta_freq_i;
            end if;

            if turn_clock_i = '1' then
                if reset_i = '1' then
                    capture_cntr <= (others => '0');
                elsif last_turn_i = '1' then
                    capture_cntr <= next_capture_cntr;
                    nco_freq <= next_nco_freq;
                    add_pll_freq <= add_pll_freq_i;
                end if;
            end if;

            -- Emit state_end_o during last turn of last state.
            turn_clock_delay <= turn_clock_i;
            if turn_clock_i = '1' or turn_clock_delay = '1' then
                state_end_o <= '0';
            else
                state_end_o <= last_turn_i and capture_cntr_zero;
            end if;

            nco_reset <= reset_phase_i and turn_clock_i and state_end_o;
        end if;
    end process;


    -- Add offset to computed frequency if required
    add_offset : entity work.tune_pll_offset generic map (
        DELAY => RESET_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        freq_offset_i => tune_pll_offset_i,
        enable_i => add_pll_freq,
        freq_i => nco_freq,
        freq_o => nco_freq_o
    );

    -- Delay reset to align with frequency change
    delay_reset : entity work.dlyline generic map (
        DLY => RESET_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => nco_reset,
        data_o(0) => nco_reset_o
    );
end;
