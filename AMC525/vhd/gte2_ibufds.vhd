-- Thin wrapper over standard library ibufds_gte2

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity gte2_ibufds is
    generic (
        GEN_BUFG : boolean := true
    );
    port (
        clk_p_i : in std_logic;
        clk_n_i : in std_logic;
        clk_o : out std_logic
    );
end;

architecture gte2_ibufds of gte2_ibufds is
    signal clock : std_logic;
begin
    ibufds_gte2_inst : IBUFDS_GTE2 generic map (
        CLKCM_CFG    => TRUE,
        CLKRCV_TRST  => TRUE,
        CLKSWING_CFG => "11"
    ) port map (
         ODIV2  => open,
         CEB    => '0',
         I      => clk_p_i,
         IB     => clk_n_i,
         O      => clock
    );

    if_bufg: if GEN_BUFG generate
        bufg_inst : BUFG port map (
            I => clock,
            O => clk_o
        );
    end generate;
    if_not_bufg: if not GEN_BUFG generate
        clk_o <= clock;
    end generate;
end;
