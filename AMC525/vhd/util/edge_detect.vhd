-- Rising edge detector.

library ieee;
use ieee.std_logic_1164.all;

entity edge_detect is
    generic (
        REGISTER_EDGE : boolean := false
    );
    port (
        clk_i : in std_ulogic;
        data_i : in std_ulogic;
        edge_o : out std_ulogic := '0'
    );
end;

architecture arch of edge_detect is
    signal last_data : std_ulogic := '0';
    signal edge : std_ulogic;

begin
    edge <= data_i and not last_data;
    process (clk_i) begin
        if rising_edge(clk_i) then
            last_data <= data_i;
        end if;
    end process;

    gen_reg : if REGISTER_EDGE generate
        process (clk_i) begin
            if rising_edge(clk_i) then
                edge_o <= edge;
            end if;
        end process;
    else generate
        edge_o <= edge;
    end generate;
end;
