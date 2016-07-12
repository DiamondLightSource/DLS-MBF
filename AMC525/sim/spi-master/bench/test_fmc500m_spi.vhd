library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_fmc500m_spi is
end test_fmc500m_spi;


use work.support.all;
use work.defines.all;

architecture test_fmc500m_spi of test_fmc500m_spi is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : std_logic := '0';


    -- Register control
    signal write_strobe : std_logic;
    signal write_data : reg_data_t;
    --
    signal read_strobe : std_logic;
    signal read_data : reg_data_t;
    signal read_ack : std_logic;

    -- PLL SPI
    signal pll_spi_csn : std_logic;
    signal pll_spi_sclk : std_logic;
    signal pll_spi_sdi : std_logic;
    signal pll_spi_sdo : std_logic;
    -- ADC SPI
    signal adc_spi_csn : std_logic;
    signal adc_spi_sclk : std_logic;
    signal adc_spi_sdi : std_logic;
    signal adc_spi_sdo : std_logic;
    signal adc_spi_sdio_en : std_logic;
    -- DAC SPI
    signal dac_spi_csn : std_logic;
    signal dac_spi_sclk : std_logic;
    signal dac_spi_sdi : std_logic;
    signal dac_spi_sdo : std_logic;


    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;

begin
    dsp_clk <= not dsp_clk after 2 ns;

    fmc500m_spi_inst : entity work.fmc500m_spi port map (
        clk_i => dsp_clk,

        write_strobe_i => write_strobe,
        write_data_i => write_data,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,

        pll_spi_csn_o => pll_spi_csn,
        pll_spi_sclk_o => pll_spi_sclk,
        pll_spi_sdi_o => pll_spi_sdi,
        pll_spi_sdo_i => pll_spi_sdo,
        adc_spi_csn_o => adc_spi_csn,
        adc_spi_sclk_o => adc_spi_sclk,
        adc_spi_sdio_o => adc_spi_sdi,
        adc_spi_sdio_i => adc_spi_sdo,
        adc_spi_sdio_en_o => adc_spi_sdio_en,
        dac_spi_csn_o => dac_spi_csn,
        dac_spi_sclk_o => dac_spi_sclk,
        dac_spi_sdi_o => dac_spi_sdi,
        dac_spi_sdo_i => dac_spi_sdo
    );

    -- Loop back the SPI inputs and outputs
    pll_spi_sdo <= pll_spi_sdi;
    adc_spi_sdo <= adc_spi_sdi when adc_spi_sdio_en = '1' else 'Z';
    dac_spi_sdo <= dac_spi_sdi;


    process
        procedure spi_write(
            do_read : in boolean;
            device : in natural;
            address : in natural;
            value : in natural) is
        begin
            write_data(31) <= to_std_logic(do_read);
            write_data(30 downto 29) <=
                std_logic_vector(to_unsigned(device, 2));
            write_data(28 downto 23) <= (others => '0');
            write_data(22 downto 8) <=
                std_logic_vector(to_unsigned(address, 15));
            write_data(7 downto 0) <=
                std_logic_vector(to_unsigned(value, 8));

            write_strobe <= '1';
            tick_wait;
            write_strobe <= '0';
        end procedure;

        procedure spi_read is
        begin
            read_strobe <= '1';
            tick_wait;
            read_strobe <= '0';
            while read_ack = '0' loop
                tick_wait;
            end loop;
        end;
    begin

        read_strobe <= '0';
        write_strobe <= '0';
        tick_wait(4);

        spi_write(false, 0, 123, 12);
        tick_wait(2);
        spi_read;

        spi_write(false, 1, 345, 34);
        tick_wait(2);
        spi_read;

        spi_write(false, 2, 67, 56);
        tick_wait(1);
        spi_read;

        spi_write(true, 0, 236, 99);
        tick_wait(2);
        spi_read;

        spi_write(true, 1, 896, 88);
        tick_wait(2);
        spi_read;

        spi_write(true, 2, 1234, 77);
        tick_wait(2);
        spi_read;

        wait;
    end process;


end;
