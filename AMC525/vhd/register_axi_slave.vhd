-- Implements register interface to LMBF system

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity register_axi_slave is
    generic (
        ADDR_BITS : natural := 16;
        DATA_BITS : natural := 32
    );
    port (
        rstn_i : in std_logic;
        clk_i : in std_logic;

        -- AXI-Lite read interface
        araddr_i : in std_logic_vector(ADDR_BITS-1 downto 0);
        arprot_i : in std_logic_vector(2 downto 0);                 -- Ignored
        arvalid_i : in std_logic;
        arready_o : out std_logic;
        --
        rdata_o : out std_logic_vector(DATA_BITS-1 downto 0);
        rresp_o : out std_logic_vector(1 downto 0);
        rvalid_o : out std_logic;
        rready_i : in std_logic;

        -- AXI-Lite write interface
        awaddr_i : in std_logic_vector(ADDR_BITS-1 downto 0);
        awprot_i : in std_logic_vector(2 downto 0);                 -- Ignored
        awvalid_i : in std_logic;
        awready_o : out std_logic;
        --
        wdata_i : in std_logic_vector(DATA_BITS-1 downto 0);
        wstrb_i : in std_logic_vector(DATA_BITS/8-1 downto 0);      -- Ignored
        wvalid_i : in std_logic;
        wready_o : out std_logic;
        --
        bready_i : in std_logic;
        bresp_o : out std_logic_vector(1 downto 0);
        bvalid_o : out std_logic;

        -- Internal read interface
        read_strobe_o : out mod_strobe_t;   -- Read select per module
        read_address_o : out reg_addr_t;    -- Shared read address
        read_data_i : in reg_data_array_t(MOD_ADDR_RANGE);  -- Read data array
        read_ack_i : in mod_strobe_t;       -- Module read ready acknowledge

        -- Internal write interface
        write_strobe_o : out mod_strobe_t;  -- Write select per module
        write_address_o : out reg_addr_t;   -- Shared write address and
        write_data_o : out reg_data_t;      --  data
        write_ack_i : in mod_strobe_t       -- Write acknowledge per module
    );
end;

architecture register_axi_slave of register_axi_slave is

    -- We split the address into four parts:
    --  +----------+---------------+---------------+------+
    --  | Ignored  | Module select | Reg address   | Byte |
    --  +----------+---------------+---------------+------+
    --              MOD_ADDR_BITS   REG_ADDR_BITS   BYTE_BITS
    constant BYTE_BITS : natural := 2;


    -- Decodes an address into a single bit strobe
    function compute_strobe(index : natural) return mod_strobe_t
    is
        variable result : mod_strobe_t := (others => '0');
    begin
        result(index) := '1';
        return result;
    end;

    -- Extracts module address from AXI address
    function module_address(addr : std_logic_vector) return MOD_ADDR_RANGE
    is
    begin
        return to_integer(unsigned(
            read_field(addr, MOD_ADDR_BITS, REG_ADDR_BITS + BYTE_BITS)));
    end;

    -- Reading state
    type read_state_t is (READ_IDLE, READ_START, READ_READING, READ_DONE);
    signal read_state : read_state_t;
    signal read_module_address : MOD_ADDR_RANGE;

    signal read_strobe : mod_strobe_t;
    signal read_ack : std_logic;
    signal read_data : reg_data_t;



    -- The data and address for writes can come separately.
    type write_state_t is (WRITE_IDLE, WRITE_WRITING, WRITE_DONE);
    signal write_state : write_state_t;
    signal waddr_valid : std_logic;
    signal wdata_valid : std_logic;
    signal write_module_address : MOD_ADDR_RANGE;

    signal write_strobe : mod_strobe_t;
    signal write_ack : std_logic;

begin

    -- ------------------------------------------------------------------------
    -- Read interface.
    read_strobe <= compute_strobe(read_module_address);
    read_ack <= read_ack_i(read_module_address);
    read_data <= read_data_i(read_module_address);

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            read_state <= READ_IDLE;
            read_strobe_o <= (others => '0');
        elsif rising_edge(clk_i) then
            case read_state is
                when READ_IDLE =>
                    -- On valid read request latch read address
                    if arvalid_i = '1' then
                        read_module_address <= module_address(araddr_i);
                        read_address_o <=
                            read_field(araddr_i, REG_ADDR_BITS, BYTE_BITS);
                        read_state <= READ_START;
                    end if;
                when READ_START =>
                    -- Now pass read request through to selected module
                    read_strobe_o <= read_strobe;
                    read_state <= READ_READING;
                when READ_READING =>
                    -- Wait for read acknowledge from module
                    if read_ack = '1' then
                        read_strobe_o <= (others => '0');
                        rdata_o <= read_data;
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
    write_strobe <= compute_strobe(write_module_address);
    write_ack <= write_ack_i(write_module_address);

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            write_state <= WRITE_IDLE;
            waddr_valid <= '0';
            wdata_valid <= '0';
        elsif rising_edge(clk_i) then
            -- Wait for valid write address
            if waddr_valid = '0' and awvalid_i = '1' then
                write_address_o <=
                    read_field(awaddr_i, REG_ADDR_BITS, BYTE_BITS);
                write_module_address <= module_address(awaddr_i);
                waddr_valid <= '1';
            end if;
            -- Wait for valid write data
            if wdata_valid = '0' and wvalid_i = '1' then
                write_data_o <= wdata_i;
                wdata_valid <= '1';
            end if;

            case write_state is
                when WRITE_IDLE =>
                    -- Wait for valid read and write data
                    if waddr_valid = '1' and wdata_valid = '1' then
                        write_strobe_o <= write_strobe;
                        write_state <= WRITE_WRITING;
                    end if;
                when WRITE_WRITING =>
                    -- Wait for target module to complete
                    if write_ack = '1' then
                        write_strobe_o <= (others => '0');
                        write_state <= WRITE_DONE;

                        -- At this point we can accept a new write
                        waddr_valid <= '0';
                        wdata_valid <= '0';
                    end if;
                when WRITE_DONE =>
                    -- Wait for master to accept our response
                    if bready_i = '1' then
                        write_state <= WRITE_IDLE;
                    end if;
            end case;
        end if;
    end process;
    awready_o <= not waddr_valid;
    wready_o  <= not wdata_valid;
    bvalid_o  <= to_std_logic(write_state = WRITE_DONE);
    bresp_o <= "00";


end;
