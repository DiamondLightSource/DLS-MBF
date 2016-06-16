-- AXI stream to burst.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity axi_burst_master is
    generic (
        DATA_WIDTH : natural := 64
    );
    port (
        clk_i : in std_logic;
        rstn_i : in std_logic;

        -- AXI write master interface
        awaddr_o : out std_logic_vector(47 downto 0);
        awburst_o : out std_logic_vector(1 downto 0);
        awsize_o : out std_logic_vector(2 downto 0);
        awlen_o : out std_logic_vector(7 downto 0);
        awcache_o : out std_logic_vector(3 downto 0);
        awlock_o : out std_logic_vector(0 downto 0);
        awprot_o : out std_logic_vector(2 downto 0);
        awqos_o : out std_logic_vector(3 downto 0);
        awregion_o : out std_logic_vector(3 downto 0);
        awvalid_o : out std_logic;
        awready_i : in std_logic;
        --
        wdata_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        wlast_o : out std_logic;
        wstrb_o : out std_logic_vector(DATA_WIDTH/8-1 downto 0);
        wvalid_o : out std_logic;
        wready_i : in std_logic;
        --
        bresp_i : in std_logic_vector(1 downto 0);
        bvalid_i : in std_logic;
        bready_o : out std_logic;

        -- Internal register interface
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;
        --
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;

        -- Data to be written
        data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_strobe_i : in std_logic;
        capture_enable_i : in std_logic
    );
end;

architecture axi_burst_master of axi_burst_master is
    constant DATA_ADDR_BITS : natural := bits(DATA_WIDTH/8-1);    -- 64 => 3
    constant BURST_ADDR_BASE : natural := DATA_ADDR_BITS + 8;
    constant RAM_ADDR_WIDTH : natural := 31;            -- 2GB of target DRAM
    constant BURST_ADDR_WIDTH : natural := RAM_ADDR_WIDTH - BURST_ADDR_BASE;

    -- State
    type write_state_t is (IDLE, ACTIVE, BURST_RUNOUT, IDLE_RUNOUT);
    signal write_state : write_state_t;
    signal starting : boolean;

    -- Address channnel
    signal burst_address : unsigned(BURST_ADDR_WIDTH-1 downto 0)
        := (others => '0');
    signal address_select : boolean;
    signal awvalid : boolean;
    signal address_error : boolean;

    -- Data channel
    signal data_strobe : boolean;       -- Qualified write request
    signal wvalid : boolean;            -- Set for valid outgoing write beat
    signal beat_counter : unsigned(7 downto 0); -- 256 beats in each burst
    signal wlast : boolean;             -- Last beat in the burst

    signal data_error : boolean;        -- Set if data has been lost
    signal bresp_error : boolean;       -- Set if non zero bresp

    -- Error counters
    subtype counter_t is unsigned(REG_DATA_WIDTH-1 downto 0);
    signal data_error_count : counter_t;
    signal bresp_error_count : counter_t;
    signal address_error_count : counter_t;

    signal reset_counter_strobe : boolean;
    signal reset_data_error : boolean;
    signal reset_bresp_error : boolean;
    signal reset_address_error : boolean;



