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
        clk_i : in std_logic;

        turn_clock_i : in std_logic;
        bunch_index_o : out bunch_count_t;

        decimation_limit_i : in unsigned;
        first_turn_o : out std_logic;
        last_turn_o : out std_logic
    );
end;

architecture bunch_fir_counter of bunch_fir_counter is
    signal turn_clock : std_logic;
    signal bunch_index : bunch_count_t := (others => '0');

    constant DECIMATION_BITS : natural := decimation_limit_i'LENGTH;
    signal decimation_counter : natural range 0 to 2**DECIMATION_BITS-1;
    signal last_turn : boolean;

begin
    last_turn <= decimation_counter = decimation_limit_i;

    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            if turn_clock = '1' then
                bunch_index <= (others => '0');
                if last_turn then
                    decimation_counter <= 0;
                else
                    decimation_counter <= decimation_counter + 1;
                end if;
                last_turn_o <= to_std_logic(last_turn);
                first_turn_o <= last_turn_o;
            else
                bunch_index <= bunch_index + 1;
            end if;
        end if;
    end process;

    bunch_index_dly : entity work.dlyreg generic map (
        DLY => 4,
        DW => bunch_index_o'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(bunch_index),
        unsigned(data_o) => bunch_index_o
    );
end;
