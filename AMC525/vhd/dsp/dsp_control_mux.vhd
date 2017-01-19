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
        dsp_clk_i : in std_logic;

        -- Multiplexer selections
        adc_mux_i : in std_logic;
        nco_0_mux_i : in std_logic;
        nco_1_mux_i : in std_logic;

        -- Data channels
        control_to_dsp_o : out control_to_dsp_array_t;
        dsp_to_control_i : in dsp_to_control_array_t
    );
end;

architecture dsp_control_mux of dsp_control_mux is
    -- Aliases for more compact code
    signal c2d0 : control_to_dsp_t := control_to_dsp_reset;
    signal c2d1 : control_to_dsp_t := control_to_dsp_reset;
    signal d2c0 : dsp_to_control_t;
    signal d2c1 : dsp_to_control_t;

begin
    d2c0 <= dsp_to_control_i(0);
    d2c1 <= dsp_to_control_i(1);
    control_to_dsp_o(0) <= c2d0;
    control_to_dsp_o(1) <= c2d1;

    -- Data multiplexing control
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- ADC input multiplexing
            if adc_mux_i = '1' then
                c2d0.adc_data <= d2c1.adc_data;
            else
                c2d0.adc_data <= d2c0.adc_data;
            end if;
            c2d1.adc_data <= d2c1.adc_data;

            -- NCO output multiplexing
            for l in LANES loop
                c2d0.nco_0_data(l) <= d2c0.nco_0_data(l).cos;
                if nco_0_mux_i = '1' then
                    c2d1.nco_0_data(l) <= d2c0.nco_0_data(l).sin;
                else
                    c2d1.nco_0_data(l) <= d2c1.nco_0_data(l).cos;
                end if;

                c2d0.nco_1_data(l) <= d2c0.nco_1_data(l).cos;
                if nco_1_mux_i = '1' then
                    c2d1.nco_1_data(l) <= d2c0.nco_1_data(l).sin;
                else
                    c2d1.nco_1_data(l) <= d2c1.nco_1_data(l).cos;
                end if;
            end loop;
        end if;
    end process;
end;
