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
        control_to_dsp0_o : out control_to_dsp_t;
        dsp0_to_control_i : in dsp_to_control_t;
        control_to_dsp1_o : out control_to_dsp_t;
        dsp1_to_control_i : in dsp_to_control_t
    );
end;

architecture dsp_control_mux of dsp_control_mux is
begin

    -- Data multiplexing control
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- ADC input multiplexing
            if adc_mux_i = '1' then
                control_to_dsp0_o.adc_data <= dsp1_to_control_i.adc_data;
            else
                control_to_dsp0_o.adc_data <= dsp0_to_control_i.adc_data;
            end if;
            control_to_dsp1_o.adc_data <= dsp1_to_control_i.adc_data;

            -- NCO output multiplexing
            for l in LANES loop
                control_to_dsp0_o.nco_0_data(l) <=
                    dsp0_to_control_i.nco_0_data(l).cos;
                if nco_0_mux_i = '1' then
                    control_to_dsp1_o.nco_0_data(l) <=
                        dsp0_to_control_i.nco_0_data(l).sin;
                else
                    control_to_dsp1_o.nco_0_data(l) <=
                        dsp1_to_control_i.nco_0_data(l).cos;
                end if;

                control_to_dsp0_o.nco_1_data(l) <=
                    dsp0_to_control_i.nco_1_data(l).cos;
                if nco_1_mux_i = '1' then
                    control_to_dsp1_o.nco_1_data(l) <=
                        dsp0_to_control_i.nco_1_data(l).sin;
                else
                    control_to_dsp1_o.nco_1_data(l) <=
                        dsp1_to_control_i.nco_1_data(l).cos;
                end if;
            end loop;
        end if;
    end process;
end;
