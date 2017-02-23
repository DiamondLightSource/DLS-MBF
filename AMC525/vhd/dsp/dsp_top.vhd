-- Top level DSP.  Takes ADC data in, generates DAC data out.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.dsp_defs.all;
use work.bunch_defs.all;
use work.nco_defs.all;
use work.sequencer_defs.all;

entity dsp_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- External data in and out
        adc_data_i : in signed;
        dac_data_o : out signed;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- External control: data multiplexing and shared control
        control_to_dsp_i : in control_to_dsp_t;
        dsp_to_control_o : out dsp_to_control_t;

        -- Front panel event generated from sequencer
        dsp_event_o : out std_logic
    );
end;

architecture dsp_top of dsp_top is
    -- General readback status bits
    signal status_bits : reg_data_t;

    -- Strobed control signals
    signal strobed_bits : reg_data_t;
    signal write_start : std_logic;
    signal delta_reset : std_logic;

    signal loopback : std_logic;
    signal dac_output_enable : std_logic;

    -- Captured pulsed events
    signal pulsed_bits : reg_data_t;
    signal adc_input_overflow : std_logic;
    signal adc_fir_overflow : std_logic;
    signal adc_mms_overflow : std_logic;
    signal adc_delta_event : std_logic;
    signal dac_fir_overflow : std_logic;
    signal dac_mux_overflow : std_logic;
    signal dac_mms_overflow : std_logic;
    signal dac_preemph_overflow : std_logic;

    -- Bunch control
    signal current_bank : unsigned(1 downto 0);
    signal bunch_config : bunch_config_t;
    signal detector_window : hom_win_t;

    -- Sequencer and detector
    signal sequencer_start : std_logic;
    signal sequencer_write : std_logic;

    -- Oscillator control
    signal nco_0_phase_advance : angle_t;
    signal nco_0_reset : std_logic;
    signal nco_0_cos_sin : cos_sin_18_t;
    signal nco_1_phase_advance : angle_t;
    signal nco_1_reset : std_logic;
    signal nco_1_cos_sin : cos_sin_18_t;
    signal nco_1_gain : unsigned(3 downto 0);

    -- Data flow
    signal adc_data_in : adc_data_i'SUBTYPE;
    signal fir_data : signed(FIR_DATA_WIDTH-1 downto 0);
    signal dac_data_out : dac_data_o'SUBTYPE;


    -- Hacks
    signal hack_registers : reg_data_array_t(DSP_HACK_REGS);

