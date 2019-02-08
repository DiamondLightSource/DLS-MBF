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
        write_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_REGS);
        read_data_o : out reg_data_array_t(DSP_TUNE_PLL_REGS);
        read_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_REGS);

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
    constant IQ_BITS : natural := 24;
    constant ANGLE_BITS : natural := 18;
    subtype detector_iq_t is
        cos_sin_t(cos(IQ_BITS-1 downto 0), sin(IQ_BITS-1 downto 0));

    -- Control of bunch memory for detector
    signal start_write : std_ulogic;
    signal write_strobe : std_ulogic;
    -- Selection of data source
    signal data_select : std_logic_vector(1 downto 0);
    signal detector_shift : unsigned(1 downto 0);

    -- Detector control signals
    signal start_detector : std_ulogic;
    signal write_detector : std_ulogic;
    signal detector_done : std_ulogic;
    signal detector_iq : detector_iq_t;

    -- Cordic signals
    signal cordic_angle : signed(ANGLE_BITS-1 downto 0);
    signal cordic_magnitude : unsigned(IQ_BITS-1 downto 0);
    signal cordic_done : std_ulogic;

begin
    pll_registers : entity work.tune_pll_registers port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,

        start_write_o => start_write,
        write_strobe_o => write_strobe,
        data_select_o => data_select,
    );

    -- The detector runs at ADC clock rate, but brings the result over to the
    -- DSP clock so that we can do the rest of our process a bit more easily.
    detector : entity work.tune_pll_detector port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        data_select_i => data_select,
        adc_data_i => adc_data_i,
        adc_fill_reject_i => adc_fill_reject_i,
        fir_data_i => fir_data_i,
        nco_iq_i => nco_iq_i,

        start_write_i => start_write,
        write_strobe_i => write_strobe,
        write_data_i => write_data_i,

        shift_i => detector_shift,
        start_i => start_detector,
        write_i => write_detector,

        detector_overflow_o => detector_overflow,
        done_o => detector_done,
        iq_o => detector_iq
    );

    cordic : entity work.tune_pll_cordic port map (
        clk_i => dsp_clk_i,
        iq_i => detector_iq,
        start_i => detector_done,
        angle_o => cordic_phase,
        magnitude_o => cordic_magnitude,
        done_o => cordic_done
    );

    feedback : entity work.tune_pll_feedback port map (
        clk_i => dsp_clk_i,
        blanking_i => blanking_i,
        magnitude_limit_i => magnitude_limit,
        phase_limit_i => phase_limit,
        target_phase_i => target_phase,
        multiplier_i => multiplier,
        base_frequency_i => base_frequency,
        set_frequency_i => set_frequency,
        start_i => cordic_done,
        phase_i => cordic_phase,
        magnitude_i => cordic_magnitude,
        done_o => feedback_done,
        magnitude_error_o => magnitude_error,
        phase_error_o => phase_error,
        frequency_o => frequency_o
    );

    control : entity work.tune_pll_control port map (
    );

    readout : entity work.tune_pll_readout port map (
    );
end;
