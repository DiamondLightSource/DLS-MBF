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
    signal dsp_clk : std_logic;
    signal dsp_reset_n : std_logic;
    signal dram_ref_clk : std_logic;
    signal dram_ref_rst_n : std_logic;

    signal n_coldrst_in : std_logic;
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

    -- Some register file assignments
    constant MOD_DDR0_GEN : natural := 0;
    constant MOD_DIO : natural := 1;
    constant MOD_FMC500 : natural := 2;
    constant MOD_DEBUG : natural := MOD_ADDR_COUNT-1;
    -- Assign the remaining space to random r/w registers for now
    subtype RW_REGISTERS is natural range 3 to MOD_ADDR_COUNT-2;

    -- Register file and debug
    type reg_file_array_t is
        array(RW_REGISTERS) of reg_data_array_t(REG_ADDR_RANGE);
    signal register_file : reg_file_array_t;
    signal debug_enable : std_logic;
    signal debug_trigger : std_logic;
    signal debug_capture : std_logic_vector(63 downto 0);

    -- Digitial IO inputs
    signal dio_inputs : std_logic_vector(4 downto 0);
    signal dio_outputs : std_logic_vector(4 downto 0);
    signal dio_leds : std_logic_vector(1 downto 0);
    signal pll_dclkout2 : std_logic;
    signal pll_sdclkout3 : std_logic;
    signal pll_status_ld1 : std_logic;
    signal pll_status_ld2 : std_logic;

begin
    -- Reset in.
    ncoldrst_inst : entity work.ibuf_array port map (
        i_i(0) => nCOLDRST,
        o_o(0) => n_coldrst_in
    );

    -- Reference clock for MGT.  For this one we don't want the BUFG.
    fclka_inst : entity work.gte2_ibufds generic map (
        GEN_BUFG => false
    ) port map (
        clk_p_i => FCLKA_P,
        clk_n_i => FCLKA_N,
        clk_o => fclka
    );

    -- Dummy DSP 250 MHz clock
    dsp_clock_inst : entity work.dsp_clock port map (
        CLK125MHZ0_P => CLK125MHZ0_P,
        CLK125MHZ0_N => CLK125MHZ0_N,
        nCOLDRST => n_coldrst_in,
        dsp_clk_o => dsp_clk,
        dsp_rst_n_o => dsp_reset_n,
        dram_ref_clk_o => dram_ref_clk,
        dram_ref_rst_n_o => dram_ref_rst_n
    );


    -- Wire up the interconnect
    interconnect_inst : entity work.interconnect_wrapper port map (
        nCOLDRST => n_coldrst_in,

        -- Interrupt interface
        INTR => INTR,

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
        CLK200MHZ => dram_ref_clk,
        CLK200MHZ_RSTN => dram_ref_rst_n,

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


    -- Register AXI slave interface
    axi_lite_slave_inst : entity work.axi_lite_slave port map (
        clk_i => dsp_clk,
        rstn_i => dsp_reset_n,

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

    -- Pattern generator for burst generator
    memory_generator_inst : entity work.memory_generator port map (
        clk_i => dsp_clk,

        write_strobe_i => REGS_write_strobe(MOD_DDR0_GEN),
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,

        read_strobe_i => REGS_read_strobe(MOD_DDR0_GEN),
        read_address_i => REGS_read_address,
        read_data_o => REGS_read_data(MOD_DDR0_GEN),
        read_ack_o => REGS_read_ack(MOD_DDR0_GEN),

        capture_enable_o => DSP_DDR0_capture_enable,
        data_ready_i => DSP_DDR0_data_ready,
        data_o => DSP_DDR0_data,
        data_valid_o => DSP_DDR0_data_valid,
        data_error_i => DSP_DDR0_data_error,
        addr_error_i => DSP_DDR0_addr_error,
        brsp_error_i => DSP_DDR0_brsp_error
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
        clk_i => dsp_clk,

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

        pll_dclkout2_o => pll_dclkout2,
        pll_sdclkout3_o => pll_sdclkout3,
        pll_status_ld1_o => pll_status_ld1,
        pll_status_ld2_o => pll_status_ld2,

        debug_enable_o => debug_enable,
        debug_trigger_o => debug_trigger,
        debug_capture_o => debug_capture
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


    -- General purpose r/w registers filling all but one module
    gen_register_file : for n in RW_REGISTERS generate
        register_file_inst : entity work.register_file port map (
            clk_i => dsp_clk,

            write_strobe_i => REGS_write_strobe(n),
            write_address_i => REGS_write_address,
            write_data_i => REGS_write_data,
            write_ack_o => REGS_write_ack(n),

            register_data_o => register_file(n)
        );
        register_read_inst : entity work.register_read port map (
            clk_i => dsp_clk,

            read_strobe_i => REGS_read_strobe(n),
            read_address_i => REGS_read_address,
            read_data_o => REGS_read_data(n),
            read_ack_o => REGS_read_ack(n),

            register_data_i => register_file(n)
        );
    end generate;


    -- Debug for capturing reads.
    debug_inst : entity work.debug generic map (
        WIDTH => 64,
        DEPTH => 1024
    ) port map (
        clk_i => dsp_clk,

        capture_i => debug_capture,
        enable_i  => debug_enable,
        trigger_i => debug_trigger,

        write_strobe_i => REGS_write_strobe(MOD_DEBUG),
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,

        read_strobe_i => REGS_read_strobe(MOD_DEBUG),
        read_address_i => REGS_read_address,
        read_data_o => REGS_read_data(MOD_DEBUG),
        read_ack_o => REGS_read_ack(MOD_DEBUG)
    );

    uled_out <= register_file(3)(0)(3 downto 0);
    uled_inst : entity work.obuf_array generic map (
        COUNT => 4
    ) port map (
        i_i => uled_out,
        o_o => ULED
    );

    INTR(0) <= DSP_DDR0_capture_enable;
    INTR(1) <= not DSP_DDR0_capture_enable;
    INTR(7 downto 2) <= register_file(3)(1)(7 downto 2);

end;