begin
    -- The target DRAM is at address location 8000_0000_0000 up to address
    -- offset 8000_0000, and the generated address is assembled from the
    -- incrementing burst address in the appropriate field.
    awaddr_o(47) <= '1';
    awaddr_o(46 downto RAM_ADDR_WIDTH) <= (others => '0');
    awaddr_o(RAM_ADDR_WIDTH-1 downto BURST_ADDR_BASE) <=
        std_logic_vector(burst_address);
    awaddr_o(BURST_ADDR_BASE-1 downto 0) <= (others => '0');

    -- Fixed write address fields
    awburst_o <= "01";                  -- Incrementing address bursts
    awsize_o <= "011";                  -- 64 bits per beat
    awlen_o <= X"FF";                   -- All bursts are 256 beats
    awcache_o <= "0110";                -- Write-through no-allocate caching
    awlock_o <= "0";                    -- No locking required
    awprot_o <= "010";                  -- Unprivileged non-secure data access
    awqos_o <= "0000";                  -- Default QoS
    awregion_o <= "0000";               -- Default region

    -- We can always accept a write response
    bready_o <= '1';


    -- -------------------------------------------------------------------------
    -- State control

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            write_state <= IDLE;
        elsif rising_edge(clk_i) then
            case write_state is
                when IDLE =>
                    if capture_enable_i = '1' then
                        write_state <= ACTIVE;
                    end if;
                when ACTIVE =>
                    if capture_enable_i = '0' then
                        if wlast then
                            -- Lucky!  Can bypass runout phase
                            write_state <= IDLE_RUNOUT;
                        else
                            write_state <= BURST_RUNOUT;
                        end if;
                    end if;
                when BURST_RUNOUT =>
                    -- Need to ensure we complete the last burst when going idle
                    if wlast then
                        write_state <= IDLE_RUNOUT;
                    end if;
                when IDLE_RUNOUT =>
                    -- Before we can accept any new writes need to ensure that
                    -- all our outstanding writes have been accepted.
                    if not awvalid and not wvalid then
                        write_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
    starting <= capture_enable_i = '1' and write_state = IDLE;


    -- -------------------------------------------------------------------------
    -- AXI Address channel

    -- Generate address for first burst and directly after each ongoing burst
    -- has completed.
    address_select <= starting or (wlast and write_state = ACTIVE);
    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            awvalid <= false;
        elsif rising_edge(clk_i) then

            if address_select then
                awvalid <= true;
            elsif awready_i = '1' then
                awvalid <= false;
            end if;

            -- Initialise address for first burst, increment for the rest
            if starting then
                burst_address <= (others => '0');
            elsif wlast and write_state = ACTIVE then
                burst_address <= burst_address + 1;
            end if;

        end if;
    end process;

    awvalid_o <= to_std_logic(awvalid);

    -- Detect an address error if we're still waiting to get rid of the last
    -- address when starting a new one
    address_error <= address_select and awvalid and awready_i = '0';


    -- -------------------------------------------------------------------------
    -- AXI Data channel (and response)

    -- Qualify incoming data strobe by our write active state
    data_strobe <= data_strobe_i = '1' and (starting or write_state = ACTIVE);
    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            wvalid <= false;
            beat_counter <= (others => '0');
        elsif rising_edge(clk_i) then

            -- Latch incoming data if appropriate, or in runout mode we'll
            -- generate empty writes to complete the burst.
            if data_strobe then
                wdata_o <= data_i;
                wstrb_o <= (others => '1');
            elsif write_state = BURST_RUNOUT then
                -- Discard data in runout mode
                wstrb_o <= (others => '0');
            end if;

            -- We have data to write when there's incoming data or when we're in
            -- burst runout mode.
            if data_strobe or write_state = BURST_RUNOUT then
                wvalid <= true;
            elsif wready_i = '1' then
                wvalid <= false;
            end if;

            -- Count each complete beat
            if wvalid and wready_i = '1' then
                beat_counter <= beat_counter + 1;
                wlast <= beat_counter = X"FE";
            end if;

        end if;
    end process;

    wvalid_o <= to_std_logic(wvalid);
    wlast_o <= to_std_logic(wlast);

    -- Detect a data write error if we've got data incoming and we've not
    -- managed to get rid of the last write.
    data_error <= wvalid and wready_i = '0' and data_strobe;

    -- Detect write response error if response is not all zeros
    bresp_error <= bvalid_i = '1' and bresp_i /= "00";


    -- -------------------------------------------------------------------------
    -- Error counters etc

    -- Counter resets by writing to register 0
    reset_counter_strobe <= write_strobe_i = '1' and write_address_i = 0;
    reset_data_error  <= reset_counter_strobe and write_data_i(0) = '1';
    reset_bresp_error <= reset_counter_strobe and write_data_i(1) = '1';
    reset_address_error <= reset_counter_strobe and write_data_i(2) = '1';

    process (clk_i) begin
        if rising_edge(clk_i) then
            if reset_data_error then
                data_error_count <= (others => '0');
            elsif data_error then
                data_error_count <= data_error_count + 1;
            end if;

            if reset_bresp_error then
                bresp_error_count <= (others => '0');
            elsif bresp_error then
                bresp_error_count <= bresp_error_count + 1;
            end if;

            if reset_address_error then
                address_error_count <= (others => '0');
            elsif address_error then
                address_error_count <= address_error_count + 1;
            end if;

            -- Register readouts
            case to_integer(read_address_i) is
                when 0 =>
                    read_data_o <= std_logic_vector(data_error_count);
                when 1 =>
                    read_data_o <= std_logic_vector(bresp_error_count);
                when 2 =>
                    read_data_o <= std_logic_vector(address_error_count);
                when others =>
                    read_data_o <= (others => '0');
            end case;
        end if;
    end process;
    read_ack_o <= '1';

end;
