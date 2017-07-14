-- DSP control specific definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

package dsp_defs is
    subtype DRAM1_ADDR_RANGE is natural range 22 downto 0;
    subtype ADC_DATA_RANGE is natural range 15 downto 0;
    subtype NCO_DATA_RANGE is natural range 17 downto 0;

    type dsp_to_control_t is record
        -- Data streams.  adc_data for capture and for multiplexing to FIR
        -- input stage, fir_data and dac_data for capture.
        adc_data : signed(ADC_DATA_RANGE);
        fir_data : signed(FIR_DATA_RANGE);
        dac_data : signed(DAC_OUT_WIDTH-1 downto 0);

        -- Bank selection from sequencer
        bank_select : unsigned(1 downto 0);

        -- NCO signals
        nco_0_data : cos_sin_18_t;
        nco_1_data : cos_sin_18_t;

        -- Data out to DRAM1
        dram1_valid : std_logic;
        dram1_address : unsigned(DRAM1_ADDR_RANGE);
        dram1_data : std_logic_vector(63 downto 0);

        -- Internally generated events
        adc_trigger : std_logic;
        seq_trigger : std_logic;
        seq_busy : std_logic;
    end record;

    type control_to_dsp_t is record
        -- Data streams after multiplexing.
        adc_data   : signed(ADC_DATA_RANGE);
        nco_0_data : signed(NCO_DATA_RANGE);
        nco_1_data : signed(NCO_DATA_RANGE);

        -- Bank selection
        bank_select : unsigned(1 downto 0);

        -- DRAM1 write ready
        dram1_ready : std_logic;

        -- Events from triggering system
        blanking : std_logic;
        turn_clock : std_logic;             -- On ADC clock
        seq_start : std_logic;
    end record;

    -- Convenient reset value for simulation
    constant control_to_dsp_reset : control_to_dsp_t := (
        adc_data   => (others => '0'),
        nco_0_data => (others => '0'),
        nco_1_data => (others => '0'),
        bank_select => (others => '0'),
        dram1_ready => '0',
        blanking => '0',
        turn_clock => '0',
        seq_start => '0'
    );

    type dsp_to_control_array_t is array(CHANNELS) of dsp_to_control_t;
    type control_to_dsp_array_t is array(CHANNELS) of control_to_dsp_t;
end;
