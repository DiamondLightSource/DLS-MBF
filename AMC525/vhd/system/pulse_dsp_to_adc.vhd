-- Converts a DSP control pulse into an ADC pulse.
-- We pipeline the input to avoid logic between the two clock domains.
--
--  adc clk i   /   /   /   /   /   /   /   /   /   /   /   /   /   /
--                   ___     ___     ___     ___     ___     ___     ___
--  dsp_clk     \___/   \___/   \___/   \___/   \___/   \___/   \___/
--                   _______
--  pulse_i    _____/       \___________________________________________
--                       _______
--  pulse_pl   _________/       \_______________________________________
--                           _______
--  pulse_in   _____________/       \___________________________________
--                           ___
--  pulse_o    _____________/   \_______________________________________

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_dsp_to_adc is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        pulse_i : in std_ulogic;             -- On DSP clock
        pulse_o : out std_ulogic := '0'      -- On ADC clock
    );
end;

architecture arch of pulse_dsp_to_adc is
    signal pulse_pl : std_ulogic := '0';
    signal pulse_in : std_ulogic := '0';

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of pulse_pl : signal is "TRUE";

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            pulse_pl <= pulse_i;
            pulse_in <= pulse_pl;
            pulse_o <= pulse_pl and not pulse_in;
        end if;
    end process;
end;
