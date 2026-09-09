-- Interfacing to swept frequency NCOs

-- Modules from the sequencer are used to make sure the swept NCO behaves
-- exactly like the sequencer frequency sweep.
--
-- The module 'swept_nco_repeat' controls the frequency sweep engine from the
-- sequencer, while  'swept_nco_seq_signals' takes care that control signal are
-- aligned with the turn clock accordingly to the sequencer needs.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.dsp_defs.all;
use work.sequencer_defs.all;
use work.register_defs.all;
use work.swept_nco_defs.all;

entity dsp_swept_nco is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Clocking
        turn_clock_adc_i : in std_ulogic;    -- Start of a machine revolution

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_NCO_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_NCO_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_NCO_REGS);
        read_data_o : out reg_data_array_t(DSP_NCO_REGS);
        read_ack_o : out std_ulogic_vector(DSP_NCO_REGS);

        tune_pll_offset_i : in signed(31 downto 0); -- Tune PLL frequency offset

        nco1_data_o : out dsp_nco_to_mux_t;
        nco2_data_o : out dsp_nco_to_mux_t
    );
end;

architecture arch of dsp_swept_nco is
    signal turn_clock : std_ulogic;

    -- Delay from turn_clock to NCO output, validated by sequencer_nco
    constant NCO_PROCESS_DELAY : natural := 14;

    -- Needed for the sequencer clocking instead of 'open'
    signal dummy_1 : signed(0 downto 0);
    signal dummy_2 : unsigned(0 downto 0);

