library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package trigger_defs is
    type turn_clock_setup_t is record
        start_sync : std_ulogic;             -- Start clock resynchronisation
        read_sync : std_ulogic;              -- Sample clock and error count
        max_bunch : bunch_count_t;          -- Maximum expected bunch count
        clock_offset : unsigned(BUNCH_NUM_BITS-1 downto 0);
    end record;

    type turn_clock_readback_t is record
        sync_busy : std_ulogic;              -- Set during synchronisation
        turn_counter : unsigned(19 downto 0);   -- Turns since last read
        error_counter : unsigned(19 downto 0);  -- Sync errors since last read
    end record;


    subtype TRIGGER_SET is natural range 6 downto 0;

    -- Programmable trigger configuration
    type trigger_setup_t is record
        arm : std_ulogic;                    -- Pulse to arm the trigger
        fire : std_ulogic;                   -- Pulse to fire trigger
        disarm : std_ulogic;                 -- Pulse to disarm trigger
        delay : unsigned(15 downto 0);      -- Turn delay from trigger fire
        enables : std_ulogic_vector(TRIGGER_SET);    -- Enabled triggers
        blanking : std_ulogic_vector(TRIGGER_SET);   -- Blanking enables
    end record;

    -- Trigger readbacks
    type trigger_readback_t is record
        armed : std_ulogic;                  -- Set while trigger is armed
        source : std_ulogic_vector(TRIGGER_SET);     -- Contributions to trigger
    end record;

    type trigger_setup_channels is array(CHANNELS) of trigger_setup_t;
    type trigger_readback_channels is array(CHANNELS) of trigger_readback_t;
end;
