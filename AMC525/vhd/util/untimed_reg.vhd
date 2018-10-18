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
        clk_i : in std_ulogic;

        write_i : in std_ulogic;
        data_i : in std_ulogic_vector(WIDTH-1 downto 0);
        data_o : out std_ulogic_vector(WIDTH-1 downto 0)
    );
end;

architecture arch of untimed_reg is
    -- Note that the signal name here and the fact that it names an actual
    -- register are used by the constraints file, where an explicit timing
    -- "false path" is created from this register to all other flip-flops.
    signal false_path_register : std_ulogic_vector(WIDTH-1 downto 0)
        := (others => '0');

    -- Ensure our register doesn't get eaten by optimisation.
    attribute KEEP : string;
    attribute KEEP of false_path_register : signal is "true";

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_i = '1' then
                false_path_register <= data_i;
            end if;
        end if;
    end process;
    data_o <= false_path_register;
end;
