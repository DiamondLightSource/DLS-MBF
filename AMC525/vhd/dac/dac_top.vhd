-- DAC output control.
--
-- This includes multiplexing three output sources, gain control on each source,
-- and a final output delay.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
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
        turn_clock_i : in std_logic;       -- start of machine revolution

        -- Data inputs
        bunch_config_i : in bunch_config_lanes_t;
        fir_data_i : in signed_array;
        nco_0_data_i : in signed_array;
        nco_1_data_i : in signed_array;

        -- Outputs and overflow detection
        data_store_o : out signed_array;    -- Data from intermediate processing
        data_o : out signed;                -- at ADC data rate
        fir_overflow_o : out std_logic;     -- If overflowed FIR used
        mux_overflow_o : out std_logic;     -- If overflow in output mux
        mms_overflow_o : out std_logic;     -- If an mms accumulator overflows
        preemph_overflow_o : out std_logic; -- Preemphasis FIR overflow detect

        -- General register interface
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        -- Pulse events
        write_start_i : in std_logic        -- For register block writes
    );
end;

architecture dac_top of dac_top is
    -- Our registers are overlaid as follows:
    --
    --  0   R   31:0    Read MMS count and switch banks
    --  1   R   31:0    Read and reset MMS bunch entries
    --  0   W   9:0     Configure DAC output delay
    --  0   W   15:12   NCO 0 gain
    --  0   W   19:16   NCO 1 gain
    --  0   W   24:20   FIR gain
    --  0   W   25      FIR enable
    --  0   W   26      NCO 0 enable
    --  0   W   27      NCO 1 enable
    --  1   W   31:7    Write FIR taps
    --
    subtype MMS_REGS_R is natural range 0 to 1;
    constant CONFIG_REG_W : natural := 0;
    constant TAPS_REG_W : natural := 1;

    -- Configuration register
    signal config_register_dsp : reg_data_t;
    signal config_register_adc : reg_data_t;
    -- Configuration settings from register
    signal dac_delay : unsigned(BUNCH_NUM_BITS downto 0);
    signal fir_gain : unsigned(4 downto 0);
    signal nco_0_gain : unsigned(3 downto 0);
    signal nco_1_gain : unsigned(3 downto 0);
    signal fir_enable : std_logic;
    signal nco_0_enable : std_logic;
    signal nco_1_enable : std_logic;

    -- Overflow detection
    signal fir_overflow_in : std_logic_vector(LANES);
    signal fir_overflow : std_logic_vector(LANES);
    signal mux_overflow : std_logic_vector(LANES);

    subtype DATA_RANGE is natural range data_o'RANGE;

    signal fir_data : signed_array(LANES)(DATA_RANGE);
    signal nco_0_data : signed_array(LANES)(DATA_RANGE);
    signal nco_1_data : signed_array(LANES)(DATA_RANGE);
    signal data_out_lanes : signed_array(LANES)(DATA_RANGE);
    signal data_out : signed(DATA_RANGE);
    signal filtered_data : signed(DATA_RANGE);
    signal delayed_data_out : signed(DATA_RANGE);

    -- This signal is ignored, but needed for sizing of port
    signal mms_delta : unsigned_array(LANES)(DATA_RANGE);

begin
    -- Register mapping
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(CONFIG_REG_W),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(CONFIG_REG_W),
        register_data_o(0) => config_register_dsp
    );
    -- Bring this over to the ADC clock without a timing constraint
    untimed_inst : entity work.untimed_reg generic map (
        WIDTH => REG_DATA_WIDTH
    ) port map (
        clk_i => dsp_clk_i,
        write_i => '1',
        data_i => config_register_dsp,
        data_o => config_register_adc
    );

    -- Not all of these will remain in registers
    dac_delay  <= unsigned(config_register_adc(9 downto 0));
    fir_gain   <= unsigned(config_register_dsp(24 downto 20));
    nco_0_gain <= unsigned(config_register_dsp(15 downto 12));
    nco_1_gain <= unsigned(config_register_dsp(19 downto 16));
    fir_enable   <= config_register_dsp(25);
    nco_0_enable <= config_register_dsp(26);
    nco_1_enable <= config_register_dsp(27);


    -- -------------------------------------------------------------------------
    -- Output preparation

    lanes_gen : for l in LANES generate
        fir_gain_inst : entity work.gain_control port map (
            clk_i => dsp_clk_i,
            gain_sel_i => fir_gain,
            data_i => fir_data_i(l),
            data_o => fir_data(l),
            overflow_o => fir_overflow_in(l)
        );

        nco_0_gain_inst : entity work.gain_control generic map (
            EXTRA_SHIFT => 2
        ) port map (
            clk_i => dsp_clk_i,
            gain_sel_i => nco_0_gain,
            data_i => nco_0_data_i(l),
            data_o => nco_0_data(l),
            overflow_o => open
        );

        nco_1_gain_inst : entity work.gain_control generic map (
            EXTRA_SHIFT => 2
        ) port map (
            clk_i => dsp_clk_i,
            gain_sel_i => nco_1_gain,
            data_i => nco_1_data_i(l),
            data_o => nco_1_data(l),
            overflow_o => open
        );

        -- Output multiplexer
        dac_output_mux_inst : entity work.dac_output_mux port map (
            dsp_clk_i => dsp_clk_i,

            bunch_config_i => bunch_config_i(l),

            fir_enable_i => fir_enable,
            fir_data_i => fir_data(l),
            fir_overflow_i => fir_overflow_in(l),
            nco_0_enable_i => nco_0_enable,
            nco_0_i => nco_0_data(l),
            nco_1_enable_i => nco_1_enable,
            nco_1_i => nco_1_data(l),

            data_o => data_out_lanes(l),
            fir_overflow_o => fir_overflow(l),
            mux_overflow_o => mux_overflow(l)
        );
    end generate;
    fir_overflow_o <= vector_or(fir_overflow);
    mux_overflow_o <= vector_or(mux_overflow);

    data_store_o <= data_out_lanes;


    -- -------------------------------------------------------------------------
    -- Finalisation of output

    -- Min/Max/Sum
    min_max_sum_inst : entity work.min_max_sum port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        data_i => data_out_lanes,
        delta_o => mms_delta,
        overflow_o => mms_overflow_o,

        read_strobe_i => read_strobe_i(MMS_REGS_R),
        read_data_o => read_data_o(MMS_REGS_R),
        read_ack_o => read_ack_o(MMS_REGS_R)
    );


    -- Convert lanes at DSP clock back to single stream of ADC data
    dsp_to_adc_inst : entity work.dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        dsp_data_i => data_out_lanes,
        adc_data_o => data_out
    );

    -- Compensation filter
    fast_fir_inst : entity work.fast_fir_top generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        write_start_i => write_start_i,
        write_strobe_i => write_strobe_i(TAPS_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(TAPS_REG_W),

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
