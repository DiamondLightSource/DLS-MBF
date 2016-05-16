library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;

architecture top of top is
    signal fclka : std_logic;
    signal sys_rst_sync_n : std_logic;
    signal sys_rst_n : std_logic;

begin
    -- Reference clock for MGT
    fclka_inst : IBUFDS_GTE2
    generic map (
        CLKCM_CFG    => TRUE,
        CLKRCV_TRST  => TRUE,
        CLKSWING_CFG => "11" )
    port map (
         O      => fclka,
         ODIV2  => open,
         CEB    => '0',
         I      => FCLKA_P,
         IB     => FCLKA_N
    );

    -- Synchronise reset to reference clock
    reset_inst : entity work.sync_bit port map (
        clk_i => fclka,
        bit_i => nCOLDRST,
        bit_o => sys_rst_sync_n);
    sys_rst_n <= nCOLDRST and sys_rst_sync_n;

    -- Wire up the interconnect
    interconnect_inst : entity work.interconnect_wrapper port map (
        GPIO_tri_o => ULED,
        pcie_mgt_rxn => AMC_RX_N,
        pcie_mgt_rxp => AMC_RX_P,
        pcie_mgt_txn => AMC_TX_N,
        pcie_mgt_txp => AMC_TX_P,
        refclk => fclka,
        sys_rst_n => sys_rst_n
    );
end;
