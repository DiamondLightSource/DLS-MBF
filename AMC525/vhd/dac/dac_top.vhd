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

entity dac_top is
    generic (
        TAP_COUNT : natural
    );
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;       -- start of machine revolution

        -- Data inputs
        bunch_config_i : in bunch_config_t;
        fir_data_i : in signed;
        nco_0_data_i : in signed;
        nco_1_data_i : in signed;
        nco_1_gain_i : in unsigned;

        -- Outputs and overflow detection
        data_store_o : out signed;          -- Data from intermediate processing
        data_o : out signed;                -- at ADC data rate

        -- General register interface
        write_strobe_i : in std_logic_vector(DSP_DAC_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(DSP_DAC_REGS);
        read_strobe_i : in std_logic_vector(DSP_DAC_REGS);
        read_data_o : out reg_data_array_t(DSP_DAC_REGS);
        read_ack_o : out std_logic_vector(DSP_DAC_REGS)
    );
end;

architecture arch of dac_top is
    -- Configuration settings from register
    signal config_register : reg_data_t;
    signal dac_delay : bunch_count_t;
    signal fir_gain : unsigned(4 downto 0);
    signal nco_0_gain : unsigned(3 downto 0);
    signal fir_enable : std_logic;
    signal nco_0_enable : std_logic;
    signal nco_1_enable : std_logic;

    signal command_bits : reg_data_t;
    signal write_start : std_logic;

    signal event_bits : reg_data_t;
    signal fir_overflow : std_logic;
    signal mux_overflow : std_logic;
    signal mms_overflow : std_logic;
    signal preemph_overflow : std_logic;

    -- Overflow detection
    signal fir_overflow_in : std_logic;

    subtype DATA_RANGE is natural range data_o'RANGE;

    signal fir_data : data_o'SUBTYPE;
    signal nco_0_data : data_o'SUBTYPE;
    signal nco_1_data : data_o'SUBTYPE;
    signal data_out : data_o'SUBTYPE;
    signal filtered_data : data_o'SUBTYPE;
    signal filtered_data_pl : data_o'SUBTYPE;
    signal delayed_data_out : data_o'SUBTYPE;

begin
    -- Register mapping
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_DAC_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_DAC_CONFIG_REG),
        register_data_o(0) => config_register
    );
    read_data_o(DSP_DAC_CONFIG_REG) <= (others => '0');
    read_ack_o(DSP_DAC_CONFIG_REG) <= '1';

    -- Command register: start write and reset limit
    command : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_DAC_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DAC_COMMAND_REG_W),
        strobed_bits_o => command_bits
    );

    -- Event detection register
    events : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(DSP_DAC_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_DAC_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_DAC_EVENTS_REG_R),
        pulsed_bits_i => event_bits
    );

    dac_delay  <= unsigned(config_register(DSP_DAC_CONFIG_DELAY_BITS));
    fir_gain   <= unsigned(config_register(DSP_DAC_CONFIG_FIR_GAIN_BITS));
    nco_0_gain <= unsigned(config_register(DSP_DAC_CONFIG_NCO0_GAIN_BITS));
    fir_enable   <= config_register(DSP_DAC_CONFIG_FIR_ENABLE_BIT);
    nco_0_enable <= config_register(DSP_DAC_CONFIG_NCO0_ENABLE_BIT);
    nco_1_enable <= config_register(DSP_DAC_CONFIG_NCO1_ENABLE_BIT);

    write_start <= command_bits(DSP_DAC_COMMAND_WRITE_BIT);

    event_bits <= (
        DSP_DAC_EVENTS_FIR_OVF_BIT => fir_overflow,
        DSP_DAC_EVENTS_MUX_OVF_BIT => mux_overflow,
        DSP_DAC_EVENTS_MMS_OVF_BIT => mms_overflow,
        DSP_DAC_EVENTS_OUT_OVF_BIT => preemph_overflow,
        others => '0'
    );


    -- -------------------------------------------------------------------------
    -- Output preparation

    fir_gain_inst : entity work.gain_control port map (
        clk_i => adc_clk_i,
        gain_sel_i => fir_gain,
        data_i => fir_data_i,
        data_o => fir_data,
        overflow_o => fir_overflow_in
    );

    nco_0_gain_inst : entity work.gain_control generic map (
        EXTRA_SHIFT => 2
    ) port map (
        clk_i => adc_clk_i,
        gain_sel_i => nco_0_gain,
        data_i => nco_0_data_i,
        data_o => nco_0_data,
        overflow_o => open
    );

    nco_1_gain_inst : entity work.gain_control generic map (
        EXTRA_SHIFT => 2
    ) port map (
        clk_i => adc_clk_i,
        gain_sel_i => nco_1_gain_i,
        data_i => nco_1_data_i,
        data_o => nco_1_data,
        overflow_o => open
    );

    -- Output multiplexer
    dac_output_mux : entity work.dac_output_mux port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        bunch_config_i => bunch_config_i,

        fir_enable_i => fir_enable,
        fir_data_i => fir_data,
        fir_overflow_i => fir_overflow_in,
        nco_0_enable_i => nco_0_enable,
        nco_0_i => nco_0_data,
        nco_1_enable_i => nco_1_enable,
        nco_1_i => nco_1_data,

        data_o => data_out,
        fir_overflow_o => fir_overflow,
        mux_overflow_o => mux_overflow
    );

    data_store_o <= data_out;


    -- -------------------------------------------------------------------------
    -- Finalisation of output

    -- Min/Max/Sum
    min_max_sum_inst : entity work.min_max_sum port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        data_i => data_out,
        delta_o => open,
        overflow_o => mms_overflow,

        read_strobe_i => read_strobe_i(DSP_DAC_MMS_REGS),
        read_data_o => read_data_o(DSP_DAC_MMS_REGS),
        read_ack_o => read_ack_o(DSP_DAC_MMS_REGS)
    );
    write_ack_o(DSP_DAC_MMS_REGS) <= (others => '1');


    -- Compensation filter
    fast_fir_inst : entity work.fast_fir_top generic map (
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

    -- Pipeline to help with timing
    filter_dly : entity work.dlyreg generic map (
        DLY => 2,
        DW => filtered_data'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(filtered_data),
        signed(data_o) => filtered_data_pl
    );

    -- Programmable long delay
    dac_delay_inst : entity work.long_delay generic map (
        WIDTH => data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        delay_i => dac_delay,
        data_i => std_logic_vector(filtered_data_pl),
        signed(data_o) => delayed_data_out
    );

    -- Pipeline to help with final output
    dlyreg_inst : entity work.dlyreg generic map (
        DLY => 2,
        DW => data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(delayed_data_out),
        signed(data_o) => data_o
    );

end;
