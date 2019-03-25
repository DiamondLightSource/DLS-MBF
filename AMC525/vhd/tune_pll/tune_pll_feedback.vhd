-- Tune PLL feedback loop

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.tune_pll_defs.all;

entity tune_pll_feedback is
    port (
        clk_i : in std_ulogic;

        -- Controls whether frequency will be updated
        enable_i : in std_ulogic;       -- Enables feedback
        blanking_i : in std_ulogic;     -- Suppress frequency update
        detector_overflow_i : in std_ulogic;    -- Set if CORDIC data invalid

        -- Limits for phase and magnitude, checked and reported as errors
        magnitude_limit_i : in unsigned;
        offset_limit_i : in signed;

        -- Target controls.  An integrating controller uses the integral to
        -- maintain phase_i as close to target_phase_i as possible.
        target_phase_i : in signed;
        integral_i : in signed;
        proportional_i : in signed;

        -- Special debug override option
        offset_override_i : in std_ulogic;
        debug_offset_i : in signed;

        -- This can be used to directly set the output frequency.  This can be
        -- written during normal feedback operation, in which case it will
        -- override the feedback.
        base_frequency_i : in angle_t;
        set_frequency_i : in std_ulogic;

        -- Phase and magnitude from CORDIC strobed by start_i
        start_i : in std_ulogic;
        phase_i : in signed;
        magnitude_i : in unsigned;

        -- Outputs, all strobed by done_o.  Note however that frequency_o will
        -- also change without a strobe event if written to directly.
        done_o : out std_ulogic;
        magnitude_error_o : out std_ulogic;
        offset_error_o : out std_ulogic;
        frequency_o : out angle_t;
        frequency_offset_o : out signed
    );
end;

architecture arch of tune_pll_feedback is
    subtype signed_angle_t is signed(angle_t'RANGE);

    signal start_in : std_ulogic;
    signal enable_feedback : boolean;
    signal update_integral : boolean;

    signal phase_error : phase_i'SUBTYPE := (others => '0');

    constant PRODUCT_LENGTH : natural := phase_i'LENGTH + integral_i'LENGTH;
    signal integral_in : integral_i'SUBTYPE;
    signal integral_update : signed(PRODUCT_LENGTH-1 downto 0);

    signal proportional_in : proportional_i'SUBTYPE;
    signal proportional_update : signed(PRODUCT_LENGTH-1 downto 0);

    signal base_frequency_in : signed_angle_t;
    signal set_frequency_in : std_ulogic;

    signal frequency_integral : signed_angle_t := (others => '0');
    signal frequency_out : signed_angle_t := (others => '0');

    signal update_out : boolean;
    signal update_offset : boolean;
    signal full_frequency_offset : signed_angle_t := (others => '0');
    signal frequency_offset : frequency_offset_o'SUBTYPE := (others => '0');
    signal offset_overflow : std_ulogic;

    -- We slice out a section of the total frequency
    constant FREQUENCY_TRUNCATE_OFFSET : natural := 8;

    attribute USE_DSP : string;
    attribute USE_DSP of integral_update : signal is "yes";
    attribute USE_DSP of frequency_integral : signal is "yes";
    attribute USE_DSP of proportional_update : signal is "yes";
    attribute USE_DSP of frequency_out : signal is "yes";

begin
    -- Delay the start in signal until we've prepared the data to write.
    -- The flow and timing is as follows:
    --  start_i, phase_i, magnitude_i
    --      => phase_error, magnitude_error_o
    --      => integral_update, phase_error, start_in
    --      => frequency_integral, frequency_o
    --      => full_frequency_offset
    --      => frequency_offset_o, offset_error_o, done_o
    delay_start : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => clk_i,
        data_i(0) => start_i,
        data_o(0) => start_in
    );
    delay_done : entity work.dlyline generic map (
        DLY => 6
    ) port map (
        clk_i => clk_i,
        data_i(0) => start_i and enable_i,
        data_o(0) => done_o
    );

    -- Feedback update is only enabled when control is enabled and the inputs
    -- are valid.  This is a static test that remains valid.
    enable_feedback <=
        enable_i = '1' and blanking_i = '0' and
        detector_overflow_i = '0' and magnitude_error_o = '0';

    -- Update the integrated frequency at the appropriate time only if feedback
    -- enabled
    update_integral <= enable_feedback and start_in = '1';

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- If magnitude too small then report an error.  Need to align this
            -- with the phase error and start signal
            if start_i = '1' then
                magnitude_error_o <=
                    to_std_ulogic(magnitude_i < magnitude_limit_i);
            end if;

            -- Work with the phase offset from the target phase.  We negate the
            -- error computed at this stage so we'll be subtracting at all
            -- later stages.
            phase_error <= target_phase_i - phase_i;

            -- Next the scale and integrate stage; this is written to fit into a
            -- DSP unit.
            integral_in <= integral_i;
            integral_update <= phase_error * integral_in;

            -- Similarly the proportional part
            proportional_in <= proportional_i;
            proportional_update <= phase_error * proportional_in;

            -- Frequency update pipeline so we can use the built-in C register.
            -- Need to keep the set strobe aligned with the value.
            base_frequency_in <= signed(base_frequency_i);
            set_frequency_in <= set_frequency_i;

            -- Frequency update overrides, otherwise we update on delayed start
            -- gated together with error and blanking vetos.
            if set_frequency_in = '1' then
                frequency_integral <= base_frequency_in;
            elsif update_integral then
                frequency_integral <= frequency_integral + integral_update;
            end if;

            update_out <= set_frequency_in = '1' or update_integral;
            if update_out then
                if enable_feedback then
                    frequency_out <= frequency_integral + proportional_update;
                else
                    frequency_out <= frequency_integral;
                end if;
            end if;

            update_offset <= update_out;
            if update_offset then
                -- Compute the frequency offset against the current base
                full_frequency_offset <= frequency_out - base_frequency_in;
            end if;

            if offset_override_i = '1' then
                -- Special debug override: set offset directly
                frequency_offset_o <= debug_offset_i;
            else
                frequency_offset_o <= frequency_offset;
            end if;

            -- Determine if the offset is ok
            offset_error_o <= to_std_ulogic(
                offset_overflow = '1' or
                frequency_offset_o > offset_limit_i or
                (not frequency_offset_o) > offset_limit_i);
        end if;
    end process;

    truncate_result(
        output => frequency_offset,
        overflow => offset_overflow,
        input => full_frequency_offset,
        offset => FREQUENCY_TRUNCATE_OFFSET);

    frequency_o <= unsigned(frequency_out);
end;
