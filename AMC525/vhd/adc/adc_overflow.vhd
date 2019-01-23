-- Check for data overflow at ADC clock rate

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity adc_overflow is
    port (
        -- Clocking
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Data flow
        data_i : in signed;                 -- on ADC clock
        limit_i : in unsigned;
        overflow_o : out std_ulogic          -- on DSP clock
    );
end;

architecture arch of adc_overflow is
    signal abs_data : unsigned(data_i'RANGE) := (others => '0');
    signal overflow : std_ulogic := '0';

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if data_i >= 0 then
                abs_data <= unsigned(data_i);
            else
                -- Poor man's negation is probably good enough for us, and is
                -- a lot quicker at 500 MHz than the real thing.
                abs_data <= unsigned(not data_i);
            end if;

            overflow <= to_std_ulogic(abs_data > limit_i);
        end if;
    end process;

    -- Bring overflow pulse to the DSP clock domain
    pulse_adc_to_dsp_inst : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => overflow,
        pulse_o => overflow_o
    );
end;
