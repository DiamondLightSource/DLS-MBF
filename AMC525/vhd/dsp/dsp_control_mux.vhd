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
        bank_mux_i : in std_logic;

        -- Data channels
        dsp_to_control_i : in dsp_to_control_array_t;

        -- Outgoing data
        adc_o   : out signed_array;
        nco_0_o : out dsp_nco_from_mux_array_t;
        nco_1_o : out dsp_nco_from_mux_array_t;
        bank_select_o : out unsigned_array
    );
end;

architecture arch of dsp_control_mux is
    -- Aliases for more compact code
    alias d2c0 : dsp_to_control_t is dsp_to_control_i(0);
    alias d2c1 : dsp_to_control_t is dsp_to_control_i(1);

    function assign_cos(input : dsp_nco_to_mux_t) return dsp_nco_from_mux_t is
        variable result : dsp_nco_from_mux_t;
    begin
        result.nco := input.nco.cos;
        result.gain := input.gain;
        result.enable := input.enable;
        return result;
    end;

    function assign_sin(input : dsp_nco_to_mux_t) return dsp_nco_from_mux_t is
        variable result : dsp_nco_from_mux_t;
    begin
        result.nco := input.nco.sin;
        result.gain := input.gain;
        result.enable := input.enable;
        return result;
    end;

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
            nco_0_o(0) <= assign_cos(d2c0.nco_0_data);
            if nco_0_mux_i = '1' then
                nco_0_o(1) <= assign_sin(d2c0.nco_0_data);
            else
                nco_0_o(1) <= assign_cos(d2c1.nco_0_data);
            end if;

            nco_1_o(0) <= assign_cos(d2c0.nco_1_data);
            if nco_0_mux_i = '1' then
                nco_1_o(1) <= assign_sin(d2c0.nco_1_data);
            else
                nco_1_o(1) <= assign_cos(d2c1.nco_1_data);
            end if;

            -- Bank selection
            bank_select_o(0) <= d2c1.bank_select;
            if bank_mux_i = '1' then
                bank_select_o(1) <= d2c1.bank_select;
            else
                bank_select_o(1) <= d2c0.bank_select;
            end if;
        end if;
    end process;
end;
