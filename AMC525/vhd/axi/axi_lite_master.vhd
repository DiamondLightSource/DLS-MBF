-- AXI-Lite master interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity axi_lite_master is
    generic (
        ADDR_PADDING : std_logic_vector := ""
    );
    port (
        clk_i : in std_logic;
        rstn_i : in std_logic;

        -- AXI-Lite write master interface
        awaddr_o : out std_logic_vector;
        awprot_o : out std_logic_vector(2 downto 0);
        awready_i : in std_logic;
        awvalid_o : out std_logic;
        --
        bready_o : out std_logic;
        bresp_i : in std_logic_vector(1 downto 0);
        bvalid_i : in std_logic;
        --
        wdata_o : out std_logic_vector;
        wready_i : in std_logic;
        wstrb_o : out std_logic_vector;
        wvalid_o : out std_logic;

        -- Control interface
        address_i : in unsigned;
        data_i : in std_logic_vector;
        data_valid_i : in std_logic;
        data_ready_o : out std_logic
    );
end;

architecture axi_lite_master of axi_lite_master is
    constant DATA_WIDTH : natural := data_i'LENGTH;
    constant ADDR_WIDTH : natural := address_i'LENGTH;
    constant BASE_BITS : natural := bits(DATA_WIDTH-1);

begin
    -- Sanity check on widths
    assert wdata_o'LENGTH = DATA_WIDTH;
    assert wstrb_o'LENGTH = DATA_WIDTH/8;
    assert awaddr_o'LENGTH = BASE_BITS + ADDR_WIDTH + ADDR_PADDING'length;
    -- Can only have 32 or 64 bit AXI Lite data
    assert DATA_WIDTH = 32 or DATA_WIDTH = 64;

    -- Assemble write address from the real write address, the given padding at
    -- the top, and zero padding for the byte offset at the bottom.
    awaddr_o(BASE_BITS-1 downto 0) <= (others => '0');
    awaddr_o(ADDR_WIDTH+BASE_BITS-1 downto BASE_BITS) <= address_i;
    awaddr_o(awaddr_o'LEFT downto ADDR_WIDTH+BASE_BITS) <= ADDR_PADDING;

    awprot_o <= "010";                  -- Unprivileged non-secure data access
    wstrb_o <= (others => '1');         -- Always write all bytes

    process (clk_i, rstn_i) begin
        if rstn_i = '0' then
        elsif rising_edge(clk_i) then
        end if;
    end process;
end;
