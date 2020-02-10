-- DAC output control.
--
-- This includes multiplexing three output sources, gain control on each source,
-- and a final output delay.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.bunch_defs.all;
use work.dsp_defs.all;

entity dac_top is
    generic (
        TAP_COUNT : natural
    );
    port (
        -- Clocking
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;   -- start of machine revolution

        -- General register interface
        write_strobe_i : in std_ulogic_vector(DSP_DAC_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_DAC_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_DAC_REGS);
        read_data_o : out reg_data_array_t(DSP_DAC_REGS);
        read_ack_o : out std_ulogic_vector(DSP_DAC_REGS);

        -- Data inputs
        bunch_config_i : in bunch_config_t;
        fir_data_i : in signed;
        nco_0_data_i : in dsp_nco_from_mux_t;
        nco_1_data_i : in dsp_nco_from_mux_t;
        nco_2_data_i : in dsp_nco_from_mux_t;
        nco_3_data_i : in dsp_nco_from_mux_t;

        -- Outputs and overflow detection
        data_store_o : out signed;      -- Data from intermediate processing
        data_o : out signed;            -- at ADC data rate
        delta_event_o : out std_ulogic  -- bunch movement over threshold
    );
end;

architecture arch of dac_top is
    -- Configuration settings from registers
    signal dac_delay : bunch_count_t;
    signal fir_gain : unsigned(3 downto 0);
    signal mms_source : std_ulogic_vector(1 downto 0);
    signal store_source : std_ulogic;
    signal delta_limit : unsigned(15 downto 0);

    signal write_start : std_ulogic;
    signal delta_reset : std_ulogic;

    -- Event readbacks to registers
    signal fir_overflow_adc : std_ulogic;
    signal mux_overflow_adc : std_ulogic;
    signal fir_overflow : std_ulogic;
    signal mux_overflow : std_ulogic;
    signal preemph_overflow : std_ulogic;

    -- Pipelines
    signal fir_data_in : fir_data_i'SUBTYPE;
    signal nco_1_data_in : nco_1_data_i'SUBTYPE;
    signal bunch_config_in : bunch_config_i'SUBTYPE;

    -- Data flowing through system
    signal fir_mms_data : data_o'SUBTYPE;
    signal data_out : data_o'SUBTYPE;
    signal filtered_data : data_o'SUBTYPE;
    signal mms_data_in : data_o'SUBTYPE;
    signal mms_delta : unsigned(data_o'RANGE);

--     -- Delay from gain control to data change
--     constant NCO1_GAIN_DELAY : natural := 4;
-- 
    -- Input delays
    constant INPUT_PIPELINE_DELAY : natural := 2;

begin
    -- Register interface
    registers : entity work.dac_registers port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_DAC_REGISTERS_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DAC_REGISTERS_REGS),
        read_strobe_i => read_strobe_i(DSP_DAC_REGISTERS_REGS),
        read_data_o => read_data_o(DSP_DAC_REGISTERS_REGS),
        read_ack_o => read_ack_o(DSP_DAC_REGISTERS_REGS),

        dac_delay_o => dac_delay,
        fir_gain_o => fir_gain,
        mms_source_o => mms_source,
        store_source_o => store_source,
        delta_limit_o => delta_limit,
        write_start_o => write_start,
        delta_reset_o => delta_reset,

        fir_overflow_i => fir_overflow,
        mux_overflow_i => mux_overflow,
        preemph_overflow_i => preemph_overflow,
        delta_event_i => delta_event_o
    );

    -- Convert overflow events to DSP clock for readout
    fir_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => fir_overflow_adc,
        pulse_o => fir_overflow
    );

    mux_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => mux_overflow_adc,
        pulse_o => mux_overflow
    );


    -- -------------------------------------------------------------------------
    -- Output generation with selected piplelines

    fir_delay : entity work.dlyreg generic map (
        DLY => INPUT_PIPELINE_DELAY,
        DW => fir_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(fir_data_i),
        signed(data_o) => fir_data_in
    );

    nco1_delay : entity work.dac_nco_delay generic map (
        DELAY => INPUT_PIPELINE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => nco_1_data_i,
        data_o => nco_1_data_in
    );

    bunch_delay : entity work.dac_bunch_config_delay generic map (
        DELAY => INPUT_PIPELINE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => bunch_config_i,
        data_o => bunch_config_in
    );


    -- Output gain control and selection
    dac_output_mux : entity work.dac_output_mux port map (
        clk_i => adc_clk_i,

        bunch_config_i => bunch_config_in,

        fir_data_i => fir_data_in,
        fir_gain_i => fir_gain,

        nco_0_data_i => nco_0_data_i,
        nco_1_data_i => nco_1_data_in,
        nco_2_data_i => nco_2_data_i,
        nco_3_data_i => nco_3_data_i,

        data_o => data_out,
        fir_mms_o => fir_mms_data,

        fir_overflow_o => fir_overflow_adc,
        mux_overflow_o => mux_overflow_adc
    );


    -- -------------------------------------------------------------------------
    -- MMS processing on selected data

    -- Select sources for stored and MMS data
    source_mux : entity work.dac_mms_dram_data_source port map (
        adc_clk_i => adc_clk_i,

        unfiltered_data_i => data_out,
        filtered_data_i => filtered_data,
        fir_data_i => fir_mms_data,

        mms_source_i => mms_source,
        mms_data_o => mms_data_in,

        dram_source_i => store_source,
        dram_data_o => data_store_o
    );

    -- Min/Max/Sum
    min_max_sum : entity work.min_max_sum port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        data_i => mms_data_in,
        delta_o => mms_delta,

        read_strobe_i => read_strobe_i(DSP_DAC_MMS_REGS),
        read_data_o => read_data_o(DSP_DAC_MMS_REGS),
        read_ack_o => read_ack_o(DSP_DAC_MMS_REGS)
    );
    write_ack_o(DSP_DAC_MMS_REGS) <= (others => '1');

    -- Bunch movement detection
    min_max_limit : entity work.min_max_limit port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        delta_i => mms_delta,
        limit_i => delta_limit,
        reset_event_i => delta_reset,

        limit_event_o => delta_event_o
    );


    -- -------------------------------------------------------------------------
    -- Final output preparation

    -- Compensation filter
    fast_fir : entity work.fast_fir_top generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_start_i => write_start,
        write_strobe_i => write_strobe_i(DSP_DAC_TAPS_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DAC_TAPS_REG),

        data_i => data_out,
        data_o => filtered_data,
        overflow_o => preemph_overflow
    );
    read_data_o(DSP_DAC_TAPS_REG) <= (others => '0');
    read_ack_o(DSP_DAC_TAPS_REG) <= '1';


    -- Programmable long delay
    long_delay : entity work.long_delay generic map (
        WIDTH => data_o'LENGTH,
        PIPELINE_DELAY => 4
    ) port map (
        clk_i => adc_clk_i,
        delay_i => dac_delay,
        data_i => std_ulogic_vector(filtered_data),
        signed(data_o) => data_o
    );
end;
