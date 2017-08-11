-- Convert a trigger on the DSP turn clock into one on a slightly delayed
-- version of the ADC turn clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trigger_resync is
    port (
        adc_clk_i : in std_logic;
        turn_clock_i : in std_logic;
        trigger_i : in std_logic;
        trigger_o : out std_logic := '0'
    );
end;

architecture arch of trigger_resync is
    signal turn_clock_in : std_logic;
    signal turn_clock : std_logic;
    signal trigger_in : std_logic := '0';

begin
    -- Delay the turn clock enough so that our trigger processing comes after
    delay : entity work.dlyline generic map (
        DLY => 8
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock_in,
        data_o(0) => turn_clock
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            turn_clock_in <= turn_clock_i;

            if trigger_i = '1' then
                trigger_in <= '1';
            elsif turn_clock = '1' then
                trigger_in <= '0';
            end if;
            trigger_o <= turn_clock and trigger_in;
        end if;
    end process;
end;
