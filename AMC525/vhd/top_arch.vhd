library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.defines.all;

architecture top of top is
    -- IO instances
    signal uled_out : std_logic_vector(3 downto 0);
    signal n_coldrst_in : std_logic;
    signal fclka : std_logic;
    signal clk125mhz : std_logic;

    -- Interrupt signals
    signal INTR : std_logic_vector(7 downto 0);

    -- Clocking and reset resources
    signal adc_clk : std_logic;
    signal dsp_clk : std_logic;
    signal dsp_clk_ok : std_logic;
    signal dsp_reset_n : std_logic;
    signal ref_clk : std_logic;
    signal ref_clk_ok : std_logic;
    signal reg_clk : std_logic;
    signal reg_clk_ok : std_logic;
    signal adc_pll_ok : std_logic;

    -- Interconnect wiring

    -- Wiring from AXI-Lite master to register slave
    signal DSP_REGS_araddr : std_logic_vector(15 downto 0);     -- AR
    signal DSP_REGS_arprot : std_logic_vector(2 downto 0);
    signal DSP_REGS_arready : std_logic;
    signal DSP_REGS_arvalid : std_logic;
    signal DSP_REGS_rdata : std_logic_vector(31 downto 0);      -- R
    signal DSP_REGS_rresp : std_logic_vector(1 downto 0);
    signal DSP_REGS_rready : std_logic;
    signal DSP_REGS_rvalid : std_logic;
    signal DSP_REGS_awaddr : std_logic_vector(15 downto 0);     -- AW
    signal DSP_REGS_awprot : std_logic_vector(2 downto 0);
    signal DSP_REGS_awready : std_logic;
    signal DSP_REGS_awvalid : std_logic;
    signal DSP_REGS_wdata : std_logic_vector(31 downto 0);      -- W
    signal DSP_REGS_wstrb : std_logic_vector(3 downto 0);
    signal DSP_REGS_wready : std_logic;
    signal DSP_REGS_wvalid : std_logic;
    signal DSP_REGS_bresp : std_logic_vector(1 downto 0);
    signal DSP_REGS_bready : std_logic;                         -- B
    signal DSP_REGS_bvalid : std_logic;

    -- Wiring from DSP burst master to AXI DDR0 slave
    signal DSP_DDR0_awaddr : std_logic_vector(47 downto 0);
    signal DSP_DDR0_awburst : std_logic_vector(1 downto 0);
    signal DSP_DDR0_awcache : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awlen : std_logic_vector(7 downto 0);
    signal DSP_DDR0_awlock : std_logic_vector(0 downto 0);
    signal DSP_DDR0_awprot : std_logic_vector(2 downto 0);
    signal DSP_DDR0_awqos : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awregion : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awsize : std_logic_vector(2 downto 0);
    signal DSP_DDR0_awready : std_logic;
    signal DSP_DDR0_awvalid : std_logic;
    signal DSP_DDR0_wdata : std_logic_vector(63 downto 0);
    signal DSP_DDR0_wlast : std_logic;
    signal DSP_DDR0_wstrb : std_logic_vector(7 downto 0);
    signal DSP_DDR0_wready : std_logic;
    signal DSP_DDR0_wvalid : std_logic;
    signal DSP_DDR0_bresp : std_logic_vector(1 downto 0);
    signal DSP_DDR0_bready : std_logic;
    signal DSP_DDR0_bvalid : std_logic;

    -- Data from DSP to burst master
    signal DSP_DDR0_capture_enable : std_logic;
    signal DSP_DDR0_data_ready : std_logic;
    signal DSP_DDR0_capture_address : std_logic_vector(30 downto 0);
    signal DSP_DDR0_data : std_logic_vector(63 downto 0);
    signal DSP_DDR0_data_valid : std_logic;
    signal DSP_DDR0_data_error : std_logic;
    signal DSP_DDR0_addr_error : std_logic;
    signal DSP_DDR0_brsp_error : std_logic;

    -- Wiring from DSP slow write master to AXI DDR1 slave
    signal DSP_DDR1_awaddr : std_logic_vector(47 downto 0);
    signal DSP_DDR1_awburst : std_logic_vector(1 downto 0);
    signal DSP_DDR1_awcache : std_logic_vector(3 downto 0);
    signal DSP_DDR1_awlen : std_logic_vector(7 downto 0);
    signal DSP_DDR1_awlock : std_logic_vector(0 downto 0);
    signal DSP_DDR1_awprot : std_logic_vector(2 downto 0);
    signal DSP_DDR1_awqos : std_logic_vector(3 downto 0);
    signal DSP_DDR1_awregion : std_logic_vector(3 downto 0);
    signal DSP_DDR1_awsize : std_logic_vector(2 downto 0);
    signal DSP_DDR1_awready : std_logic;
    signal DSP_DDR1_awvalid : std_logic;
    signal DSP_DDR1_wdata : std_logic_vector(63 downto 0);
    signal DSP_DDR1_wlast : std_logic;
    signal DSP_DDR1_wstrb : std_logic_vector(7 downto 0);
    signal DSP_DDR1_wready : std_logic;
    signal DSP_DDR1_wvalid : std_logic;
    signal DSP_DDR1_bresp : std_logic_vector(1 downto 0);
    signal DSP_DDR1_bready : std_logic;
    signal DSP_DDR1_bvalid : std_logic;

    -- Internal register path from AXI conversion
    signal REGS_write_strobe : mod_strobe_t;
    signal REGS_write_address : reg_addr_t;
    signal REGS_write_data : reg_data_t;
    signal REGS_write_ack : mod_strobe_t;
    signal REGS_read_strobe : mod_strobe_t;
    signal REGS_read_address : reg_addr_t;
    signal REGS_read_data : reg_data_array_t(MOD_ADDR_RANGE);
    signal REGS_read_ack : mod_strobe_t;

    -- Digital I/O on FMC0
    signal dio_inputs : std_logic_vector(4 downto 0);
    signal dio_outputs : std_logic_vector(4 downto 0);
    signal dio_leds : std_logic_vector(1 downto 0);

    -- Connections to FMC500M on FMC0
    signal adc_dco : std_logic;
    signal dsp0_adc_data : adc_inp_t;
    signal dsp1_adc_data : adc_inp_t;
    signal dsp0_dac_data : dac_out_t;
    signal dsp1_dac_data : dac_out_t;
    signal fast_ext_trigger : std_logic;
    signal fmc500_outputs : fmc500_outputs_t;
    signal fmc500_inputs : fmc500_inputs_t;

    -- Top register wiring
    signal system_write_strobe : reg_strobe_t;
    signal system_write_ack : reg_strobe_t;
    signal system_read_strobe : reg_strobe_t;
    signal system_read_data : reg_data_array_t(REG_ADDR_RANGE);
    signal system_read_ack : reg_strobe_t;
    signal ctrl_write_strobe : reg_strobe_t;
    signal ctrl_write_ack : reg_strobe_t;
    signal ctrl_read_strobe : reg_strobe_t;
    signal ctrl_read_data : reg_data_array_t(REG_ADDR_RANGE);
    signal ctrl_read_ack : reg_strobe_t;
    signal dsp0_write_strobe : reg_strobe_t;
    signal dsp0_write_ack : reg_strobe_t;
    signal dsp0_read_strobe : reg_strobe_t;
    signal dsp0_read_data : reg_data_array_t(REG_ADDR_RANGE);
    signal dsp0_read_ack : reg_strobe_t;
    signal dsp1_write_strobe : reg_strobe_t;
    signal dsp1_write_ack : reg_strobe_t;
    signal dsp1_read_strobe : reg_strobe_t;
    signal dsp1_read_data : reg_data_array_t(REG_ADDR_RANGE);
    signal dsp1_read_ack : reg_strobe_t;

    -- System register wiring
    -- Control registers
    signal version_data : reg_data_t;
    signal status_data : reg_data_t;
    signal control_data : reg_data_t;
    -- IDELAY control
    signal idelay_write_strobe : std_logic;
    signal idelay_read_data : reg_data_t;
    -- FMC500 SPI interface
    signal fmc500m_spi_write_strobe : std_logic;
    signal fmc500m_spi_write_ack : std_logic;
    signal fmc500m_spi_read_strobe : std_logic;
    signal fmc500m_spi_read_data : reg_data_t;
    signal fmc500m_spi_read_ack : std_logic;

    -- Connections to DSP units
    signal dsp0_ddr0_data : ddr0_data_channels;
    signal dsp0_ddr1_data : ddr1_data_t;
    signal dsp0_ddr1_data_strobe : std_logic;
    signal dsp0_control : dsp_control_t;
    signal dsp0_status : dsp_status_t;

    signal dsp1_ddr0_data : ddr0_data_channels;
    signal dsp1_ddr1_data : ddr1_data_t;
    signal dsp1_ddr1_data_strobe : std_logic;
    signal dsp1_control : dsp_control_t;
    signal dsp1_status : dsp_status_t;

