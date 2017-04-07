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

architecture arch of dsp_top is
    -- General readback status bits
    signal status_bits : reg_data_t;

    -- Strobed control signals
    signal strobed_bits : reg_data_t;
    signal write_start : std_logic;
    signal delta_reset : std_logic;

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
    signal nco_0_cos_sin : cos_sin_18_t;
    signal nco_1_phase_advance : angle_t;
    signal nco_1_cos_sin : cos_sin_18_t;
    signal nco_1_gain : unsigned(3 downto 0);

    -- Data flow
    signal fir_data : signed(FIR_DATA_WIDTH-1 downto 0);

begin
    -- -------------------------------------------------------------------------
    -- General register handling

    dsp_registers : entity work.dsp_registers port map (
        dsp_clk_i => dsp_clk_i,

        -- DSP general control registers
        write_strobe_i => write_strobe_i(DSP_MISC_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_MISC_REGS),
        read_strobe_i => read_strobe_i(DSP_MISC_REGS),
        read_data_o => read_data_o(DSP_MISC_REGS),
        read_ack_o => read_ack_o(DSP_MISC_REGS),

        -- Processed registers
        strobed_bits_o => strobed_bits,
        status_bits_i => status_bits,
        pulsed_bits_i => pulsed_bits,
        nco_0_frequency_o => nco_0_phase_advance
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
        others => '0'
    );


    -- -------------------------------------------------------------------------
    -- Miscellaneous control

    -- Bunch specific control
    bunch_select : entity work.bunch_select port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock_adc,

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
    nco_0 : entity work.nco port map (
        clk_i => adc_clk_i,
        phase_advance_i => nco_0_phase_advance,
        cos_sin_o => nco_0_cos_sin
    );
    dsp_to_control_o.nco_0_data <= nco_0_cos_sin;

    nco_1 : entity work.nco port map (
        clk_i => adc_clk_i,
        phase_advance_i => nco_1_phase_advance,
        cos_sin_o => nco_1_cos_sin
    );
    dsp_to_control_o.nco_1_data <= nco_1_cos_sin;


    -- -------------------------------------------------------------------------
    -- Signal processing chain

    -- ADC input processing
    adc_top : entity work.adc_top generic map (
        TAP_COUNT => ADC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock_adc,

        data_i => adc_data_i,
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
    bunch_fir_top : entity work.bunch_fir_top generic map (
        TAP_COUNT => BUNCH_FIR_TAP_COUNT
    ) port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,

        data_i => control_to_dsp_i.adc_data,
        data_o => fir_data,

        turn_clock_i => control_to_dsp_i.turn_clock_adc,
        bunch_config_i => bunch_config,

        write_strobe_i => write_strobe_i(DSP_FIR_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_FIR_REGS),
        read_strobe_i => read_strobe_i(DSP_FIR_REGS),
        read_data_o => read_data_o(DSP_FIR_REGS),
        read_ack_o => read_ack_o(DSP_FIR_REGS),

        write_start_i => write_start
    );
    dsp_to_control_o.fir_data <= fir_data;

    -- DAC output processing
    dac_top : entity work.dac_top generic map (
        TAP_COUNT => DAC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock_adc,

        bunch_config_i => bunch_config,
        fir_data_i => fir_data,
        nco_0_data_i => control_to_dsp_i.nco_0_data,
        nco_1_data_i => control_to_dsp_i.nco_1_data,
        nco_1_gain_i => nco_1_gain,

        data_store_o => dsp_to_control_o.dac_data,
        data_o => dac_data_o,
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


    -- -------------------------------------------------------------------------
    -- Sequencer and detector

    sequencer : entity work.sequencer_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        turn_clock_i => control_to_dsp_i.turn_clock_dsp,
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

    detector : entity work.detector_top generic map (
        DATA_BUFFER_LENGTH => 2,
        NCO_BUFFER_LENGTH => 2,
        MEMORY_BUFFER_LENGTH => 2
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock_adc,

        write_strobe_i => write_strobe_i(DSP_DET_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DET_REGS),
        read_strobe_i => read_strobe_i(DSP_DET_REGS),
        read_data_o => read_data_o(DSP_DET_REGS),
        read_ack_o => read_ack_o(DSP_DET_REGS),

        adc_data_i => control_to_dsp_i.adc_data,
        fir_data_i => fir_data,
        nco_iq_i => nco_1_cos_sin,
        window_i => detector_window,

        start_i => sequencer_start,
        write_i => sequencer_write,

        mem_valid_o => dsp_to_control_o.dram1_valid,
        mem_ready_i => control_to_dsp_i.dram1_ready,
        mem_addr_o => dsp_to_control_o.dram1_address,
        mem_data_o => dsp_to_control_o.dram1_data
    );





    dsp_event_o <= '0';

    dsp_to_control_o.dram0_enable <= '1';
    dsp_to_control_o.adc_trigger <= adc_delta_event;

end;
