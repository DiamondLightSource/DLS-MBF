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
        turn_clock_i : in std_ulogic;       -- start of machine revolution

        -- Data inputs
        bunch_config_i : in bunch_config_t;
        fir_data_i : in signed;
        nco_0_data_i : in dsp_nco_from_mux_t;
        nco_1_data_i : in dsp_nco_from_mux_t;
        nco_2_data_i : in dsp_nco_from_mux_t;

        -- Gain controls to multiplexer
        nco_0_gain_o : out unsigned;
        nco_0_enable_o : out std_ulogic;

        -- Outputs and overflow detection
        data_store_o : out signed;          -- Data from intermediate processing
        data_o : out signed;                -- at ADC data rate

        -- General register interface
        write_strobe_i : in std_ulogic_vector(DSP_DAC_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_DAC_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_DAC_REGS);
        read_data_o : out reg_data_array_t(DSP_DAC_REGS);
        read_ack_o : out std_ulogic_vector(DSP_DAC_REGS);

        delta_event_o : out std_ulogic  -- bunch movement over threshold
    );
end;

architecture arch of dac_top is
    -- Configuration settings from registers
    signal dac_delay : bunch_count_t;
    signal fir_gain : unsigned(3 downto 0);
    signal nco_0_enable : std_ulogic;
    signal nco_1_enable : std_ulogic;
    signal nco_2_enable : std_ulogic;
    signal mms_source : std_ulogic_vector(1 downto 0);
    signal store_source : std_ulogic;
    signal delta_limit : unsigned(15 downto 0);

    signal write_start : std_ulogic;
    signal delta_reset : std_ulogic;

    signal fir_overflow : std_ulogic;
    signal mux_overflow : std_ulogic;
    signal preemph_overflow : std_ulogic;

    -- Pipelined input
    signal fir_data_in : fir_data_i'SUBTYPE;
    signal nco_0_data_in : nco_0_data_i'SUBTYPE;
    signal nco_1_data_in : nco_1_data_i'SUBTYPE;
    signal nco_2_data_in : nco_2_data_i'SUBTYPE;
    signal bunch_config_in : bunch_config_t;

    -- Overflow detection
    signal fir_overflow_in : std_ulogic;

    subtype DATA_RANGE is natural range data_o'RANGE;

    signal fir_data : data_o'SUBTYPE;
    signal nco_0_data : data_o'SUBTYPE;
    signal nco_1_data : data_o'SUBTYPE;
    signal nco_2_data : data_o'SUBTYPE;
    signal data_out : data_o'SUBTYPE;
    signal filtered_data : data_o'SUBTYPE;
    signal mms_data_in : data_o'SUBTYPE;
    signal mms_delta : unsigned(data_o'RANGE);

    -- Delay from gain control to data change
    constant NCO1_GAIN_DELAY : natural := 4;

    -- Input delays
    constant INPUT_PIPELINE_DELAY : natural := 4;

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
        nco_0_gain_o => nco_0_gain_o,
        nco_0_enable_o => nco_0_enable_o,
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


    -- -------------------------------------------------------------------------
    -- Data input pipelines

    fir_delay : entity work.dlyreg generic map (
        DLY => INPUT_PIPELINE_DELAY,
        DW => fir_data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(fir_data_i),
        signed(data_o) => fir_data_in
    );

    nco0_delay : entity work.dac_nco_delay generic map (
        DELAY => INPUT_PIPELINE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => nco_0_data_i,
        data_o => nco_0_data_in
    );

    nco1_delay : entity work.dac_nco_delay generic map (
        DELAY => INPUT_PIPELINE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => nco_1_data_i,
        data_o => nco_1_data_in
    );

    nco2_delay : entity work.dac_nco_delay generic map (
        DELAY => INPUT_PIPELINE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => nco_2_data_i,
        data_o => nco_2_data_in
    );

    bunch_delay : entity work.dac_bunch_config_delay generic map (
        DELAY => INPUT_PIPELINE_DELAY + NCO1_GAIN_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => bunch_config_i,
        data_o => bunch_config_in
    );


    -- -------------------------------------------------------------------------
    -- Output preparation

    fir_gain_control : entity work.gain_control port map (
        clk_i => adc_clk_i,
        gain_sel_i => fir_gain,
        data_i => fir_data_in,
        data_o => fir_data,
        overflow_o => fir_overflow_in
    );

    nco_0_gain_control : entity work.gain_control generic map (
        EXTRA_SHIFT => 2
    ) port map (
        clk_i => adc_clk_i,
        gain_sel_i => nco_0_data_in.gain,
        data_i => nco_0_data_in.nco,
        data_o => nco_0_data,
        overflow_o => open
    );
    nco_0_enable <= nco_0_data_in.enable;

    nco_1_gain_control : entity work.gain_control generic map (
        EXTRA_SHIFT => 2,
        GAIN_DELAY => NCO1_GAIN_DELAY
    ) port map (
        clk_i => adc_clk_i,
        gain_sel_i => nco_1_data_in.gain,
        data_i => nco_1_data_in.nco,
        data_o => nco_1_data,
        overflow_o => open
    );

    nco_2_gain_control : entity work.gain_control generic map (
        EXTRA_SHIFT => 2
    ) port map (
        clk_i => adc_clk_i,
        gain_sel_i => nco_2_data_in.gain,
        data_i => nco_2_data_in.nco,
        data_o => nco_2_data,
        overflow_o => open
    );
    nco_2_enable <= nco_2_data_in.enable;


    -- Align NCO 1 enable with gain control
    nco_1_enable_delay : entity work.dlyline generic map (
        DLY => NCO1_GAIN_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => nco_1_data_in.enable,
        data_o(0) => nco_1_enable
    );


    -- Output multiplexer
    dac_output_mux : entity work.dac_output_mux port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        bunch_config_i => bunch_config_in,

        fir_data_i => fir_data,
        fir_overflow_i => fir_overflow_in,
        nco_0_enable_i => nco_0_enable,
        nco_0_i => nco_0_data,
        nco_1_enable_i => nco_1_enable,
        nco_1_i => nco_1_data,
        nco_2_enable_i => nco_2_enable,
        nco_2_i => nco_2_data,

        data_o => data_out,
        fir_overflow_o => fir_overflow,
        mux_overflow_o => mux_overflow
    );


    -- Select sources for stored and MMS data
    source_mux : entity work.dac_mms_dram_data_source port map (
        adc_clk_i => adc_clk_i,

        unfiltered_data_i => data_out,
        filtered_data_i => filtered_data,
        fir_data_i => fir_data,

        mms_source_i => mms_source,
        mms_data_o => mms_data_in,

        dram_source_i => store_source,
        dram_data_o => data_store_o
    );


    -- -------------------------------------------------------------------------
    -- Finalisation of output

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
