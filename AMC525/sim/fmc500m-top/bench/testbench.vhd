library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


use work.support.all;
use work.defines.all;

architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : STD_LOGIC := '0';



    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;



    signal FMC_LA_P : std_logic_vector(0 to 33);
    signal FMC_LA_N : std_logic_vector(0 to 33);
    signal FMC_HB_P : std_logic_vector(0 to 21);
    signal FMC_HB_N : std_logic_vector(0 to 21);
    signal write_strobe : std_logic;
    signal write_address : reg_addr_t;
    signal write_data : reg_data_t;
    signal read_strobe : std_logic;
    signal read_address : reg_addr_t;
    signal read_data : reg_data_t;
    signal read_ack : std_logic;

    -- Make the SPI signals visible
    signal pll_spi_csn : std_logic;
    signal pll_spi_sclk : std_logic;
    signal pll_spi_sdi : std_logic;
    signal pll_spi_sdo : std_logic;
    signal adc_spi_csn : std_logic;
    signal adc_spi_sclk : std_logic;
    signal adc_spi_sdio : std_logic;
    signal dac_spi_csn : std_logic;
    signal dac_spi_sclk : std_logic;
    signal dac_spi_sdi : std_logic;
    signal dac_spi_sdo : std_logic;

begin

    dsp_clk <= not dsp_clk after 2 ns;

    fmc500m_top_inst : entity work.fmc500m_top port map (
        clk_i => dsp_clk,

        FMC_LA_P => FMC_LA_P,
        FMC_LA_N => FMC_LA_N,
        FMC_HB_P => FMC_HB_P,
        FMC_HB_N => FMC_HB_N,

        write_strobe_i => write_strobe,
        write_address_i => write_address,
        write_data_i => write_data,
        read_strobe_i => read_strobe,
        read_address_i => read_address,
        read_data_o => read_data,
        read_ack_o => read_ack
    );

    -- Loop back the SPI PLL and DAC data lines.
    -- Can't usefully loopback ADC because it's tristate here.
    FMC_LA_N(22) <= FMC_LA_P(22);       -- PLL
    FMC_HB_P(20) <= FMC_HB_N(20);       -- DAC

    -- Loop back the power control lines
    FMC_LA_P(27) <= FMC_LA_P(30);
    FMC_LA_N(26) <= FMC_LA_P(26);
    FMC_LA_N(32) <= FMC_LA_P(32);

    -- Set PLL status bits to known value
    FMC_LA_P(29) <= '0';
    FMC_LA_N(29) <= '0';

    process
        procedure reg_write(address : in natural; value : in reg_data_t) is
        begin
            write_address <= to_unsigned(address, REG_ADDR_BITS);
            write_data <= value;
            tick_wait;
            write_strobe <= '1';
            tick_wait;
            write_strobe <= '0';
            report "reg_write [" & natural'image(address) & "] <= " &
                to_hstring(value);
        end;

        procedure reg_read(address : in natural) is
        begin
            read_address <= to_unsigned(address, REG_ADDR_BITS);
            tick_wait;
            read_strobe <= '1';
            while read_ack = '0' loop
                tick_wait;
                read_strobe <= '0';
            end loop;
            report "reg_read [" & natural'image(address) & "] => " &
                to_hstring(read_data);
            tick_wait;
            read_strobe <= '0';
        end;
    begin
        write_strobe <= '0';
        read_strobe <= '0';

        tick_wait(4);
        reg_write(0, x"80345678");
        reg_read(0);
        reg_write(0, x"A0345678");
        reg_read(0);
        reg_write(0, x"C0000678");
        reg_read(0);
        reg_read(1);
        reg_write(1, x"00000001");
        reg_read(1);
        reg_write(1, x"00000002");
        reg_read(1);
        reg_write(1, x"00000007");
        reg_read(1);

        wait;
    end process;


    -- Make the SPI signals visible
    pll_spi_csn  <= FMC_LA_N(28);
    pll_spi_sclk <= FMC_LA_P(28);
    pll_spi_sdi  <= FMC_LA_P(22);
    pll_spi_sdo  <= FMC_LA_N(22);
    adc_spi_csn  <= FMC_LA_N(10);
    adc_spi_sclk <= FMC_LA_P(10);
    adc_spi_sdio <= FMC_LA_N(6);
    dac_spi_csn  <= FMC_LA_N(33);
    dac_spi_sclk <= FMC_HB_P(4);
    dac_spi_sdi  <= FMC_HB_N(20);
    dac_spi_sdo  <= FMC_HB_P(20);


end testbench;