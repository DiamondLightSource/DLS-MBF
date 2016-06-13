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
    signal clk100mhz : std_logic;
    signal dsp_clk : std_logic;
    signal dsp_reset_n : std_logic;

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

    -- Internal register path
    signal REGS_read_strobe : mod_strobe_t;
    signal REGS_read_address : reg_addr_t;
    signal REGS_read_data : reg_data_array_t(MOD_ADDR_RANGE);
    signal REGS_read_ack : mod_strobe_t;
    signal REGS_write_strobe : mod_strobe_t;
    signal REGS_write_address : reg_addr_t;
    signal REGS_write_data : reg_data_t;

    -- Register file and debug
    type reg_file_array_t is
        array(MOD_ADDR_RANGE) of reg_data_array_t(REG_ADDR_RANGE);
    signal register_file : reg_file_array_t;
    signal counter : unsigned(15 downto 0);
    signal debug_trigger : std_logic;

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


    -- Register AXI slave interface
    register_axi_slave_inst : entity work.register_axi_slave port map (
        rstn_i => dsp_reset_n,
        clk_i => dsp_clk,

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
        write_data_o => REGS_write_data
    );


    -- General purpose r/w registers filling all but one module
    gen_register_file : for n in 0 to MOD_ADDR_COUNT-2 generate
        register_file_inst : entity work.register_file port map (
            clk_i => dsp_clk,

            write_strobe_i => REGS_write_strobe(n),
            write_address_i => REGS_write_address,
            write_data_i => REGS_write_data,

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
    debug_trigger <= DSP_REGS_arvalid;
    debug_inst : entity work.debug generic map (
        WIDTH => 128,
        DEPTH => 1024
    ) port map (
        clk_i => dsp_clk,

        capture_i(15 downto 0) => REGS_read_ack,
        capture_i(31 downto 16) => DSP_REGS_araddr,
        capture_i(63 downto 32) => DSP_REGS_rdata,
        capture_i(95 downto 64) => REGS_read_data(0),
        capture_i(111 downto 96) => REGS_read_strobe,
        capture_i(116 downto 112) => std_logic_vector(REGS_read_address),
        capture_i(121 downto 117) => (others => '0'),
        capture_i(122) => DSP_REGS_arready,
        capture_i(123) => DSP_REGS_arvalid,
        capture_i(124) => DSP_REGS_rready,
        capture_i(125) => DSP_REGS_rvalid,
        capture_i(126) => '0',
        capture_i(127) => '0',
        enable_i => '1',
        trigger_i => debug_trigger,

        write_strobe_i => REGS_write_strobe(MOD_ADDR_COUNT-1),
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,

        read_strobe_i => REGS_read_strobe(MOD_ADDR_COUNT-1),
        read_address_i => REGS_read_address,
        read_data_o => REGS_read_data(MOD_ADDR_COUNT-1),
        read_ack_o => REGS_read_ack(MOD_ADDR_COUNT-1)
    );
    process (dsp_clk) begin
        if rising_edge(dsp_clk) then
            counter <= counter + 1;
        end if;
    end process;

    ULED <= register_file(0)(0)(3 downto 0);

end;
