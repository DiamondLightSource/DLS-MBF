-- Tune following through phase locked loop

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;

entity tune_pll_top is
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
    constant PHASE_ANGLE_BITS : natural := 18;

    -- Delayed turn clock to help with placement
    signal turn_clock_in : std_ulogic;

    -- Control of bunch memory for detector
    signal bunch_start_write : std_ulogic;
    signal bunch_write_strobe : std_ulogic;
    -- Selection of data source
    signal data_select : std_logic_vector(1 downto 0);
    signal detector_shift : unsigned(1 downto 0);

    -- Detector control signals
    signal dwell_clock : std_ulogic;
    signal detector_done : std_ulogic;
    signal detector_overflow : std_ulogic;
    signal detector_iq : cos_sin_t(cos(31 downto 0), sin(31 downto 0));

    -- Cordic signals
    signal cordic_phase : signed(PHASE_ANGLE_BITS-1 downto 0);
    signal cordic_magnitude : unsigned(31 downto 0);
    signal cordic_done : std_ulogic;

    -- Feedback signals
    signal enable_feedback : std_ulogic;
    signal magnitude_limit : unsigned(31 downto 0);
    signal offset_limit : signed(31 downto 0);
    signal target_phase : signed(PHASE_ANGLE_BITS-1 downto 0);
    signal integral : signed(24 downto 0);
    signal proportional : signed(24 downto 0);
    signal base_frequency : angle_t;
    signal set_frequency : std_ulogic;
    signal feedback_done : std_ulogic;
    signal magnitude_error : std_ulogic;
    signal offset_error : std_ulogic;
    signal frequency_offset : signed(31 downto 0);

    -- Control signals
    signal dwell_time : unsigned(11 downto 0);
    -- Stop reasons
    signal stop_stop : std_ulogic;
    signal stop_detector_overflow : std_ulogic;
    signal stop_magnitude_error : std_ulogic;
    signal stop_offset_error : std_ulogic;

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
        -- NCO control
        nco_gain_o => nco_gain_o,
        nco_enable_o => nco_enable_o,
        nco_freq_i => nco_freq_o,
        -- Detector control and status
        bunch_start_write_o => bunch_start_write,
        bunch_write_strobe_o => bunch_write_strobe,
        data_select_o => data_select,
        detector_shift_o => detector_shift,
        detector_overflow_i => detector_overflow,
        -- Feedback control and status
        target_phase_o => target_phase,
        integral_o => integral,
        proportional_o => proportional,
        magnitude_limit_o => magnitude_limit,
        offset_limit_o => offset_limit,
        base_frequency_o => base_frequency,
        set_frequency_o => set_frequency,
        magnitude_error_i => magnitude_error,
        offset_error_i => offset_error,
        -- Control
        dwell_time_o => dwell_time,
        enable_feedback_i => enable_feedback,
        stop_stop_i => stop_stop,
        stop_detector_overflow_i => stop_detector_overflow,
        stop_magnitude_error_i => stop_magnitude_error,
        stop_offset_error_i => stop_offset_error
    );

    -- The detector runs at ADC clock rate, but brings the result over to the
    -- DSP clock so that we can do the rest of our process a bit more easily.
    detector : entity work.tune_pll_detector port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_in,
        -- Data input and selection
        data_select_i => data_select,
        adc_data_i => adc_data_i,
        adc_fill_reject_i => adc_fill_reject_i,
        fir_data_i => fir_data_i,
        nco_iq_i => nco_iq_i,
        -- Bunch selection interface
        start_write_i => bunch_start_write,
        write_strobe_i => bunch_write_strobe,
        write_data_i => write_data_i,
        -- Select scaling of detector readout
        shift_i => detector_shift,
        -- Detector triggering
        start_i => dwell_clock,      -- Detector is always running, so
        write_i => dwell_clock,      -- start and write are the same signal
        -- Results
        detector_overflow_o => detector_overflow,
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
        enable_i => enable_feedback,
        blanking_i => blanking_i,
        detector_overflow_i => detector_overflow,
        -- Limits for feedback
        magnitude_limit_i => magnitude_limit,
        offset_limit_i => offset_limit,
        -- Target phase and feedback scaling
        target_phase_i => target_phase,
        integral_i => integral,
        proportional_i => proportional,
        -- Interface for setting output frequency
        base_frequency_i => base_frequency,
        set_frequency_i => set_frequency,
        -- Phase and magnitude from CORDIC
        start_i => cordic_done,
        phase_i => cordic_phase,
        magnitude_i => cordic_magnitude,
        -- Feedback and error flags
        done_o => feedback_done,
        magnitude_error_o => magnitude_error,
        offset_error_o => offset_error,
        frequency_o => nco_freq_o,
        frequency_offset_o => frequency_offset
    );

    control : entity work.tune_pll_control port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_in,
        -- Continuous detector dwell
        dwell_time_i => dwell_time,
        dwell_clock_o => dwell_clock,
        -- Feedback status
        detector_overflow_i => detector_overflow,
        magnitude_error_i => magnitude_error,
        offset_error_i => offset_error,
        -- Stop reasons
        stop_o => stop_stop,
        detector_overflow_o => stop_detector_overflow,
        magnitude_error_o => stop_magnitude_error,
        offset_error_o => stop_offset_error,
        -- Feedback operation
        start_i => start_i,
        stop_i => stop_i,
        enable_o => enable_feedback
    );

-- 
--     readout : entity work.tune_pll_readout port map (
--     );
end;
