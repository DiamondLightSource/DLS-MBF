-- AXI stream to burst.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity axi_burst_master is
    generic (
        DATA_WIDTH : natural := 64;
        RAM_ADDR_WIDTH : natural := 31;
        BURST_LENGTH : natural := 32
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
        wdata_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
            := (others => '0');
        wlast_o : out std_logic := '0';
        wstrb_o : out std_logic_vector(DATA_WIDTH/8-1 downto 0)
            := (others => '0');
        wvalid_o : out std_logic;
        wready_i : in std_logic;
        --
        bresp_i : in std_logic_vector(1 downto 0);
        bvalid_i : in std_logic;
        bready_o : out std_logic;

        -- Control interface.
        -- If capture_enable_i is held high then eventually data_ready_o will
        -- go high, after which data will be processed until capture_enable_i
        -- goes low, at which point data_ready_o will go low.
        capture_enable_i : in std_logic;
        data_ready_o : out std_logic;
        -- This is the address of the currently written data word.
        capture_address_o : out std_logic_vector(RAM_ADDR_WIDTH-1 downto 0)
            := (others => '0');

        -- Data to be written.  If data_ready_o is not set then data_strobe_i
        -- will be ignored and any data write will be lost.
        data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid_i : in std_logic;

        -- Error detection flags.  These need to be latched externally as
        -- they're only set transiently.
        data_error_o : out std_logic := '0';   -- Data lost via wready_i
        addr_error_o : out std_logic := '0';   -- Should never happen
        brsp_error_o : out std_logic := '0'    -- Non zero bresp received
    );
end;

architecture axi_burst_master of axi_burst_master is
    constant DATA_ADDR_BITS : natural := bits(DATA_WIDTH/8-1);
    constant BURST_BITS : natural := bits(BURST_LENGTH-1);
    constant BURST_ADDR_BASE : natural := DATA_ADDR_BITS + BURST_BITS;
    constant BURST_ADDR_WIDTH : natural := RAM_ADDR_WIDTH - BURST_ADDR_BASE;

    -- Delay in clocks from first address write to burst start
    constant FIRST_DELAY : natural := 4;

    -- State
    signal write_done : boolean := false;
    signal burst_active : boolean := false;
    signal first_write_done : boolean := false;
    signal first_burst : std_logic := '0';
    signal enable_request : std_logic := '0';
    signal first_write : std_logic := '0';
    signal starting : boolean := false;
    signal next_burst : boolean := false;
    signal data_active : boolean := false;

    -- Address channnel
    signal half_burst : std_logic := '0';
    signal write_address : boolean := false;
    signal burst_address : unsigned(BURST_ADDR_WIDTH-1 downto 0)
        := (others => '0');
    signal awvalid : boolean := false;

    -- Data channel
    signal beat_counter : unsigned(BURST_BITS-1 downto 0)
        := (others => '0');
    signal wlast_early : std_logic;
    signal wlast_early_edge : std_logic := '0';
    signal wvalid : boolean := false;
    signal wlast : boolean := false;

