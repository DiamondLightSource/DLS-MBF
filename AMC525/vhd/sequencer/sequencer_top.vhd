-- Top level sequencer

-- Two groups of control signals need to be output synchronously for the rest
-- of the system to work correctly.
--
-- Output control:
--
--  bunch_bank_o    Determines FIR selection, DAC output selection, output gain
--  nco_data_o      Generated NCO for output and detector
--
-- Detector control:
--
--  detector_window_o    Detector window
--  seq_start_o     Detector dwell start accumulator reset
--  seq_write_o     Detector dwell end
--
-- The following signals on this interface are on the ADC clock:
--
--  turn_clock_adc_i
--  seq_start_adc_o
--  seq_write_adc_o

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.dsp_defs.all;
use work.sequencer_defs.all;
use work.register_defs.all;

entity sequencer_top is
    generic (
        -- Delay from bunch bank selection to bank configuration
        BUNCH_SELECT_DELAY : natural
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Clocking
        turn_clock_adc_i : in std_ulogic;    -- Start of a machine revolution
        blanking_i : in std_ulogic;      -- Can be used to disable sequence

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_SEQ_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_SEQ_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_SEQ_REGS);
        read_data_o : out reg_data_array_t(DSP_SEQ_REGS);
        read_ack_o : out std_ulogic_vector(DSP_SEQ_REGS);

        -- Triggering control for starting sequencer
        trigger_i : in std_ulogic;       -- Sequencer trigger

        -- Event generation on entering selected sequencer state, available as
        -- internal event for event generation elsewhere.
        state_trigger_o : out std_ulogic; -- Sequencer about to start state
        seq_busy_o : out std_ulogic;     -- Set during sequencer operation

        seq_start_adc_o : out std_ulogic;   -- Resets detector at start of dwell
        seq_write_adc_o : out std_ulogic;   -- End of dwell interval

        tune_pll_offset_i : in signed(31 downto 0); -- Tune PLL frequency offset
        nco_data_o : out dsp_nco_to_mux_t;
        detector_window_o : out detector_win_t; -- Detector input window
        bunch_bank_o : out unsigned(1 downto 0) -- Bunch bank selection
    );
end;

architecture arch of sequencer_top is
    -- Register configuration
    signal seq_abort : std_ulogic;
    signal target_seq_pc : seq_pc_t;
    signal target_super_count : super_count_t;
    signal trigger_state : seq_pc_t;
    -- Memory interface
    constant MEM_PROGRAM : natural := 0;
    constant MEM_WINDOW : natural := 1;
    constant MEM_FREQUENCY : natural := 2;
    signal mem_write_strobe : std_ulogic_vector(0 to 2);
    signal mem_write_addr : unsigned(9 downto 0);
    signal mem_write_data : reg_data_t;

    signal turn_clock : std_ulogic;
    signal nco_freq : angle_t;
    signal nco_reset : std_ulogic;
    signal detector_window : detector_window_o'SUBTYPE;
    signal bunch_bank : bunch_bank_o'SUBTYPE;

    -- Program Counter interface
    --
    -- Valid from shortly after turn_clock, a rising edge on this signal
    -- triggers the program counter to advance.
    signal state_end : std_ulogic;
    -- Program counter and reset, also triggers loading of next state.
    signal start_load : std_ulogic;  -- Command to load next state
    signal seq_pc : seq_pc_t;       -- Current program counter
    signal seq_pc_out : seq_pc_t;   -- Reported program counter
    signal reset_turn : std_ulogic;  -- Reset counters to abort current state.
    -- Frequency offset from super sequencer
    signal nco_freq_base : angle_t;
    signal super_count : super_count_t;
    signal tune_pll_offset : signed(31 downto 0);

    -- Seq state loading
    --
    -- Next program state loaded at end of dwell: start_load is generated by
    -- sequencer_pc in response to state_end generated by dwell module.
    signal seq_state : seq_state_t;
    signal blanking_in : std_ulogic;

    -- Dwell engine
    signal first_turn : std_ulogic;
    signal last_turn : std_ulogic;

    -- Pipelined outputs
    signal seq_start : std_ulogic;
    signal seq_write : std_ulogic;

    -- The following delays are needed to configure the sequencer so that the
    -- sweep output and other controls are aligned at the DAC output.
    --
    -- Delay from nco phase control to cos/sin output, validated by NCO core, in
    -- ADC clock units.
    constant NCO_PROCESS_DELAY : natural := 16;
    -- Delay settings for NCO
    constant NCO_IN_DELAY : natural := 1;       -- In DSP clocks
    constant NCO_OUT_DELAY : natural := 4;      -- In ADC clocks
    -- This is the delay needed on the NCO gain to align with NCO output, in
    -- DSP clock units.
    constant NCO_GAIN_DELAY : natural :=
        NCO_PROCESS_DELAY/2 + NCO_IN_DELAY + NCO_OUT_DELAY/2 + 2;
    -- Extra delay for the bunch bank select taking NCO delays into account
    constant BANK_DELAY : natural := NCO_GAIN_DELAY + 4 - BUNCH_SELECT_DELAY;

