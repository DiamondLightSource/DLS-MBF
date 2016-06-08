library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;

architecture top of top is
    signal fclka : std_logic;
    signal clk100mhz : std_logic;
    signal dsp_clk : std_logic;
    signal dsp_reset_n : std_logic;

begin
    -- Reference clock for MGT.  For this one we don't want the BUFG.
    fclka_inst : entity work.gte2_ibufds generic map (
        GEN_BUFG => false
    ) port map (
        clk_p_i => FCLKA_P,
        clk_n_i => FCLKA_N,
        clk_o => fclka
    );

    -- Reference clock for DDR timing
    clk100mhz_inst : entity work.gte2_ibufds port map (
        clk_p_i => CLK100MHZ1_P,
        clk_n_i => CLK100MHZ1_N,
        clk_o => clk100mhz
    );

    -- Dummy DSP 250 MHz clock
    dsp_clock_inst : entity work.dsp_clock port map (
        CLK125MHZ0_P => CLK125MHZ0_P,
        CLK125MHZ0_N => CLK125MHZ0_N,
        nCOLDRST => nCOLDRST,
        dsp_clk_o => dsp_clk,
        dsp_rst_n_o => dsp_reset_n
    );


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
        CLK100MHZ => clk100mhz,

        -- AXI-Lite register slave interface
        M_DSP_REGS_araddr => open,
        M_DSP_REGS_arprot => open,
        M_DSP_REGS_arready => '1',
        M_DSP_REGS_arvalid => open,
        M_DSP_REGS_awaddr => open,
        M_DSP_REGS_awprot => open,
        M_DSP_REGS_awready => '1',
        M_DSP_REGS_awvalid => open,
        M_DSP_REGS_bready => open,
        M_DSP_REGS_bresp => "10",
        M_DSP_REGS_bvalid => '1',
        M_DSP_REGS_rdata => (others => '0'),
        M_DSP_REGS_rready => open,
        M_DSP_REGS_rresp => "10",
        M_DSP_REGS_rvalid => '1',
        M_DSP_REGS_wdata => open,
        M_DSP_REGS_wready => '1',
        M_DSP_REGS_wstrb => open,
        M_DSP_REGS_wvalid => open,

        -- AXI master interface to DDR block 0
        S_DSP_DDR0_awaddr => (others => '0'),
        S_DSP_DDR0_awburst => (others => '0'),
        S_DSP_DDR0_awcache => (others => '0'),
        S_DSP_DDR0_awlen => (others => '0'),
        S_DSP_DDR0_awlock => (others => '0'),
        S_DSP_DDR0_awprot => (others => '0'),
        S_DSP_DDR0_awqos => (others => '0'),
        S_DSP_DDR0_awready => open,
        S_DSP_DDR0_awregion => (others => '0'),
        S_DSP_DDR0_awsize => (others => '0'),
        S_DSP_DDR0_awvalid => '0',
        S_DSP_DDR0_bready => '0',
        S_DSP_DDR0_bresp => open,
        S_DSP_DDR0_bvalid => open,
        S_DSP_DDR0_wdata => (others => '0'),
        S_DSP_DDR0_wlast => '0',
        S_DSP_DDR0_wready => open,
        S_DSP_DDR0_wstrb => (others => '0'),
        S_DSP_DDR0_wvalid => '0',

        -- AXI master interface to DDR block 1
        S_DSP_DDR1_awaddr => (others => '0'),
        S_DSP_DDR1_awburst => (others => '0'),
        S_DSP_DDR1_awcache => (others => '0'),
        S_DSP_DDR1_awlen => (others => '0'),
        S_DSP_DDR1_awlock => (others => '0'),
        S_DSP_DDR1_awprot => (others => '0'),
        S_DSP_DDR1_awqos => (others => '0'),
        S_DSP_DDR1_awready => open,
        S_DSP_DDR1_awregion => (others => '0'),
        S_DSP_DDR1_awsize => (others => '0'),
        S_DSP_DDR1_awvalid => '0',
        S_DSP_DDR1_bready => '0',
        S_DSP_DDR1_bresp => open,
        S_DSP_DDR1_bvalid => open,
        S_DSP_DDR1_wdata => (others => '0'),
        S_DSP_DDR1_wlast => '0',
        S_DSP_DDR1_wready => open,
        S_DSP_DDR1_wstrb => (others => '0'),
        S_DSP_DDR1_wvalid => '0',

        -- DSP interface clock, running at half RF frequency
        DSP_CLK => dsp_clk,
        DSP_RESETN => dsp_reset_n
    );
end;
