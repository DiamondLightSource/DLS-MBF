-- Transports data from DSP clock domain to ADC clock domain.  This is mostly
-- straighforward, except that we need to be quite careful when working with
-- the high speed ADC clock!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity dsp_to_adc is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        dsp_data_i : in signed_array;
        adc_data_o : out signed
    );
end;

architecture dsp_to_adc of dsp_to_adc is
    signal adc_phase : std_logic;
    signal dsp_data : dsp_data_i'SUBTYPE := (others => (others => '0'));
    signal adc_data : adc_data_o'SUBTYPE := (others => '0');

begin
    -- Timing for DSP to ADC conversion
    --
    --             _     ___     ___     ___     ___     ___     ___     ___
    --  adc_clk     \___/   \___/   \___/   \___/   \___/   \___/   \___/
    --                   _______         _______         _______         ___
    --  adc_phase  _____/       \_______/       \_______/       \_______/
    --             _____ _______________ _______________ _______________ ___
    --  dsp_data_0 _____X__D0___________X__D2___________X__D4___________X___
    --             _____ _______________ _______________ _______________ ___
    --  dsp_data_1 _____X__D1___________X__D3___________X__D5___________X___
    --             _____ _______ _______ _______ _______ _______ _______ ___
    --  adc_data_o _____X_______X__D0___X__D1___X__D2___X__D3___X__D4___X___
    --

    phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    -- Local register of incoming data to help with difficult clock crossing.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            dsp_data <= dsp_data_i;
        end if;
    end process;

    -- Transfer across synchronous clock boundary with phase advance.
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            adc_data <= dsp_data(to_integer(adc_phase));
        end if;
    end process;

    adc_data_o <= adc_data;
end;
