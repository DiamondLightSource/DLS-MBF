library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package trigger_defs is
    type turn_clock_setup_t is record
        start_sync : std_logic;             -- Start clock resynchronisation
        start_sample : std_logic;           -- Sample clock count and phase
        max_bunch : bunch_count_t;          -- Maximum expected bunch count
        clock_offsets : unsigned_array(CHANNELS)(BUNCH_NUM_BITS-1 downto 0);
    end record;

    type turn_clock_readback_t is record
        sync_busy : std_logic;          -- Set during synchronisation
        sync_phase : std_logic;         -- ADC clock phase at synchronisation
        sync_error : std_logic;         -- Set if synchronisation mismatch seen
        sample_busy : std_logic;        -- Set during sampling
        sample_phase : std_logic;       -- ADC clock phase at sample
        sample_count : bunch_count_t;   -- Sample count at sample
    end record;


    subtype TRIGGER_SET is natural range 6 downto 0;

    -- Programmable trigger configuration
    type trigger_setup_t is record
        arm : std_logic;                    -- Pulse to arm the trigger
        disarm : std_logic;                 -- Pulse to disarm trigger
        delay : unsigned(23 downto 0);      -- Turn delay from trigger fire
        enables : std_logic_vector(TRIGGER_SET);    -- Enabled triggers
        blanking : std_logic_vector(TRIGGER_SET);   -- Blanking enables
    end record;

    -- Trigger readbacks
    type trigger_readback_t is record
        armed : std_logic;                  -- Set while trigger is armed
        source : std_logic_vector(TRIGGER_SET);     -- Contributions to trigger
    end record;

    type trigger_setup_channels is array(CHANNELS) of trigger_setup_t;
    type trigger_readback_channels is array(CHANNELS) of trigger_readback_t;
end;
