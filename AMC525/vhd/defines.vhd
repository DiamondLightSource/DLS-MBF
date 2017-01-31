-- Constants and common type definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

package defines is

    -- Register data is in blocks of 32-bits
    constant REG_DATA_WIDTH : natural := 32;
    subtype reg_data_t is std_logic_vector(REG_DATA_WIDTH-1 downto 0);
    type reg_data_array_t is array(natural range <>) of reg_data_t;

    -- Number of bunch control banks
    constant BUNCH_BANK_BITS : natural := 2;
    -- Number of selectable FIR coefficient sets
    constant FIR_BANK_BITS : natural := 2;

    constant FIR_DATA_WIDTH : natural := 36;
    subtype FIR_DATA_RANGE is natural range FIR_DATA_WIDTH-1 downto 0;

    -- External interface constants
    constant ADC_INP_WIDTH : natural := 14;     -- ADC input data width
    constant DAC_OUT_WIDTH : natural := 16;     -- DAC output data width

    -- All our DSP processing is done at half ADC clock rate, so we have two
    -- data processing lanes.
    constant LANE_COUNT : natural := 2;
    subtype LANES is natural range 0 to LANE_COUNT-1;

    constant CHANNEL_COUNT : natural := 2;
    subtype CHANNELS is natural range 0 to CHANNEL_COUNT-1;

    -- This determines the maximum number of bunches in a machine turn, equal to
    -- LANE_COUNT * 2**BUNCH_NUM_BITS.  At DLS with our 936 bunches and 2 lanes
    -- in the FPGA design a value of 9 is sufficient.
    constant BUNCH_NUM_BITS : natural := 9;
    subtype bunch_count_t is unsigned(BUNCH_NUM_BITS-1 downto 0);

end;