begin
    -- Generate logic for the two swept NCOs.
    gen_nco : for jj in 1 to 2 generate
        -- Frequency sweep reset signals.
        signal reset_sweep_jj : std_ulogic;
        signal reset_sweep_turn_jj : std_ulogic;

        -- Phase reset signals.
        signal reset_phase_in_jj : std_ulogic;
        signal reset_phase_jj : std_ulogic;

        -- Signals used to start a repeat sequence.
        signal repeat_start_jj : std_ulogic;
        signal repeat_start_reset_jj : std_ulogic;
        signal repeat_start_turn_jj : std_ulogic;

        -- Sweep sequence signals
        signal state_end_jj : std_ulogic;
        signal last_turn_jj : std_ulogic;

        -- Seq state
        -- Many signals are not used for the swept NCO so we set them to '0'.
        signal seq_state_jj : seq_state_t := initial_seq_state;

        -- NCO frequency
        signal nco_freq_jj : angle_t;

        -- Repeat control signals.
        signal repeat_count_jj : repeat_count_t;
        signal repeat_readout_jj : repeat_count_t;
        signal repeat_continuous_jj : std_ulogic;
        signal nco_gain_set : nco_gain_t;

        -- NCO output
        signal nco_out_jj : dsp_nco_to_mux_t;

        -- Register interface bus
        signal write_strobe_jj : std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
        signal write_ack_jj : std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
        signal read_strobe_jj : std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
        signal read_data_jj : reg_data_array_t(SWEPT_NCO_REGS_RANGE);
        signal read_ack_jj : std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
    begin

        -- Split the bus for the two swept NCOs.
        nco_reg_intf: if jj = 1 generate
            write_strobe_jj <= write_strobe_i(DSP_NCO_NCO1_REGS);
            write_ack_o(DSP_NCO_NCO1_REGS) <= write_ack_jj;
            read_strobe_jj <= read_strobe_i(DSP_NCO_NCO1_REGS);
            read_data_o(DSP_NCO_NCO1_REGS) <= read_data_jj;
            read_ack_o(DSP_NCO_NCO1_REGS) <= read_ack_jj;
        elsif jj = 2 generate
            write_strobe_jj <= write_strobe_i(DSP_NCO_NCO2_REGS);
            write_ack_o(DSP_NCO_NCO2_REGS) <= write_ack_jj;
            read_strobe_jj <= read_strobe_i(DSP_NCO_NCO2_REGS);
            read_data_o(DSP_NCO_NCO2_REGS) <= read_data_jj;
            read_ack_o(DSP_NCO_NCO2_REGS) <= read_ack_jj;
        end generate nco_reg_intf;


        -- Assign NCO outputs.
        nco_out_sel: if jj = 1 generate
            nco1_data_o <= nco_out_jj;
        elsif jj = 2 generate
            nco2_data_o <= nco_out_jj;
        end generate nco_out_sel;


        -- Swept NCO settings
        set_nco_config : entity work.swept_nco_register port map (
            clk_i => dsp_clk_i,

            write_strobe_i => write_strobe_jj,
            write_data_i => write_data_i,
            write_ack_o => write_ack_jj,
            read_strobe_i => read_strobe_jj,
            read_data_o => read_data_jj,
            read_ack_o => read_ack_jj,

            start_freq_o => seq_state_jj.start_freq,
            delta_freq_o => seq_state_jj.delta_freq,
            dwell_count_o => seq_state_jj.dwell_count,
            point_count_o => seq_state_jj.capture_count,
            nco_gain_o => seq_state_jj.nco_gain,
            enable_tune_pll_o => seq_state_jj.enable_tune_pll,
            repeat_count_o => repeat_count_jj,
            repeat_continuous_o => repeat_continuous_jj,
            repeat_start_o => repeat_start_jj,
            repeat_start_reset_o => repeat_start_reset_jj,

            repeat_count_i => repeat_readout_jj,

            reset_phase_o => reset_phase_in_jj,
            reset_sweep_o => reset_sweep_jj
        );


        -- Central sequencer engine, generates end of dwell signals.
        dwell : entity work.sequencer_dwell port map (
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock,

            reset_i => reset_sweep_turn_jj,
            blanking_i => '0',

            dwell_count_i => seq_state_jj.dwell_count,
            holdoff_count_i => (others => '0'),
            state_holdoff_i => (others => '0'),

            state_end_i => state_end_jj,

            first_turn_o => open,
            last_turn_o => last_turn_jj
        );


        -- Counts down dwells during a frequency sweep and manages
        -- frequency output.
        counter : entity work.sequencer_counter port map (
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock,
            reset_i => reset_sweep_turn_jj,

            freq_base_i => (others => '0'),
            seq_state_i => seq_state_jj,
            last_turn_i => last_turn_jj,

            state_end_o => state_end_jj,

            enable_pll_o => open,
            nco_freq_o => nco_freq_jj,
            nco_reset_o => open
        );

        -- The super sequencer is not used.
        -- In practice, enabling it would not make any difference.
        seq_state_jj.disable_super <= '1';


        -- Control the number of frequency sweep repetitions by acting on 
        -- nco_gain.
        nco_repeat : entity work.swept_nco_repeat port map (
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock,
            reset_i => reset_sweep_turn_jj,

            repeat_count_i => repeat_count_jj,
            repeat_continuous_i => repeat_continuous_jj,
            repeat_start_i => repeat_start_turn_jj,
            repeat_count_o => repeat_readout_jj,

            nco_gain_i => seq_state_jj.nco_gain,

            state_end_i => state_end_jj,

            nco_gain_o => nco_gain_set
        );


        -- NCO output
        seq_nco : entity work.sequencer_nco generic map (
            PROCESS_DELAY => NCO_PROCESS_DELAY
        ) port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock,

            tune_pll_offset_i => tune_pll_offset_i,
            enable_pll_i => seq_state_jj.enable_tune_pll,
            nco_freq_i => nco_freq_jj,
            reset_phase_i => reset_phase_jj,
            nco_gain_i => nco_gain_set,

            nco_data_o => nco_out_jj
        );


        -- Signals shaping and synchronisation.
        seq_signals : entity work.swept_nco_seq_signals port map (
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock,

            state_end_i => state_end_jj,

            reset_sweep_i => reset_sweep_jj,
            reset_turn_o => reset_sweep_turn_jj,

            reset_phase_i => reset_phase_in_jj,
            nco_reset_o => reset_phase_jj,

            repeat_start_i => repeat_start_jj,
            repeat_start_reset_i => repeat_start_reset_jj,
            repeat_start_turn_o => repeat_start_turn_jj
        );
    end generate;


    -- The turn clock is made just like for the sequencer.
    clocking : entity work.sequencer_clocking port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        turn_clock_adc_i => turn_clock_adc_i,
        turn_clock_dsp_o => turn_clock,

        seq_start_dsp_i => '0',
        seq_start_adc_o => open,

        seq_write_dsp_i => '0',
        seq_write_adc_o => open,

        detector_window_dsp_i => "0",
        detector_window_adc_o => dummy_1,

        bunch_bank_i => "0",
        bunch_bank_o => dummy_2
    );
end;
