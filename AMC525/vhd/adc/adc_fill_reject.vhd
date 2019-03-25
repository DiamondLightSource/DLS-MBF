-- ADC fill pattern rejection filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fill_reject is
    generic (
        MAX_SHIFT : natural
    );
    port (
        clk_i : in std_ulogic;

        turn_clock_i : in std_ulogic;
        shift_i : in unsigned(3 downto 0);

        data_i : in signed;
        data_o : out signed
    );
end;

architecture arch of adc_fill_reject is
    signal data_in : data_i'SUBTYPE;
    signal turn_clock : std_ulogic;

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;

    -- Turn clock and data in are pipelined for safety
    data_in_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => data_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_in
    );

    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );

    core : entity work.adc_fill_reject_core generic map (
        MAX_SHIFT => MAX_SHIFT
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock,
        shift_i => shift_i,
        data_i => data_in,
        data_o => data_o
    );
end;