begin
    pll_freq_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => 32
    ) port map (
        clk_i => dsp_clk_i,
        data_i => std_ulogic_vector(tune_pll_offset_i),
        signed(data_o) => tune_pll_offset
    );

    registers : entity work.sequencer_registers port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,

        seq_abort_o => seq_abort,
        target_seq_pc_o => target_seq_pc,
        target_super_count_o => target_super_count,
        trigger_state_o => trigger_state,

        seq_pc_i => seq_pc_out,
        super_count_i => super_count,
        seq_busy_i => seq_busy_o,

        mem_write_strobe_o => mem_write_strobe,
        mem_write_addr_o => mem_write_addr,
        mem_write_data_o => mem_write_data
    );

    super : entity work.sequencer_super port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => mem_write_strobe(MEM_FREQUENCY),
        write_addr_i => mem_write_addr,
        write_data_i => mem_write_data,

        super_state_i => super_count,
        nco_freq_base_o => nco_freq_base
    );

    pc : entity work.sequencer_pc port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock,

        trigger_i => trigger_i,

        reset_i => seq_abort,
        seq_pc_i => target_seq_pc,
        state_end_i => state_end,
        trigger_state_i => trigger_state,
        state_trigger_o => state_trigger_o,
        super_count_i => target_super_count,
        super_count_o => super_count,

        start_load_o => start_load,
        seq_pc_o => seq_pc,
        busy_o => seq_busy_o,
        reset_o => reset_turn
    );

    load_state : entity work.sequencer_load_state port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => mem_write_strobe(MEM_PROGRAM),
        write_addr_i => mem_write_addr,
        write_data_i => mem_write_data,

        start_load_i => start_load,
        seq_pc_i => seq_pc,
        seq_state_o => seq_state
    );

    -- Central sequencer engine, generates start and end of dwell signals.
    blanking_in <= blanking_i and seq_state.enable_blanking;
    dwell : entity work.sequencer_dwell port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock,

        reset_i => reset_turn,
        blanking_i => blanking_in,

        dwell_count_i => seq_state.dwell_count,
        holdoff_count_i => seq_state.holdoff_count,
        state_holdoff_i => seq_state.state_holdoff,

        state_end_i => state_end,

        first_turn_o => first_turn,
        last_turn_o => last_turn
    );

    -- Counts down dwells during a single state and manages frequency output.
    counter : entity work.sequencer_counter port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock,
        reset_i => reset_turn,

        freq_base_i => nco_freq_base,
        seq_state_i => seq_state,
        last_turn_i => last_turn,
        tune_pll_offset_i => tune_pll_offset,

        state_end_o => state_end,
        nco_freq_o => nco_freq,
        nco_reset_o => nco_reset
    );

    -- Generates detector window.
    window : entity work.sequencer_window port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock,

        write_strobe_i => mem_write_strobe(MEM_WINDOW),
        write_addr_i => mem_write_addr,
        write_data_i => mem_write_data,

        window_rate_i => seq_state.window_rate,
        enable_window_i => seq_state.enable_window,
        write_enable_i => seq_state.enable_write,

        first_turn_i => first_turn,
        last_turn_i => last_turn,

        seq_start_o => seq_start,
        seq_write_o => seq_write,
        detector_window_o => detector_window
    );

    -- Fine tuning to output
    delays : entity work.sequencer_delays generic map (
        NCO_GAIN_DELAY => NCO_GAIN_DELAY,
        BANK_DELAY => BANK_DELAY
    ) port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock,
        seq_state_i => seq_state,
        seq_pc_i => seq_pc,
        seq_pc_o => seq_pc_out,
        nco_gain_o => nco_data_o.gain,
        bunch_bank_o => bunch_bank
    );

    -- Swept NCO
    seq_nco : entity work.nco generic map (
        PROCESS_DELAY => NCO_PROCESS_DELAY,
        IN_DELAY => NCO_IN_DELAY,
        OUT_DELAY => NCO_OUT_DELAY
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        phase_advance_i => nco_freq,
        reset_phase_i => nco_reset,
        cos_sin_o => nco_data_o.nco
    );


    clocking : entity work.sequencer_clocking port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        turn_clock_adc_i => turn_clock_adc_i,
        turn_clock_dsp_o => turn_clock,

        seq_start_dsp_i => seq_start,
        seq_start_adc_o => seq_start_adc_o,

        seq_write_dsp_i => seq_write,
        seq_write_adc_o => seq_write_adc_o,

        detector_window_dsp_i => detector_window,
        detector_window_adc_o => detector_window_o,

        bunch_bank_i => bunch_bank,
        bunch_bank_o => bunch_bank_o
    );
end;
