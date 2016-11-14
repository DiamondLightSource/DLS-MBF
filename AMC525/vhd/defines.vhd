-- Constants and common type definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.support.all;

package defines is

    -- The register control interface consists of a set of "modules" each of
    -- can implement a number of registers.
    constant MOD_ADDR_BITS : natural := 2;
    constant REG_ADDR_BITS : natural := 5;

    -- Register data is in blocks of 32-bits
    constant REG_DATA_WIDTH : natural := 32;
    subtype reg_data_t is std_logic_vector(REG_DATA_WIDTH-1 downto 0);
    type reg_data_array_t is array(natural range <>) of reg_data_t;

    -- Modules are selected by appropriate strobes
    constant MOD_ADDR_COUNT : natural := 2**MOD_ADDR_BITS;
    subtype MOD_ADDR_RANGE is natural range 0 to MOD_ADDR_COUNT-1;
    subtype mod_strobe_t is std_logic_vector(MOD_ADDR_RANGE);

    -- Within a single module we have an addressable range
    constant REG_ADDR_COUNT : natural := 2**REG_ADDR_BITS;
    subtype REG_ADDR_RANGE is natural range 0 to REG_ADDR_COUNT-1;
    subtype reg_addr_t is unsigned(REG_ADDR_BITS-1 downto 0);
    subtype reg_strobe_t is std_logic_vector(REG_ADDR_RANGE);


    constant DDR0_ADDR_WIDTH : natural := 31;
    constant DDR1_ADDR_WIDTH : natural := 27;
    subtype DDR0_ADDR_RANGE is natural range DDR0_ADDR_WIDTH-1 downto 0;
    subtype DDR1_ADDR_RANGE is natural range DDR1_ADDR_WIDTH-1 downto 0;
    subtype ddr0_addr_t is std_logic_vector(DDR0_ADDR_RANGE);
    subtype ddr1_addr_t is std_logic_vector(DDR1_ADDR_RANGE);


    -- External interface constants
    constant ADC_INP_WIDTH : natural := 14;     -- ADC input data width
    constant DAC_OUT_WIDTH : natural := 16;     -- DAC output data width

    -- All our DSP processing is done at half ADC clock rate, so we have two
    -- data processing lanes.
    constant LANE_COUNT : natural := 2;
    subtype LANES is natural range 0 to LANE_COUNT-1;



    -- ADC input
    subtype ADC_INP_RANGE is natural range ADC_INP_WIDTH-1 downto 0;
    subtype adc_inp_t is signed(ADC_INP_RANGE);
    subtype adc_inp_lanes is signed_array(LANES)(ADC_INP_RANGE);

    -- DAC output
    subtype DAC_OUT_RANGE is natural range DAC_OUT_WIDTH-1 downto 0;
    subtype dac_out_t is signed(DAC_OUT_RANGE);
    subtype dac_out_lanes is signed_array(LANES)(DAC_OUT_RANGE);


    -- Data from DSP to DDR0 DRAM interface
    subtype ddr0_data_t is std_logic_vector(15 downto 0);
    type ddr0_data_lanes is array(LANES) of ddr0_data_t;

    -- Data from DSP to DDR1 DRAM interface
    subtype ddr1_data_t is std_logic_vector(31 downto 0);

    -- Control interface from control top to dsp_top
    type dsp_control_t is record
        dummy : std_logic;      -- Placeholder for interface
    end record;
    type dsp_status_t is record
        dummy : std_logic;      -- Placeholder for interface
    end record;



end package;
