library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_support is
    port (
        adc_clk_o : out std_logic;
        dsp_clk_o : out std_logic;
        adc_phase_o : out std_logic
    );
end;

architecture clock_support of clock_support is
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';
    signal dsp_reset_n : std_logic;
    signal dsp_clk_ok : std_logic;

begin
    -- Clocking: ADC clock at 500 MHz, synchronous DSP clock at 250 MHz.
    -- Also generate synchronous reset and correct adc_phase signal.
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;
    dsp_reset_n <= '1' after 5.5 ns;

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

    adc_clk_o <= adc_clk when dsp_clk_ok else '0';
    dsp_clk_o <= dsp_clk when dsp_clk_ok else '0';

end;
