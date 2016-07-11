-- SPI control for FMC500M

-- Control is through a single register.  When written, the bit fields of the
-- command register are interpreted as follows:
--
--       31 30    29 28 23 22      8 7    0
--  +------+--------+-----+---------+------+
--  | R/W* | Device |   0 | Address | Data |
--  +------+--------+-----+---------+------+
--
-- Every write should be followed by a read, which will block until the
-- addressed SPI device has completed its transation, after which the returned
-- data payload is returned the the bottom bits of the register.
--
-- We run the PLL and ADC SPI core with an SCLK divisor of 3, corresponding to
-- an SPI clock at 250MHz/2^4 = 15.625MHz, limited by the PLL device with a
-- maximum frequency of 20MHz.  The DAC SPI core runs with a divisor of 4 giving
-- an SPI clock of 31.25MHz.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fmc500m_spi is
    port (
        clk_i : in std_logic;

        -- Register control
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        --
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- PLL SPI
        pll_spi_csn_o : out std_logic;
        pll_spi_sclk_o : out std_logic;
        pll_spi_sdi_o : out std_logic;
        pll_spi_sdo_i : in std_logic;
        -- ADC SPI
        adc_spi_csn_o : out std_logic;
        adc_spi_sclk_o : out std_logic;
        adc_spi_sdio_o : out std_logic;
        adc_spi_sdio_i : in std_logic;
        adc_spi_sdio_en_o : out std_logic;
        -- DAC SPI
        dac_spi_csn_o : out std_logic;
        dac_spi_sclk_o : out std_logic;
        dac_spi_sdi_o : out std_logic;
        dac_spi_sdo_i : in std_logic
    );
end;

architecture fmc500m_spi of fmc500m_spi is

    -- Internal SPI signals
    signal spi15_start : std_logic := '0';
    signal spi15_busy : std_logic;
    signal spi15_response : std_logic_vector(7 downto 0);
    signal spi15_csb : std_logic;
    signal spi15_sclk : std_logic;
    signal spi15_mosi : std_logic;
    signal spi15_moen : std_logic;
    signal spi15_miso : std_logic;
    signal spi7_start : std_logic;
    signal spi7_busy : std_logic;
    signal spi7_response : std_logic_vector(7 downto 0);
    signal spi7_csb : std_logic;
    signal spi7_sclk : std_logic;
    signal spi7_mosi : std_logic;
    signal spi7_moen : std_logic;
    signal spi7_miso : std_logic;

    -- Selected SPI target
    type spi_selection_t is (PLL, ADC, DAC);
    signal selection : spi_selection_t;

    -- Decode of input
    signal read_write_n : std_logic;
    signal selection_in : spi_selection_t;
    signal address : std_logic_vector(14 downto 0);
    signal write_data : std_logic_vector(7 downto 0);

    -- Delayed read if necessary.
    signal reading : boolean;

    signal busy : boolean;

    -- Enables for three SPI targets.
    signal pll_cs : boolean;
    signal adc_cs : boolean;
    signal dac_cs : boolean;

