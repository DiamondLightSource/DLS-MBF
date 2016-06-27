library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity interconnect_tb is
end interconnect_tb;

library work;
use work.defines.all;

architecture STRUCTURE of interconnect_tb is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal DSP_DDR0_araddr     : STD_LOGIC_VECTOR ( 47 downto 0 );
    signal DSP_DDR0_arburst    : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal DSP_DDR0_arcache    : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_arid :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_arlen : STD_LOGIC_VECTOR ( 7 downto 0 );
    signal DSP_DDR0_arlock : STD_LOGIC_VECTOR ( 0 to 0 );
    signal DSP_DDR0_arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal DSP_DDR0_arqos :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_arready :  STD_LOGIC;
    signal DSP_DDR0_arregion : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_arsize :  STD_LOGIC_VECTOR ( 2 downto 0 );
    signal DSP_DDR0_arvalid :  STD_LOGIC;
    signal DSP_DDR0_awaddr :  STD_LOGIC_VECTOR ( 47 downto 0 );
    signal DSP_DDR0_awburst :  STD_LOGIC_VECTOR ( 1 downto 0 );
    signal DSP_DDR0_awcache :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_awid :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_awlen :  STD_LOGIC_VECTOR ( 7 downto 0 );
    signal DSP_DDR0_awlock :  STD_LOGIC_VECTOR ( 0 to 0 );
    signal DSP_DDR0_awprot :  STD_LOGIC_VECTOR ( 2 downto 0 );
    signal DSP_DDR0_awqos :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_awready :  STD_LOGIC;
    signal DSP_DDR0_awregion :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_awsize :  STD_LOGIC_VECTOR ( 2 downto 0 );
    signal DSP_DDR0_awvalid :  STD_LOGIC;
    signal DSP_DDR0_bid :  STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_bready :  STD_LOGIC;
    signal DSP_DDR0_bresp :  STD_LOGIC_VECTOR ( 1 downto 0 );
    signal DSP_DDR0_bvalid :  STD_LOGIC;
    signal DSP_DDR0_rdata : STD_LOGIC_VECTOR ( 63 downto 0 );
    signal DSP_DDR0_rid : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal DSP_DDR0_rlast : STD_LOGIC;
    signal DSP_DDR0_rready : STD_LOGIC;
    signal DSP_DDR0_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal DSP_DDR0_rvalid : STD_LOGIC;
    signal DSP_DDR0_wdata : STD_LOGIC_VECTOR ( 63 downto 0 );
    signal DSP_DDR0_wlast : STD_LOGIC;
    signal DSP_DDR0_wready : STD_LOGIC;
    signal DSP_DDR0_wstrb : STD_LOGIC_VECTOR ( 7 downto 0 );
    signal DSP_DDR0_wvalid : STD_LOGIC;

    signal dsp_clk : STD_LOGIC := '0';
    signal dsp_reset_n : STD_LOGIC := '0';

    -- Data from DSP to burst master
    signal DSP_DDR0_capture_enable : std_logic;
    signal DSP_DDR0_data_ready : std_logic;
    signal DSP_DDR0_capture_address : std_logic_vector(30 downto 0);
    signal DSP_DDR0_data : std_logic_vector(63 downto 0);
    signal DSP_DDR0_data_valid : std_logic;
    signal DSP_DDR0_data_error : std_logic;
    signal DSP_DDR0_addr_error : std_logic;
    signal DSP_DDR0_brsp_error : std_logic;

    signal REGS_write_strobe : std_logic;
    signal REGS_write_address : reg_addr_t;
    signal REGS_write_data : reg_data_t;

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

    procedure write_reg(
        signal address_o : out reg_addr_t;
        signal data_o : out reg_data_t;
        signal strobe_o : out std_logic;
        reg : natural; value : reg_data_t) is
    begin
        address_o <= to_unsigned(reg, 5);
        data_o <= value;
        tick_wait;
        strobe_o <= '1';
        tick_wait;
        strobe_o <= '0';
    end procedure;

