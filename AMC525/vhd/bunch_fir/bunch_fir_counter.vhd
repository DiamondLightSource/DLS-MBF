-- Decimation counter for data reduction
--
-- Generates two data valid pulses back to back for the first and last turn;
-- these are used during processing downstream.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_fir_counter is
    port (
        dsp_clk_i : in std_logic;

        decimation_limit_i : in unsigned;

        turn_clock_i : in std_logic;
        first_turn_o : out std_logic;
        last_turn_o : out std_logic
    );
end;

architecture bunch_fir_counter of bunch_fir_counter is
    constant DECIMATION_BITS : natural := decimation_limit_i'LENGTH;
    signal decimation_counter : natural range 0 to 2**DECIMATION_BITS-1;
    signal last_turn : boolean;

begin
    last_turn <= decimation_counter = decimation_limit_i;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if turn_clock_i = '1' then
                if last_turn then
                    decimation_counter <= 0;
                else
                    decimation_counter <= decimation_counter + 1;
                end if;
                last_turn_o <= to_std_logic(last_turn);
                first_turn_o <= last_turn_o;
            end if;
        end if;
    end process;
end;
