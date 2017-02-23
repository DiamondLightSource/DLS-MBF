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
        adc_phase_i : in std_logic;
        turn_clock_adc_i : in std_logic;       -- start of machine revolution

        -- Data inputs
        bunch_config_i : in bunch_config_t;
        fir_data_i : in signed;
        nco_0_data_i : in signed;
        nco_1_data_i : in signed;
        nco_1_gain_i : in unsigned;

        -- Outputs and overflow detection
        data_store_o : out signed;          -- Data from intermediate processing
        data_o : out signed;                -- at ADC data rate
        fir_overflow_o : out std_logic;     -- If overflowed FIR used
        mux_overflow_o : out std_logic;     -- If overflow in output mux
        mms_overflow_o : out std_logic;     -- If an mms accumulator overflows
        preemph_overflow_o : out std_logic; -- Preemphasis FIR overflow detect

        -- General register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Pulse events
        write_start_i : in std_logic        -- For register block writes
    );
end;

architecture dac_top of dac_top is
    -- Configuration register
    signal config_register : reg_data_t;
    signal config_untimed : reg_data_t;
    -- Configuration settings from register
    signal dac_delay : bunch_count_t;
    signal fir_gain : unsigned(4 downto 0);
    signal nco_0_gain : unsigned(3 downto 0);
    signal fir_enable : std_logic;
    signal nco_0_enable : std_logic;
    signal nco_1_enable : std_logic;

    -- Overflow detection
    signal fir_overflow_in : std_logic;

    subtype DATA_RANGE is natural range data_o'RANGE;

    signal fir_data : data_o'SUBTYPE;
    signal nco_0_data : data_o'SUBTYPE;
    signal nco_1_data : data_o'SUBTYPE;
    signal data_out : data_o'SUBTYPE;
    signal filtered_data : data_o'SUBTYPE;
    signal delayed_data_out : data_o'SUBTYPE;

begin
    -- Register mapping
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_DAC_CONFIG_REG_W),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_DAC_CONFIG_REG_W),
        register_data_o(0) => config_register
    );
    -- Bring this over to the ADC clock without a timing constraint
    untimed_inst : entity work.untimed_reg generic map (
        WIDTH => REG_DATA_WIDTH
    ) port map (
        clk_i => adc_clk_i,
        write_i => '1',
        data_i => config_register,
        data_o => config_untimed
    );

    -- Not all of these will remain in registers
    dac_delay  <= unsigned(config_untimed(9 downto 0));
    fir_gain   <= unsigned(config_untimed(24 downto 20));
    nco_0_gain <= unsigned(config_untimed(15 downto 12));
    fir_enable   <= config_untimed(25);
    nco_0_enable <= config_untimed(26);
    nco_1_enable <= config_untimed(27);


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
    dac_output_mux_inst : entity work.dac_output_mux port map (
        clk_i => adc_clk_i,

        bunch_config_i => bunch_config_i,

        fir_enable_i => fir_enable,
        fir_data_i => fir_data,
        fir_overflow_i => fir_overflow_in,
        nco_0_enable_i => nco_0_enable,
        nco_0_i => nco_0_data,
        nco_1_enable_i => nco_1_enable,
        nco_1_i => nco_1_data,

        data_o => data_out,
        fir_overflow_o => fir_overflow_o,
        mux_overflow_o => mux_overflow_o
    );

    data_store_o <= data_out;


    -- -------------------------------------------------------------------------
    -- Finalisation of output

    -- Min/Max/Sum
    min_max_sum_inst : entity work.min_max_sum port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,
        turn_clock_adc_i => turn_clock_adc_i,

        data_i => data_out,
        delta_o => open,
        overflow_o => mms_overflow_o,

        read_strobe_i => read_strobe_i(DSP_DAC_MMS_REGS_R),
        read_data_o => read_data_o(DSP_DAC_MMS_REGS_R),
        read_ack_o => read_ack_o(DSP_DAC_MMS_REGS_R)
    );


    -- Compensation filter
    fast_fir_inst : entity work.fast_fir_top generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        write_start_i => write_start_i,
        write_strobe_i => write_strobe_i(DSP_DAC_TAPS_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DAC_TAPS_REG_W),

        data_i => data_out,
        data_o => filtered_data,
        overflow_o => preemph_overflow_o
    );

    -- Programmable long delay
    dac_delay_inst : entity work.long_delay generic map (
        WIDTH => data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        delay_i => dac_delay,
        data_i => std_logic_vector(filtered_data),
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
