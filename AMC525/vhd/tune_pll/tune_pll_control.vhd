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

--         enable_i : in std_ulogic;           -- Enable control from register
--         start_i : in std_ulogic;            -- External trigger to start
--         feedback_ok_i : in std_ulogic;      -- Last cycle ok
--         running_o : out std_ulogic;         -- Reports if running

        dwell_time_i : in unsigned;         -- Turns per update
        start_detector_o : out std_ulogic   -- Process detector output (ADC clk)
    );
end;

architecture arch of tune_pll_control is
    signal dwell_counter : dwell_time_i'SUBTYPE := (others => '0');
    -- Note: We trigger a spurious start signal at start so that the detector is
    -- reset in simulation, so that we can suppress simulation warnings about
    -- unknown values in arithmetic.  This should have no other consequence.
    signal dwell_start_adc : std_ulogic := '1';
    signal dwell_start : std_ulogic;

begin
    -- The detector start signal is generated on the ADC clock.
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if turn_clock_i = '1' then
                if dwell_counter = 0 then
                    dwell_counter <= dwell_time_i;
                else
                    dwell_counter <= dwell_counter - 1;
                end if;
            end if;
            dwell_start_adc <=
                to_std_ulogic(dwell_counter = 0 and turn_clock_i = '1');
        end if;
    end process;

    start_detector_o <= dwell_start_adc;

    -- Bring the start event over to the DSP clock for further processing.
    dwell_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => dwell_start_adc,
        pulse_o => dwell_start
    );

--     process (clk_i) begin
--         if rising_edge(clk_i) then
-- 
--             -- Generate dwell clock by dividing the turn clock
--             if turn_clock_i = '1' then
--                 if dwell_counter = 0 then
--                     dwell_counter <= dwell_time_i;
--                 else
--                     dwell_counter <= dwell_counter - 1;
--                 end if;
--             end if;
--             dwell_start <= dwell_counter = 0 and turn_clock_i = '1';
-- 
--             -- Detect a start request, remember until next turn
--             if start_i = '1' and enable_i = '1' then
--                 start_request <= true;
--             elsif turn_clock_i = '1' then
--                 start_request <= false;
--             end if;
-- 
--             -- Process running state
--             if turn_clock_i = '1'
--         end if;
--     end process;
end;
