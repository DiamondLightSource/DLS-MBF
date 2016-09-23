library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.defines.all;

architecture top of top is
    -- Clocking and reset resources
    signal fclka : std_logic;
    signal n_coldrst_in : std_logic;
    signal clk125mhz : std_logic;
    signal adc_clk : std_logic;
    signal dsp_clk : std_logic;
    signal dsp_clk_ok : std_logic;
    signal ref_clk : std_logic;
    signal ref_clk_ok : std_logic;
    signal reg_clk : std_logic;
    signal reg_clk_ok : std_logic;

    signal uled_out : std_logic_vector(3 downto 0);

    signal INTR : std_logic_vector(7 downto 0);

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

    -- Internal register path
    signal REGS_read_strobe : mod_strobe_t;
    signal REGS_read_address : reg_addr_t;
    signal REGS_read_data : reg_data_array_t(MOD_ADDR_RANGE);
    signal REGS_read_ack : mod_strobe_t;
    signal REGS_write_strobe : mod_strobe_t;
    signal REGS_write_address : reg_addr_t;
    signal REGS_write_data : reg_data_t;
    signal REGS_write_ack : mod_strobe_t;

    -- Clock converted fields for DDR0_GEN
    signal DDR0_GEN_write_strobe : std_logic;
    signal DDR0_GEN_write_ack : std_logic;
    signal DDR0_GEN_read_strobe : std_logic;
    signal DDR0_GEN_read_data : reg_data_t;
    signal DDR0_GEN_read_ack : std_logic;

    -- Some register file assignments
    constant MOD_DDR0_GEN : natural := 0;
    constant MOD_DIO : natural := 1;
    constant MOD_FMC500 : natural := 2;
    -- Assign the remaining space to random r/w registers for now
    subtype RW_REGISTERS is natural range 3 to MOD_ADDR_COUNT-1;

    -- Register file
    type reg_file_array_t is
        array(RW_REGISTERS) of reg_data_array_t(REG_ADDR_RANGE);
    signal register_file : reg_file_array_t;

    -- Digitial IO inputs
    signal dio_inputs : std_logic_vector(4 downto 0);
    signal dio_outputs : std_logic_vector(4 downto 0);
    signal dio_leds : std_logic_vector(1 downto 0);
    signal pll_dclkout2 : std_logic;
    signal pll_sdclkout3 : std_logic;
    signal pll_status_ld1 : std_logic;
    signal pll_status_ld2 : std_logic;

    -- ADC data
    signal adc_data_a : std_logic_vector(13 downto 0);
    signal adc_data_b : std_logic_vector(13 downto 0);

begin
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

    -- 200 MHz timing reference clock
    clocking_inst : entity work.ref_clock port map (
        clk125mhz_i => clk125mhz,
        nCOLDRST => n_coldrst_in,
        ref_clk_o => ref_clk,
        ref_clk_ok_o => ref_clk_ok,
        reg_clk_o => reg_clk,
        reg_clk_ok_o => reg_clk_ok
    );


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
        DSP_RESETN => dsp_clk_ok
    );


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
        rstn_i => dsp_clk_ok,

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

