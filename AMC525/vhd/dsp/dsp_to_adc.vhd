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

        dsp_data_i : in signed_array;
        adc_data_o : out signed
    );
end;

architecture dsp_to_adc of dsp_to_adc is
    signal adc_phase_in : std_logic;
    signal adc_phase : LANES;

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

    -- Simple delay line to help with distribution.
    dlyreg_inst : entity work.dlyreg generic map (
        DLY => 2
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => adc_phase_i,
        data_o(0) => adc_phase_in
    );

    -- Transfer across synchronous clock boundary with phase advance.
    adc_phase <= to_integer(not adc_phase_in);
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            adc_data_o <= dsp_data_i(adc_phase);
        end if;
    end process;

end;
