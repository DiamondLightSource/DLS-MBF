-- Check for data overflow at ADC clock rate

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity adc_overflow is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Data flow
        data_i : in signed;                 -- on ADC clock
        limit_i : in unsigned;
        overflow_o : out std_logic          -- on DSP clock
    );
end;

architecture adc_overflow of adc_overflow is
    signal abs_data : unsigned(data_i'RANGE);
    signal overflow : std_logic;

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if data_i >= 0 then
                abs_data <= unsigned(data_i);
            else
                abs_data <= unsigned(-data_i);
            end if;

            overflow <= to_std_logic(abs_data > limit_i);
        end if;
    end process;

    -- Bring overflow pulse to the DSP clock domain
    pulse_adc_to_dsp_inst : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        pulse_i => overflow,
        pulse_o => overflow_o
    );
end;
