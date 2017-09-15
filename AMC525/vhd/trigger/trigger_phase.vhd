-- Captures the ADC clock phase of the turn clock associated with the trigger

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trigger_phase is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;        -- On ADC clock
        trigger_i : in std_logic;           -- On DSP clock
        phase_o : out std_logic := '0'      -- On DSP clock
    );
end;

architecture arch of trigger_phase is
    signal adc_phase : std_logic;
    signal turn_clock_phase_adc : std_logic := '0';
    signal turn_clock_phase : std_logic := '0';

begin
    adc_dsp_phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if turn_clock_i = '1' then
                turn_clock_phase_adc <= adc_phase;
            end if;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            turn_clock_phase <= turn_clock_phase_adc;
            if trigger_i = '1' then
                phase_o <= turn_clock_phase;
            end if;
        end if;
    end process;
end;
