-- Transports data from ADC clock domain to DSP clock domain.  This is mostly
-- straighforward, except that we need to be quite careful when working with
-- the high speed ADC clock!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity adc_to_dsp is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        adc_data_i : in signed;
        dsp_data_o : out signed_array
    );
end;

architecture arch of adc_to_dsp is
    signal adc_phase : std_logic;
    signal adc_data_in : adc_data_i'SUBTYPE := (others => '0');
    signal dsp_data : signed_array(LANES)(adc_data_i'RANGE)
        := (others => (others => '0'));
    signal dsp_data_out : signed_array(LANES)(adc_data_i'RANGE)
        := (others => (others => '0'));

begin
    -- Timing for ADC to DSP conversion
    --
    --             _     ___     ___     ___     ___     ___     ___     ___
    --  adc_clk     \___/   \___/   \___/   \___/   \___/   \___/   \___/
    --                   _______         _______         _______         ___
    --  dsp_clk    _____/       \_______/       \_______/       \_______/
    --                   _______         _______         _______         ___
    --  adc_phase  _____/       \_______/       \_______/       \_______/
    --             _____ _______ _______ _______ _______ _______ _______ ___
    --  adc_data   _D0__X__D1___X__D2___X__D3___X__D4___X__D5___X__D6___X___
    --             _____ _______________ _______________ _______________ ___
    --  dsp_data_0 _____X__D0___________X__D2___________X__D4___________X___
    --             _____________ _______________ _______________ ___________
    --  dsp_data_1 _____________X__D1___________X__D3___________X__D5_______
    --             _____ _______________ _______________ _______________ ___
    --  dsp_data_o _____X_______________X__D0:D1________X__D2:D3________X___
    --

    phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    -- Transfer across synchronous clock boundary with phase advance.
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            adc_data_in <= adc_data_i;
            dsp_data(to_integer(adc_phase)) <= adc_data_in;
        end if;
    end process;

    -- Ensure result is purely in DSP clock.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            dsp_data_out <= dsp_data;
        end if;
    end process;
    dsp_data_o <= dsp_data_out;
end;
