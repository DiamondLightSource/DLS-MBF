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
        pll_dclkout3_o : out std_logic;

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
        pll_pwr_en_i : in std_logic;
        adc_pwr_good_o : out std_logic;
        dac_pwr_good_o : out std_logic;
        pll_pwr_good_o : out std_logic;
        -- External trigger
        ext_trig_o : out std_logic;
        -- Temperature alert
        temp_alert_o : out std_logic
    );
end;

architecture fmc500m_io of fmc500m_io is
begin
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


    -- -------------------------------------------------------------------------
    -- PLL

    -- SPI outputs
    pll_spi_obuf_inst : entity work.obuf_array generic map (
        COUNT => 3
    ) port map (
        i_i(0) => pll_spi_csn_i,
        o_o(0) => FMC_LA_N(28),

        i_i(1) => pll_spi_sclk_i,
        o_o(1) => FMC_LA_P(28),

        i_i(2) => pll_spi_sdi_i,
        o_o(2) => FMC_LA_P(22)
    );
    -- SPI input
    pll_spi_sdo_inst : entity work.ibuf_array port map (
        i_i(0) => FMC_LA_N(22),
        o_o(0) => pll_spi_sdo_o
    );
    -- Status inputs
    pll_status_inst : entity work.ibuf_array generic map (
        COUNT => 2
    ) port map (
        i_i(0) => FMC_LA_P(29),
        o_o(0) => pll_status_ld1_o,

        i_i(1) => FMC_LA_N(29),
        o_o(1) => pll_status_ld2_o
    );
    -- Miscellaneous control outputs
    pll_misc_obuf_inst : entity work.obuf_array generic map (
        COUNT => 3
    ) port map (
        i_i(0) => pll_clkin_sel0_i,
        o_o(0) => FMC_LA_P(31),

        i_i(1) => pll_clkin_sel1_i,
        o_o(1) => FMC_LA_N(31),

        i_i(2) => pll_sync_i,
        o_o(2) => FMC_LA_P(18)
    );

    -- Clocks
    pll_dclkout2_inst : entity work.ibufgds_array port map (
        p_i(0) => FMC_HB_P(0),      n_i(0) => FMC_HB_N(0),
        o_o(0) => pll_dclkout2_o
    );
    -- This one isn't on a CC pair, so seems even less useful...
    pll_dclkout3_inst : entity work.ibufds_array port map (
        p_i(0) => FMC_LA_P(19),     n_i(0) => FMC_LA_N(19),
        o_o(0) => pll_dclkout3_o
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
    adc_data_inst : entity work.ibufds_array generic map (
        COUNT => 14
    ) port map (
        p_i(0)  => FMC_LA_P(7),     n_i(0)  => FMC_LA_N(7),
        p_i(1)  => FMC_LA_P(2),     n_i(1)  => FMC_LA_N(2),
        p_i(2)  => FMC_LA_P(1),     n_i(2)  => FMC_LA_N(1),
        p_i(3)  => FMC_LA_P(3),     n_i(3)  => FMC_LA_N(3),
        p_i(4)  => FMC_LA_P(4),     n_i(4)  => FMC_LA_N(4),
        p_i(5)  => FMC_LA_P(5),     n_i(5)  => FMC_LA_N(5),
        p_i(6)  => FMC_LA_P(8),     n_i(6)  => FMC_LA_N(8),
        p_i(7)  => FMC_LA_P(9),     n_i(7)  => FMC_LA_N(9),
        p_i(8)  => FMC_LA_P(12),    n_i(8)  => FMC_LA_N(12),
        p_i(9)  => FMC_LA_P(11),    n_i(9)  => FMC_LA_N(11),
        p_i(10) => FMC_LA_P(16),    n_i(10) => FMC_LA_N(16),
        p_i(11) => FMC_LA_P(15),    n_i(11) => FMC_LA_N(15),
        p_i(12) => FMC_LA_P(20),    n_i(12) => FMC_LA_N(20),
        p_i(13) => FMC_LA_P(13),    n_i(13) => FMC_LA_N(13),
        o_o => adc_data_o
    );
    -- ADC overflow detect signal
    adc_status_inst : entity work.ibufds_array port map (
        p_i(0)  => FMC_LA_P(14),    n_i(0)  => FMC_LA_N(14),
        o_o(0) => adc_status_o
    );
    -- Fast detect inputs
    adc_fd_inst : entity work.ibuf_array generic map (
        COUNT => 2
    ) port map (
        i_i(0) => FMC_LA_N(18),
        o_o(0) => adc_fd_a_o,

        i_i(1) => FMC_LA_P(6),
        o_o(1) => adc_fd_b_o
    );
    -- SPI bidirectional SDIO
    adc_spi_sdio_inst : entity work.iobuf_array port map (
        o_o(0) => adc_spi_sdio_o,
        i_i(0) => adc_spi_sdio_i,
        en_i(0) => adc_spi_sdio_en_i,
        io(0) => FMC_LA_N(6)
    );
    -- Remaining SPI and power enable
    adc_misc_out_inst : entity work.obuf_array generic map (
        COUNT => 3
    ) port map (
        i_i(0) => adc_spi_csn_i,
        o_o(0) => FMC_LA_N(10),

        i_i(1) => adc_spi_sclk_i,
        o_o(1) => FMC_LA_P(10),

        i_i(2) => adc_pdwn_i,
        o_o(2) => FMC_LA_P(25)
    );


    -- -------------------------------------------------------------------------
    -- DAC

    -- Data buffer to DAC
    dac_d_inst : entity work.obufds_array generic map (
        COUNT => 16
    ) port map (
        i_i => dac_data_i,
        p_o(0)  => FMC_HB_P(17),    n_o(0)  => FMC_HB_N(17),
        p_o(1)  => FMC_HB_P(19),    n_o(1)  => FMC_HB_N(19),
        p_o(2)  => FMC_HB_P(18),    n_o(2)  => FMC_HB_N(18),
        p_o(3)  => FMC_HB_P(15),    n_o(3)  => FMC_HB_N(15),
        p_o(4)  => FMC_HB_P(21),    n_o(4)  => FMC_HB_N(21),
        p_o(5)  => FMC_HB_P(14),    n_o(5)  => FMC_HB_N(14),
        p_o(6)  => FMC_HB_P(10),    n_o(6)  => FMC_HB_N(10),
        p_o(7)  => FMC_HB_P(13),    n_o(7)  => FMC_HB_N(13),
        p_o(8)  => FMC_HB_P(11),    n_o(8)  => FMC_HB_N(11),
        p_o(9)  => FMC_HB_P(8),     n_o(9)  => FMC_HB_N(8),
        p_o(10) => FMC_HB_P(9),     n_o(10) => FMC_HB_N(9),
        p_o(11) => FMC_HB_P(7),     n_o(11) => FMC_HB_N(7),
        p_o(12) => FMC_HB_P(6),     n_o(12) => FMC_HB_N(6),
        p_o(13) => FMC_HB_P(5),     n_o(13) => FMC_HB_N(5),
        p_o(14) => FMC_HB_P(1),     n_o(14) => FMC_HB_N(1),
        p_o(15) => FMC_HB_P(3),     n_o(15) => FMC_HB_N(3)
    );
    -- Miscellaneous differential DAC outputs
    dac_misc_obufds_inst : entity work.obufds_array generic map (
        COUNT => 2
    ) port map (
        i_i(0) => dac_dci_i,
        p_o(0) => FMC_HB_P(16),     n_o(0) => FMC_HB_N(16),

        i_i(1) => dac_frame_i,
        p_o(1) => FMC_HB_P(12),     n_o(1) => FMC_HB_N(12)
    );
    -- SPI and miscellaneous outputs
    -- Note that we operate the DAC SDIO pin as an SDI pin
    dac_misc_obuf_inst : entity work.obuf_array generic map (
        COUNT => 4
    ) port map (
        i_i(0) => dac_spi_csn_i,
        o_o(0) => FMC_LA_N(33),

        i_i(1) => dac_rstn_i,
        o_o(1) => FMC_LA_P(33),

        i_i(2) => dac_spi_sclk_i,
        o_o(2) => FMC_HB_P(4),

        i_i(3) => dac_spi_sdi_i,
        o_o(3) => FMC_HB_N(20)
    );
    -- SPI and miscellaneous intuts
    dac_misc_ibuf_inst : entity work.ibuf_array generic map (
        COUNT => 2
    ) port map (
        i_i(0) => FMC_HB_P(20),
        o_o(0) => dac_spi_sdo_o,

        i_i(1) => FMC_HB_N(4),
        o_o(1) => dac_irqn_o
    );


    -- -------------------------------------------------------------------------
    -- Miscellaneous

    -- Custom power management controllers
    power_en_inst : entity work.obuf_array generic map (
        COUNT => 3
    ) port map (
        i_i(0) => adc_pwr_en_i,
        o_o(0) => FMC_LA_P(26),

        i_i(1) => dac_pwr_en_i,
        o_o(1) => FMC_LA_P(32),

        i_i(2) => pll_pwr_en_i,
        o_o(2) => FMC_LA_P(30)
    );
    power_good_inst : entity work.ibuf_array generic map (
        COUNT => 3
    ) port map (
        i_i(0) => FMC_LA_N(26),
        o_o(0) => adc_pwr_good_o,

        i_i(1) => FMC_LA_N(32),
        o_o(1) => dac_pwr_good_o,

        i_i(2) => FMC_LA_P(27),
        o_o(2) => pll_pwr_good_o
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