--     -- Pattern generator for burst generator
--     memory_generator_inst : entity work.memory_generator port map (
--         clk_i => dsp_clk,
-- 
--         write_strobe_i => DDR0_GEN_write_strobe,
--         write_address_i => REGS_write_address,
--         write_data_i => REGS_write_data,
--         write_ack_o => DDR0_GEN_write_ack,
-- 
--         read_strobe_i => DDR0_GEN_read_strobe,
--         read_address_i => REGS_read_address,
--         read_data_o => DDR0_GEN_read_data,
--         read_ack_o => DDR0_GEN_read_ack,
-- 
--         capture_enable_o => DSP_DDR0_capture_enable,
--         data_ready_i => DSP_DDR0_data_ready,
--         data_o => DSP_DDR0_data,
--         data_valid_o => DSP_DDR0_data_valid,
--         data_error_i => DSP_DDR0_data_error,
--         addr_error_i => DSP_DDR0_addr_error,
--         brsp_error_i => DSP_DDR0_brsp_error
--     );

    -- ADC to DRAM capture
    adc_capture_inst : entity work.adc_dram_capture port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

        write_strobe_i => DDR0_GEN_write_strobe,
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,
        write_ack_o => DDR0_GEN_write_ack,
        read_strobe_i => DDR0_GEN_read_strobe,
        read_address_i => REGS_read_address,
        read_data_o => DDR0_GEN_read_data,
        read_ack_o => DDR0_GEN_read_ack,

        adc_data_a_i => adc_data_a,
        adc_data_b_i => adc_data_b,

        capture_enable_o => DSP_DDR0_capture_enable,
        data_ready_i => DSP_DDR0_data_ready,
        data_o => DSP_DDR0_data,
        data_valid_o => DSP_DDR0_data_valid,
        capture_address_i => DSP_DDR0_capture_address,
        data_error_i => DSP_DDR0_data_error,
        addr_error_i => DSP_DDR0_addr_error,
        brsp_error_i => DSP_DDR0_brsp_error
    );

    -- Clock converter between burst generator and AXI
    memory_generatory_cc_inst : entity work.register_cc port map (
        axi_clk_i => reg_clk,
        dsp_clk_i => dsp_clk,
        dsp_rst_n_i => dsp_clk_ok,

        axi_write_strobe_i => REGS_write_strobe(MOD_DDR0_GEN),
        axi_write_ack_o => REGS_write_ack(MOD_DDR0_GEN),
        dsp_write_strobe_o => DDR0_GEN_write_strobe,
        dsp_write_ack_i => DDR0_GEN_write_ack,

        axi_read_strobe_i => REGS_read_strobe(MOD_DDR0_GEN),
        axi_read_data_o => REGS_read_data(MOD_DDR0_GEN),
        axi_read_ack_o => REGS_read_ack(MOD_DDR0_GEN),
        dsp_read_strobe_o => DDR0_GEN_read_strobe,
        dsp_read_data_i => DDR0_GEN_read_data,
        dsp_read_ack_i => DDR0_GEN_read_ack
    );


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
    REGS_read_data(MOD_DIO)(4 downto 0) <= dio_inputs;
    REGS_read_data(MOD_DIO)(31 downto 5) <= (others => '0');
    REGS_read_ack(MOD_DIO) <= '1';
    dio_outputs(0) <= pll_dclkout2;
    dio_outputs(1) <= pll_sdclkout3;
    dio_outputs(2) <= pll_status_ld1;
    dio_outputs(3) <= pll_status_ld2;
    dio_outputs(4) <= '0';
    dio_leds(0) <= pll_status_ld1;
    dio_leds(1) <= pll_status_ld2;


    -- FMC1 FMC500M ADC/DAC and clock source
    fmc500m_top_inst : entity work.fmc500m_top port map (
        axi_clk_i => reg_clk,
        ref_clk_i => ref_clk,
        ref_clk_ok_i => ref_clk_ok,

        FMC_LA_P => FMC1_LA_P,
        FMC_LA_N => FMC1_LA_N,
        FMC_HB_P => FMC1_HB_P,
        FMC_HB_N => FMC1_HB_N,

        write_strobe_i => REGS_write_strobe(MOD_FMC500),
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,
        write_ack_o => REGS_write_ack(MOD_FMC500),
        read_strobe_i => REGS_read_strobe(MOD_FMC500),
        read_address_i => REGS_read_address,
        read_data_o => REGS_read_data(MOD_FMC500),
        read_ack_o => REGS_read_ack(MOD_FMC500),

        adc_clk_o => adc_clk,
        dsp_clk_o => dsp_clk,
        dsp_clk_ok_o => dsp_clk_ok,
        adc_data_a_o => adc_data_a,
        adc_data_b_o => adc_data_b,

        pll_dclkout2_o => pll_dclkout2,
        pll_sdclkout3_o => pll_sdclkout3,
        pll_status_ld1_o => pll_status_ld1,
        pll_status_ld2_o => pll_status_ld2
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


    -- General purpose r/w registers filling all unused modules
    gen_register_file : for n in RW_REGISTERS generate
        register_file_inst : entity work.register_file port map (
            clk_i => reg_clk,

            write_strobe_i => REGS_write_strobe(n),
            write_address_i => REGS_write_address,
            write_data_i => REGS_write_data,
            write_ack_o => REGS_write_ack(n),

            register_data_o => register_file(n)
        );
        register_read_inst : entity work.register_read port map (
            clk_i => reg_clk,

            read_strobe_i => REGS_read_strobe(n),
            read_address_i => REGS_read_address,
            read_data_o => REGS_read_data(n),
            read_ack_o => REGS_read_ack(n),

            register_data_i => register_file(n)
        );
    end generate;

    -- Front panel LEDs on register 3:0
    uled_out <= register_file(3)(0)(3 downto 0);
    uled_inst : entity work.obuf_array generic map (
        COUNT => 4
    ) port map (
        i_i => uled_out,
        o_o => ULED
    );

    -- Interrupt events on register 3:1 and DDR0 capture
    INTR(0) <= DSP_DDR0_capture_enable;
    INTR(1) <= not DSP_DDR0_capture_enable;
    INTR(7 downto 2) <= register_file(3)(1)(5 downto 0);

end;
