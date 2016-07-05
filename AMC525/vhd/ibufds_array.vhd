-- Array of IBUFDS
--
-- Double ended input buffers with LVDS input standard

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity ibufds_array is
    generic (
        COUNT : natural := 1
    );
    port (
        p_i : in  std_logic_vector(COUNT-1 downto 0);
        n_i : in  std_logic_vector(COUNT-1 downto 0);
        o_o : out std_logic_vector(COUNT-1 downto 0)
    );
end;

architecture ibufds_array of ibufds_array is
begin
    ibufds_array:
    for i in 0 to COUNT-1 generate
        ibufds_inst: IBUFDS generic map (
            IOSTANDARD => "LVDS",
            DIFF_TERM => true
        ) port map (
            I  => p_i(i),
            IB => n_i(i),
            O  => o_o(i)
        );
    end generate;
end;
