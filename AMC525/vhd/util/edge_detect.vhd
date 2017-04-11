-- Rising edge detector.

library ieee;
use ieee.std_logic_1164.all;

entity edge_detect is
    generic (
        REGISTER_EDGE : boolean := false
    );
    port (
        clk_i : in std_logic;
        data_i : in std_logic;
        edge_o : out std_logic := '0'
    );
end;

architecture arch of edge_detect is
    signal last_data : std_logic := '0';
    signal edge : std_logic;

begin
    edge <= data_i and not last_data;
    process (clk_i) begin
        if rising_edge(clk_i) then
            last_data <= data_i;
            if REGISTER_EDGE then
                edge_o <= edge;
            end if;
        end if;
    end process;

    gen_reg : if not REGISTER_EDGE generate
        edge_o <= edge;
    end generate;
end;
