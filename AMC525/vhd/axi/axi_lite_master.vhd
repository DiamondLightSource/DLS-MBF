-- AXI-Lite master interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        data_ready_o : out std_logic;
        brsp_error_o : out std_logic
    );
end;

architecture arch of axi_lite_master is
    constant DATA_WIDTH : natural := data_i'LENGTH;
    constant ADDR_WIDTH : natural := address_i'LENGTH;
    constant BASE_BITS : natural := bits(DATA_WIDTH/8 - 1); -- Byte address

    -- Three address sub-fields.  The top is padded out with the given fixed
    -- address base, and the bottom byte bits are set to zero.
    subtype ADDR_TOP is natural range awaddr_o'LEFT downto ADDR_WIDTH+BASE_BITS;
    subtype ADDR_MID is natural range ADDR_WIDTH+BASE_BITS-1 downto BASE_BITS;
    subtype ADDR_LOW is natural range BASE_BITS-1 downto 0;

    -- State used to track AXI interface
    signal aw_busy : boolean := false;
    signal w_busy : boolean := false;
    signal write_done : boolean;

    type write_state_t is (IDLE, BUSY);
    signal write_state : write_state_t := IDLE;

begin
    -- Sanity check on widths
    assert wdata_o'LENGTH = DATA_WIDTH severity failure;
    assert wstrb_o'LENGTH = DATA_WIDTH/8 severity failure;
    assert awaddr_o'LENGTH = BASE_BITS + ADDR_WIDTH + ADDR_PADDING'length
        severity failure;
    -- Can only have 32 or 64 bit AXI Lite data
    assert DATA_WIDTH = 32 or DATA_WIDTH = 64 severity failure;

    -- Assemble write address from the real write address.
    awaddr_o(ADDR_TOP) <= ADDR_PADDING;
    awaddr_o(ADDR_MID) <= std_logic_vector(address_i);
    awaddr_o(ADDR_LOW) <= (others => '0');

    awprot_o <= "010";                  -- Unprivileged non-secure data access

    bready_o <= '1';                    -- Always ready for bresp

    wstrb_o <= (wstrb_o'RANGE => '1');  -- Always write all bytes
    wdata_o <= data_i;

    process (clk_i, rstn_i) begin
        if rstn_i = '0' then
            write_state <= IDLE;
            aw_busy <= false;
            w_busy <= false;
            write_done <= false;
        elsif rising_edge(clk_i) then
            case write_state is
                when IDLE =>
                    if data_valid_i = '1' then
                        write_state <= BUSY;
                        aw_busy <= true;
                        w_busy <= true;
                    end if;
                    write_done <= false;
                when BUSY =>
                    if awready_i = '1' then
                        aw_busy <= false;
                    end if;
                    if wready_i = '1' then
                        w_busy <= false;
                    end if;

                    write_done <=
                        (not aw_busy or awready_i = '1') and
                        (not w_busy  or wready_i  = '1');
                    if write_done then
                        write_state <= IDLE;
                    end if;
            end case;

            brsp_error_o <= to_std_logic(bvalid_i = '1' and bresp_i /= "00");
        end if;
    end process;

    -- Convert the write state into the appropriate validity outputs
    data_ready_o <= to_std_logic(write_done);
    awvalid_o <= to_std_logic(aw_busy);
    wvalid_o <= to_std_logic(w_busy);
end;
