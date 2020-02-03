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
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- External data in and out
        adc_data_i : in signed;
        dac_data_o : out signed;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_ulogic_vector(DSP_REGS_RANGE);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_REGS_RANGE);
        read_strobe_i : in std_ulogic_vector(DSP_REGS_RANGE);
        read_data_o : out reg_data_array_t(DSP_REGS_RANGE);
        read_ack_o : out std_ulogic_vector(DSP_REGS_RANGE);

        -- External control: data multiplexing and shared control
        control_to_dsp_i : in control_to_dsp_t;
        dsp_to_control_o : out dsp_to_control_t;

        -- Front panel event generated from sequencer
        dsp_event_o : out std_ulogic
    );
end;

architecture arch of dsp_top is
    -- Bunch control
    signal bunch_config : bunch_config_t;
    signal detector_window : detector_win_t;

    -- Sequencer and detector
    signal sequencer_start : std_ulogic;
    signal sequencer_write : std_ulogic;
    signal tune_pll_offset : signed(31 downto 0);

    -- Oscillator control
    signal nco_0_phase_advance : angle_t;
    signal nco_0_reset_phase : std_ulogic;
    signal nco_0_cos_sin : cos_sin_18_t;

    -- Data flow
    signal fir_data : signed(FIR_DATA_RANGE);
    signal fill_reject_adc : signed(ADC_DATA_RANGE);

    -- Delay from bunch bank selection to bank configuration, validated by
    -- bunch_select, used by sequencer_top.
    constant BUNCH_SELECT_DELAY : natural := 8;

