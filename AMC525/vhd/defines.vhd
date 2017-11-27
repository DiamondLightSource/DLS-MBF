-- Constants and common type definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

package defines is
    -- Number of taps in ADC compensation filter
    constant ADC_FIR_TAP_COUNT : natural := 20;
    constant BUNCH_FIR_TAP_COUNT : natural := 16;
    constant DAC_FIR_TAP_COUNT : natural := 20;


    -- Register data is in blocks of 32-bits
    constant REG_DATA_WIDTH : natural := 32;
    subtype REG_DATA_RANGE is natural range REG_DATA_WIDTH-1 downto 0;
    subtype reg_data_t is std_logic_vector(REG_DATA_RANGE);
    type reg_data_array_t is array(natural range <>) of reg_data_t;

    -- Number of bunch control banks
    constant BUNCH_BANK_BITS : natural := 2;
    -- Number of selectable FIR coefficient sets
    constant FIR_BANK_BITS : natural := 2;

    constant CHANNEL_COUNT : natural := 2;
    subtype CHANNELS is natural range 0 to CHANNEL_COUNT-1;

    -- This determines the maximum number of bunches in a machine turn, equal to
    -- 2**BUNCH_NUM_BITS.  At DLS with our 936 bunches a value of 10 is
    -- sufficient.
    constant BUNCH_NUM_BITS : natural := 10;
    subtype bunch_count_t is unsigned(BUNCH_NUM_BITS-1 downto 0);

end;
