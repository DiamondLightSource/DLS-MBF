library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity interconnect_tb is
end interconnect_tb;

library work;
use work.support.all;
use work.defines.all;

architecture arch of interconnect_tb is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal DSP_DDR0_araddr : std_logic_vector(47 downto 0);
    signal DSP_DDR0_arburst : std_logic_vector(1 downto 0);
    signal DSP_DDR0_arcache : std_logic_vector(3 downto 0);
    signal DSP_DDR0_arid : std_logic_vector(3 downto 0);
    signal DSP_DDR0_arlen : std_logic_vector(7 downto 0);
    signal DSP_DDR0_arlock : std_logic_vector(0 to 0);
    signal DSP_DDR0_arprot : std_logic_vector(2 downto 0);
    signal DSP_DDR0_arqos : std_logic_vector(3 downto 0);
    signal DSP_DDR0_arready : std_logic;
    signal DSP_DDR0_arregion : std_logic_vector(3 downto 0);
    signal DSP_DDR0_arsize : std_logic_vector(2 downto 0);
    signal DSP_DDR0_arvalid : std_logic;
    signal DSP_DDR0_awaddr : std_logic_vector(47 downto 0);
    signal DSP_DDR0_awburst : std_logic_vector(1 downto 0);
    signal DSP_DDR0_awcache : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awid : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awlen : std_logic_vector(7 downto 0);
    signal DSP_DDR0_awlock : std_logic_vector(0 to 0);
    signal DSP_DDR0_awprot : std_logic_vector(2 downto 0);
    signal DSP_DDR0_awqos : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awready : std_logic;
    signal DSP_DDR0_awregion : std_logic_vector(3 downto 0);
    signal DSP_DDR0_awsize : std_logic_vector(2 downto 0);
    signal DSP_DDR0_awvalid : std_logic;
    signal DSP_DDR0_bid : std_logic_vector(3 downto 0);
    signal DSP_DDR0_bready : std_logic;
    signal DSP_DDR0_bresp : std_logic_vector(1 downto 0);
    signal DSP_DDR0_bvalid : std_logic;
    signal DSP_DDR0_rdata : std_logic_vector(63 downto 0);
    signal DSP_DDR0_rid : std_logic_vector(3 downto 0);
    signal DSP_DDR0_rlast : std_logic;
    signal DSP_DDR0_rready : std_logic;
    signal DSP_DDR0_rresp : std_logic_vector(1 downto 0);
    signal DSP_DDR0_rvalid : std_logic;
    signal DSP_DDR0_wdata : std_logic_vector(63 downto 0);
    signal DSP_DDR0_wlast : std_logic;
    signal DSP_DDR0_wready : std_logic;
    signal DSP_DDR0_wstrb : std_logic_vector(7 downto 0);
    signal DSP_DDR0_wvalid : std_logic;

    signal adc_clk : std_logic := '0';
    signal dsp_clk : std_logic := '0';
    signal dsp_reset_n : std_logic := '0';

    signal adc_data_a : unsigned(13 downto 0) := (others => '0');
    signal adc_data_b : unsigned(13 downto 0) := (others => '0');

    -- Data from DSP to burst master
    signal DSP_DDR0_capture_enable : std_logic;
    signal DSP_DDR0_data_ready : std_logic;
    signal DSP_DDR0_capture_address : std_logic_vector(30 downto 0);
    signal DSP_DDR0_data : std_logic_vector(63 downto 0);
    signal DSP_DDR0_data_valid : std_logic;
    signal DSP_DDR0_data_error : std_logic;
    signal DSP_DDR0_addr_error : std_logic;
    signal DSP_DDR0_brsp_error : std_logic;

    -- Signals for delaying {w,aw}{valid,ready}
    signal DSP_awready : std_logic;
    signal DSP_awvalid : std_logic;
    signal DSP_wready : std_logic;
    signal DSP_wvalid : std_logic;
    signal wdelay : unsigned(1 downto 0) := "00";


    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;


