-- Rising edge detector.

library ieee;
use ieee.std_logic_1164.all;

entity edge_detect is
    port (
        clk_i : in std_logic;
        data_i : in std_logic;
        edge_o : out boolean
    );
end;

architecture edge_detect of edge_detect is
    signal last_data : std_logic;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            last_data <= data_i;
        end if;
    end process;
    edge_o <= data_i = '1' and last_data = '0';
end;
