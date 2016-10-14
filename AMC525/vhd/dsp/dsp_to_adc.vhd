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
        adc_phase_i : in std_logic;

        dsp_data_i : in dac_out_channels;
        adc_data_o : out dac_out_t
    );
end;

architecture dsp_to_adc of dsp_to_adc is
    signal adc_phase : CHANNELS;

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

    -- Transfer across synchronous clock boundary with phase advance.
    adc_phase <= to_integer(adc_phase_i);
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            adc_data_o <= dsp_data_i(adc_phase);
        end if;
    end process;

end;
