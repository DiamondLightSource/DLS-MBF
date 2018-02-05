-- Stretches any transient pulse (such as an overflow detect) on the ADC clock
-- into a DSP clock timed pulse
--
-- Two possible timings, depending on timing of incoming pulse:
--
--  adc clk i   /   /   /   /   /   /   /   /   /   /   /   /   /   /
--
--  dsp_clk         /       /       /       /       /       /       /
--                   ___                 ___
--  pulse_i    _____/   \_______________/   \___________________________
--                       ___                 ___
--  pulse_delay   ______/   \_______________/   \___________________________
--                       _______             _______
--  pulse_stretch ______/       \___________/       \_______________________
--                           _______                 _______
--  pulse_o    _____________/       \_______________/       \___________

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_adc_to_dsp is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        pulse_i : in std_logic;             -- On ADC clock
        pulse_o : out std_logic := '0'      -- On DSP clock
    );
end;

architecture arch of pulse_adc_to_dsp is
    signal pulse_delay : std_logic := '0';
    signal pulse_stretch : std_logic := '0';

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            pulse_delay <= pulse_i;
            pulse_stretch <= pulse_i or pulse_delay;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            pulse_o <= pulse_stretch;
        end if;
    end process;
end;
