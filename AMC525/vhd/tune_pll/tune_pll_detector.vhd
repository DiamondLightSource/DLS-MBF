-- Detector for tune pll

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;

entity tune_pll_detector is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        -- Data in
        data_select_i : in std_ulogic_vector(1 downto 0);
        adc_data_i : in signed;
        adc_fill_reject_i : in signed;
        fir_data_i : in signed;
        nco_iq_i : in cos_sin_t;

        -- Bunch write control
        start_write_i : in std_ulogic;
        write_strobe_i : in std_ulogic;
        write_data_i : in reg_data_t;

        -- Control signals
        shift_i : in unsigned;
        start_i : in std_ulogic;
        write_i : in std_ulogic;

        -- Result
        detector_overflow_o : out std_ulogic;
        done_o : out std_ulogic;
        iq_o : out cos_sin_t
    );
end;

architecture arch of tune_pll_detector is
    constant RESULT_WIDTH : natural := iq_o.cos'LENGTH;

    signal shift : natural;
    signal bunch_enable : std_ulogic;
    signal data_in : signed(24 downto 0);
    signal detector_overflow : std_ulogic;
    signal det_done : std_ulogic;
    signal done : std_ulogic;
    signal iq : cos_sin_96_t;
    signal iq_out : cos_sin_96_t;

begin
    -- Compute shift.
    shift <= 8 * to_integer(shift_i) + 16;

    -- Bunch select memory
    bunch_select : entity work.detector_bunch_select port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        start_write_i => start_write_i,
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,

        bunch_enable_o => bunch_enable
    );

    -- Data preparation: selection, FIR gain, and windowing
    detector_input : entity work.detector_input generic map (
        BUFFER_LENGTH => DATA_IN_BUFFER_LENGTH,
        USE_WINDOW => false
    ) port map (
        clk_i => adc_clk_i,

        data_select_i => data_select_i,

        adc_data_i => adc_data_i,
        adc_fill_reject_i => adc_fill_reject_i,
        fir_data_i => fir_data_i,
        window_i => open,

        data_o => data_in
    );

    -- IQ Detector
    detector : entity work.detector_core generic map (
        RESULT_WIDTH => RESULT_WIDTH
    ) port map (
        clk_i => adc_clk_i,

        data_i => data_in,
        iq_i => nco_iq_i,
        bunch_enable_i => bunch_enable,

        shift_i => shift,
        start_i => start_i,
        write_i => write_i,

        write_o => det_done,
        detector_overflow_o => detector_overflow,
        iq_o => iq
    );

    -- The detector results now remain valid so we can bring them over to the
    -- DSP clock
    done_adc_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => det_done,
        pulse_o => done
    );

    -- Extract and register desired result on the DSP clock.  We have to do this
    -- in two steps: first bring the data across unchanged, then process for
    -- output (shift and gate overflow).  This two stage processing is required
    -- to avoid logic on the ADC->DSP path.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            detector_overflow_out <= detector_overflow;
            iq_out <= iq;

            -- Note that it is safe to use the done strobe at this point
            if done = '1' then
                iq_o.cos <=
                    shift_right(iq_out.cos, shift)(RESULT_WIDTH-1 downto 0);
                iq_o.sin <=
                    shift_right(iq_out.sin, shift)(RESULT_WIDTH-1 downto 0);
            end if;

            detector_overflow_o <= detector_overflow and done;
            done_o <= done;
        end process;
    end;
end;
