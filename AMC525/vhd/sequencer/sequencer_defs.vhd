-- Sequencer program state

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.nco_defs.all;

package sequencer_defs is

    subtype dwell_count_t is unsigned(15 downto 0);
    subtype capture_count_t is unsigned(15 downto 0);

    type seq_state_t is record
        start_freq : angle_t;           -- Sweep start frequency
        delta_freq : angle_t;           -- Frequency advance per capture
        dwell_count : dwell_count_t;    -- Dwell count turns per capture
        capture_count : capture_count_t;    -- Number of captures in state
        bunch_bank : unsigned(1 downto 0);  -- Bunch bank selection
        hom_gain : unsigned(3 downto 0);    -- Sweep NCO gain select
        hom_enable : std_logic;         -- Enable sweep output
        enable_window : std_logic;      -- Enable detector window
        enable_write : std_logic;       -- Enable data capture for this sweep
        enable_blanking : std_logic;    -- Observe blanking input signal
        window_rate : angle_t;          -- Detector window advance rate
        holdoff_count : dwell_count_t;  -- Holdoff count before each dwell
    end record;

    -- Sequencer specific types
    subtype seq_pc_t is unsigned(2 downto 0);
    subtype super_count_t is unsigned(9 downto 0);

    subtype hom_win_t is signed(15 downto 0);

    constant initial_seq_state : seq_state_t := (
        start_freq => (others => '0'),
        delta_freq => (others => '0'),
        dwell_count => (others => '0'),
        capture_count => (others => '0'),
        bunch_bank => (others => '0'),
        hom_gain => (others => '0'),
        hom_enable => '0',
        enable_window => '0',
        enable_write => '0',
        enable_blanking => '0',
        window_rate => (others => '0'),
        holdoff_count => (others => '0')
    );

end package;
