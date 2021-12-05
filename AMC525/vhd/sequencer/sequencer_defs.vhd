-- Sequencer program state

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.dsp_defs.all;
use work.nco_defs.all;

package sequencer_defs is

    subtype dwell_count_t is unsigned(15 downto 0);
    subtype capture_count_t is unsigned(15 downto 0);
    subtype window_rate_t is unsigned(31 downto 0);

    type seq_state_t is record
        start_freq : angle_t;           -- Sweep start frequency
        delta_freq : angle_t;           -- Frequency advance per capture
        dwell_count : dwell_count_t;    -- Dwell count turns per capture
        capture_count : capture_count_t;    -- Number of captures in state
        bunch_bank : unsigned(1 downto 0);  -- Bunch bank selection
        nco_gain : nco_gain_t;          -- Sweep NCO gain select
        enable_window : std_ulogic;     -- Enable detector window
        enable_write : std_ulogic;      -- Enable data capture for this sweep
        enable_blanking : std_ulogic;   -- Observe blanking input signal
        reset_phase : std_ulogic;       -- Reset NCO phase at start
        enable_tune_pll : std_ulogic;   -- Enable Tune PLL frequency offset
        disable_super : std_ulogic;     -- Disable super sequencer offset
        window_rate : window_rate_t;    -- Detector window advance rate
        holdoff_count : dwell_count_t;  -- Holdoff count before each dwell
        state_holdoff : dwell_count_t;  -- Holdoff at start of state
    end record;

    -- Sequencer specific types
    subtype seq_pc_t is unsigned(2 downto 0);
    subtype super_count_t is unsigned(10 downto 0);

    subtype detector_win_t is signed(15 downto 0);

    constant initial_seq_state : seq_state_t := (
        start_freq => (others => '0'),
        delta_freq => (others => '0'),
        dwell_count => (others => '0'),
        capture_count => (others => '0'),
        bunch_bank => (others => '0'),
        nco_gain => (others => '0'),
        enable_window => '0',
        enable_write => '0',
        enable_blanking => '0',
        reset_phase => '0',
        enable_tune_pll => '0',
        disable_super => '0',
        window_rate => (others => '0'),
        holdoff_count => (others => '0'),
        state_holdoff => (others => '0')
    );

end package;
