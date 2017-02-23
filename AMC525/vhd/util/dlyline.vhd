-- This module implements a variable delay line for variable DW data input.

library ieee;
use ieee.std_logic_1164.all;

entity dlyline is
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

architecture dlyline of dlyline is
    type dlyline_t is array(DLY-1 downto 0) of std_logic_vector(DW-1 downto 0);
    signal dlyline : dlyline_t := (others => (others => '0'));

begin
    assert DLY > 0 severity failure;
    process (clk_i) begin
        if rising_edge(clk_i) then
            dlyline(0) <= data_i;
            for i in 1 to DLY-1 loop
                dlyline(i) <= dlyline(i-1);
            end loop;
        end if;
    end process;
    data_o <= dlyline(DLY-1);
end;
