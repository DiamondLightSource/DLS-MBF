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

        -- Trigger etc
        start_i : in std_ulogic;
        blanking_i : in std_ulogic;

        -- Control frequency out
        nco_gain_o : out unsigned;
        nco_enable_o : out std_ulogic;
        nco_freq_o : out angle_t
    );
end;

architecture arch of tune_pll_top is
    constant ANGLE_BITS : natural := 18;

    -- Control of bunch memory for detector
    signal bunch_start_write : std_ulogic;
    signal bunch_write_strobe : std_ulogic;
    -- Selection of data source
    signal data_select : std_logic_vector(1 downto 0);
    signal detector_shift : unsigned(1 downto 0);

    -- Detector control signals
    signal start_detector : std_ulogic;
    signal write_detector : std_ulogic;
    signal detector_done : std_ulogic;
    signal detector_overflow : std_ulogic;
    signal detector_iq : cos_sin_t(cos(31 downto 0), sin(31 downto 0));

    -- Cordic signals
    signal cordic_phase : signed(ANGLE_BITS-1 downto 0);
    signal cordic_magnitude : unsigned(31 downto 0);
    signal cordic_done : std_ulogic;

    -- Feedback signals
    signal enable : std_ulogic;
    signal magnitude_limit : unsigned(31 downto 0);
    signal phase_limit : unsigned(ANGLE_BITS-1 downto 0);
    signal target_phase : signed(ANGLE_BITS-1 downto 0);
    signal multiplier : signed(24 downto 0);
    signal base_frequency : angle_t;
    signal set_frequency : std_ulogic;
    signal feedback_done : std_ulogic;
    signal magnitude_error : std_ulogic;
    signal phase_error : std_ulogic;
    signal frequency_out : angle_t;

begin
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
        -- Detector control and status
        bunch_start_write_o => bunch_start_write,
        bunch_write_strobe_o => bunch_write_strobe,
        data_select_o => data_select,
        detector_shift_o => detector_shift,
        detector_overflow_i => detector_overflow,
        -- Feedback control and status
        target_phase_o => target_phase,
        multiplier_o => multiplier,
        magnitude_limit_o => magnitude_limit,
        phase_limit_o => phase_limit,
        base_frequency_o => base_frequency,
        set_frequency_o => set_frequency,
        magnitude_error_i => magnitude_error,
        phase_error_i => phase_error
    );

    -- The detector runs at ADC clock rate, but brings the result over to the
    -- DSP clock so that we can do the rest of our process a bit more easily.
    detector : entity work.tune_pll_detector port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,
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
        start_i => start_detector,
        write_i => write_detector,
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
        enable_i => enable,
        -- Limits for feedback
        magnitude_limit_i => magnitude_limit,
        phase_limit_i => phase_limit,
        -- Target phase and feedback scaling
        target_phase_i => target_phase,
        multiplier_i => multiplier,
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
        phase_error_o => phase_error,
        frequency_o => frequency_out
    );

    nco_freq_o <= frequency_out;

--     control : entity work.tune_pll_control port map (
--     );
-- 
--     readout : entity work.tune_pll_readout port map (
--     );
end;
