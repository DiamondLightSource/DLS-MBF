-- Interface to Innovative Integration FMC-500M Dual ADC/DAC
--
-- This entity maps the raw FMC LA and HB banks to the appropriate I/O
-- definitions.  Clocking and data handling is not resolved in this file, so
-- for example the ADC and DAC data are at DDR rates here.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fmc500m_io is
    port (
        -- FMC -----------------------------------------------------------------
        FMC_LA_P : inout std_logic_vector(0 to 33);
        FMC_LA_N : inout std_logic_vector(0 to 33);
        FMC_HB_P : inout std_logic_vector(0 to 21);
        FMC_HB_N : inout std_logic_vector(0 to 21);


        -- PLL -----------------------------------------------------------------
        -- SPI
        pll_spi_csn_i : in std_logic;
        pll_spi_sclk_i : in std_logic;
        pll_spi_sdi_i : in std_logic;
        pll_spi_sdo_o : out std_logic;
        -- Misc
        pll_status_ld1_o : out std_logic;
        pll_status_ld2_o : out std_logic;
        pll_clkin_sel0_i : in std_logic;
        pll_clkin_sel1_i : in std_logic;
        pll_sync_i : in std_logic;
        -- Internal clocks from PLL.  Probably will be discarded
        pll_dclkout2_o : out std_logic;     -- On CC pin
        pll_sdclkout3_o : out std_logic;

        -- ADC -----------------------------------------------------------------
        -- Data and clocking
        adc_dco_o : out std_logic;          -- Will be master DSP clock
        adc_data_o : out std_logic_vector(13 downto 0);
        adc_status_o : out std_logic;
        adc_fd_a_o : out std_logic;
        adc_fd_b_o : out std_logic;
        -- SPI
        adc_spi_csn_i : in std_logic;
        adc_spi_sclk_i : in std_logic;
        adc_spi_sdio_i : in std_logic;
        adc_spi_sdio_o : out std_logic;
        adc_spi_sdio_en_i : in std_logic;
        -- Misc
        adc_pdwn_i : in std_logic;

        -- DAC -----------------------------------------------------------------
        -- Data
        dac_data_i : in std_logic_vector(15 downto 0);
        dac_dci_i : in std_logic;
        dac_frame_i : in std_logic;
        -- SPI
        dac_spi_csn_i : in std_logic;
        dac_spi_sclk_i : in std_logic;
        dac_spi_sdi_i : in std_logic;
        dac_spi_sdo_o : out std_logic;
        -- Misc
        dac_rstn_i : in std_logic;
        dac_irqn_o : out std_logic;

        -- Misc ----------------------------------------------------------------
        -- Power management
        adc_pwr_en_i : in std_logic;
        dac_pwr_en_i : in std_logic;
        adc_pwr_good_o : out std_logic;
        dac_pwr_good_o : out std_logic;
        vcxo_pwr_good_o : out std_logic;
        -- External trigger
        ext_trig_o : out std_logic;
        -- Temperature alert
        temp_alert_o : out std_logic
    );
end;

architecture arch of fmc500m_io is
    signal adc_spi_sdio_tri : std_logic;
    signal adc_data_p : std_logic_vector(13 downto 0);
    signal adc_data_n : std_logic_vector(13 downto 0);
    signal dac_data_p : std_logic_vector(15 downto 0);
    signal dac_data_n : std_logic_vector(15 downto 0);

