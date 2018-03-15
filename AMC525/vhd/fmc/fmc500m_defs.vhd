-- Defines specific to FMC500M ADC & DAC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.support.all;

package fmc500m_defs is

    type fmc500_outputs_t is record
        -- PLL input clock select and sync signals
        pll_clkin_sel0_out : std_logic;     -- Output to PLL chip
        pll_clkin_sel1_out : std_logic;
        pll_clkin_sel0_ena : std_logic;     -- Enable output
        pll_clkin_sel1_ena : std_logic;
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
        pll_clkin_sel0_in : std_logic;      -- Inputs from PLL chip
        pll_clkin_sel1_in : std_logic;
        -- Clocks from PLL to FPGA
        pll_dclkout2 : std_logic;
        pll_sdclkout3 : std_logic;
        -- Interrupt from DAC
        dac_irqn : std_logic;
        -- On board temperature sensor
        temp_alert_n : std_logic;
    end record;
end;
