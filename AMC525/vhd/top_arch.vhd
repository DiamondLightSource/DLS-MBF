library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;

architecture top of top is
    signal fclka : std_logic;
    signal clk100mhz : std_logic;
    signal clk100mhz_bufg : std_logic;

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

    -- Reference clock for DDR timing
    clk100mhz_inst : IBUFDS_GTE2
    generic map (
        CLKCM_CFG    => TRUE,
        CLKRCV_TRST  => TRUE,
        CLKSWING_CFG => "11" )
    port map (
         O      => clk100mhz,
         ODIV2  => open,
         CEB    => '0',
         I      => CLK100MHZ1_P,
         IB     => CLK100MHZ1_N
    );
    clk100mhz_bufg_inst : BUFG
    port map (I => clk100mhz, O => clk100mhz_bufg);

    -- Wire up the interconnect
    interconnect_inst : entity work.interconnect_wrapper port map (
        GPIO_tri_o => ULED,
        nCOLDRST => nCOLDRST,

        -- MTCA Backplane PCI Express interface
        pcie_mgt_rxn => AMC_RX_N,
        pcie_mgt_rxp => AMC_RX_P,
        pcie_mgt_txn => AMC_TX_N,
        pcie_mgt_txp => AMC_TX_P,
        FCLKA => fclka,

        -- 2GB of 64-bit wide DDR3 DRAM
        C0_DDR3_dq => C0_DDR3_DQ,
        C0_DDR3_dqs_p => C0_DDR3_DQS_P,
        C0_DDR3_dqs_n => C0_DDR3_DQS_N,
        C0_DDR3_addr => C0_DDR3_ADDR,
        C0_DDR3_ba => C0_DDR3_BA,
        C0_DDR3_ras_n => C0_DDR3_RAS_N,
        C0_DDR3_cas_n => C0_DDR3_CAS_N,
        C0_DDR3_we_n => C0_DDR3_WE_N,
        C0_DDR3_reset_n => C0_DDR3_RESET_N,
        C0_DDR3_ck_p => C0_DDR3_CK_P,
        C0_DDR3_ck_n => C0_DDR3_CK_N,
        C0_DDR3_cke => C0_DDR3_CKE,
        C0_DDR3_dm => C0_DDR3_DM,
        C0_DDR3_odt => C0_DDR3_ODT,
        CLK533MHZ1_clk_p => CLK533MHZ1_P,
        CLK533MHZ1_clk_n => CLK533MHZ1_N,

        -- 128MB of 16-bit wide DDR3 DRAM
        C1_DDR3_dq => C1_DDR3_DQ,
        C1_DDR3_dqs_p => C1_DDR3_DQS_P,
        C1_DDR3_dqs_n => C1_DDR3_DQS_N,
        C1_DDR3_addr => C1_DDR3_ADDR,
        C1_DDR3_ba => C1_DDR3_BA,
        C1_DDR3_ras_n => C1_DDR3_RAS_N,
        C1_DDR3_cas_n => C1_DDR3_CAS_N,
        C1_DDR3_we_n => C1_DDR3_WE_N,
        C1_DDR3_reset_n => C1_DDR3_RESET_N,
        C1_DDR3_ck_p => C1_DDR3_CK_P,
        C1_DDR3_ck_n => C1_DDR3_CK_N,
        C1_DDR3_cke => C1_DDR3_CKE,
        C1_DDR3_dm => C1_DDR3_DM,
        C1_DDR3_odt => C1_DDR3_ODT,
        CLK533MHZ0_clk_p => CLK533MHZ0_P,
        CLK533MHZ0_clk_n => CLK533MHZ0_N,

        -- Reference timing clock for DDR3 controller
        CLK100MHZ => clk100mhz_bufg
    );
end;
