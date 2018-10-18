library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal dsp_clk : std_ulogic := '1';
    signal adc_clk : std_ulogic := '1';

    signal adc_phase : std_ulogic;
    signal ok : boolean;

begin

    dsp_clk <= not dsp_clk after 2 ns;
    adc_clk <= not adc_clk after 1 ns;

    i_phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        adc_phase_o => adc_phase
    );

    ok <= adc_phase = dsp_clk;
end;
