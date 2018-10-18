-- Defines specific to FMC500M ADC & DAC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.support.all;

package fmc500m_defs is

    type fmc500_outputs_t is record
        -- PLL input clock select and sync signals
        pll_clkin_sel0_out : std_ulogic;     -- Output to PLL chip
        pll_clkin_sel1_out : std_ulogic;
        pll_clkin_sel0_ena : std_ulogic;     -- Enable output
        pll_clkin_sel1_ena : std_ulogic;
        pll_sync : std_ulogic;
        -- ADC and DAC control pins
        adc_pdwn : std_ulogic;
        dac_rstn : std_ulogic;
    end record;

    type fmc500_inputs_t is record
        -- Power status reports from FMC
        vcxo_pwr_good : std_ulogic;
        adc_pwr_good : std_ulogic;
        dac_pwr_good : std_ulogic;
        -- PLL status outputs
        pll_status_ld1 : std_ulogic;
        pll_status_ld2 : std_ulogic;
        pll_clkin_sel0_in : std_ulogic;      -- Inputs from PLL chip
        pll_clkin_sel1_in : std_ulogic;
        -- Clocks from PLL to FPGA
        pll_dclkout2 : std_ulogic;
        pll_sdclkout3 : std_ulogic;
        -- Interrupt from DAC
        dac_irqn : std_ulogic;
        -- On board temperature sensor
        temp_alert_n : std_ulogic;
    end record;
end;