begin
    -- -------------------------------------------------------------------------
    -- General register handling

    dsp_registers_inst : entity work.dsp_registers port map (
        dsp_clk_i => dsp_clk_i,

        -- DSP general control registers
        write_strobe_i => write_strobe_i(DSP_GENERAL_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_GENERAL_REGS),
        read_strobe_i => read_strobe_i(DSP_GENERAL_REGS),
        read_data_o => read_data_o(DSP_GENERAL_REGS),
        read_ack_o => read_ack_o(DSP_GENERAL_REGS),

        -- Processed registers
        strobed_bits_o => strobed_bits,
        status_bits_i => status_bits,
        pulsed_bits_i => pulsed_bits
    );

    write_start <= strobed_bits(0);
    delta_reset <= strobed_bits(1);

    -- Miscellaneous status bits etc
    status_bits <= (
        others => '0'
    );

    -- Capture of single clock events
    pulsed_bits <= (
        0 => adc_input_overflow,    -- ADC out of limit
        1 => adc_fir_overflow,      -- Compensation filter overflow
        2 => adc_mms_overflow,      -- ADC MMS accumulator overflow
        3 => adc_delta_event,       -- Bunch by bunch motion over threshold
        4 => dac_fir_overflow,      -- FIR overflow in output
        5 => dac_mux_overflow,      -- Overflow in output multiplexer
        6 => dac_mms_overflow,      -- DAC MMS accumulator overflow
        7 => dac_preemph_overflow,  -- Preemphasis filter overflow
        8 => control_to_dsp_i.dram1_error,  -- Overrun writing to DRAM1
        others => '0'
    );


    -- -------------------------------------------------------------------------
    -- Miscellaneous control

    -- Bunch specific control
    bunch_select_inst : entity work.bunch_select port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,
        turn_clock_adc_i => control_to_dsp_i.turn_clock_adc,

        write_strobe_i => write_strobe_i(DSP_BUNCH_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_BUNCH_REGS),
        read_strobe_i => read_strobe_i(DSP_BUNCH_REGS),
        read_data_o => read_data_o(DSP_BUNCH_REGS),
        read_ack_o => read_ack_o(DSP_BUNCH_REGS),

        bank_select_i => current_bank,
        bunch_config_o => bunch_config
    );


    -- Oscillators
    nco_0_inst : entity work.nco port map (
        clk_i => adc_clk_i,
        phase_advance_i => nco_0_phase_advance,
        reset_i => nco_0_reset,
        cos_sin_o => nco_0_cos_sin
    );
    dsp_to_control_o.nco_0_data <= nco_0_cos_sin;

    nco_1_inst : entity work.nco port map (
        clk_i => adc_clk_i,
        phase_advance_i => nco_1_phase_advance,
        reset_i => nco_1_reset,
        cos_sin_o => nco_1_cos_sin
    );
    dsp_to_control_o.nco_1_data <= nco_1_cos_sin;


    slow_memory_control_inst : entity work.slow_memory_control port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_SLOW_MEM_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_SLOW_MEM_REG),
        read_strobe_i => read_strobe_i(DSP_SLOW_MEM_REG),
        read_data_o => read_data_o(DSP_SLOW_MEM_REG),
        read_ack_o => read_ack_o(DSP_SLOW_MEM_REG),

        dram1_strobe_o => dsp_to_control_o.dram1_strobe,
        dram1_error_i => control_to_dsp_i.dram1_error,
        dram1_address_o => dsp_to_control_o.dram1_address,
        dram1_data_o => dsp_to_control_o.dram1_data
    );


    -- -------------------------------------------------------------------------
    -- Signal processing chain

    -- ADC input processing
    adc_top_inst : entity work.adc_top generic map (
        TAP_COUNT => ADC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,
        turn_clock_adc_i => control_to_dsp_i.turn_clock_adc,

        data_i => adc_data_in,
        data_o => dsp_to_control_o.adc_data,

        write_strobe_i => write_strobe_i(DSP_ADC_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_ADC_REGS),
        read_strobe_i => read_strobe_i(DSP_ADC_REGS),
        read_data_o => read_data_o(DSP_ADC_REGS),
        read_ack_o => read_ack_o(DSP_ADC_REGS),

        write_start_i => write_start,
        delta_reset_i => delta_reset,

        input_overflow_o => adc_input_overflow,
        fir_overflow_o => adc_fir_overflow,
        mms_overflow_o => adc_mms_overflow,
        delta_event_o => adc_delta_event
    );


    -- FIR processing
    bunch_fir_top_inst : entity work.bunch_fir_top generic map (
        TAP_COUNT => BUNCH_FIR_TAP_COUNT
    ) port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,
        adc_phase_i => adc_phase_i,

        data_i => control_to_dsp_i.adc_data,
        data_o => fir_data,

        turn_clock_i => control_to_dsp_i.turn_clock_dsp,
        bunch_config_i => bunch_config,

        write_strobe_i => write_strobe_i(DSP_B_FIR_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_B_FIR_REGS),
        read_strobe_i => read_strobe_i(DSP_B_FIR_REGS),
        read_data_o => read_data_o(DSP_B_FIR_REGS),
        read_ack_o => read_ack_o(DSP_B_FIR_REGS),

        write_start_i => write_start
    );
    dsp_to_control_o.fir_data <= fir_data;

    -- DAC output processing
    dac_top_inst : entity work.dac_top generic map (
        TAP_COUNT => DAC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,
        turn_clock_adc_i => control_to_dsp_i.turn_clock_adc,

        bunch_config_i => bunch_config,
        fir_data_i => fir_data,
        nco_0_data_i => control_to_dsp_i.nco_0_data,
        nco_1_data_i => control_to_dsp_i.nco_1_data,
        nco_1_gain_i => nco_1_gain,

        data_store_o => dsp_to_control_o.dac_data,
        data_o => dac_data_out,
        fir_overflow_o => dac_fir_overflow,
        mux_overflow_o => dac_mux_overflow,
        mms_overflow_o => dac_mms_overflow,
        preemph_overflow_o => dac_preemph_overflow,

        write_strobe_i => write_strobe_i(DSP_DAC_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DAC_REGS),
        read_strobe_i => read_strobe_i(DSP_DAC_REGS),
        read_data_o => read_data_o(DSP_DAC_REGS),
        read_ack_o => read_ack_o(DSP_DAC_REGS),

        write_start_i => write_start
    );


    -- Loopback enable for internal testing and output control
    loopback_inst : entity work.dsp_loopback port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        loopback_i => loopback,
        output_enable_i => dac_output_enable,

        adc_data_i => adc_data_i,
        dac_data_i => dac_data_out,

        adc_data_o => adc_data_in,
        dac_data_o => dac_data_o
    );


    -- -------------------------------------------------------------------------
    -- Sequencer and detector

    sequencer_top_inst : entity work.sequencer_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        turn_clk_i => control_to_dsp_i.turn_clock_dsp,
        blanking_i => control_to_dsp_i.blanking,

        write_strobe_i => write_strobe_i(DSP_SEQ_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_SEQ_REGS),
        read_strobe_i => read_strobe_i(DSP_SEQ_REGS),
        read_data_o => read_data_o(DSP_SEQ_REGS),
        read_ack_o => read_ack_o(DSP_SEQ_REGS),

        trigger_i => control_to_dsp_i.seq_start,

        state_trigger_o => dsp_to_control_o.seq_trigger,

        seq_start_o => sequencer_start,
        seq_write_o => sequencer_write,

        hom_freq_o => nco_1_phase_advance,
        hom_gain_o => nco_1_gain,
        hom_window_o => detector_window,
        bunch_bank_o => current_bank
    );

    -- Transfer NCO gain over to ADC clock


    -- -------------------------------------------------------------------------
    -- Work in progress hacks below

    -- registers for temporary hacks
    hack_regs_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_HACK_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_HACK_REGS),
        register_data_o => hack_registers
    );
    read_data_o(DSP_HACK_REGS) <= hack_registers;
    read_ack_o(DSP_HACK_REGS) <= (others => '1');


    loopback <= hack_registers(DSP_HACK_REG0)(2);
    dac_output_enable <= hack_registers(DSP_HACK_REG0)(3);

    nco_0_phase_advance <= unsigned(hack_registers(DSP_HACK_REG1));

    -- These will need to be hardware triggers
    nco_0_reset <= strobed_bits(30);
    nco_1_reset <= strobed_bits(29);

    dsp_event_o <= '0';

    dsp_to_control_o.dram0_enable <= '1';
    dsp_to_control_o.adc_trigger <= adc_delta_event;

end;
