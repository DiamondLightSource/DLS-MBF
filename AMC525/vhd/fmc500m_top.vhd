-- FMC-500M top level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fmc500m_top is
    port (
        axi_clk_i : in std_logic;

        -- FMC
        FMC_LA_P : inout std_logic_vector(0 to 33);
        FMC_LA_N : inout std_logic_vector(0 to 33);
        FMC_HB_P : inout std_logic_vector(0 to 21);
        FMC_HB_N : inout std_logic_vector(0 to 21);

        -- Register control
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        --
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- Other signals
        pll_dclkout2_o : out std_logic;
        pll_sdclkout3_o : out std_logic;
        pll_status_ld1_o : out std_logic;
        pll_status_ld2_o : out std_logic
    );
end;

architecture fmc500m_top of fmc500m_top is
    -- Signal interfaces to IO.
    -- PLL
    signal pll_spi_csn : std_logic;
    signal pll_spi_sclk : std_logic;
    signal pll_spi_sdi : std_logic;
    signal pll_spi_sdo : std_logic;
    signal pll_status_ld1 : std_logic;
    signal pll_status_ld2 : std_logic;
    signal pll_clkin_sel0 : std_logic;
    signal pll_clkin_sel1 : std_logic;
    signal pll_sync : std_logic;
    signal pll_dclkout2 : std_logic;     -- On CC pin
    signal pll_sdclkout3 : std_logic;

    -- ADC
    signal adc_dco : std_logic;          -- Will be master DSP clock
    signal adc_data : std_logic_vector(13 downto 0);
    signal adc_status : std_logic;
    signal adc_fd_a : std_logic;
    signal adc_fd_b : std_logic;
    signal adc_spi_csn : std_logic;
    signal adc_spi_sclk : std_logic;
    signal adc_spi_sdi : std_logic;
    signal adc_spi_sdo : std_logic;
    signal adc_spi_sdio_en : std_logic;
    signal adc_pdwn : std_logic;

    -- DAC
    signal dac_data : std_logic_vector(15 downto 0);
    signal dac_dci : std_logic;
    signal dac_frame : std_logic;
    signal dac_spi_csn : std_logic;
    signal dac_spi_sclk : std_logic;
    signal dac_spi_sdi : std_logic;
    signal dac_spi_sdo : std_logic;
    signal dac_rstn : std_logic;
    signal dac_irqn : std_logic;

    -- Misc
    signal adc_pwr_en : std_logic;
    signal dac_pwr_en : std_logic;
    signal vcxo_pwr_en : std_logic;
    signal adc_pwr_good : std_logic;
    signal dac_pwr_good : std_logic;
    signal vcxo_pwr_good : std_logic;
    signal ext_trig : std_logic;
    signal temp_alert : std_logic;

    -- Register interface
    signal write_strobes : reg_strobe_t;
    signal read_strobes : reg_strobe_t;
    signal read_acks : reg_strobe_t;
    signal read_data : reg_data_array_t(REG_ADDR_RANGE);

    constant SPI_REG : natural := 0;
    constant PWR_REG : natural := 1;
    constant STA_REG : natural := 2;
    subtype UNUSED_REGS is natural range 3 to REG_ADDR_COUNT-1;

    signal power_control : reg_data_t;
    signal power_status : reg_data_t;

