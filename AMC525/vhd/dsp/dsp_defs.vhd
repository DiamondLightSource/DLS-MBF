-- DSP control specific definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

package dsp_defs is
    subtype DRAM1_ADDR_RANGE is natural range 22 downto 0;  -- 23 bits
    subtype ADC_DATA_RANGE is natural range 15 downto 0;    -- 16 bits
    subtype NCO_DATA_RANGE is natural range 17 downto 0;    -- 18 bits
    subtype FIR_DATA_RANGE is natural range 24 downto 0;    -- 25 bits
    subtype DAC_DATA_RANGE is natural range 15 downto 0;    -- 16 bits

    -- We support 4 NCOs: 0 => NCO1, 1 => SEQ, 2 => PLL, 3 => NCO2
    constant NCO_NCO1 : natural := 0;
    constant NCO_SEQ  : natural := 1;
    constant NCO_PLL  : natural := 2;
    constant NCO_NCO2 : natural := 3;
    subtype NCO_SET is natural range 0 to 3;

    -- We allocate a couple of extra bits to the NCO gain to help avoiding
    -- loss of resolution when rounding later on.
    subtype nco_gain_t is unsigned(17 downto 0);

    -- Gather the entire NCO state into a single record
    type dsp_nco_to_mux_t is record
        nco : cos_sin_18_t;
        gain : nco_gain_t;
    end record;

    type dsp_nco_from_mux_t is record
        nco : signed(NCO_DATA_RANGE);
        gain : nco_gain_t;
    end record;

    type nco_iq_array_t is array(NCO_SET) of dsp_nco_to_mux_t;
    type nco_data_array_t is array(NCO_SET) of dsp_nco_from_mux_t;

    type dsp_to_control_t is record
        -- Data streams.  adc_data for capture and for multiplexing to FIR
        -- input stage, fir_data and dac_data for capture.
        adc_data : signed(ADC_DATA_RANGE);
        store_adc_data : signed(ADC_DATA_RANGE);
        store_fir_data : signed(DAC_DATA_RANGE);
        store_dac_data : signed(DAC_DATA_RANGE);

        -- Bank selection from sequencer
        bank_select : unsigned(1 downto 0);

        -- NCO signals
        nco_iq : nco_iq_array_t;

        -- Data out to DRAM1
        dram1_valid : std_ulogic;
        dram1_address : unsigned(DRAM1_ADDR_RANGE);
        dram1_data : std_ulogic_vector(63 downto 0);

        -- Internally generated events
        adc_trigger : std_ulogic;
        dac_trigger : std_ulogic;
        seq_trigger : std_ulogic;
        seq_busy : std_ulogic;
        tune_pll_ready : std_ulogic_vector(2 downto 0);
    end record;

    type control_to_dsp_t is record
        -- Data streams after multiplexing.
        adc_data : signed(ADC_DATA_RANGE);
        nco_data : nco_data_array_t;

        -- Bank selection
        bank_select : unsigned(1 downto 0);

        -- DRAM1 write ready
        dram1_ready : std_ulogic;

        -- Events from triggering system
        blanking : std_ulogic;
        turn_clock : std_ulogic;             -- On ADC clock
        seq_start : std_ulogic;

        start_tune_pll : std_ulogic;
        stop_tune_pll : std_ulogic;
    end record;


    -- Convenient reset value for simulation
    constant dsp_nco_from_mux_reset : dsp_nco_from_mux_t := (
        nco => (others => '0'),
        gain => (others => '0')
    );

    constant control_to_dsp_reset : control_to_dsp_t := (
        adc_data   => (others => '0'),
        nco_data => (others => dsp_nco_from_mux_reset),
        bank_select => (others => '0'),
        dram1_ready => '0',
        blanking => '0',
        turn_clock => '0',
        seq_start => '0',
        start_tune_pll => '0',
        stop_tune_pll => '0'
    );

    type dsp_to_control_array_t is array(CHANNELS) of dsp_to_control_t;
    type control_to_dsp_array_t is array(CHANNELS) of control_to_dsp_t;
end;