begin

    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;
    adc_data_a <= adc_data_a + 1 after 2 ns;
    adc_data_b <= adc_data_b + 1 after 2 ns;

    DSP_DDR0_arvalid <= '0';
    DSP_DDR0_rready <= '1';

    interconnect_i: entity work.interconnect port map (
        S_AXI_araddr => DSP_DDR0_araddr,
        S_AXI_arburst => DSP_DDR0_arburst,
        S_AXI_arcache => DSP_DDR0_arcache,
        S_AXI_arid => DSP_DDR0_arid,
        S_AXI_arlen => DSP_DDR0_arlen,
        S_AXI_arlock => DSP_DDR0_arlock,
        S_AXI_arprot => DSP_DDR0_arprot,
        S_AXI_arqos => DSP_DDR0_arqos,
        S_AXI_arready => DSP_DDR0_arready,
        S_AXI_arregion => DSP_DDR0_arregion,
        S_AXI_arsize => DSP_DDR0_arsize,
        S_AXI_arvalid => DSP_DDR0_arvalid,
        S_AXI_awaddr => DSP_DDR0_awaddr,
        S_AXI_awburst => DSP_DDR0_awburst,
        S_AXI_awcache => DSP_DDR0_awcache,
        S_AXI_awid => DSP_DDR0_awid,
        S_AXI_awlen => DSP_DDR0_awlen,
        S_AXI_awlock => DSP_DDR0_awlock,
        S_AXI_awprot => DSP_DDR0_awprot,
        S_AXI_awqos => DSP_DDR0_awqos,
        S_AXI_awready => DSP_DDR0_awready,
        S_AXI_awregion => DSP_DDR0_awregion,
        S_AXI_awsize => DSP_DDR0_awsize,
        S_AXI_awvalid => DSP_DDR0_awvalid,
        S_AXI_bid => DSP_DDR0_bid,
        S_AXI_bready => DSP_DDR0_bready,
        S_AXI_bresp => DSP_DDR0_bresp,
        S_AXI_bvalid => DSP_DDR0_bvalid,
        S_AXI_rdata => DSP_DDR0_rdata,
        S_AXI_rid => DSP_DDR0_rid,
        S_AXI_rlast => DSP_DDR0_rlast,
        S_AXI_rready => DSP_DDR0_rready,
        S_AXI_rresp => DSP_DDR0_rresp,
        S_AXI_rvalid => DSP_DDR0_rvalid,
        S_AXI_wdata => DSP_DDR0_wdata,
        S_AXI_wlast => DSP_DDR0_wlast,
        S_AXI_wready => DSP_DDR0_wready,
        S_AXI_wstrb => DSP_DDR0_wstrb,
        S_AXI_wvalid => DSP_DDR0_wvalid,
        s_axi_aclk => dsp_clk,
        s_axi_aresetn => dsp_reset_n
    );

    -- AXI burst master for streaming data to DDR0 DRAM
    axi_burst_master_inst : entity work.axi_burst_master generic map (
        BURST_LENGTH => 32,
        ADDR_PADDING => X"8000" & '0'
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
        awvalid_o => DSP_awvalid,
        awready_i => DSP_awready,
        wdata_o => DSP_DDR0_wdata,
        wlast_o => DSP_DDR0_wlast,
        wstrb_o => DSP_DDR0_wstrb,
        wvalid_o => DSP_wvalid,
        wready_i => DSP_wready,
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


    DSP_awready <= DSP_DDR0_awready;
    DSP_DDR0_awvalid <= DSP_awvalid;
    DSP_wready <= DSP_DDR0_wready;
    DSP_DDR0_wvalid <= DSP_wvalid;
    DSP_DDR0_data_valid <= '1';

    process (adc_clk)
        function sign_extend(data : unsigned; width : natural)
            return std_logic_vector is
        begin
            return sign_extend(std_logic_vector(data), width);
        end;

    begin
        if rising_edge(adc_clk) then
            if dsp_clk = '0' then
                DSP_DDR0_data(15 downto  0) <= sign_extend(adc_data_a, 16);
                DSP_DDR0_data(31 downto 16) <= sign_extend(adc_data_b, 16);
            else
                DSP_DDR0_data(47 downto 32) <= sign_extend(adc_data_a, 16);
                DSP_DDR0_data(63 downto 48) <= sign_extend(adc_data_b, 16);
            end if;
        end if;
    end process;

    process begin
        -- Start with system reset
        dsp_reset_n <= '0';
        DSP_DDR0_capture_enable <= '0';
        tick_wait(10);
        dsp_reset_n <= '1';
        tick_wait(2);

        -- First burst request
        tick_wait(25);
        DSP_DDR0_capture_enable <= '1';
        tick_wait(90);
        DSP_DDR0_capture_enable <= '0';

        wait;
    end process;

end;
