-- Implements register interface to LMBF system

-- This is an AXI-Lite slave which only accepts full 32-bit writes.  The
-- incoming 16-bit address is split into four parts:
--
--  +----------+---------------+---------------+------+
--  | Ignored  | Module select | Reg address   | Byte |
--  +----------+---------------+---------------+------+
--              MOD_ADDR_BITS   REG_ADDR_BITS   BYTE_BITS
--
-- The module select field is used to determine which sub-module receives the
-- associated read or write, and the reg address field is passed through to the
-- sub-module.
--
-- The internal write interface is quite simple: write_strobe_o is pulsed for
-- one clock cycle after the write_address and write_data outputs are valid.
-- The write data and address will be held valid until write_ack_i is high:
--
--  State           | IDLE  | START |WRITING| DONE  |
--                           ________________________
--  write_data_o,   XXXXXXXXX________________________
--  write_address_o
--                                    _______
--  write_strobe_o  _________________/       \_______
--
-- This means that modules can implement a simple one-cycle write interface.
--
-- Inevitably, the read interface is a little more involved, and completion can
-- be stretched by the module using the module specific read_ack signal.  For
-- single cycle reads which don't depend on read_strobe, read_ack can be
-- permanently high as shown here:
--
--  State           | IDLE  | START |READING| DONE  |
--                           ________________________
--  read_address_o  XXXXXXXXX________________________
--                                    _______
--  read_strobe_o   _________________/       \_______
--                                   ________
--  read_data_i     XXXXXXXXXXXXXXXXX________XXXXXXXX
--                  _________________________________
--  read_ack_i                                          (permanently high)
--
-- Alternatively read_ack can be generated some delay after read_strobe if it is
-- necessary to delay the generation of read_data:
--
--  State           | IDLE  | START |READING|READING|READING| DONE  |
--                           ________________________________________
--  read_address_o  XXXXXXXXX________________________________________
--                                    _______
--  read_strobe_o   _________________/       \_______________________
--                                                   ________
--  read_data_i     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX________XXXXXXXX
--                                                    _______
--  read_ack_i      _________________________________/       \_______
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity axi_lite_slave is
    port (
        clk_i : in std_logic;
        rstn_i : in std_logic;

        -- AXI-Lite read interface
        araddr_i : in std_logic_vector;
        arprot_i : in std_logic_vector(2 downto 0);                 -- Ignored
        arready_o : out std_logic;
        arvalid_i : in std_logic;
        --
        rdata_o : out std_logic_vector;
        rresp_o : out std_logic_vector(1 downto 0);
        rready_i : in std_logic;
        rvalid_o : out std_logic;

        -- AXI-Lite write interface
        awaddr_i : in std_logic_vector;
        awprot_i : in std_logic_vector(2 downto 0);                 -- Ignored
        awready_o : out std_logic;
        awvalid_i : in std_logic;
        --
        wdata_i : in std_logic_vector;
        wstrb_i : in std_logic_vector;
        wready_o : out std_logic;
        wvalid_i : in std_logic;
        --
        bresp_o : out std_logic_vector(1 downto 0);
        bready_i : in std_logic;
        bvalid_o : out std_logic;

        -- Internal read interface
        read_strobe_o : out std_logic;          -- Read request strobe
        read_address_o : out unsigned;
        read_data_i : in std_logic_vector;
        read_ack_i : in std_logic;              -- Read data valid acknowledge

        -- Internal write interface
        write_strobe_o : out std_logic;         -- Write request strobe
        write_address_o : out unsigned;
        write_data_o : out std_logic_vector;
        write_ack_i : in std_logic              -- Write complete acknowledge
    );
end;

architecture axi_lite_slave of axi_lite_slave is
    constant BYTE_BITS : natural := bits(wstrb_i'LENGTH-1);
    constant ADDR_WIDTH : natural := read_address_o'LENGTH;

    -- Reading state
    type read_state_t is (READ_IDLE, READ_START, READ_READING, READ_DONE);
    signal read_state : read_state_t;

    -- Writing state
    -- The data and address for writes can come separately.
    type write_state_t is (WRITE_IDLE, WRITE_START, WRITE_WRITING, WRITE_DONE);
    signal write_state : write_state_t;
    signal valid_write : std_logic;


    -- Extracts register address from AXI address
    function register_address(addr : std_logic_vector) return unsigned
    is begin
        return unsigned(read_field(addr, ADDR_WIDTH, BYTE_BITS));
    end;

begin
    assert read_address_o'LENGTH = write_address_o'LENGTH;

    -- ------------------------------------------------------------------------
    -- Read interface.

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            read_state <= READ_IDLE;
            read_strobe_o <= '0';
        elsif rising_edge(clk_i) then
            case read_state is
                when READ_IDLE =>
                    -- On valid read request latch read address
                    if arvalid_i = '1' then
                        read_address_o <= register_address(araddr_i);
                        read_state <= READ_START;
                    end if;
                when READ_START =>
                    -- Now pass read request through to selected module
                    read_strobe_o <= '1';
                    read_state <= READ_READING;
                when READ_READING =>
                    -- Wait for read acknowledge from module
                    read_strobe_o <= '0';
                    if read_ack_i = '1' then
                        rdata_o <= read_data_i;
                        read_state <= READ_DONE;
                    end if;
                when READ_DONE =>
                    -- Waiting for master to acknowledge our data.
                    if rready_i = '1' then
                        read_state <= READ_IDLE;
                    end if;
            end case;
        end if;
    end process;
    arready_o <= to_std_logic(read_state = READ_IDLE);
    rvalid_o  <= to_std_logic(read_state = READ_DONE);
    rresp_o <= "00";


    -- ------------------------------------------------------------------------
    -- Write interface.

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            write_state <= WRITE_IDLE;
        elsif rising_edge(clk_i) then
            case write_state is
                when WRITE_IDLE =>
                    -- Wait for valid read and write data
                    if awvalid_i = '1' and wvalid_i = '1' then
                        write_address_o <= register_address(awaddr_i);
                        write_data_o <= wdata_i;
                        valid_write <= vector_and(wstrb_i);
                        write_state <= WRITE_START;
                    end if;

                when WRITE_START =>
                    if valid_write = '1' then
                        -- Generate write strobe for valid cycle
                        write_strobe_o <= '1';
                        write_state <= WRITE_WRITING;
                    else
                        -- For invalid write go straight to completion
                        write_state <= WRITE_DONE;
                    end if;

                when WRITE_WRITING =>
                    write_strobe_o <= '0';
                    if write_ack_i = '1' then
                        write_state <= WRITE_DONE;
                    end if;

                when WRITE_DONE =>
                    -- Wait for master to accept our response
                    if bready_i = '1' then
                        write_state <= WRITE_IDLE;
                    end if;
            end case;
        end if;
    end process;
    awready_o <= to_std_logic(write_state = WRITE_START);
    wready_o  <= to_std_logic(write_state = WRITE_START);
    bvalid_o  <= to_std_logic(write_state = WRITE_DONE);
    bresp_o <= "00";

end;
