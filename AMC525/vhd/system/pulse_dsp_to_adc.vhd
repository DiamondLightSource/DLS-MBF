-- Converts a DSP control pulse into an ADC pulse.
--
--  adc clk i   /   /   /   /   /   /   /   /   /   /   /   /   /   /
--                   ___     ___     ___     ___     ___     ___     ___
--  dsp_clk     \___/   \___/   \___/   \___/   \___/   \___/   \___/
--                   _______
--  pulse_i    _____/       \___________________________________________
--                       _______
--  pulse_in   _________/       \_______________________________________
--                       ___
--  pulse_o    _________/   \___________________________________________

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_dsp_to_adc is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        pulse_i : in std_logic;             -- On DSP clock
        pulse_o : out std_logic := '0'      -- On ADC clock
    );
end;

architecture arch of pulse_dsp_to_adc is
    signal pulse_in : std_logic := '0';

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            pulse_in <= pulse_i;
            pulse_o <= pulse_i and not pulse_in;
        end if;
    end process;
end;