begin
    -- -------------------------------------------------------------------------
    -- General register handling

    nco_register : entity work.nco_register port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_NCO0_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_NCO0_REGS),
        read_strobe_i => read_strobe_i(DSP_NCO0_REGS),
        read_data_o => read_data_o(DSP_NCO0_REGS),
        read_ack_o => read_ack_o(DSP_NCO0_REGS),

        nco_freq_i => nco_0_phase_advance,
        nco_freq_o => nco_0_phase_advance,
        reset_phase_o => nco_0_reset_phase,
        write_freq_o => open
    );

    -- -------------------------------------------------------------------------
    -- Miscellaneous control

    -- Bunch specific control
    bunch_select : entity work.bunch_select generic map (
        BUNCH_SELECT_DELAY => BUNCH_SELECT_DELAY
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock,

        write_strobe_i => write_strobe_i(DSP_BUNCH_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_BUNCH_REGS),
        read_strobe_i => read_strobe_i(DSP_BUNCH_REGS),
        read_data_o => read_data_o(DSP_BUNCH_REGS),
        read_ack_o => read_ack_o(DSP_BUNCH_REGS),

        bank_select_i => control_to_dsp_i.bank_select,
        bunch_config_o => bunch_config
    );


    -- Oscillators
    nco_0 : entity work.nco port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        phase_advance_i => nco_0_phase_advance,
        reset_phase_i => nco_0_reset_phase,
        cos_sin_o => nco_0_cos_sin
    );
    dsp_to_control_o.nco_0_data.nco <= nco_0_cos_sin;



    -- -------------------------------------------------------------------------
    -- Signal processing chain

    -- ADC input processing
    adc_top : entity work.adc_top generic map (
        TAP_COUNT => ADC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock,

        data_i => adc_data_i,
        data_o => dsp_to_control_o.adc_data,
        fill_reject_o => fill_reject_adc,
        data_store_o => dsp_to_control_o.store_adc_data,

        write_strobe_i => write_strobe_i(DSP_ADC_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_ADC_REGS),
        read_strobe_i => read_strobe_i(DSP_ADC_REGS),
        read_data_o => read_data_o(DSP_ADC_REGS),
        read_ack_o => read_ack_o(DSP_ADC_REGS),

        delta_event_o => dsp_to_control_o.adc_trigger
    );


    -- FIR processing
    bunch_fir_top : entity work.bunch_fir_top generic map (
        TAP_COUNT => BUNCH_FIR_TAP_COUNT,
        HEADROOM_OFFSET => 2
    ) port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,

        data_i => control_to_dsp_i.adc_data,
        data_o => fir_data,

        turn_clock_i => control_to_dsp_i.turn_clock,
        bunch_config_i => bunch_config,

        write_strobe_i => write_strobe_i(DSP_FIR_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_FIR_REGS),
        read_strobe_i => read_strobe_i(DSP_FIR_REGS),
        read_data_o => read_data_o(DSP_FIR_REGS),
        read_ack_o => read_ack_o(DSP_FIR_REGS)
    );
    dsp_to_control_o.fir_data <= fir_data;


    -- DAC output processing
    dac_top : entity work.dac_top generic map (
        TAP_COUNT => DAC_FIR_TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock,

        bunch_config_i => bunch_config,
        fir_data_i => fir_data,
        nco_0_data_i => control_to_dsp_i.nco_0_data,
        nco_1_data_i => control_to_dsp_i.nco_1_data,
        nco_2_data_i => control_to_dsp_i.nco_2_data,

        -- These controls are here mainly as an accident of register assignment
        nco_0_gain_o => dsp_to_control_o.nco_0_data.gain,
        nco_0_enable_o => dsp_to_control_o.nco_0_data.enable,

        data_store_o => dsp_to_control_o.dac_data,
        data_o => dac_data_o,

        write_strobe_i => write_strobe_i(DSP_DAC_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DAC_REGS),
        read_strobe_i => read_strobe_i(DSP_DAC_REGS),
        read_data_o => read_data_o(DSP_DAC_REGS),
        read_ack_o => read_ack_o(DSP_DAC_REGS),

        delta_event_o => dsp_to_control_o.dac_trigger
    );


    -- -------------------------------------------------------------------------
    -- Sequencer and detector

    sequencer : entity work.sequencer_top generic map (
        BUNCH_SELECT_DELAY => BUNCH_SELECT_DELAY
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        turn_clock_adc_i => control_to_dsp_i.turn_clock,
        blanking_i => control_to_dsp_i.blanking,

        write_strobe_i => write_strobe_i(DSP_SEQ_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_SEQ_REGS),
        read_strobe_i => read_strobe_i(DSP_SEQ_REGS),
        read_data_o => read_data_o(DSP_SEQ_REGS),
        read_ack_o => read_ack_o(DSP_SEQ_REGS),

        trigger_i => control_to_dsp_i.seq_start,

        state_trigger_o => dsp_to_control_o.seq_trigger,
        seq_busy_o => dsp_to_control_o.seq_busy,

        seq_start_adc_o => sequencer_start,
        seq_write_adc_o => sequencer_write,

        tune_pll_offset_i => tune_pll_offset,
        nco_data_o => dsp_to_control_o.nco_1_data,
        detector_window_o => detector_window,
        bunch_bank_o => dsp_to_control_o.bank_select
    );
    dsp_event_o <= dsp_to_control_o.seq_trigger;


    detector : entity work.detector_top generic map (
        DATA_IN_BUFFER_LENGTH => 4,
        DATA_BUFFER_LENGTH => 8,
        NCO_BUFFER_LENGTH => 4,
        MEMORY_BUFFER_LENGTH => 4,
        CONTROL_BUFFER_LENGTH => 8
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock,

        write_strobe_i => write_strobe_i(DSP_DET_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DET_REGS),
        read_strobe_i => read_strobe_i(DSP_DET_REGS),
        read_data_o => read_data_o(DSP_DET_REGS),
        read_ack_o => read_ack_o(DSP_DET_REGS),

        adc_data_i => control_to_dsp_i.adc_data,
        adc_fill_reject_i => fill_reject_adc,
        fir_data_i => fir_data,
        nco_iq_i => dsp_to_control_o.nco_1_data.nco,
        window_i => detector_window,

        start_i => sequencer_start,
        write_i => sequencer_write,

        mem_valid_o => dsp_to_control_o.dram1_valid,
        mem_ready_i => control_to_dsp_i.dram1_ready,
        mem_addr_o => dsp_to_control_o.dram1_address,
        mem_data_o => dsp_to_control_o.dram1_data
    );


    tune_pll : entity work.tune_pll_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => control_to_dsp_i.turn_clock,

        write_strobe_i => write_strobe_i(DSP_TUNE_PLL_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_TUNE_PLL_REGS),
        read_strobe_i => read_strobe_i(DSP_TUNE_PLL_REGS),
        read_data_o => read_data_o(DSP_TUNE_PLL_REGS),
        read_ack_o => read_ack_o(DSP_TUNE_PLL_REGS),

        adc_data_i => control_to_dsp_i.adc_data,
        adc_fill_reject_i => fill_reject_adc,
        fir_data_i => fir_data,

        start_i => control_to_dsp_i.start_tune_pll,
        stop_i => control_to_dsp_i.stop_tune_pll,
        blanking_i => control_to_dsp_i.blanking,

        nco_data_o => dsp_to_control_o.nco_2_data,
        freq_offset_o => tune_pll_offset,

        interrupt_o => dsp_to_control_o.tune_pll_ready
    );
end;
