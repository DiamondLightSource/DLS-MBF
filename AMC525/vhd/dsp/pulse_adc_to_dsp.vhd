-- Stretches any transient pulse (such as an overflow detect) on the ADC clock
-- into a DSP clock timed pulse

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_adc_to_dsp is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        pulse_i : in std_logic;
        pulse_o : out std_logic := '0'
    );
end;

architecture pulse_adc_to_dsp of pulse_adc_to_dsp is
    signal pulse : std_logic := '0';

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if adc_phase_i = '1' then
                pulse <= pulse or pulse_i;
            else
                pulse <= pulse_i;
            end if;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            pulse_o <= pulse;
        end if;
    end process;
end;
