-- Tune following through phase locked loop

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;

use work.tune_pll_defs.all;

entity tune_pll_top is
    generic (
        -- This default readout IIR shift corresponds to a delay constant of
        -- 2^13 or around 8000.  With an IIR clock at around 0.5MHz this
        -- corresponds to a 3dB point around 60Hz and a settling time to 1% of
        -- around 100 ms.
        READOUT_IIR_SHIFT : unsigned := "1101";
        -- Divide the DSP clock by 512 to produce the IIR clock.  This is enough
        -- to ensure we should see all relevant updates.
        READOUT_IIR_CLOCK_BITS : natural := 9
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        read_data_o : out reg_data_array_t(DSP_TUNE_PLL_CONTROL_REGS);
        read_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);

        -- Data in
        adc_data_i : in signed;
        adc_fill_reject_i : in signed;
        fir_data_i : in signed;
        nco_iq_i : in cos_sin_t;

        -- Global start/stop.  These controls come from outside so that both
        -- Tune PLL units can be started and stopped together.
        start_i : in std_ulogic;
        stop_i : in std_ulogic;
        blanking_i : in std_ulogic;

        -- Control frequency out
        nco_gain_o : out unsigned(3 downto 0);
        nco_enable_o : out std_ulogic;
        nco_freq_o : out angle_t
    );
end;

architecture arch of tune_pll_top is
    -- Delayed turn clock to help with placement
    signal turn_clock_in : std_ulogic;

    -- Register configuration
    signal config : tune_pll_config_t;
    signal status : tune_pll_status_t;

    -- Control of bunch memory for detector
    signal bunch_start_write : std_ulogic;
    signal bunch_write_strobe : std_ulogic;

    -- Detector control signals
    signal dwell_clock : std_ulogic;
    signal detector_done : std_ulogic;
    signal detector_iq : cos_sin_t(cos(31 downto 0), sin(31 downto 0));

    -- Cordic signals
    signal cordic_phase : phase_angle_t;
    signal phase_error : phase_angle_t;
    signal cordic_magnitude : unsigned(31 downto 0);
    signal cordic_done : std_ulogic;

    -- Feedback signals
    signal set_frequency : std_ulogic;
    signal feedback_done : std_ulogic;
    signal frequency_offset : signed(31 downto 0);

begin
    turn_clock : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock_in
    );

    registers : entity work.tune_pll_registers port map (
        dsp_clk_i => dsp_clk_i,
        -- Register interface
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,
        -- Configuration control
        config_o => config,
        status_i => status,
        -- NCO readback
        nco_freq_i => nco_freq_o,
        set_frequency_o => set_frequency,
        -- Detector bunch memory
        bunch_start_write_o => bunch_start_write,
        bunch_write_strobe_o => bunch_write_strobe
    );

    -- The detector runs at ADC clock rate, but brings the result over to the
    -- DSP clock so that we can do the rest of our process a bit more easily.
    detector : entity work.tune_pll_detector port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_in,
        -- Data input and selection
        data_select_i => config.data_select,
        adc_data_i => adc_data_i,
        adc_fill_reject_i => adc_fill_reject_i,
        fir_data_i => fir_data_i,
        nco_iq_i => nco_iq_i,
        -- Bunch selection interface
        start_write_i => bunch_start_write,
        write_strobe_i => bunch_write_strobe,
        write_data_i => write_data_i,
        -- Select scaling of detector readout
        shift_i => config.detector_shift,
        -- Detector triggering
        start_i => dwell_clock,      -- Detector is always running, so
        write_i => dwell_clock,      -- start and write are the same signal
        -- Results
        detector_overflow_o => status.detector_overflow,
        done_o => detector_done,
        iq_o => detector_iq
    );

    -- Convert detector IQ to phase and magnitude
    cordic : entity work.tune_pll_cordic port map (
        clk_i => dsp_clk_i,
        iq_i => detector_iq,
        start_i => detector_done,
        angle_o => cordic_phase,
        magnitude_o => cordic_magnitude,
        done_o => cordic_done
    );

    -- Perform frequency feedback on the phase, use the magnitude to qualify
    feedback : entity work.tune_pll_feedback port map (
        clk_i => dsp_clk_i,
        -- Controls whether to update frequency.
        enable_i => status.enable_feedback,
        blanking_i => blanking_i,
        detector_overflow_i => status.detector_overflow,
        -- Limits for feedback
        magnitude_limit_i => config.magnitude_limit,
        offset_limit_i => config.offset_limit,
        -- Target phase and feedback scaling
        target_phase_i => config.target_phase,
        integral_i => config.integral,
        proportional_i => config.proportional,
        -- Interface for setting output frequency
        base_frequency_i => config.base_frequency,
        set_frequency_i => set_frequency,
        -- Phase and magnitude from CORDIC
        start_i => cordic_done,
        phase_i => cordic_phase,
        magnitude_i => cordic_magnitude,
        phase_error_o => phase_error,
        -- Feedback and error flags
        done_o => feedback_done,
        magnitude_error_o => status.magnitude_error,
        offset_error_o => status.offset_error,
        frequency_o => nco_freq_o,
        frequency_offset_o => frequency_offset
    );

    -- Control: generates dwell clock and feedback enable
    control : entity work.tune_pll_control port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_in,
        -- Continuous detector dwell
        dwell_time_i => config.dwell_time,
        dwell_clock_o => dwell_clock,
        -- Feedback status
        detector_overflow_i => status.detector_overflow,
        magnitude_error_i => status.magnitude_error,
        offset_error_i => status.offset_error,
        -- Stop reasons
        stop_o => status.stop_stop,
        detector_overflow_o => status.stop_detector_overflow,
        magnitude_error_o => status.stop_magnitude_error,
        offset_error_o => status.stop_offset_error,
        -- Feedback operation
        start_i => start_i,
        stop_i => stop_i,
        enable_o => status.enable_feedback
    );

    -- Register interface to read out state and results
    readout : entity work.tune_pll_readout generic map (
        READOUT_IIR_SHIFT => READOUT_IIR_SHIFT,
        READOUT_IIR_CLOCK_BITS => READOUT_IIR_CLOCK_BITS
    ) port map (
        clk_i => dsp_clk_i,
        -- Detector output
        detector_done_i => detector_done,
        iq_i => detector_iq,
        filtered_iq_o => status.filtered_iq,
        -- CORDIC output
        cordic_done_i => cordic_done,
        phase_i => phase_error,
        magnitude_i => cordic_magnitude,
        filtered_phase_o => status.filtered_phase,
        filtered_magnitude_o => status.filtered_magnitude,
        -- Feedback output
        feedback_done_i => feedback_done,
        frequency_offset_i => frequency_offset,
        filtered_frequency_offset_o => status.filtered_frequency_offset
    );

    nco_gain_o <= config.nco_gain;
    nco_enable_o <= config.nco_enable;
end;
