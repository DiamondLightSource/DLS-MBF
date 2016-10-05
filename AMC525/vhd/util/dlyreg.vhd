-- This module implements a delay line in registers.  This is designed to be
-- used to help with timing, as the use of hard registers is forced.

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity dlyreg is
    generic (
        DLY : natural := 1;
        DW  : natural := 1
    );
    port (
       clk_i : in std_logic;
       data_i : in std_logic_vector(DW-1 downto 0);
       data_o : out std_logic_vector(DW-1 downto 0)
    );
end;

architecture dlyreg of dlyreg is
    type dlyreg_t is array(DLY-1 downto 0) of std_logic_vector(DW-1 downto 0);
    signal dly_in : dlyreg_t;
    signal dly_out : dlyreg_t;

begin
    assert DLY > 0;

    dly_in(0) <= data_i;

    dly_gen : for i in 0 to DLY-1 generate
        reg_gen : for j in 0 to DW-1 generate
            fdce_inst : FDCE port map (
                C => clk_i,
                D => dly_in(i)(j),
                Q => dly_out(i)(j),
                CE => '1',
                CLR => '0'
            );
        end generate;
    end generate;

    data_o <= dly_out(DLY-1);
end;