begin
    -- Sanity check on parameters
    assert DATA_WIDTH = 2**DATA_ADDR_BITS;
    assert BURST_LENGTH = 2**BURST_BITS;


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
    awcache_o <= "0110";                -- Write-through no-allocate caching
    awlock_o <= "0";                    -- No locking required
    awprot_o <= "010";                  -- Unprivileged non-secure data access
    awqos_o <= "0000";                  -- Default QoS
    awregion_o <= "0000";               -- Default region
    -- All bursts are the same configured burst length
    awlen_o <= std_logic_vector(to_unsigned(BURST_LENGTH-1, 8));
    -- Each beat is our full data width in size
    awsize_o <= std_logic_vector(to_unsigned(DATA_ADDR_BITS, 3));

    -- We can always accept a write response
    bready_o <= '1';


    -- The beat counter is directly written into the capture address, and the
    -- bottom bits are permanently zero.
    capture_address_o(BURST_ADDR_BASE-1 downto DATA_ADDR_BITS) <=
        std_logic_vector(beat_counter);
    capture_address_o(DATA_ADDR_BITS-1 downto 0) <= (others => '0');


    -- -------------------------------------------------------------------------
    -- State control

    -- Data transfers must occur as a sequence of back to back bursts of data
    -- writes, with each burst preceded by an address write for that burst.
    -- Once a data write has occurred, we're committed to completing the
    -- associated data burst.  Also, to avoid data bubbles (periods when
    -- wready_i is low), it is necessary for the address to be several ticks
    -- earlier than the start of the burst.
    --
    -- The first address (and subsequent burst) is generated in response to
    -- capture_enable_i high when the controller is idle, and subsequent
    -- addressesses are generated half way through the preceding burst, if
    -- capture_enable_i is still high.

    -- Initial startup timing:
    --                  _______________________
    --  enable      ___/
    --                  __
    --  first write ___/  \____________________
    --  controller         ____________________
    --  active      ______/
    --                     ____
    --  awvalid     ______/    \_______________
    --                    | first
    --                      delay --->|__
    --  first burst __________________/  \_____
    --                                    _____
    --  burst active ____________________/

    -- Generation of delay from first write to first burst.
    first_write_done <= write_done and not burst_active;
    first_delay_inst : entity work.dlyline generic map (
        DLY => FIRST_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => to_std_logic(first_write_done),
        data_o(0) => first_burst);

    -- Use rising edge of capture_enable_i and inactivity to generate start.
    enable_request <= to_std_logic(
        capture_enable_i = '1' and not burst_active and not starting);
    first_write_inst : entity work.edge_detect port map (
        clk_i => clk_i,
        data_i => enable_request,
        edge_o => first_write);

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Stay in starting state until we start writing bursts.
            if first_write = '1' then
                starting <= true;
            elsif burst_active then
                starting <= false;
            end if;

            -- When a write completes during a burst we need to latch this until
            -- the next burst is ready.
            if write_done and burst_active then
                next_burst <= true;
            elsif wlast_early_edge = '1' then
                next_burst <= false;
            end if;

            -- Enable burst engine on completion of the first burst and each
            -- time we have to generate a next burst.
            if first_burst = '1' then
                burst_active <= true;
            elsif wlast_early_edge = '1' then
                burst_active <= next_burst;
            end if;

            -- Enable data as soon as we're about to start our first burst, and
            -- disable it when we're disabled or when we stop bursting.
            if first_burst = '1' then
                data_active <= true;
            elsif capture_enable_i = '0' or not burst_active then
                data_active <= false;
            end if;
        end if;
    end process;

    data_ready_o <= to_std_logic(data_active);


    -- -------------------------------------------------------------------------
    -- AXI Address channel

    -- Inputs:
    --  first_write:    Set in response to enable request when idle
    --  half_burst:     Generated half way through a burst
    -- Outputs:
    --  write_done:     Used to enable subsequent burst.

    -- Generate write on startup or half way through each burst, so long as
    -- we're still actively taking data.
    write_address <= first_write = '1' or (data_active and half_burst = '1');

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            awvalid <= false;
        elsif rising_edge(clk_i) then
            -- Start a write when asked if we can.
            if write_address and not awvalid then
                awvalid <= true;
            elsif awready_i = '1' then
                awvalid <= false;
            end if;

            -- Manage burst address.
            if first_write = '1' then
                burst_address <= (others => '0');
            elsif half_burst = '1' then
                burst_address <= burst_address + 1;
            end if;

            -- One clock pulse when write successful.  This will trigger the
            -- required burst.
            write_done <= awvalid and awready_i = '1';

            -- Detect an address error if we're still waiting to get rid of the
            -- last address when starting a new one
            addr_error_o <= to_std_logic(write_address and awvalid);

            -- Update the capture address when starting a new burst
            if wlast and wvalid and wready_i = '1' then
                capture_address_o(RAM_ADDR_WIDTH-1 downto BURST_ADDR_BASE) <=
                    std_logic_vector(burst_address);
            end if;
        end if;
    end process;

    awvalid_o <= to_std_logic(awvalid);


    -- -------------------------------------------------------------------------
    -- AXI Data channel burst generator

    -- Inputs:
    --  burst_active:   Must remain valid for duration of entire burst
    --  data_active:    If not set then dummy writes are generated
    -- Outputs:
    --  wlast_early:    Signal to update burst_active

    -- The next beat will be the last one.  This flag is required for updating
    -- burst_active, which must only be updated during the last beat.
    wlast_early <= to_std_logic(
        beat_counter = BURST_LENGTH - 2 and wready_i = '1');
    wlast_early_inst : entity work.edge_detect port map (
        clk_i => clk_i,
        data_i => wlast_early,
        edge_o => wlast_early_edge);

    process (rstn_i, clk_i) begin
        if rstn_i = '0' then
            wvalid <= false;
            wlast <= false;
            beat_counter <= (others => '0');
        elsif rising_edge(clk_i) then

            if burst_active then
                -- During each burst generate data
                if data_active then
                    if data_valid_i = '1' then
                        wdata_o <= data_i;
                        wstrb_o <= (others => '1');
                    end if;
                else
                    -- Once data_active has gone false we need to generate
                    -- empty beats until our burst is complete.
                    wstrb_o <= (others => '0');
                end if;
            end if;

            -- The wvalid bit is set when we're writing data, otherwise
            -- reset on an acknowledged write.
            if burst_active and (data_valid_i = '1' or not data_active) then
                wvalid <= true;
            elsif wready_i = '1' then
                wvalid <= false;
            end if;

            -- Count each completed beat
            if wvalid and wready_i = '1' then
                beat_counter <= beat_counter + 1;
                wlast <= wlast_early = '1';
            end if;

            -- Detect a data write error if we've got data incoming and we've
            -- not managed to get rid of the last write.
            data_error_o <= to_std_logic(
                burst_active and data_active and data_valid_i = '1' and
                wvalid and wready_i = '0');

            -- Detect write response error if response is not all zeros
            brsp_error_o <= to_std_logic(bvalid_i = '1' and bresp_i /= "00");
        end if;
    end process;

    -- Generate a single pulse half way through the burst to trigger the next
    -- address.
    half_burst_inst : entity work.edge_detect port map (
        clk_i => clk_i,
        data_i => beat_counter(BURST_BITS-1),
        edge_o => half_burst);

    wvalid_o <= to_std_logic(wvalid);
    wlast_o <= to_std_logic(wlast);

end;
