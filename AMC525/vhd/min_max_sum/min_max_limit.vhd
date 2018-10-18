-- Event detection based on current bunch delta

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity min_max_limit is
    port (
        dsp_clk_i : in std_ulogic;
        adc_clk_i : in std_ulogic;

        delta_i : in unsigned;                  -- On ADC clock

        limit_i : in unsigned;                  -- On DSP clock
        reset_event_i : in std_ulogic;           -- On DSP clock
        limit_event_o : out std_ulogic           -- On DSP clock
    );
end;

architecture arch of min_max_limit is
    signal reset_event : std_ulogic;
    signal limit_detect : std_ulogic := '0';
    signal limit_event : std_ulogic := '0';
    signal limit_event_edge : std_ulogic := '0';

begin
    -- Bring reset event over to ADC clock where the event detection occurs
    reset_to_adc : entity work.pulse_dsp_to_adc port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => reset_event_i,
        pulse_o => reset_event
    );

    -- Pipelined event detection
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            limit_detect <= to_std_ulogic(delta_i > limit_i);
            if reset_event = '1' then
                limit_event <= '0';
            elsif limit_detect = '1' then
                limit_event <= '1';
                limit_event_edge <= limit_detect and not limit_event;
            end if;
        end if;
    end process;

    -- Stretch event detection to DSP clock
    event_to_adc : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => limit_event_edge,
        pulse_o => limit_event_o
    );
end;
