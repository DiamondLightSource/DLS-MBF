-- Implements untimed register.  A false path will be established between the
-- two registers defined in this entity, so that there is no particular timing
-- constraint from data_i to data_o.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity untimed_reg is
    generic (
        WIDTH : natural
    );
    port (
        clk_in_i : in std_logic;        -- Clock for data_i and write_i
        clk_out_i : in std_logic;       -- Clock for data_o

        write_i : in std_logic;
        data_i : in std_logic_vector(WIDTH-1 downto 0);
        data_o : out std_logic_vector(WIDTH-1 downto 0)
    );
end;

architecture untimed_reg of untimed_reg is
    -- Note that the signal names here and the fact that they name actual
    -- registers are used by the constraints file, where an explicit timing
    -- "false path" is created between these two names.
    signal false_path_register_from : std_logic_vector(WIDTH-1 downto 0)
        := (others => '0');
    signal false_path_register_to   : std_logic_vector(WIDTH-1 downto 0)
        := (others => '0');

    -- Ensure our registers don't get eaten by optimisation.
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