begin

    -- -------------------------------------------------------------------------
    -- IO instances.

    -- Front panel LEDs
    uled_inst : entity work.obuf_array generic map (
        COUNT => 4
    ) port map (
        i_i => uled_out,
        o_o => ULED
    );

    -- Reset in.
    ncoldrst_inst : entity work.ibuf_array port map (
        i_i(0) => nCOLDRST,
        o_o(0) => n_coldrst_in
    );

    -- Reference clock for MGT.
    fclka_inst : entity work.ibufds_gte2_array port map (
        p_i(0) => FCLKA_P,
        n_i(0) => FCLKA_N,
        o_o(0) => fclka
    );

    -- Fixed 125 MHz reference clock
    clk125mhz_inst : entity work.ibufds_gte2_array port map (
        p_i(0) => CLK125MHZ0_P,
        n_i(0) => CLK125MHZ0_N,
        o_o(0) => clk125mhz
    );


    -- -------------------------------------------------------------------------
    -- Wiring to LEDs and interrupts

    -- Front panel LEDs
    uled_out <= (
        0 => dsp_clk_ok,
        1 => adc_pll_ok,
        2 => reg_clk_ok,
        3 => dsp_reset_n
    );

    -- FMC0 LEDs
    dio_leds <= (
        0 => fmc500_inputs.pll_status_ld1,
        1 => fmc500_inputs.pll_status_ld2
    );

    -- FMC0 outputs
    dio_outputs <= (
        0 => fmc500_inputs.pll_dclkout2,
        1 => fmc500_inputs.pll_sdclkout3,
        2 => fmc500_inputs.pll_status_ld1,
        3 => fmc500_inputs.pll_status_ld2,
        4 => '0'
    );

    -- Interrupt events
    INTR <= (
        0 => DSP_DDR0_capture_enable,
        1 => not DSP_DDR0_capture_enable,
        others => '0'
    );

    -- -------------------------------------------------------------------------
    -- Clocking

    -- We work with the following external clocking sources:
    --
    --  FCLKA           Dedicated 100 MHz PCIe reference clock
    --  CLK533MHZ{1,2}  Dedicated DDR DRAM clocks
    --  CLK125MHZ       General purpose fixed frequency clock
    --  ADC_DCO         ADC data clock, not always available or valid
    --
    -- The first three clocks are routed directly to the corresponding Xilinix
    -- modules and are not visible outside of the interconnect block diagram.
    --
    -- Here we process clk125mhz and adc_dco to generate the following internal
    -- clocks:
    --
    --  CLK125MHZ generates:
    --      ref_clk     200 MHz reference clock needed for FPGA timing control
    --      reg_clk     Slow (125 MHz) register clock for control interface
    --
    --  ADC_DCO generates:
    --      adc_clk     500 MHz RF clock for raw ADC and DAC data
    --      dsp_clk     Signal processing clock running at half adc_clk speed
    --
    -- Note that ADC_DCO is not always available, so also adc_clk and dsp_clk
    -- can lose availability.

    clocking_inst : entity work.clocking port map (
        nCOLDRST => n_coldrst_in,
        clk125mhz_i => clk125mhz,
        adc_dco_i => adc_dco,

        ref_clk_o => ref_clk,
        ref_clk_ok_o => ref_clk_ok,

        adc_clk_o => adc_clk,
        dsp_clk_o => dsp_clk,
        dsp_clk_ok_o => dsp_clk_ok,
        reg_clk_o => reg_clk,
        reg_clk_ok_o => reg_clk_ok,
        dsp_reset_n_o => dsp_reset_n,

        write_strobe_i => idelay_write_strobe,
        write_data_i => REGS_write_data,
        read_data_o => idelay_read_data,

        adc_pll_ok_o => adc_pll_ok
    );


    -- -------------------------------------------------------------------------
    -- Interconnect: PCIe and DRAM

    -- Wire up the interconnect
    interconnect_inst : entity work.interconnect_wrapper port map (
        nCOLDRST => n_coldrst_in,

        -- Interrupt interface
        INTR => INTR,

        -- Clocking for register interface
        REG_CLK => reg_clk,
        REG_RESETn => reg_clk_ok,

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
        CLK200MHZ => ref_clk,
        CLK200MHZ_RSTN => ref_clk_ok,

        -- AXI-Lite register master interface
        M_DSP_REGS_araddr => DSP_REGS_araddr,
        M_DSP_REGS_arprot => DSP_REGS_arprot,
        M_DSP_REGS_arready => DSP_REGS_arready,
        M_DSP_REGS_arvalid => DSP_REGS_arvalid,
        M_DSP_REGS_rdata => DSP_REGS_rdata,
        M_DSP_REGS_rresp => DSP_REGS_rresp,
        M_DSP_REGS_rready => DSP_REGS_rready,
        M_DSP_REGS_rvalid => DSP_REGS_rvalid,
        M_DSP_REGS_awaddr => DSP_REGS_awaddr,
        M_DSP_REGS_awprot => DSP_REGS_awprot,
        M_DSP_REGS_awready => DSP_REGS_awready,
        M_DSP_REGS_awvalid => DSP_REGS_awvalid,
        M_DSP_REGS_wdata => DSP_REGS_wdata,
        M_DSP_REGS_wstrb => DSP_REGS_wstrb,
        M_DSP_REGS_wready => DSP_REGS_wready,
        M_DSP_REGS_wvalid => DSP_REGS_wvalid,
        M_DSP_REGS_bresp => DSP_REGS_bresp,
        M_DSP_REGS_bready => DSP_REGS_bready,
        M_DSP_REGS_bvalid => DSP_REGS_bvalid,

        -- AXI slave interface to DDR block 0
        S_DSP_DDR0_awaddr => DSP_DDR0_awaddr,
        S_DSP_DDR0_awburst => DSP_DDR0_awburst,
        S_DSP_DDR0_awcache => DSP_DDR0_awcache,
        S_DSP_DDR0_awlen => DSP_DDR0_awlen,
        S_DSP_DDR0_awlock => DSP_DDR0_awlock,
        S_DSP_DDR0_awprot => DSP_DDR0_awprot,
        S_DSP_DDR0_awqos => DSP_DDR0_awqos,
        S_DSP_DDR0_awregion => DSP_DDR0_awregion,
        S_DSP_DDR0_awsize => DSP_DDR0_awsize,
        S_DSP_DDR0_awready => DSP_DDR0_awready,
        S_DSP_DDR0_awvalid => DSP_DDR0_awvalid,
        S_DSP_DDR0_wdata => DSP_DDR0_wdata,
        S_DSP_DDR0_wlast => DSP_DDR0_wlast,
        S_DSP_DDR0_wstrb => DSP_DDR0_wstrb,
        S_DSP_DDR0_wready => DSP_DDR0_wready,
        S_DSP_DDR0_wvalid => DSP_DDR0_wvalid,
        S_DSP_DDR0_bresp => DSP_DDR0_bresp,
        S_DSP_DDR0_bready => DSP_DDR0_bready,
        S_DSP_DDR0_bvalid => DSP_DDR0_bvalid,

        -- AXI slave interface to DDR block 1
        S_DSP_DDR1_awaddr => DSP_DDR1_awaddr,
        S_DSP_DDR1_awburst => DSP_DDR1_awburst,
        S_DSP_DDR1_awcache => DSP_DDR1_awcache,
        S_DSP_DDR1_awlen => DSP_DDR1_awlen,
        S_DSP_DDR1_awlock => DSP_DDR1_awlock,
        S_DSP_DDR1_awprot => DSP_DDR1_awprot,
        S_DSP_DDR1_awqos => DSP_DDR1_awqos,
        S_DSP_DDR1_awready => DSP_DDR1_awready,
        S_DSP_DDR1_awregion => DSP_DDR1_awregion,
        S_DSP_DDR1_awsize => DSP_DDR1_awsize,
        S_DSP_DDR1_awvalid => DSP_DDR1_awvalid,
        S_DSP_DDR1_bready => DSP_DDR1_bready,
        S_DSP_DDR1_bresp => DSP_DDR1_bresp,
        S_DSP_DDR1_bvalid => DSP_DDR1_bvalid,
        S_DSP_DDR1_wdata => DSP_DDR1_wdata,
        S_DSP_DDR1_wlast => DSP_DDR1_wlast,
        S_DSP_DDR1_wready => DSP_DDR1_wready,
        S_DSP_DDR1_wstrb => DSP_DDR1_wstrb,
        S_DSP_DDR1_wvalid => DSP_DDR1_wvalid,

        -- DSP interface clock, running at half RF frequency
        DSP_CLK => dsp_clk,
        DSP_RESETN => dsp_reset_n
    );


    -- -------------------------------------------------------------------------
    -- AXI interfacing

    -- Register AXI slave interface
    axi_lite_slave_inst : entity work.axi_lite_slave port map (
        clk_i => reg_clk,
        rstn_i => reg_clk_ok,

        -- AXI-Lite read interface
        araddr_i => DSP_REGS_araddr,
        arprot_i => DSP_REGS_arprot,
        arvalid_i => DSP_REGS_arvalid,
        arready_o => DSP_REGS_arready,
        rdata_o => DSP_REGS_rdata,
        rresp_o => DSP_REGS_rresp,
        rvalid_o => DSP_REGS_rvalid,
        rready_i => DSP_REGS_rready,

        -- AXI-Lite write interface
        awaddr_i => DSP_REGS_awaddr,
        awprot_i => DSP_REGS_awprot,
        awvalid_i => DSP_REGS_awvalid,
        awready_o => DSP_REGS_awready,
        wdata_i => DSP_REGS_wdata,
        wstrb_i => DSP_REGS_wstrb,
        wvalid_i => DSP_REGS_wvalid,
        wready_o => DSP_REGS_wready,
        bready_i => DSP_REGS_bready,
        bresp_o => DSP_REGS_bresp,
        bvalid_o => DSP_REGS_bvalid,

        -- Internal read interface
        read_strobe_o => REGS_read_strobe,
        read_address_o => REGS_read_address,
        read_data_i => REGS_read_data,
        read_ack_i => REGS_read_ack,

        -- Internal write interface
        write_strobe_o => REGS_write_strobe,
        write_address_o => REGS_write_address,
        write_data_o => REGS_write_data,
        write_ack_i => REGS_write_ack
    );

    -- AXI burst master for streaming data to DDR0 DRAM
    axi_burst_master_inst : entity work.axi_burst_master generic map (
        BURST_LENGTH => 32
    ) port map (
        clk_i => dsp_clk,
        rstn_i => dsp_reset_n,

        -- AXI write master
        awaddr_o => DSP_DDR0_awaddr,
        awburst_o => DSP_DDR0_awburst,
        awsize_o => DSP_DDR0_awsize,
        awlen_o => DSP_DDR0_awlen,
        awcache_o => DSP_DDR0_awcache,
        awlock_o => DSP_DDR0_awlock,
        awprot_o => DSP_DDR0_awprot,
        awqos_o => DSP_DDR0_awqos,
        awregion_o => DSP_DDR0_awregion,
        awvalid_o => DSP_DDR0_awvalid,
        awready_i => DSP_DDR0_awready,
        wdata_o => DSP_DDR0_wdata,
        wlast_o => DSP_DDR0_wlast,
        wstrb_o => DSP_DDR0_wstrb,
        wvalid_o => DSP_DDR0_wvalid,
        wready_i => DSP_DDR0_wready,
        bresp_i => DSP_DDR0_bresp,
        bvalid_i => DSP_DDR0_bvalid,
        bready_o => DSP_DDR0_bready,

        -- Data streaming interface
        capture_enable_i => DSP_DDR0_capture_enable,
        data_ready_o => DSP_DDR0_data_ready,
        capture_address_o => DSP_DDR0_capture_address,

        data_i => DSP_DDR0_data,
        data_valid_i => DSP_DDR0_data_valid,

        data_error_o => DSP_DDR0_data_error,
        addr_error_o => DSP_DDR0_addr_error,
        brsp_error_o => DSP_DDR0_brsp_error
    );

    -- Dummy wiring for unused DDR1 DRAM connections
    DSP_DDR1_awaddr <= (others => '0');
    DSP_DDR1_awburst <= (others => '0');
    DSP_DDR1_awcache <= (others => '0');
    DSP_DDR1_awlen <= (others => '0');
    DSP_DDR1_awlock <= (others => '0');
    DSP_DDR1_awprot <= (others => '0');
    DSP_DDR1_awqos <= (others => '0');