begin
    -- Default values for outputs we're not using yet
    dac_data <= (others => '0');
    dac_dci <= '0';
    dac_frame <= '0';


    -- Wire up the IO
    fmc500m_io_inst : entity work.fmc500m_io port map (
        -- FMC
        FMC_LA_P => FMC_LA_P,
        FMC_LA_N => FMC_LA_N,
        FMC_HB_P => FMC_HB_P,
        FMC_HB_N => FMC_HB_N,

        -- PLL control
        pll_spi_csn_i => pll_spi_csn,
        pll_spi_sclk_i => pll_spi_sclk,
        pll_spi_sdi_i => pll_spi_sdi,
        pll_spi_sdo_o => pll_spi_sdo,
        pll_status_ld1_o => pll_status_ld1,
        pll_status_ld2_o => pll_status_ld2,
        pll_clkin_sel0_i => pll_clkin_sel0,
        pll_clkin_sel1_i => pll_clkin_sel1,
        pll_sync_i => pll_sync,
        pll_dclkout2_o => pll_dclkout2,
        pll_sdclkout3_o => pll_sdclkout3,

        -- ADC
        adc_dco_o => adc_dco,
        adc_data_o => adc_data,
        adc_status_o => adc_status,
        adc_fd_a_o => adc_fd_a,
        adc_fd_b_o => adc_fd_b,
        adc_spi_csn_i => adc_spi_csn,
        adc_spi_sclk_i => adc_spi_sclk,
        adc_spi_sdio_i => adc_spi_sdi,
        adc_spi_sdio_o => adc_spi_sdo,
        adc_spi_sdio_en_i => adc_spi_sdio_en,
        adc_pdwn_i => adc_pdwn,

        -- DAC
        dac_data_i => dac_data,
        dac_dci_i => dac_dci,
        dac_frame_i => dac_frame,
        dac_spi_csn_i => dac_spi_csn,
        dac_spi_sclk_i => dac_spi_sclk,
        dac_spi_sdi_i => dac_spi_sdi,
        dac_spi_sdo_o => dac_spi_sdo,
        dac_rstn_i => dac_rstn,
        dac_irqn_o => dac_irqn,

        -- Miscellaneous
        adc_pwr_en_i => adc_pwr_en,
        dac_pwr_en_i => dac_pwr_en,
        vcxo_pwr_en_i => vcxo_pwr_en,
        adc_pwr_good_o => adc_pwr_good,
        dac_pwr_good_o => dac_pwr_good,
        vcxo_pwr_good_o => vcxo_pwr_good,
        ext_trig_o => ext_trig,
        temp_alert_o => temp_alert
    );


    -- SPI controller
    fmc500m_spi_inst : entity work.fmc500m_spi port map (
        clk_i => axi_clk_i,

        -- Register control
        write_strobe_i => write_strobes(SPI_REG),
        write_data_i => write_data_i,
        read_strobe_i => read_strobes(SPI_REG),
        read_data_o => read_data(SPI_REG),
        read_ack_o => read_acks(SPI_REG),

        -- PLL SPI
        pll_spi_csn_o => pll_spi_csn,
        pll_spi_sclk_o => pll_spi_sclk,
        pll_spi_sdi_o => pll_spi_sdi,
        pll_spi_sdo_i => pll_spi_sdo,
        -- ADC SPI
        adc_spi_csn_o => adc_spi_csn,
        adc_spi_sclk_o => adc_spi_sclk,
        adc_spi_sdio_o => adc_spi_sdi,
        adc_spi_sdio_i => adc_spi_sdo,
        adc_spi_sdio_en_o => adc_spi_sdio_en,
        -- DAC SPI
        dac_spi_csn_o => dac_spi_csn,
        dac_spi_sclk_o => dac_spi_sclk,
        dac_spi_sdi_o => dac_spi_sdi,
        dac_spi_sdo_i => dac_spi_sdo
    );


    -- Top level register control
    register_mux_inst : entity work.register_mux port map (
        write_strobe_i => write_strobe_i,
        write_address_i => write_address_i,
        write_strobe_o => write_strobes,
        write_ack_i => (others => '1'),
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_address_i => read_address_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,
        read_data_i => read_data,
        read_strobe_o => read_strobes,
        read_ack_i => read_acks
    );

    -- Register for custom power etc
    pwr_reg_inst : entity work.single_register port map (
        clk_i => axi_clk_i,
        register_o => power_control,
        write_strobe_i => write_strobes(PWR_REG),
        write_data_i => write_data_i
    );

    read_acks(PWR_REG) <= '1';
    read_data(PWR_REG) <= power_control;

    read_acks(STA_REG) <= '1';
    read_data(STA_REG) <= power_status;

    -- Unused registers
    read_acks(UNUSED_REGS) <= (others => '1');
    read_data(UNUSED_REGS) <= (others => (others => '0'));


    -- Power control and other miscellaneous controls
    vcxo_pwr_en <= power_control(0);
    adc_pwr_en <= power_control(1);
    dac_pwr_en <= power_control(2);
    adc_pdwn   <= power_control(3);
    dac_rstn   <= power_control(4);
    pll_clkin_sel0 <= power_control(8);
    pll_clkin_sel1 <= power_control(9);
    pll_sync   <= power_control(10);

    power_status(0) <= vcxo_pwr_good;
    power_status(1) <= adc_pwr_good;
    power_status(2) <= dac_pwr_good;
    power_status(3) <= '0';
    power_status(4) <= pll_status_ld1;
    power_status(5) <= pll_status_ld2;
    power_status(31 downto 6) <= (others => '0');


    -- For IO observation only
    pll_dclkout2_o <= pll_dclkout2;
    pll_sdclkout3_o <= pll_sdclkout3;
    pll_status_ld1_o <= pll_status_ld1;
    pll_status_ld2_o <= pll_status_ld2;

end;
