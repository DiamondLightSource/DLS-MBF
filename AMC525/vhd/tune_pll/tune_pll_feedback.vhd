-- Tune PLL feedback loop

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;

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

        -- Target controls.  An integrating controller uses the multiplier to
        -- maintain phase_i as close to target_phase_i as possible.
        target_phase_i : in signed;
        multiplier_i : in signed;
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
    signal update_frequency : boolean;

    signal phase_error : phase_i'SUBTYPE;

    constant PRODUCT_LENGTH : natural := phase_i'LENGTH + multiplier_i'LENGTH;
    signal multiplier_in : multiplier_i'SUBTYPE;
    signal scaled_update : signed(PRODUCT_LENGTH-1 downto 0);

    signal base_frequency_in : signed_angle_t;
    signal set_frequency_in : std_ulogic;

    signal frequency_out : signed_angle_t := (others => '0');

    signal update_offset : boolean;
    signal full_frequency_offset : signed_angle_t;
    signal offset_overflow : std_ulogic;

    attribute USE_DSP : string;
    attribute USE_DSP of frequency_out : signal is "yes";
    attribute USE_DSP of scaled_update : signal is "yes";

    -- We slice out a section of the total frequency
    constant FREQUENCY_TRUNCATE_OFFSET : natural := 8;

begin
    -- Delay the start in signal until we've prepared the data to write.
    -- The flow and timing is as follows:
    --  start_i, phase_i, magnitude_i
    --      => phase_error, magnitude_error_o
    --      => scaled_update, phase_error, start_in
    --      => frequency_out, frequency_o
    --      => frequency_offset_o
    --      => offset_error_o, done_o
    delay_start : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => clk_i,
        data_i(0) => start_i,
        data_o(0) => start_in
    );
    delay_done : entity work.dlyline generic map (
        DLY => 5
    ) port map (
        clk_i => clk_i,
        data_i(0) => start_i,
        data_o(0) => done_o
    );

    -- The feedback frequency update only happens during feedback when enabled
    -- and if no errors have been detected.
    update_frequency <=
        start_in = '1' and enable_i = '1' and blanking_i = '0' and
        detector_overflow_i = '0' and magnitude_error_o = '0';

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- If magnitude too small then report an error.  Need to align this
            -- with the phase error and start signal
            if start_i = '1' then
                magnitude_error_o <=
                    to_std_ulogic(magnitude_i < magnitude_limit_i);
            end if;

            -- Work with the phase offset from the target phase.
            phase_error <= phase_i - target_phase_i;

            -- Next the scale and integrate stage; this is written to fit into a
            -- DSP unit.
            multiplier_in <= multiplier_i;
            scaled_update <= phase_error * multiplier_in;

            -- Frequency update pipeline so we can use the built-in C register.
            -- Need to keep the set strobe aligned with the value.
            base_frequency_in <= signed(base_frequency_i);
            set_frequency_in <= set_frequency_i;

            -- Frequency update overrides, otherwise we update on delayed start
            -- gated together with error and blanking vetos.
            if set_frequency_in = '1' then
                frequency_out <= base_frequency_in;
            elsif update_frequency then
                frequency_out <= frequency_out + scaled_update;
            end if;
            update_offset <= set_frequency_in = '1' or update_frequency;

            if update_offset then
                -- Compute the frequency offset against the current base
                full_frequency_offset <= frequency_out - base_frequency_in;
            end if;

            -- Determine if the offset is ok
            offset_error_o <= to_std_ulogic(
                offset_overflow = '1' or
                frequency_offset_o > offset_limit_i or
                (not frequency_offset_o) > offset_limit_i);
        end if;
    end process;

    truncate_result(
        output => frequency_offset_o,
        overflow => offset_overflow,
        input => full_frequency_offset,
        offset => FREQUENCY_TRUNCATE_OFFSET);

    frequency_o <= unsigned(frequency_out);
end;