--     DSP_DDR1_awready <= open;
    DSP_DDR1_awregion <= (others => '0');
    DSP_DDR1_awsize <= (others => '0');
    DSP_DDR1_awvalid <= '0';
    DSP_DDR1_bready <= '0';
--     DSP_DDR1_bresp <= open;
--     DSP_DDR1_bvalid <= open;
    DSP_DDR1_wdata <= (others => '0');
    DSP_DDR1_wlast <= '0';
--     DSP_DDR1_wready <= open;
    DSP_DDR1_wstrb <= (others => '0');
    DSP_DDR1_wvalid <= '0';



    -- -------------------------------------------------------------------------
    -- FMC modules

    -- FMC0 Digital I/O
    fmc_digital_io_inst : entity work.fmc_digital_io port map (
        FMC_LA_P => FMC0_LA_P,
        FMC_LA_N => FMC0_LA_N,

        -- Configure I/O #5 as terminated input, the other four are outputs.
        out_enable_i  => "01111",
        term_enable_i => "10000",

        output_i => dio_outputs,
        leds_i => dio_leds,
        input_o => dio_inputs
    );

    -- FMC1 FMC500M ADC/DAC and clock source
    fmc500m_top_inst : entity work.fmc500m_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_ok_i => dsp_clk_ok,
        reg_clk_i => reg_clk,

        FMC_LA_P => FMC1_LA_P,
        FMC_LA_N => FMC1_LA_N,
        FMC_HB_P => FMC1_HB_P,
        FMC_HB_N => FMC1_HB_N,

        spi_write_strobe_i => fmc500m_spi_write_strobe,
        spi_write_data_i => REGS_write_data,
        spi_write_ack_o => fmc500m_spi_write_ack,
        spi_read_strobe_i => fmc500m_spi_read_strobe,
        spi_read_data_o => fmc500m_spi_read_data,
        spi_read_ack_o => fmc500m_spi_read_ack,

        adc_dco_o => adc_dco,
        adc_data_a_o => dsp0_adc_data,
        adc_data_b_o => dsp1_adc_data,

        dac_data_a_i => dsp0_dac_data,
        dac_data_b_i => dsp1_dac_data,

        ext_trig_o => fast_ext_trigger,
        misc_outputs_i => fmc500_outputs,
        misc_inputs_o => fmc500_inputs
    );


    -- -------------------------------------------------------------------------
    -- Register interfacing

    -- Four register groups:
    --  System      Direct control of hardware
    --  Control     Shared control of DSP elements
    --  DSP{0,1}    Individual control of DSP elements
    register_top_inst : entity work.register_top port map (
        reg_clk_i => reg_clk,
        reg_clk_ok_i => reg_clk_ok,
        dsp_clk_i => dsp_clk,
        dsp_clk_ok_i => dsp_clk_ok,

        write_strobe_i => REGS_write_strobe,
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,
        write_ack_o => REGS_write_ack,
        read_strobe_i => REGS_read_strobe,
        read_address_i => REGS_read_address,
        read_data_o => REGS_read_data,
        read_ack_o => REGS_read_ack,

        system_write_strobe_o => system_write_strobe,
        system_write_ack_i => system_write_ack,
        system_read_strobe_o => system_read_strobe,
        system_read_data_i => system_read_data,
        system_read_ack_i => system_read_ack,

        ctrl_write_strobe_o => ctrl_write_strobe,
        ctrl_write_ack_i => ctrl_write_ack,
        ctrl_read_strobe_o => ctrl_read_strobe,
        ctrl_read_data_i => ctrl_read_data,
        ctrl_read_ack_i => ctrl_read_ack,

        dsp0_write_strobe_o => dsp0_write_strobe,
        dsp0_write_ack_i => dsp0_write_ack,
        dsp0_read_strobe_o => dsp0_read_strobe,
        dsp0_read_data_i => dsp0_read_data,
        dsp0_read_ack_i => dsp0_read_ack,

        dsp1_write_strobe_o => dsp1_write_strobe,
        dsp1_write_ack_i => dsp1_write_ack,
        dsp1_read_strobe_o => dsp1_read_strobe,
        dsp1_read_data_i => dsp1_read_data,
        dsp1_read_ack_i => dsp1_read_ack
    );

    -- System registers for hardware management
    system_registers_inst : entity work.system_registers port map (
        reg_clk_i => reg_clk,
        reg_clk_ok_i => reg_clk_ok,
        ref_clk_i => ref_clk,
        ref_clk_ok_i => ref_clk_ok,

        write_strobe_i => system_write_strobe,
        write_data_i => REGS_write_data,
        write_ack_o => system_write_ack,
        read_strobe_i => system_read_strobe,
        read_data_o => system_read_data,
        read_ack_o => system_read_ack,

        version_read_data_i => version_data,
        status_read_data_i => status_data,
        control_data_o => control_data,

        idelay_write_strobe_o => idelay_write_strobe,
        idelay_read_data_i => idelay_read_data,

        fmc500m_spi_write_strobe_o => fmc500m_spi_write_strobe,
        fmc500m_spi_write_ack_i => fmc500m_spi_write_ack,
        fmc500m_spi_read_strobe_o => fmc500m_spi_read_strobe,
        fmc500m_spi_read_data_i => fmc500m_spi_read_data,
        fmc500m_spi_read_ack_i => fmc500m_spi_read_ack
    );

    control_top_inst : entity work.control_top port map (
        dsp_clk_i => dsp_clk,
        dsp_clk_ok_i => dsp_clk_ok,

        write_strobe_i => ctrl_write_strobe,
        write_data_i => REGS_write_data,
        write_ack_o => ctrl_write_ack,
        read_strobe_i => ctrl_read_strobe,
        read_data_o => ctrl_read_data,
        read_ack_o => ctrl_read_ack,

        dsp0_control_o => dsp0_control,
        dsp0_status_i => dsp0_status,
        dsp1_control_o => dsp1_control,
        dsp1_status_i => dsp1_status,

        ddr0_capture_enable_o => DSP_DDR0_capture_enable,
        ddr0_data_ready_i => DSP_DDR0_data_ready,
        ddr0_capture_address_i => DSP_DDR0_capture_address,
        ddr0_data_valid_o => DSP_DDR0_data_valid,
        ddr0_data_error_i => DSP_DDR0_data_error,
        ddr0_addr_error_i => DSP_DDR0_addr_error,
        ddr0_brsp_error_i => DSP_DDR0_brsp_error
    );


    -- -------------------------------------------------------------------------
    -- DSP instances.

    dsp0_top_inst : entity work.dsp_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        dsp_clk_ok_i => dsp_clk_ok,

        adc_data_i => dsp0_adc_data,
        dac_data_o => dsp0_dac_data,

        write_strobe_i => dsp0_write_strobe,
        write_data_i => REGS_write_data,
        write_ack_o => dsp0_write_ack,
        read_strobe_i => dsp0_read_strobe,
        read_data_o => dsp0_read_data,
        read_ack_o => dsp0_read_ack,

        ddr0_data_o => dsp0_ddr0_data,

        ddr1_data_o => dsp0_ddr1_data,
        ddr1_data_strobe_o => dsp0_ddr1_data_strobe,

        dsp_control_i => dsp0_control,
        dsp_status_o => dsp0_status
    );

    dsp1_top_inst : entity work.dsp_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        dsp_clk_ok_i => dsp_clk_ok,

        adc_data_i => dsp1_adc_data,
        dac_data_o => dsp1_dac_data,

        write_strobe_i => dsp1_write_strobe,
        write_data_i => REGS_write_data,
        write_ack_o => dsp1_write_ack,
        read_strobe_i => dsp1_read_strobe,
        read_data_o => dsp1_read_data,
        read_ack_o => dsp1_read_ack,

        ddr0_data_o => dsp1_ddr0_data,

        ddr1_data_o => dsp1_ddr1_data,
        ddr1_data_strobe_o => dsp1_ddr1_data_strobe,

        dsp_control_i => dsp1_control,
        dsp_status_o => dsp1_status
    );

    -- Reorder DDR0 data: we want alternating dsp0/dsp1 values.
    DSP_DDR0_data(15 downto  0) <= dsp0_ddr0_data(0);
    DSP_DDR0_data(31 downto 16) <= dsp1_ddr0_data(0);
    DSP_DDR0_data(47 downto 32) <= dsp0_ddr0_data(1);
    DSP_DDR0_data(63 downto 48) <= dsp1_ddr0_data(1);


    -- -------------------------------------------------------------------------
    -- Control register mapping.

    version_data(31 downto 0) <= (others => '0');

    status_data <= (
        0 => dsp_clk_ok,
        1 => DSP_DDR0_capture_enable,
        2 => fmc500_inputs.vcxo_pwr_good,
        3 => fmc500_inputs.adc_pwr_good,
        4 => fmc500_inputs.dac_pwr_good,
        5 => fmc500_inputs.pll_status_ld1,
        6 => fmc500_inputs.pll_status_ld2,
        7 => fmc500_inputs.pll_dclkout2,
        8 => fmc500_inputs.pll_sdclkout3,
        9 => fmc500_inputs.temp_alert,
        others => '0'
    );

    fmc500_outputs.adc_pwr_en <= control_data(0);
    fmc500_outputs.dac_pwr_en <= control_data(1);
    fmc500_outputs.vcxo_pwr_en <= control_data(2);
    fmc500_outputs.pll_clkin_sel0 <= control_data(3);
    fmc500_outputs.pll_clkin_sel1 <= control_data(4);
    fmc500_outputs.pll_sync <= control_data(5);

end;
