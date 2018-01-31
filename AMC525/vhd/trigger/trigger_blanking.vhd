-- Blanking trigger

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity trigger_blanking is
    port (
        dsp_clk_i : in std_logic;

        blanking_i : in std_logic;
        blanking_interval_i : in unsigned_array(CHANNELS);
        turn_clock_i : in std_logic;
        blanking_window_o : out std_logic_vector(CHANNELS) := (others => '0')
    );
end;

architecture arch of trigger_blanking is
    signal blanking_counter : blanking_interval_i'SUBTYPE
        := (others => (others => '0'));
    signal blanking_window : std_logic_vector(CHANNELS) := (others => '0');

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            for c in CHANNELS loop
                if blanking_i = '1' then
                    blanking_counter(c) <= blanking_interval_i(c);
                    blanking_window(c) <= '1';
                elsif turn_clock_i = '1' then
                    if blanking_counter(c) > 0 then
                        blanking_counter(c) <= blanking_counter(c) - 1;
                    else
                        blanking_window(c) <= '0';
                    end if;
                end if;
            end loop;

            blanking_window_o <= blanking_window;
        end if;
    end process;
end;
