-- Timing and control for tune PLL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity tune_pll_control is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;       -- On ADC clock

        -- Generation of detector dwell cycle.  This runs continually.
        dwell_time_i : in unsigned;         -- Turns per dwell
        start_detector_o : out std_ulogic := '1';
        write_detector_o : out std_ulogic := '1';

        -- Feedback status
        detector_overflow_i : in std_ulogic;
        magnitude_error_i : in std_ulogic;
        offset_error_i : in std_ulogic;

        -- Stop reasons, latched when disabled
        stop_o : out std_ulogic;
        detector_overflow_o : out std_ulogic;
        magnitude_error_o : out std_ulogic;
        offset_error_o : out std_ulogic;

        -- Blanking control
        blanking_i : in std_ulogic;
        blanking_enable_i : in std_ulogic;
        blanking_o : out std_ulogic := '0';

        -- Start and stop feedback
        start_i : in std_ulogic;
        stop_i : in std_ulogic;
        -- The enable signal only changes state shortly after the detector dwell
        -- clock; this ensures that (normally) this control flag will be stable
        -- during feedback.
        enable_o : out std_ulogic := '0'
    );
end;

architecture arch of tune_pll_control is
    signal dwell_counter : dwell_time_i'SUBTYPE := (others => '0');
    -- Note: We trigger a spurious start signal at start so that the detector is
    -- reset in simulation, so that we can suppress simulation warnings about
    -- unknown values in arithmetic.  This should have no other consequence.
    signal dwell_clock : std_ulogic := '1';

    signal dwell_start : std_ulogic;

    signal sync_request : std_ulogic;
    type sync_state_t is (SYNC_IDLE, SYNC_START, SYNC_DWELL);
    signal sync_state : sync_state_t := SYNC_IDLE;

    type run_state_t is (
        STATE_IDLE, STATE_STARTING, STATE_RUNNING, STATE_STOPPING);
    signal run_state : run_state_t := STATE_IDLE;
    signal stopping_feedback : boolean;

    signal sync_request_dsp : std_ulogic := '0';
    signal sync_done : std_ulogic;
    signal sync_done_adc : std_ulogic;

    -- Simple pipeline of blanking to help timing
    signal blanking_in : std_ulogic := '0';

begin
    -- The detector start signal is generated on the ADC clock.
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if sync_request = '1' then
                -- Synchronise the dwell counter with the synchronisation
                -- request.  We'll wait for two dwell clocks so that a good
                -- dwell has been generated.
                dwell_counter <= (others => '0');
            elsif turn_clock_i = '1' then
                if dwell_counter = 0 then
                    dwell_counter <= dwell_time_i;
                else
                    dwell_counter <= dwell_counter - 1;
                end if;
            end if;
            dwell_clock <=
                to_std_ulogic(dwell_counter = 0 and turn_clock_i = '1');

            -- Sync state management
            case sync_state is
                when SYNC_IDLE =>
                    if sync_request = '1' then
                        sync_state <= SYNC_START;
                    end if;
                when SYNC_START =>
                    if dwell_clock = '1' then
                        sync_state <= SYNC_DWELL;
                    end if;
                when SYNC_DWELL =>
                    if dwell_clock = '1' then
                        sync_state <= SYNC_IDLE;
                    end if;
            end case;
            sync_done_adc <= to_std_ulogic(
                sync_state = SYNC_DWELL and dwell_clock = '1');

            -- Ensure we don't generate a detector write for the short sync
            -- dwell, just skip this one.
            start_detector_o <= dwell_clock;
            write_detector_o <=
                dwell_clock and to_std_ulogic(sync_state /= SYNC_START);
        end if;
    end process;


    -- Bring the start event over to the DSP clock for further processing.
    dwell_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => dwell_clock,
        pulse_o => dwell_start
    );

    -- Resync request over to ADC clock for dwell counter
    sync_to_adc : entity work.pulse_dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => sync_request_dsp,
        pulse_o => sync_request
    );

    -- Resync done back to DSP clock
    done_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => sync_done_adc,
        pulse_o => sync_done
    );


    stopping_feedback <=
        stop_i = '1' or
        detector_overflow_i = '1' or
        magnitude_error_i = '1' or
        offset_error_i= '1';

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case run_state is
                when STATE_IDLE =>
                    if start_i = '1' then
                        run_state <= STATE_STARTING;
                    end if;
                    enable_o <= '0';
                when STATE_STARTING =>
                    if sync_done = '1' then
                        run_state <= STATE_RUNNING;
                    end if;
                when STATE_RUNNING =>
                    if stopping_feedback then
                        run_state <= STATE_STOPPING;
                    end if;
                    enable_o <= '1';
                when STATE_STOPPING =>
                    if dwell_start = '1' then
                        run_state <= STATE_IDLE;
                    end if;
            end case;

            -- Generate synchronisation requested when starting
            sync_request_dsp <= to_std_ulogic(
                run_state = STATE_IDLE and start_i = '1');

            if (run_state = STATE_STARTING or run_state = STATE_RUNNING) and
                   stopping_feedback then
                -- Record the stop reason
                stop_o <= stop_i;
                detector_overflow_o <= detector_overflow_i;
                magnitude_error_o <= magnitude_error_i;
                offset_error_o <= offset_error_i;
            elsif run_state = STATE_IDLE and start_i = '1' then
                -- Reset the stop reasons
                stop_o <= '0';
                detector_overflow_o <= '0';
                magnitude_error_o <= '0';
                offset_error_o <= '0';
            end if;

            -- Use dwell_start to register blanking.
            blanking_in <= blanking_i;
            if dwell_start = '1' then
                blanking_o <= blanking_in and blanking_enable_i;
            end if;
        end if;
    end process;
end;
