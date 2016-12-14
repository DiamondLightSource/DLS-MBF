library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;

entity testbench is
end testbench;


architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : STD_LOGIC := '0';
    signal dsp_reset_n : STD_LOGIC := '0';



    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;


    subtype CHANNELS is natural range 0 to 1;

    signal awaddr : std_logic_vector(26 downto 0);
    signal awprot : std_logic_vector(2 downto 0);
    signal awready : std_logic;
    signal awvalid : std_logic;
    signal bready : std_logic;
    signal bresp : std_logic_vector(1 downto 0);
    signal bvalid : std_logic;
    signal wdata : std_logic_vector(63 downto 0);
    signal wready : std_logic;
    signal wstrb : std_logic_vector(7 downto 0);
    signal wvalid : std_logic;

    signal address : unsigned(23 downto 0);
    signal data : std_logic_vector(63 downto 0);
    signal data_valid : std_logic;
    signal data_ready : std_logic;
    signal brsp_error : std_logic;

    signal dsp_strobe : std_logic_vector(CHANNELS);
    signal dsp_address : unsigned_array(CHANNELS)(22 downto 0);
    signal dsp_data : vector_array(CHANNELS)(63 downto 0);
    signal dsp_error : std_logic_vector(CHANNELS);

    -- Data receiver support

    -- This procedure handles the receive handshake after a delay
    procedure receiver(
        signal delay : in natural;
        signal ready : out std_logic; signal valid : in std_logic) is
        variable is_valid : boolean;
    begin
        ready <= '0';
        loop
            tick_wait(delay);
            ready <= '1';
            loop
                is_valid := valid = '1';
                tick_wait;
                exit when is_valid;
            end loop;
            ready <= '0';
        end loop;
    end;

    -- Intrinsic data delays for receiver
    signal awdelay : natural := 0;
    signal wdelay : natural := 0;

begin

    dsp_reset_n <= '1' after 10 ns;
    dsp_clk <= not dsp_clk after 2 ns;


    axi_lite_master_inst : entity work.axi_lite_master port map (
        clk_i => dsp_clk,
        rstn_i => dsp_reset_n,

        awaddr_o => awaddr,
        awprot_o => awprot,
        awready_i => awready,
        awvalid_o => awvalid,
        bready_o => bready,
        bresp_i => bresp,
        bvalid_i => bvalid,
        wdata_o => wdata,
        wready_i => wready,
        wstrb_o => wstrb,
        wvalid_o => wvalid,

        address_i => address,
        data_i => data,
        data_valid_i => data_valid,
        data_ready_o => data_ready,
        brsp_error_o => brsp_error
    );

    slow_inst : entity work.slow_memory_top generic map (
        FIFO_BITS => 2
    ) port map (
        dsp_clk_i => dsp_clk,

        dsp_strobe_i => dsp_strobe,
        dsp_address_i => dsp_address,
        dsp_data_i => dsp_data,
        dsp_error_o => dsp_error,

        dram1_address_o => address,
        dram1_data_o => data,
        dram1_data_valid_o => data_valid,
        dram1_data_ready_i => data_ready
    );


    -- Writing to buffer
    process
        procedure step(c : natural) is
        begin
            dsp_address(c) <= dsp_address(c) + 1;
            dsp_data(c) <= std_logic_vector(unsigned(dsp_data(c)) + 1);
        end;

    begin
        dsp_strobe <= (others => '0');
        tick_wait(5);

        -- Start with four back to back writes on both channels.  This will fill
        -- both FIFOs
        dsp_address <= (others => (others => '0'));
        dsp_data <= (X"0123456789ABCDEF", X"FEDCBA9876543210");
        dsp_strobe <= (others => '1');
        for n in 0 to 4 loop
            tick_wait;
            for c in CHANNELS loop
                step(c);
            end loop;
        end loop;
        dsp_strobe <= (others => '0');

        tick_wait(20);
        step(0);
        dsp_strobe <= (0 => '1', others => '0');
        tick_wait;
        dsp_strobe <= (others => '0');
        wait;
    end process;


    -- Receiver endpoing
    receiver(awdelay, awready, awvalid);
    receiver(wdelay, wready, wvalid);

    process begin
        awdelay <= 0;
        wdelay <= 0;
        tick_wait(20);
        awdelay <= 5;
        wait;
    end process;


    bresp <= "00";
    bvalid <= '0';
end;
