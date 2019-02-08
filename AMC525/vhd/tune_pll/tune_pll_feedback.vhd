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

        -- Signal to temporarily suppress processing of updates: output
        -- frequency stands still.
        blanking_i : in std_ulogic;

        -- Limits for phase and magnitude, checked and reported as errors
        magnitude_limit_i : in unsigned;
        phase_limit_i : in unsigned;

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
        phase_error_o : out std_ulogic;
        frequency_o : out angle_t
    );
end;

architecture arch of tune_pll_feedback is
    signal start_in : std_ulogic;

    signal update_frequency : boolean;

    signal magnitude_error_pl : boolean;
    signal magnitude_error : boolean;

    signal phase_limit : signed(phase_limit_i'LENGTH downto 0);
    signal phase_offset : phase_i'SUBTYPE;
    signal phase_error : boolean;

    constant PRODUCT_LENGTH : natural := phase_i'LENGTH + multiplier_i'LENGTH;
    signal multiplier_in : multiplier_i'SUBTYPE;
    signal scaled_update : signed(PRODUCT_LENGTH-1 downto 0);

    signal frequency_out : signed(angle_t'RANGE);

    attribute USE_DSP : string;
    attribute USE_DSP of frequency_out : signal is "yes";
    attribute USE_DSP of scaled_update : signal is "yes";

begin
    -- Delay the start in signal until we've prepared the data to write.
    -- The flow and timing is as follows:
    --  start_i, phase_i, magnitude_i
    --      => phase_offset, magnitude_error_pl
    --      => scaled_update, phase_error, magnitude_error, start_in
    --      => done_o, frequency_out, frequency_o
    delay_start : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => clk_i,
        data_i(0) => start_i,
        data_o(0) => start_in
    );

    -- The feedback frequency update only happens during feedback without
    -- blanking and if no errors have been detected.
    update_frequency <=
        start_in = '1' and blanking_i = '0' and
        not magnitude_error and not phase_error;

    phase_limit <= signed('0' & phase_limit_i);

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- If magnitude too small then report an error.  Need to align this
            -- with the phase error and start signal
            magnitude_error_pl <= magnitude_i < magnitude_limit_i;
            magnitude_error <= magnitude_error_pl;
            magnitude_error_o <= to_std_ulogic(magnitude_error);

            -- Similarly the phase error, but first we need to compute the phase
            -- offset from the target.
            phase_offset <= phase_i - target_phase_i;
            phase_error <=
                phase_offset > phase_limit or (not phase_offset) > phase_limit;
            phase_error_o <= to_std_ulogic(phase_error);

            -- Next the scale and integrate stage; this is written to fit into a
            -- DSP unit.
            multiplier_in <= multiplier_i;
            scaled_update <= phase_offset * multiplier_in;
            -- Frequency update overrides, otherwise we update on delayed start
            -- gated together with error and blanking vetos.
            if set_frequency_i = '1' then
                frequency_out <= new_frequency_i;
            elsif update_frequency then
                frequency_out <= frequency_out + scaled_update;
            end if;

            done_o <= start_in;
        end if;
    end process;

    frequency_o <= unsigned(frequency_out);
end;
