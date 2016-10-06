-- Array of ODDR
--
-- Output DDR registers

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity oddr_array is
    generic (
        COUNT : natural := 1
    );
    port (
        clk_i : in std_logic;
        d1_i : in std_logic_vector(COUNT-1 downto 0);
        d2_i : in std_logic_vector(COUNT-1 downto 0);
        q_o : out std_logic_vector(COUNT-1 downto 0)
    );
end;

architecture oddr_array of oddr_array is
begin
    oddr_array:
    for i in 0 to COUNT-1 generate
        oddr_inst : ODDR generic map (
            DDR_CLK_EDGE => "SAME_EDGE"
        ) port map (
            S => '0',
            C => clk_i,
            CE => '1',
            D1 => d1_i(i),
            D2 => d2_i(i),
            Q => q_o(i)
        );
    end generate;
end;
