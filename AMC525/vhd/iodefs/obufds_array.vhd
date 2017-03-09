-- Array of OBUFDS
--
-- Double ended output buffers with LVDS output standard

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity obufds_array is
    generic (
        COUNT : natural := 1
    );
    port (
        i_i : in  std_logic_vector(COUNT-1 downto 0);
        p_o : out std_logic_vector(COUNT-1 downto 0);
        n_o : out std_logic_vector(COUNT-1 downto 0)
    );
end;

architecture arch of obufds_array is
begin
    obufds_array:
    for i in 0 to COUNT-1 generate
        obufds_inst: OBUFDS generic map (
            IOSTANDARD => "LVDS"
        ) port map (
            I  => i_i(i),
            O  => p_o(i),
            OB => n_o(i)
        );
    end generate;
end;
