-- DSP data multiplexing
--
-- This manages the switching of DSP data between the two operational channels
-- depending on whether we're operating in independent or coupled channel mode.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.dsp_defs.all;

entity dsp_control_mux is
    port (
        clk_i : in std_logic;

        -- Multiplexer selections
        adc_mux_i : in std_logic;
        nco_0_mux_i : in std_logic;
        nco_1_mux_i : in std_logic;

        -- Data channels
        dsp_to_control_i : in dsp_to_control_array_t;

        -- Outgoing data
        adc_o   : out signed_array;
        nco_0_o : out signed_array;
        nco_1_o : out signed_array
    );
end;

architecture dsp_control_mux of dsp_control_mux is
    -- Aliases for more compact code
    alias d2c0 : dsp_to_control_t is dsp_to_control_i(0);
    alias d2c1 : dsp_to_control_t is dsp_to_control_i(1);

begin
    -- Data multiplexing control
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- ADC input multiplexing
            if adc_mux_i = '1' then
                adc_o(0) <= d2c1.adc_data;
            else
                adc_o(0) <= d2c0.adc_data;
            end if;
            adc_o(1) <= d2c1.adc_data;

            -- NCO output multiplexing
            nco_0_o(0) <= d2c0.nco_0_data.cos;
            if nco_0_mux_i = '1' then
                nco_0_o(1) <= d2c0.nco_0_data.sin;
            else
                nco_0_o(1) <= d2c1.nco_0_data.cos;
            end if;

            nco_1_o(0) <= d2c0.nco_1_data.cos;
            if nco_1_mux_i = '1' then
                nco_1_o(1) <= d2c0.nco_1_data.sin;
            else
                nco_1_o(1) <= d2c1.nco_1_data.cos;
            end if;
        end if;
    end process;
end;
