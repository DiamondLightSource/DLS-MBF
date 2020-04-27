-- Array of IBUFDS_GTE2
--
-- Double ended input buffers dedicated for MGT receiver
-- Documented in UG476

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity ibufds_gte2_array is
    generic (
        COUNT : natural := 1
    );
    port (
        p_i : in  std_ulogic_vector(COUNT-1 downto 0);
        n_i : in  std_ulogic_vector(COUNT-1 downto 0);
        o_o : out std_ulogic_vector(COUNT-1 downto 0)
    );
end;

architecture arch of ibufds_gte2_array is
begin
    ibufds_gte2_array:
    for i in 0 to COUNT-1 generate
        ibufds_inst: IBUFDS_GTE2 generic map (
            CLKCM_CFG    => TRUE,
            CLKRCV_TRST  => TRUE,
            CLKSWING_CFG => "11"
        ) port map (
            ODIV2 => open,
            CEB => '0',
            I  => p_i(i),
            IB => n_i(i),
            O  => o_o(i)
        );
    end generate;
end;
