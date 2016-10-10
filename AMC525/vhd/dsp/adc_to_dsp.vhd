-- Transports data from ADC clock domain to DSP clock domain.  This is mostly
-- straighforward, except that we need to be quite careful when working with
-- the high speed ADC clock!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity adc_to_dsp is
    generic (
        ADC_WIDTH : natural := ADC_INP_WIDTH
    );
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        dsp_clk_ok_i : in std_logic;

        adc_data_i : in adc_inp_t;
        dsp_data_o : out adc_inp_channels
    );
end;

architecture adc_to_dsp of adc_to_dsp is
    signal adc_phase_reset : boolean;
    signal adc_phase : CHANNELS;
    signal dsp_data : adc_inp_channels;

begin
    -- Timing for ADC to DSP conversion including coming out of reset.
    --
    --             _     ___     ___     ___     ___     ___     ___     ___
    --  adc_clk     \___/   \___/   \___/   \___/   \___/   \___/   \___/
    --                   _______         _______         _______         ___
    --  dsp_clk    _____/       \_______/       \_______/       \_______/
    --                   ___________________________________________________
    --  dsp_clk_ok _____/
    --             _____________
    --  adc_phase_reset         \___________________________________________
    --                                   _______         _______         ___
    --  adc_phase  _____________________/       \_______/       \_______/
    --             _____ _______ _______ _______ _______ _______ _______ ___
    --  adc_data   _D0__X__D1___X__D2___X__D3___X__D4___X__D5___X__D6___X___
    --             _____ _______ _______ _______________ _______________ ___
    --  dsp_data_0 _____X__D0___X__D1___X__D2___________X__D4___________X___
    --             _____________________________ _______________ ___________
    --  dsp_data_1 _____________________________X__D3___________X__D4_______
    --             _____ _______________ _______________ _______________ ___
    --  dsp_data_o _____X_______________X_______________X__D2:D3________X___
    --
    -- We separate the ADC phase reset from the data capture to help with timing
    -- for the reset signal.

    -- Phase reset detection.
    process (adc_clk_i, dsp_clk_ok_i) begin
        if dsp_clk_ok_i = '0' then
            adc_phase_reset <= true;
        elsif rising_edge(adc_clk_i) then
            adc_phase_reset <= false;
        end if;
    end process;

    -- Transfer across synchronous clock boundary with phase advance.
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if adc_phase_reset then
                adc_phase <= 2 mod CHANNEL_COUNT;
            else
                adc_phase <= (adc_phase + 1) mod CHANNEL_COUNT;
            end if;

            dsp_data(adc_phase) <= adc_data_i;
        end if;
    end process;

    -- Ensure result is purely in DSP clock.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            dsp_data_o <= dsp_data;
        end if;
    end process;
end;