begin
    -- Combinatorial decode of incoming request
    read_write_n <= write_data_i(31);
    process (write_data_i) begin
        case to_integer(unsigned(write_data_i(30 downto 29))) is
            when 0 => selection_in <= PLL;
            when 1 => selection_in <= ADC;
            when 2 => selection_in <= DAC;
            when others => selection_in <= DAC;
        end case;
    end process;
    address <= write_data_i(22 downto 8);
    write_data <= write_data_i(7 downto 0);


    -- -------------------------------------------------------------------------
    -- Register control.

    -- Writing is easy.  If we're busy we ignore any write request, otherwise
    -- just latch the request and start the appropriate device.
    process (clk_i) begin
        if rising_edge(clk_i) then
            if not busy and write_strobe_i = '1' then
                selection <= selection_in;
                case selection_in is
                    when PLL | ADC => spi15_start <= '1';
                    when DAC       => spi7_start <= '1';
                end case;
            else
                spi15_start <= '0';
                spi7_start  <= '0';
            end if;
        end if;
    end process;


    -- Reading needs to block while busy.
    process (clk_i) begin
        if rising_edge(clk_i) then
            if busy then
                -- While we're busy any reads will have to be blocked until
                -- we're finished.
                if read_strobe_i = '1' then
                    reading <= true;
                end if;
                read_ack_o <= '0';
            else
                -- No longer busy, so generate read ack as appropriate.
                if reading or read_strobe_i = '1' then
                    read_ack_o <= '1';
                else
                    read_ack_o <= '0';
                end if;
                reading <= false;
            end if;

            case selection is
                when PLL => read_data_o(7 downto 0) <= spi15_response;
                when ADC => read_data_o(7 downto 0) <= spi15_response;
                when DAC => read_data_o(7 downto 0) <= spi7_response;
            end case;
            read_data_o(31 downto 8) <= (others => '0');
        end if;
    end process;



    -- -------------------------------------------------------------------------
    -- SPI Master instances

    -- SPI controller with 15-bit addresses for PLL and ADC
    spi_15_bit : entity work.spi_master generic map (
        LOG_SCLK_DIVISOR => 3,
        ADDRESS_BITS => 15
    ) port map (
        clk_i => clk_i,

        start_i => spi15_start,
        r_wn_i => read_write_n,
        command_i => address,
        data_i => write_data,
        busy_o => spi15_busy,
        response_o => spi15_response,

        csb_o  => spi15_csb,
        sclk_o => spi15_sclk,
        mosi_o => spi15_mosi,
        moen_o => spi15_moen,
        miso_i => spi15_miso
    );

    -- SPI controller with 7-bit addresses for DAC
    spi_7_bit : entity work.spi_master generic map (
        LOG_SCLK_DIVISOR => 2,
        ADDRESS_BITS => 7
    ) port map (
        clk_i => clk_i,

        start_i => spi7_start,
        r_wn_i => read_write_n,
        command_i => address(6 downto 0),
        data_i => write_data,
        busy_o => spi7_busy,
        response_o => spi7_response,

        csb_o  => spi7_csb,
        sclk_o => spi7_sclk,
        mosi_o => spi7_mosi,
        moen_o => spi7_moen,
        miso_i => spi7_miso
    );

    -- Decode of busy state
    busy <= spi7_busy = '1' when selection = DAC else spi15_busy = '1';


    -- -------------------------------------------------------------------------
    -- SPI outputs

    pll_cs <= spi15_csb = '0' and selection = PLL;
    adc_cs <= spi15_csb = '0' and selection = ADC;
    dac_cs <= spi7_csb = '0'  and selection = DAC;

    pll_spi_csn_o <= to_std_logic(not pll_cs);
    adc_spi_csn_o <= to_std_logic(not adc_cs);
    dac_spi_csn_o <= to_std_logic(not dac_cs);

    pll_spi_sclk_o <= spi15_sclk when pll_cs else '0';
    adc_spi_sclk_o <= spi15_sclk when adc_cs else '0';
    dac_spi_sclk_o <= spi7_sclk  when dac_cs else '0';

    -- The IO pins are different for the three devices.  For PLL we need to hold
    -- SDI high during reads, for ADC we have to used a tri-state buffer, and
    -- for DAC we have a simple four wire connection.
    pll_spi_sdi_o <= spi15_mosi when pll_cs and spi15_moen = '1' else '1';
    adc_spi_sdio_o <= spi15_mosi;
    adc_spi_sdio_en_o <= spi15_moen when adc_cs else '0';
    dac_spi_sdi_o <= spi7_mosi when dac_cs else '1';

    spi15_miso <=
        pll_spi_sdo_i  when selection = PLL else
        adc_spi_sdio_i when selection = ADC else 'X';
    spi7_miso <= dac_spi_sdo_i;
end;