begin

    dsp_reset_n <= '1' after 50 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    DSP_DDR0_arvalid <= '0';
    DSP_DDR0_rready <= '1';

    interconnect_i: entity work.interconnect port map (
        S_AXI_araddr(47 downto 0) => DSP_DDR0_araddr(47 downto 0),
        S_AXI_arburst(1 downto 0) => DSP_DDR0_arburst(1 downto 0),
        S_AXI_arcache(3 downto 0) => DSP_DDR0_arcache(3 downto 0),
        S_AXI_arid(3 downto 0) => DSP_DDR0_arid(3 downto 0),
        S_AXI_arlen(7 downto 0) => DSP_DDR0_arlen(7 downto 0),
        S_AXI_arlock(0) => DSP_DDR0_arlock(0),
        S_AXI_arprot(2 downto 0) => DSP_DDR0_arprot(2 downto 0),
        S_AXI_arqos(3 downto 0) => DSP_DDR0_arqos(3 downto 0),
        S_AXI_arready => DSP_DDR0_arready,
        S_AXI_arregion(3 downto 0) => DSP_DDR0_arregion(3 downto 0),
        S_AXI_arsize(2 downto 0) => DSP_DDR0_arsize(2 downto 0),
        S_AXI_arvalid => DSP_DDR0_arvalid,
        S_AXI_awaddr(47 downto 0) => DSP_DDR0_awaddr(47 downto 0),
        S_AXI_awburst(1 downto 0) => DSP_DDR0_awburst(1 downto 0),
        S_AXI_awcache(3 downto 0) => DSP_DDR0_awcache(3 downto 0),
        S_AXI_awid(3 downto 0) => DSP_DDR0_awid(3 downto 0),
        S_AXI_awlen(7 downto 0) => DSP_DDR0_awlen(7 downto 0),
        S_AXI_awlock(0) => DSP_DDR0_awlock(0),
        S_AXI_awprot(2 downto 0) => DSP_DDR0_awprot(2 downto 0),
        S_AXI_awqos(3 downto 0) => DSP_DDR0_awqos(3 downto 0),
        S_AXI_awready => DSP_DDR0_awready,
        S_AXI_awregion(3 downto 0) => DSP_DDR0_awregion(3 downto 0),
        S_AXI_awsize(2 downto 0) => DSP_DDR0_awsize(2 downto 0),
        S_AXI_awvalid => DSP_DDR0_awvalid,
        S_AXI_bid(3 downto 0) => DSP_DDR0_bid(3 downto 0),
        S_AXI_bready => DSP_DDR0_bready,
        S_AXI_bresp(1 downto 0) => DSP_DDR0_bresp(1 downto 0),
        S_AXI_bvalid => DSP_DDR0_bvalid,
        S_AXI_rdata(63 downto 0) => DSP_DDR0_rdata(63 downto 0),
        S_AXI_rid(3 downto 0) => DSP_DDR0_rid(3 downto 0),
        S_AXI_rlast => DSP_DDR0_rlast,
        S_AXI_rready => DSP_DDR0_rready,
        S_AXI_rresp(1 downto 0) => DSP_DDR0_rresp(1 downto 0),
        S_AXI_rvalid => DSP_DDR0_rvalid,
        S_AXI_wdata(63 downto 0) => DSP_DDR0_wdata(63 downto 0),
        S_AXI_wlast => DSP_DDR0_wlast,
        S_AXI_wready => DSP_DDR0_wready,
        S_AXI_wstrb(7 downto 0) => DSP_DDR0_wstrb(7 downto 0),
        S_AXI_wvalid => DSP_DDR0_wvalid,
        s_axi_aclk => dsp_clk,
        s_axi_aresetn => dsp_reset_n
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

    -- Pattern generator for burst generator
    memory_generator_inst : entity work.memory_generator port map (
        clk_i => dsp_clk,

        write_strobe_i => REGS_write_strobe,
        write_address_i => REGS_write_address,
        write_data_i => REGS_write_data,

        read_strobe_i => '0',
        read_address_i => (others => '0'),
        read_data_o => open,
        read_ack_o => open,

        capture_enable_o => DSP_DDR0_capture_enable,
        data_ready_i => DSP_DDR0_data_ready,
        data_o => DSP_DDR0_data,
        data_valid_o => open,

        data_error_i => DSP_DDR0_data_error,
        addr_error_i => DSP_DDR0_addr_error,
        brsp_error_i => DSP_DDR0_brsp_error
    );


    DSP_awready <= DSP_DDR0_awready;
    DSP_DDR0_awvalid <= DSP_awvalid;
    DSP_wready <= DSP_DDR0_wready;
    DSP_DDR0_wvalid <= DSP_wvalid;

--     process (dsp_clk) begin
--         if rising_edge(dsp_clk) then
--             if wdelay > 0 then
--                 wdelay <= wdelay - 1;
--                 if wdelay = 1 then
--                     DSP_DDR0_wvalid <= '1';
--                     DSP_wready <= '1';
--                 end if;
--             else
--                 DSP_DDR0_wvalid <= '0';
--                 DSP_wready <= '0';
--                 if DSP_wvalid = '1' then
--                     wdelay <= "10";
--                 end if;
--             end if;
--         end if;
--     end process;

    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(
                REGS_write_address, REGS_write_data, REGS_write_strobe,
                reg, value);
        end;

    begin
        REGS_write_strobe <= '0';
        tick_wait(25);
        write_reg(4, std_logic_vector(to_unsigned(64, 32)));
        tick_wait(90);
        write_reg(4, std_logic_vector(to_unsigned(15, 32)));

        wait;
    end process;

    process begin
        DSP_DDR0_data_valid <= '1';
        while true loop
            wait;   -- Remove this line for data_valid test
            tick_wait(3);
            DSP_DDR0_data_valid <= not DSP_DDR0_data_valid;
        end loop;
    end process;



end STRUCTURE;
