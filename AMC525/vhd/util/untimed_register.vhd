-- Implements untimed register.  A false path will be established between the
-- two registers defined in this entity.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity untimed_register is
    port (
        clk_in_i : in std_logic;
        clk_out_i : in std_logic;

        write_i : in std_logic;
        data_i : in std_logic_vector;
        data_o : out std_logic_vector
    );
end;

architecture untimed_register of untimed_register is
    signal false_path_register_from : std_logic_vector(data_i'RANGE)
        := (others => '0');
    signal false_path_register_to   : std_logic_vector(data_o'RANGE)
        := (others => '0');

    -- Ensure our registers don't get eaten by premature optimisation.
    attribute KEEP : string;
    attribute KEEP of false_path_register_from : signal is "true";
    attribute KEEP of false_path_register_to   : signal is "true";

begin
    process (clk_in_i) begin
        if rising_edge(clk_in_i) then
            if write_i = '1' then
                false_path_register_from <= data_i;
            end if;
        end if;
    end process;

    process (clk_out_i) begin
        if rising_edge(clk_out_i) then
            false_path_register_to <= false_path_register_from;
        end if;
    end process;
    data_o <= false_path_register_to;
end;
