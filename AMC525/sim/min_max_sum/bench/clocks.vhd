-- Simulation clocks with synchronised reset

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clocks is
    port (
        adc_clk_o : out std_logic;
        dsp_clk_o : out std_logic;
        adc_phase_o : out std_logic
    );
end;

architecture clocks of clocks is
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';
    signal dsp_reset_n : std_logic := '0';
    signal dsp_clk_ok : std_logic;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;
    dsp_reset_n <= '1' after 3.5 ns;

    sync_reset_inst : entity work.sync_reset port map (
        clk_i => dsp_clk,
        clk_ok_i => dsp_reset_n,
        sync_clk_ok_o => dsp_clk_ok
    );

    adc_phase_inst : entity work.adc_phase port map (
        adc_clk_i => adc_clk,
        dsp_clk_ok_i => dsp_clk_ok,
        adc_phase_o => adc_phase_o
    );

    adc_clk_o <= adc_clk;
    dsp_clk_o <= dsp_clk;

end;
