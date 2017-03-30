-- Compute ADC phase from ADC clock and DSP clock.  Essentially
-- this mirrors the DSP clock as a signal.  We can't take the DSP clock as a
-- signal because that causes awful timing problems.
--
--             _     ___     ___     ___     ___     ___     ___     ___
--  adc_clk_i   \___/   \___/   \___/   \___/   \___/   \___/   \___/
--                   _______         _______         _______         ___
--  dsp_clk    _____/       \_______/       \_______/       \_______/
--                   _______________                 _______________
--  phase_0    _____/               \_______________/               \___
--                           _______________                 ___________
--  phase_90   _____________/               \_______________/
--                   _______         _______         _______         ___
--  adc_phase_o ____/       \_______/       \_______/       \_______/
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_dsp_phase is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_o : out std_logic := '0'
    );
end;

architecture arch of adc_dsp_phase is
    signal phase_0 : std_logic := '0';
    signal phase_90 : std_logic := '0';

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            phase_0 <= not phase_0;
        end if;
    end process;

    process (dsp_clk_i) begin
        if falling_edge(dsp_clk_i) then
            phase_90 <= phase_0;
        end if;
    end process;

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            adc_phase_o <= not (phase_0 xor phase_90);
        end if;
    end process;
end;