begin
    -- These lines for simulation only, they quell rather a lot of error
    -- messages from the simulation!
    -- synthesis translate_off
    FMC_LA_P <= (others => 'Z');
    FMC_LA_N <= (others => 'Z');
    FMC_HB_P <= (others => 'Z');
    FMC_HB_N <= (others => 'Z');
    -- synthesis translate_on

    -- Unused pins
    FMC_HB_P(2) <= 'Z';     -- dac_ext_sync, unused input
    FMC_HB_N(2) <= 'Z';
    FMC_LA_P(17) <= 'Z';    -- fpga_sysref, n/c
    FMC_LA_N(17) <= 'Z';
    FMC_LA_P(24) <= 'Z';    -- pll_reset, n/c
    FMC_LA_N(24) <= 'Z';    -- pll_gpo, n/c
    FMC_LA_P(23) <= 'Z';    -- n/c
    FMC_LA_N(23) <= 'Z';    -- n/c
    FMC_LA_N(27) <= 'Z';    -- n/c
    FMC_LA_P(30) <= 'Z';    -- FCXO_PWR_EN, leave unconnected


    -- -------------------------------------------------------------------------
    -- PLL

    -- SPI
    pll_spi_csn_inst : entity work.obuf_array port map (
        i_i(0) => pll_spi_csn_i,
        o_o(0) => FMC_LA_N(28)
    );
    pll_spi_sclk_inst : entity work.obuf_array port map (
        i_i(0) => pll_spi_sclk_i,
        o_o(0) => FMC_LA_P(28)
    );
    pll_spi_sdi_inst : entity work.obuf_array port map (
        i_i(0) => pll_spi_sdi_i,
        o_o(0) => FMC_LA_P(22)
    );
    pll_spi_sdo_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(22),
        o_o(0) => pll_spi_sdo_o
    );

    -- Status inputs
    pll_status_ld1_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_P(29),
        o_o(0) => pll_status_ld1_o
    );
    pll_status_ld2_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(29),
        o_o(0) => pll_status_ld2_o
    );

    -- Miscellaneous control outputs
    pll_clkin_sel0_inst : entity work.obuf_array port map (
        i_i(0) => pll_clkin_sel0_i,
        o_o(0) => FMC_LA_P(31)
    );
    pll_clkin_sel1_inst : entity work.obuf_array port map (
        i_i(0) => pll_clkin_sel1_i,
        o_o(0) => FMC_LA_N(31)
    );
    pll_sync_inst : entity work.obuf_array port map (
        i_i(0) => pll_sync_i,
        o_o(0) => FMC_LA_P(18)
    );

    -- Clocks
    pll_dclkout2_inst : entity work.ibufgds_array port map (
        p_i(0) => FMC_HB_P(0),      n_i(0) => FMC_HB_N(0),
        o_o(0) => pll_dclkout2_o
    );
    -- This one isn't on a CC pair, so seems even less useful...
    pll_sdclkout3_inst : entity work.ibufds_array port map (
        p_i(0) => FMC_LA_P(19),     n_i(0) => FMC_LA_N(19),
        o_o(0) => pll_sdclkout3_o
    );


    -- -------------------------------------------------------------------------
    -- ADC

    -- The ADC data clock (edge synchronous with data) will be used as our data
    -- processing clock throughout the system.
    adc_dco_inst : entity work.ibufgds_array port map (
        p_i(0) => FMC_LA_P(0),      n_i(0) => FMC_LA_N(0),
        o_o(0) => adc_dco_o
    );

    -- Data buffer from ADC
    adc_data_p(0)  <= FMC_LA_P(7);      adc_data_n(0)  <= FMC_LA_N(7);
    adc_data_p(1)  <= FMC_LA_P(2);      adc_data_n(1)  <= FMC_LA_N(2);
    adc_data_p(2)  <= FMC_LA_P(1);      adc_data_n(2)  <= FMC_LA_N(1);
    adc_data_p(3)  <= FMC_LA_P(3);      adc_data_n(3)  <= FMC_LA_N(3);
    adc_data_p(4)  <= FMC_LA_P(4);      adc_data_n(4)  <= FMC_LA_N(4);
    adc_data_p(5)  <= FMC_LA_P(5);      adc_data_n(5)  <= FMC_LA_N(5);
    adc_data_p(6)  <= FMC_LA_P(8);      adc_data_n(6)  <= FMC_LA_N(8);
    adc_data_p(7)  <= FMC_LA_P(9);      adc_data_n(7)  <= FMC_LA_N(9);
    adc_data_p(8)  <= FMC_LA_P(12);     adc_data_n(8)  <= FMC_LA_N(12);
    adc_data_p(9)  <= FMC_LA_P(11);     adc_data_n(9)  <= FMC_LA_N(11);
    adc_data_p(10) <= FMC_LA_P(16);     adc_data_n(10) <= FMC_LA_N(16);
    adc_data_p(11) <= FMC_LA_P(15);     adc_data_n(11) <= FMC_LA_N(15);
    adc_data_p(12) <= FMC_LA_P(20);     adc_data_n(12) <= FMC_LA_N(20);
    adc_data_p(13) <= FMC_LA_P(13);     adc_data_n(13) <= FMC_LA_N(13);
    adc_data_inst : entity work.ibufds_array generic map (
        COUNT => 14
    ) port map (
        p_i => adc_data_p,
        n_i => adc_data_n,
        o_o => adc_data_o
    );

    -- ADC overflow detect signal
    adc_status_inst : entity work.ibufds_array port map (
        p_i(0)  => FMC_LA_P(14),    n_i(0)  => FMC_LA_N(14),
        o_o(0) => adc_status_o
    );
    -- Fast detect inputs
    adc_fd_a_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(18),
        o_o(0) => adc_fd_a_o
    );
    adc_fd_b_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_P(6),
        o_o(0) => adc_fd_b_o
    );

    -- SPI
    adc_spi_sdio_tri <= not adc_spi_sdio_en_i;
    adc_spi_sdio_inst : entity work.iobuf_array port map (
        o_o(0) => adc_spi_sdio_o,
        i_i(0) => adc_spi_sdio_i,
        t_i(0) => adc_spi_sdio_tri,
        io(0) => FMC_LA_N(6)
    );
    adc_spi_csn_inst : entity work.obuf_array port map (
        i_i(0) => adc_spi_csn_i,
        o_o(0) => FMC_LA_N(10)
    );
    adc_spi_sclk_inst : entity work.obuf_array port map (
        i_i(0) => adc_spi_sclk_i,
        o_o(0) => FMC_LA_P(10)
    );

    -- ADC power down control
    adc_pdwn_inst : entity work.obuf_array port map (
        i_i(0) => adc_pdwn_i,
        o_o(0) => FMC_LA_P(25)
    );


    -- -------------------------------------------------------------------------
    -- DAC

    -- Data buffer to DAC
    FMC_HB_P(17) <= dac_data_p(0);      FMC_HB_N(17) <= dac_data_n(0);
    FMC_HB_P(19) <= dac_data_p(1);      FMC_HB_N(19) <= dac_data_n(1);
    FMC_HB_P(18) <= dac_data_p(2);      FMC_HB_N(18) <= dac_data_n(2);
    FMC_HB_P(15) <= dac_data_p(3);      FMC_HB_N(15) <= dac_data_n(3);
    FMC_HB_P(21) <= dac_data_p(4);      FMC_HB_N(21) <= dac_data_n(4);
    FMC_HB_P(14) <= dac_data_p(5);      FMC_HB_N(14) <= dac_data_n(5);
    FMC_HB_P(10) <= dac_data_p(6);      FMC_HB_N(10) <= dac_data_n(6);
    FMC_HB_P(13) <= dac_data_p(7);      FMC_HB_N(13) <= dac_data_n(7);
    FMC_HB_P(11) <= dac_data_p(8);      FMC_HB_N(11) <= dac_data_n(8);
    FMC_HB_P(8)  <= dac_data_p(9);      FMC_HB_N(8)  <= dac_data_n(9);
    FMC_HB_P(9)  <= dac_data_p(10);     FMC_HB_N(9)  <= dac_data_n(10);
    FMC_HB_P(7)  <= dac_data_p(11);     FMC_HB_N(7)  <= dac_data_n(11);
    FMC_HB_P(6)  <= dac_data_p(12);     FMC_HB_N(6)  <= dac_data_n(12);
    FMC_HB_P(5)  <= dac_data_p(13);     FMC_HB_N(5)  <= dac_data_n(13);
    FMC_HB_P(1)  <= dac_data_p(14);     FMC_HB_N(1)  <= dac_data_n(14);
    FMC_HB_P(3)  <= dac_data_p(15);     FMC_HB_N(3)  <= dac_data_n(15);
    dac_data_inst : entity work.obufds_array generic map (
        COUNT => 16
    ) port map (
        i_i => dac_data_i,
        p_o => dac_data_p,
        n_o => dac_data_n
    );

    -- Miscellaneous differential DAC outputs
    dac_dci_inst : entity work.obufds_array port map (
        i_i(0) => dac_dci_i,
        p_o(0) => FMC_HB_P(16),     n_o(0) => FMC_HB_N(16)
    );
    dac_frame_inst : entity work.obufds_array port map (
        i_i(0) => dac_frame_i,
        p_o(0) => FMC_HB_P(12),     n_o(0) => FMC_HB_N(12)
    );

    -- SPI
    -- Note that we operate the DAC SDIO pin as an SDI pin
    dac_spi_csn_inst : entity work.obuf_array port map (
        i_i(0) => dac_spi_csn_i,
        o_o(0) => FMC_LA_N(33)
    );
    dac_spi_sclk_inst : entity work.obuf_array port map (
        i_i(0) => dac_spi_sclk_i,
        o_o(0) => FMC_HB_P(4)
    );
    dac_spi_sdi_inst : entity work.obuf_array port map (
        i_i(0) => dac_spi_sdi_i,
        o_o(0) => FMC_HB_N(20)
    );
    dac_spi_sdo_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_HB_P(20),
        o_o(0) => dac_spi_sdo_o
    );

    -- Miscellanous
    dac_rstn_inst : entity work.obuf_array port map (
        i_i(0) => dac_rstn_i,
        o_o(0) => FMC_LA_P(33)
    );
    dac_irqn_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_HB_N(4),
        o_o(0) => dac_irqn_o
    );


    -- -------------------------------------------------------------------------
    -- Miscellaneous

    -- Custom power management controllers
    vcxo_pwr_good_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_P(27),
        o_o(0) => vcxo_pwr_good_o
    );

    adc_pwr_en_inst : entity work.obuf_array port map (
        i_i(0) => adc_pwr_en_i,
        o_o(0) => FMC_LA_P(26)
    );
    adc_pwr_good_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(26),
        o_o(0) => adc_pwr_good_o
    );

    dac_pwr_en_inst : entity work.obuf_array port map (
        i_i(0) => dac_pwr_en_i,
        o_o(0) => FMC_LA_P(32)
    );
    dac_pwr_good_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(32),
        o_o(0) => dac_pwr_good_o
    );

    -- External trigger input
    ext_trig_inst : entity work.ibufds_array port map (
        p_i(0) => FMC_LA_P(21),     n_i(0) => FMC_LA_N(21),
        o_o(0) => ext_trig_o
    );
    -- Hard wire mux selector to select input panel EXT TRIG (J11)
    trig_sel_inst : entity work.obuf_array port map (
        i_i(0) => '0',
        o_o(0) => FMC_LA_N(25)
    );

    -- Temperature alert from on board STTS2002 sensor
    temp_alert_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(30),
        o_o(0) => temp_alert_o
    );

end;
