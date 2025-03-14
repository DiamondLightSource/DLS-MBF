library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.fmc500m_defs.all;
use work.dsp_defs.all;
use work.version.all;

architecture arch of top is
    -- IO instances
    signal uled_out : std_ulogic_vector(3 downto 0);
    signal n_coldrst_in : std_ulogic;
    signal fclka : std_ulogic;
    signal clk125mhz : std_ulogic;

    -- Interrupt signals
    signal INTR : std_ulogic_vector(30 downto 0);

    -- Clocking and reset resources
    signal adc_clk : std_ulogic;
    signal dsp_clk : std_ulogic;
    signal dsp_clk_ok : std_ulogic;
    signal dsp_reset_n : std_ulogic;
    signal ref_clk : std_ulogic;
    signal ref_clk_ok : std_ulogic;
    signal reg_clk : std_ulogic;
    signal reg_clk_ok : std_ulogic;
    signal adc_pll_ok : std_ulogic;


    -- -------------------------------------------------------------------------
    -- Interconnect wiring

    -- Wiring from AXI-Lite master to register slave
    signal DSP_REGS_araddr : std_ulogic_vector(15 downto 0);     -- AR
    signal DSP_REGS_arprot : std_ulogic_vector(2 downto 0);
    signal DSP_REGS_arready : std_ulogic;
    signal DSP_REGS_arvalid : std_ulogic;
    signal DSP_REGS_rdata : std_ulogic_vector(31 downto 0);      -- R
    signal DSP_REGS_rresp : std_ulogic_vector(1 downto 0);
    signal DSP_REGS_rready : std_ulogic;
    signal DSP_REGS_rvalid : std_ulogic;
    signal DSP_REGS_awaddr : std_ulogic_vector(15 downto 0);     -- AW
    signal DSP_REGS_awprot : std_ulogic_vector(2 downto 0);
    signal DSP_REGS_awready : std_ulogic;
    signal DSP_REGS_awvalid : std_ulogic;
    signal DSP_REGS_wdata : std_ulogic_vector(31 downto 0);      -- W
    signal DSP_REGS_wstrb : std_ulogic_vector(3 downto 0);
    signal DSP_REGS_wready : std_ulogic;
    signal DSP_REGS_wvalid : std_ulogic;
    signal DSP_REGS_bresp : std_ulogic_vector(1 downto 0);
    signal DSP_REGS_bready : std_ulogic;                         -- B
    signal DSP_REGS_bvalid : std_ulogic;

    -- Wiring from DSP burst master to AXI DRAM0 slave
    signal DSP_DRAM0_awaddr : std_ulogic_vector(47 downto 0);    -- AW
    signal DSP_DRAM0_awburst : std_ulogic_vector(1 downto 0);
    signal DSP_DRAM0_awcache : std_ulogic_vector(3 downto 0);
    signal DSP_DRAM0_awlen : std_ulogic_vector(7 downto 0);
    signal DSP_DRAM0_awlock : std_ulogic_vector(0 downto 0);
    signal DSP_DRAM0_awprot : std_ulogic_vector(2 downto 0);
    signal DSP_DRAM0_awqos : std_ulogic_vector(3 downto 0);
    signal DSP_DRAM0_awregion : std_ulogic_vector(3 downto 0);
    signal DSP_DRAM0_awsize : std_ulogic_vector(2 downto 0);
    signal DSP_DRAM0_awready : std_ulogic;
    signal DSP_DRAM0_awvalid : std_ulogic;
    signal DSP_DRAM0_wdata : std_ulogic_vector(63 downto 0);     -- W
    signal DSP_DRAM0_wlast : std_ulogic;
    signal DSP_DRAM0_wstrb : std_ulogic_vector(7 downto 0);
    signal DSP_DRAM0_wready : std_ulogic;
    signal DSP_DRAM0_wvalid : std_ulogic;
    signal DSP_DRAM0_bresp : std_ulogic_vector(1 downto 0);      -- B
    signal DSP_DRAM0_bready : std_ulogic;
    signal DSP_DRAM0_bvalid : std_ulogic;

    -- Wiring from DSP slow write master to AXI-Lite DRAM1 slave
    signal DSP_DRAM1_awaddr : std_ulogic_vector(47 downto 0);    -- AW
    signal DSP_DRAM1_awprot : std_ulogic_vector(2 downto 0);
    signal DSP_DRAM1_awready : std_ulogic;
    signal DSP_DRAM1_awvalid : std_ulogic;
    signal DSP_DRAM1_wdata : std_ulogic_vector(63 downto 0);     -- W
    signal DSP_DRAM1_wstrb : std_ulogic_vector(7 downto 0);
    signal DSP_DRAM1_wready : std_ulogic;
    signal DSP_DRAM1_wvalid : std_ulogic;
    signal DSP_DRAM1_bresp : std_ulogic_vector(1 downto 0);      -- B
    signal DSP_DRAM1_bready : std_ulogic;
    signal DSP_DRAM1_bvalid : std_ulogic;

    -- -------------------------------------------------------------------------
    -- Memory controller wiring

    -- Internal register path from AXI conversion
    signal REGS_write_strobe : std_ulogic;
    signal REGS_write_address : unsigned(13 downto 0);
    signal REGS_write_data : std_ulogic_vector(31 downto 0);
    signal REGS_write_ack : std_ulogic;
    signal REGS_read_strobe : std_ulogic;
    signal REGS_read_address : unsigned(13 downto 0);
    signal REGS_read_data : std_ulogic_vector(31 downto 0);
    signal REGS_read_ack : std_ulogic;

    -- Data from DSP to DRAM0 burst master
    signal DRAM0_capture_enable : std_ulogic;
    signal DRAM0_data_ready : std_ulogic;
    signal DRAM0_capture_address : std_ulogic_vector(30 downto 0);
    signal DRAM0_data : std_ulogic_vector(63 downto 0);
    signal DRAM0_data_valid : std_ulogic;
    signal DRAM0_data_error : std_ulogic;
    signal DRAM0_addr_error : std_ulogic;
    signal DRAM0_brsp_error : std_ulogic;

    -- Data from DSP to DRAM1 master
    signal DRAM1_address : unsigned(23 downto 0);
    signal DRAM1_data : std_ulogic_vector(63 downto 0);
    signal DRAM1_data_valid : std_ulogic;
    signal DRAM1_data_ready : std_ulogic;
    signal DRAM1_brsp_error : std_ulogic;

    -- -------------------------------------------------------------------------
    -- FMC wiring

    -- Digital I/O on FMC0
    signal dio_inputs : std_ulogic_vector(4 downto 0);
    signal dio_out_enable : std_ulogic_vector(4 downto 0);
    signal dio_term_enable : std_ulogic_vector(4 downto 0);
    signal dio_outputs : std_ulogic_vector(4 downto 0);
    signal dio_leds : std_ulogic_vector(1 downto 0);

    -- Connections to FMC500M on FMC0
    signal adc_dco : std_ulogic;
    signal dsp_adc_data : signed_array(CHANNELS)(13 downto 0);
    signal dsp_dac_data : signed_array(CHANNELS)(15 downto 0);
    signal fast_ext_trigger : std_ulogic;
    signal fmc500_outputs : fmc500_outputs_t;
    signal fmc500_inputs : fmc500_inputs_t;

    -- FMC500 SPI interface
    signal fmc500m_spi_write_strobe : std_ulogic;
    signal fmc500m_spi_write_data : reg_data_t;
    signal fmc500m_spi_write_ack : std_ulogic;
    signal fmc500m_spi_read_strobe : std_ulogic;
    signal fmc500m_spi_read_data : reg_data_t;
    signal fmc500m_spi_read_ack : std_ulogic;

    -- -------------------------------------------------------------------------
    -- Top register wiring

    -- System register wiring
    signal system_write_strobe : std_ulogic_vector(SYS_REGS_RANGE);
    signal system_write_data : reg_data_t;
    signal system_write_ack : std_ulogic_vector(SYS_REGS_RANGE);
    signal system_read_strobe : std_ulogic_vector(SYS_REGS_RANGE);
    signal system_read_data : reg_data_array_t(SYS_REGS_RANGE);
    signal system_read_ack : std_ulogic_vector(SYS_REGS_RANGE);

    -- DSP control register wiring
    signal dsp_write_strobe : std_ulogic;
    signal dsp_write_address : unsigned(12 downto 0);
    signal dsp_write_data : reg_data_t;
    signal dsp_write_ack : std_ulogic;
    signal dsp_read_strobe : std_ulogic;
    signal dsp_read_address : unsigned(12 downto 0);
    signal dsp_read_data : reg_data_t;
    signal dsp_read_ack : std_ulogic;

    -- Control registers
    signal version_data : reg_data_t;
    signal git_version_data : reg_data_t;
    signal info_data : reg_data_t;
    signal status_data : reg_data_t;
    signal control_data : reg_data_t;

    -- ADC clock IDELAY control
    signal adc_idelay_write_strobe : std_ulogic;
    signal adc_idelay_write_data : reg_data_t;
    signal adc_idelay_read_data : reg_data_t;

    -- Revolution clock IDELAY control
    signal rev_idelay_write_strobe : std_ulogic;
    signal rev_idelay_write_data : reg_data_t;
    signal rev_idelay_read_data : reg_data_t;

    -- External triggers
    signal revolution_clock : std_ulogic;
    signal event_trigger : std_ulogic;
    signal postmortem_trigger : std_ulogic;
    signal blanking_trigger : std_ulogic;
    signal dsp_events : std_ulogic_vector(CHANNELS);

    signal dio_output_5 : std_ulogic;

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

    clocking : entity work.clocking port map (
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

        adc_pll_ok_o => adc_pll_ok
    );

    -- Controllable delay for revolution clock
    rev_clk_idelay : entity work.idelay_control port map (
        ref_clk_i => ref_clk,
        signal_i(0) => fast_ext_trigger,
        signal_o(0) => revolution_clock,
        write_strobe_i => rev_idelay_write_strobe,
        write_data_i => rev_idelay_write_data,
        read_data_o => rev_idelay_read_data
    );


    -- -------------------------------------------------------------------------
    -- Interconnect: PCIe and DRAM

    -- Wire up the interconnect
    interconnect : entity work.interconnect_wrapper port map (
        nCOLDRST => n_coldrst_in,

        -- Interrupt interface
        INTR => INTR,

        -- Clocking for register interface
        REG_CLK => reg_clk,
        REG_RESETn => reg_clk_ok,

        -- Reference timing clock for DDR3 controller
        CLK200MHZ => ref_clk,

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

        -- AXI slave interface to DRAM block 0
        S_DSP_DRAM0_awaddr => DSP_DRAM0_awaddr,
        S_DSP_DRAM0_awburst => DSP_DRAM0_awburst,
        S_DSP_DRAM0_awcache => DSP_DRAM0_awcache,
        S_DSP_DRAM0_awlen => DSP_DRAM0_awlen,
        S_DSP_DRAM0_awlock => DSP_DRAM0_awlock,
        S_DSP_DRAM0_awprot => DSP_DRAM0_awprot,
        S_DSP_DRAM0_awqos => DSP_DRAM0_awqos,
        S_DSP_DRAM0_awregion => DSP_DRAM0_awregion,
        S_DSP_DRAM0_awsize => DSP_DRAM0_awsize,
        S_DSP_DRAM0_awready => DSP_DRAM0_awready,
        S_DSP_DRAM0_awvalid => DSP_DRAM0_awvalid,
        S_DSP_DRAM0_wdata => DSP_DRAM0_wdata,
        S_DSP_DRAM0_wlast => DSP_DRAM0_wlast,
        S_DSP_DRAM0_wstrb => DSP_DRAM0_wstrb,
        S_DSP_DRAM0_wready => DSP_DRAM0_wready,
        S_DSP_DRAM0_wvalid => DSP_DRAM0_wvalid,
        S_DSP_DRAM0_bresp => DSP_DRAM0_bresp,
        S_DSP_DRAM0_bready => DSP_DRAM0_bready,
        S_DSP_DRAM0_bvalid => DSP_DRAM0_bvalid,

        -- AXI-Lite slave interface to DRAM block 1
        S_DSP_DRAM1_awaddr => DSP_DRAM1_awaddr,
        S_DSP_DRAM1_awprot => DSP_DRAM1_awprot,
        S_DSP_DRAM1_awready => DSP_DRAM1_awready,
        S_DSP_DRAM1_awvalid => DSP_DRAM1_awvalid,
        S_DSP_DRAM1_bready => DSP_DRAM1_bready,
        S_DSP_DRAM1_bresp => DSP_DRAM1_bresp,
        S_DSP_DRAM1_bvalid => DSP_DRAM1_bvalid,
        S_DSP_DRAM1_wdata => DSP_DRAM1_wdata,
        S_DSP_DRAM1_wready => DSP_DRAM1_wready,
        S_DSP_DRAM1_wstrb => DSP_DRAM1_wstrb,
        S_DSP_DRAM1_wvalid => DSP_DRAM1_wvalid,

        -- DSP interface clock, running at half RF frequency
        DSP_CLK => dsp_clk,
        DSP_RESETN => dsp_reset_n
    );


    -- -------------------------------------------------------------------------
    -- AXI interfacing

    -- Register AXI slave interface
    axi_lite_slave : entity work.axi_lite_slave port map (
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

    -- AXI burst master for streaming data to DRAM0 DRAM
    axi_burst_master : entity work.axi_burst_master generic map (
        BURST_LENGTH => 32,
        -- Base address: 0x8000_0000_0000 to 0x8000_7FFF_FFFF
        ADDR_PADDING => X"8000" & '0'
    ) port map (
        clk_i => dsp_clk,
        rstn_i => dsp_reset_n,

        -- AXI write master
        awaddr_o => DSP_DRAM0_awaddr,
        awburst_o => DSP_DRAM0_awburst,
        awsize_o => DSP_DRAM0_awsize,
        awlen_o => DSP_DRAM0_awlen,
        awcache_o => DSP_DRAM0_awcache,
        awlock_o => DSP_DRAM0_awlock,
        awprot_o => DSP_DRAM0_awprot,
        awqos_o => DSP_DRAM0_awqos,
        awregion_o => DSP_DRAM0_awregion,
        awvalid_o => DSP_DRAM0_awvalid,
        awready_i => DSP_DRAM0_awready,
        wdata_o => DSP_DRAM0_wdata,
        wlast_o => DSP_DRAM0_wlast,
        wstrb_o => DSP_DRAM0_wstrb,
        wvalid_o => DSP_DRAM0_wvalid,
        wready_i => DSP_DRAM0_wready,
        bresp_i => DSP_DRAM0_bresp,
        bvalid_i => DSP_DRAM0_bvalid,
        bready_o => DSP_DRAM0_bready,

        -- Data streaming interface
        capture_enable_i => DRAM0_capture_enable,
        data_ready_o => DRAM0_data_ready,
        capture_address_o => DRAM0_capture_address,

        data_i => DRAM0_data,
        data_valid_i => DRAM0_data_valid,

        data_error_o => DRAM0_data_error,
        addr_error_o => DRAM0_addr_error,
        brsp_error_o => DRAM0_brsp_error
    );

    -- AXI master for writing to slow DRAM1
    axi_lite_master : entity work.axi_lite_master generic map (
        -- Base address: 0x8000_8000_0000 to 0x8000_87FF_FFFF
        ADDR_PADDING => X"8000_8" & '0'
    ) port map (
        clk_i => dsp_clk,
        rstn_i => dsp_reset_n,

        awaddr_o => DSP_DRAM1_awaddr,
        awprot_o => DSP_DRAM1_awprot,
        awready_i => DSP_DRAM1_awready,
        awvalid_o => DSP_DRAM1_awvalid,
        bready_o => DSP_DRAM1_bready,
        bresp_i => DSP_DRAM1_bresp,
        bvalid_i => DSP_DRAM1_bvalid,
        wdata_o => DSP_DRAM1_wdata,
        wready_i => DSP_DRAM1_wready,
        wstrb_o => DSP_DRAM1_wstrb,
        wvalid_o => DSP_DRAM1_wvalid,

        address_i => DRAM1_address,
        data_i => DRAM1_data,
        data_valid_i => DRAM1_data_valid,
        data_ready_o => DRAM1_data_ready,
        brsp_error_o => DRAM1_brsp_error
    );


    -- -------------------------------------------------------------------------
    -- FMC modules

    -- FMC0 Digital I/O
    fmc_digital_io : entity work.fmc_digital_io port map (
        FMC_LA_P => FMC0_LA_P,
        FMC_LA_N => FMC0_LA_N,

        -- Configure ports 1-3 as terminated inputs, ports 4,5 will be outputs.
        out_enable_i  => dio_out_enable,
        term_enable_i => dio_term_enable,

        output_i => dio_outputs,
        leds_i => dio_leds,
        input_o => dio_inputs
    );

    -- FMC1 FMC500M ADC/DAC and clock source
    fmc500m_top : entity work.fmc500m_top port map (
        adc_clk_i => adc_clk,
        reg_clk_i => reg_clk,
        ref_clk_i => ref_clk,

        FMC_LA_P => FMC1_LA_P,
        FMC_LA_N => FMC1_LA_N,
        FMC_HB_P => FMC1_HB_P,
        FMC_HB_N => FMC1_HB_N,

        spi_write_strobe_i => fmc500m_spi_write_strobe,
        spi_write_data_i => fmc500m_spi_write_data,
        spi_write_ack_o => fmc500m_spi_write_ack,
        spi_read_strobe_i => fmc500m_spi_read_strobe,
        spi_read_data_o => fmc500m_spi_read_data,
        spi_read_ack_o => fmc500m_spi_read_ack,

        adc_idelay_write_strobe_i => adc_idelay_write_strobe,
        adc_idelay_write_data_i => adc_idelay_write_data,
        adc_idelay_read_data_o => adc_idelay_read_data,

        adc_dco_o => adc_dco,
        adc_data_a_o => dsp_adc_data(0),
        adc_data_b_o => dsp_adc_data(1),

        dac_data_a_i => dsp_dac_data(0),
        dac_data_b_i => dsp_dac_data(1),
        dac_frame_i => '0',

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
    register_top : entity work.register_top port map (
        reg_clk_i => reg_clk,
        dsp_clk_i => dsp_clk,
        dsp_clk_ok_i => dsp_clk_ok,

        -- On reg_clk_i from AXI slave
        write_strobe_i => REGS_write_strobe,
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,
        write_ack_o => REGS_write_ack,
        read_strobe_i => REGS_read_strobe,
        read_address_i => REGS_read_address,
        read_data_o => REGS_read_data,
        read_ack_o => REGS_read_ack,

        -- On reg_clk_i to core system registers
        system_write_strobe_o => system_write_strobe,
        system_write_data_o => system_write_data,
        system_write_ack_i => system_write_ack,
        system_read_strobe_o => system_read_strobe,
        system_read_data_i => system_read_data,
        system_read_ack_i => system_read_ack,

        -- On dsp_clk_i to all DSP registers
        dsp_write_strobe_o => dsp_write_strobe,
        dsp_write_address_o => dsp_write_address,
        dsp_write_data_o => dsp_write_data,
        dsp_write_ack_i => dsp_write_ack,
        dsp_read_strobe_o => dsp_read_strobe,
        dsp_read_address_o => dsp_read_address,
        dsp_read_data_i => dsp_read_data,
        dsp_read_ack_i => dsp_read_ack
    );


    -- System registers for hardware management
    system_registers : entity work.system_registers port map (
        reg_clk_i => reg_clk,
        ref_clk_i => ref_clk,
        ref_clk_ok_i => ref_clk_ok,

        write_strobe_i => system_write_strobe,
        write_data_i => system_write_data,
        write_ack_o => system_write_ack,
        read_strobe_i => system_read_strobe,
        read_data_o => system_read_data,
        read_ack_o => system_read_ack,

        version_read_data_i => version_data,
        git_version_read_data_i => git_version_data,
        info_read_data_i => info_data,
        status_read_data_i => status_data,
        control_data_o => control_data,

        adc_idelay_write_strobe_o => adc_idelay_write_strobe,
        adc_idelay_write_data_o => adc_idelay_write_data,
        adc_idelay_read_data_i => adc_idelay_read_data,

        rev_idelay_write_strobe_o => rev_idelay_write_strobe,
        rev_idelay_write_data_o => rev_idelay_write_data,
        rev_idelay_read_data_i => rev_idelay_read_data,

        fmc500m_spi_write_strobe_o => fmc500m_spi_write_strobe,
        fmc500m_spi_write_data_o => fmc500m_spi_write_data,
        fmc500m_spi_write_ack_i => fmc500m_spi_write_ack,
        fmc500m_spi_read_strobe_o => fmc500m_spi_read_strobe,
        fmc500m_spi_read_data_i => fmc500m_spi_read_data,
        fmc500m_spi_read_ack_i => fmc500m_spi_read_ack
    );


    -- -------------------------------------------------------------------------
    -- DSP

    -- Core signal processing
    dsp_main : entity work.dsp_main port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

        adc_data_i => dsp_adc_data,
        dac_data_o => dsp_dac_data,

        write_strobe_i => dsp_write_strobe,
        write_address_i => dsp_write_address,
        write_data_i => dsp_write_data,
        write_ack_o => dsp_write_ack,
        read_strobe_i => dsp_read_strobe,
        read_address_i => dsp_read_address,
        read_data_o => dsp_read_data,
        read_ack_o => dsp_read_ack,

        dram0_capture_enable_o => DRAM0_capture_enable,
        dram0_data_ready_i => DRAM0_data_ready,
        dram0_capture_address_i => DRAM0_capture_address,
        dram0_data_o => DRAM0_data,
        dram0_data_valid_o => DRAM0_data_valid,
        dram0_data_error_i => DRAM0_data_error,
        dram0_addr_error_i => DRAM0_addr_error,
        dram0_brsp_error_i => DRAM0_brsp_error,

        dram1_address_o => DRAM1_address,
        dram1_data_o => DRAM1_data,
        dram1_data_valid_o => DRAM1_data_valid,
        dram1_data_ready_i => DRAM1_data_ready,
        dram1_brsp_error_i => DRAM1_brsp_error,

        revolution_clock_i => revolution_clock,
        event_trigger_i => event_trigger,
        postmortem_trigger_i => postmortem_trigger,
        blanking_trigger_i => blanking_trigger,
        dsp_events_o => dsp_events,

        interrupts_o => INTR
    );


    -- -------------------------------------------------------------------------
    -- Control register mapping.

    version_data <= (
        SYS_VERSION_PATCH_BITS => to_std_ulogic_vector(VERSION_PATCH, 8),
        SYS_VERSION_MINOR_BITS => to_std_ulogic_vector(VERSION_MINOR, 8),
        SYS_VERSION_MAJOR_BITS => to_std_ulogic_vector(VERSION_MAJOR, 8),
        SYS_VERSION_FIRMWARE_BITS =>
            to_std_ulogic_vector(FIRMWARE_COMPAT_VERSION, 8)
    );

    git_version_data <= (
        SYS_GIT_VERSION_SHA_BITS => to_std_ulogic_vector(GIT_VERSION, 28),
        SYS_GIT_VERSION_DIRTY_BIT => to_std_ulogic(GIT_DIRTY),
        others => '0'
    );

    info_data <= (
        SYS_INFO_ADC_TAPS_BITS     =>
            to_std_ulogic_vector(ADC_FIR_TAP_COUNT, 8),
        SYS_INFO_BUNCH_TAPS_BITS   =>
            to_std_ulogic_vector(BUNCH_FIR_TAP_COUNT, 8),
        SYS_INFO_DAC_TAPS_BITS     =>
            to_std_ulogic_vector(DAC_FIR_TAP_COUNT, 8),
        others => '0'
    );

    status_data <= (
        SYS_STATUS_DSP_OK_BIT       => dsp_clk_ok,
        SYS_STATUS_VCXO_OK_BIT      => fmc500_inputs.vcxo_pwr_good,
        SYS_STATUS_ADC_OK_BIT       => fmc500_inputs.adc_pwr_good,
        SYS_STATUS_DAC_OK_BIT       => fmc500_inputs.dac_pwr_good,
        SYS_STATUS_PLL_LD1_BIT      => fmc500_inputs.pll_status_ld1,
        SYS_STATUS_PLL_LD2_BIT      => fmc500_inputs.pll_status_ld2,
        SYS_STATUS_PLL_SEL0_BIT     => fmc500_inputs.pll_clkin_sel0_in,
        SYS_STATUS_PLL_SEL1_BIT     => fmc500_inputs.pll_clkin_sel1_in,
        SYS_STATUS_DAC_IRQN_BIT     => fmc500_inputs.dac_irqn,
        SYS_STATUS_TEMP_ALERT_BIT   => not fmc500_inputs.temp_alert_n,
        others => '0'
    );

    fmc500_outputs.pll_clkin_sel0_out <= control_data(SYS_CONTROL_PLL_SEL0_BIT);
    fmc500_outputs.pll_clkin_sel1_out <= control_data(SYS_CONTROL_PLL_SEL1_BIT);
    fmc500_outputs.pll_clkin_sel0_ena <=
        control_data(SYS_CONTROL_PLL_SEL0_ENA_BIT);
    fmc500_outputs.pll_clkin_sel1_ena <=
        control_data(SYS_CONTROL_PLL_SEL1_ENA_BIT);
    fmc500_outputs.pll_sync <= control_data(SYS_CONTROL_PLL_SYNC_BIT);
    fmc500_outputs.adc_pdwn <= control_data(SYS_CONTROL_ADC_PDWN_BIT);
    fmc500_outputs.dac_rstn <= not control_data(SYS_CONTROL_DAC_RSTN_BIT);

    -- External events
    event_trigger      <= dio_inputs(0);
    postmortem_trigger <= dio_inputs(1);
    blanking_trigger   <= dio_inputs(2);

    -- FMC0 outputs
    process (control_data, fmc500_inputs, dsp_events) begin
        if control_data(SYS_CONTROL_DIO_SEL_SDCLK_BIT) = '1' then
            dio_output_5 <= fmc500_inputs.pll_sdclkout3;
        else
            dio_output_5 <= dsp_events(1);
        end if;
    end process;
    dio_outputs <= (
        3 => dsp_events(0),
        4 => dio_output_5,      -- Front panel name is 5
        others => '0'
    );
    -- The top two IOs are configured as outputs, we control termination for the
    -- remaining three inputs.
    dio_out_enable <= "11000";
    dio_term_enable <= "00" & control_data(SYS_CONTROL_DIO_TERM_BITS);

end;
