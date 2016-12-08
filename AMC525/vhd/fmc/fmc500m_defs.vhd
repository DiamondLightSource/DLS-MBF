-- Defines specific to FMC500M ADC & DAC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.support.all;

package fmc500m_defs is

    type fmc500_outputs_t is record
        -- Component power enable outputs to FMC
        adc_pwr_en : std_logic;
        dac_pwr_en : std_logic;
        vcxo_pwr_en : std_logic;
        -- PLL input clock select and sync signals
        pll_clkin_sel0 : std_logic;
        pll_clkin_sel1 : std_logic;
        pll_sync : std_logic;
        -- ADC and DAC control pins
        adc_pdwn : std_logic;
        dac_rstn : std_logic;
    end record;

    type fmc500_inputs_t is record
        -- Power status reports from FMC
        vcxo_pwr_good : std_logic;
        adc_pwr_good : std_logic;
        dac_pwr_good : std_logic;
        -- PLL status outputs
        pll_status_ld1 : std_logic;
        pll_status_ld2 : std_logic;
        -- Clocks from PLL to FPGA
        pll_dclkout2 : std_logic;
        pll_sdclkout3 : std_logic;
        -- Interrupt from DAC
        dac_irqn : std_logic;
        -- On board temperature sensor
        temp_alert_n : std_logic;
    end record;
end;
