-- FMC-500M top level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.fmc500m_defs.all;

entity fmc500m_top is
    port (
        adc_clk_i : in std_ulogic;       -- Derived ADC clock
        reg_clk_i : in std_ulogic;       -- Register clock
        ref_clk_i : in std_ulogic;       -- Hardware reference clock

        -- FMC
        FMC_LA_P : inout std_ulogic_vector(0 to 33);
        FMC_LA_N : inout std_ulogic_vector(0 to 33);
        FMC_HB_P : inout std_ulogic_vector(0 to 21);
        FMC_HB_N : inout std_ulogic_vector(0 to 21);

        -- SPI Register control
        spi_write_strobe_i : in std_ulogic;
        spi_write_data_i : in reg_data_t;
        spi_write_ack_o : out std_ulogic;
        spi_read_strobe_i : in std_ulogic;
        spi_read_data_o : out reg_data_t;
        spi_read_ack_o : out std_ulogic;

        -- ADC IDELAY Register control (on ref_clk)
        adc_idelay_write_strobe_i : in std_ulogic;
        adc_idelay_write_data_i : in reg_data_t;
        adc_idelay_read_data_o : out reg_data_t;

        -- ADC clock and data
        adc_dco_o : out std_ulogic;      -- Raw data clock from ADC
        adc_data_a_o : out signed;
        adc_data_b_o : out signed;

        -- DAC clock and data (clocked by ADC clock)
        dac_data_a_i : in signed;
        dac_data_b_i : in signed;
        dac_frame_i : in std_ulogic;

        -- Miscellaneous IO signals
        ext_trig_o : out std_ulogic;     -- Fast external trigger
        misc_outputs_i : in fmc500_outputs_t;
        misc_inputs_o : out fmc500_inputs_t
    );
end;

architecture arch of fmc500m_top is
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    -- Signal interfaces to IO.

    -- PLL
    signal pll_spi_csn : std_ulogic;
    signal pll_spi_sclk : std_ulogic;
    signal pll_spi_sdi : std_ulogic;
    signal pll_spi_sdo : std_ulogic;
    signal pll_status_ld1 : std_ulogic;
    signal pll_status_ld2 : std_ulogic;
    signal pll_clkin_sel0_in : std_ulogic;
    signal pll_clkin_sel0_out : std_ulogic;
    signal pll_clkin_sel0_ena : std_ulogic;
    signal pll_clkin_sel1_in : std_ulogic;
    signal pll_clkin_sel1_out : std_ulogic;
    signal pll_clkin_sel1_ena : std_ulogic;
    signal pll_sync : std_ulogic;
    signal pll_dclkout2 : std_ulogic;     -- On CC pin
    signal pll_sdclkout3 : std_ulogic;

    -- ADC
    signal adc_data : std_ulogic_vector(13 downto 0);
    signal adc_data_delay : std_ulogic_vector(13 downto 0);
    signal adc_fd_a : std_ulogic;
    signal adc_fd_b : std_ulogic;
    signal adc_spi_csn : std_ulogic;
    signal adc_spi_sclk : std_ulogic;
    signal adc_spi_sdi : std_ulogic;
    signal adc_spi_sdo : std_ulogic;
    signal adc_spi_sdio_en : std_ulogic;
    signal adc_pdwn : std_ulogic;

    -- DAC
    signal dac_data : std_ulogic_vector(15 downto 0);
    signal dac_dci : std_ulogic;
    signal dac_frame : std_ulogic;
    signal dac_spi_csn : std_ulogic;
    signal dac_spi_sclk : std_ulogic;
    signal dac_spi_sdi : std_ulogic;
    signal dac_spi_sdo : std_ulogic;
    signal dac_rstn : std_ulogic;
    signal dac_irqn : std_ulogic;

    -- Misc
    signal adc_pwr_good : std_ulogic;
    signal dac_pwr_good : std_ulogic;
    signal vcxo_pwr_good : std_ulogic;
    signal temp_alert_n : std_ulogic;


begin
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
        pll_clkin_sel0_i => pll_clkin_sel0_out,
        pll_clkin_sel0_ena_i => pll_clkin_sel0_ena,
        pll_clkin_sel0_o => pll_clkin_sel0_in,
        pll_clkin_sel1_i => pll_clkin_sel1_out,
        pll_clkin_sel1_ena_i => pll_clkin_sel1_ena,
        pll_clkin_sel1_o => pll_clkin_sel1_in,
        pll_sync_i => pll_sync,
        pll_dclkout2_o => pll_dclkout2,
        pll_sdclkout3_o => pll_sdclkout3,

        -- ADC
        adc_dco_o => adc_dco_o,
        adc_data_o => adc_data,
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
        adc_pwr_en_i => '1',
        dac_pwr_en_i => '1',
        adc_pwr_good_o => adc_pwr_good,
        dac_pwr_good_o => dac_pwr_good,
        vcxo_pwr_good_o => vcxo_pwr_good,
        ext_trig_o => ext_trig_o,
        temp_alert_o => temp_alert_n
    );


    -- SPI controller
    fmc500m_spi_inst : entity work.fmc500m_spi port map (
        clk_i => reg_clk_i,

        -- Register control
        write_strobe_i => spi_write_strobe_i,
        write_data_i => spi_write_data_i,
        write_ack_o => spi_write_ack_o,
        read_strobe_i => spi_read_strobe_i,
        read_data_o => spi_read_data_o,
        read_ack_o => spi_read_ack_o,

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


    -- DDR data from ADC input: first IDELAY then IDDR
    idelay_inst : entity work.idelay_control port map (
        ref_clk_i => ref_clk_i,
        signal_i => adc_data,
        signal_o => adc_data_delay,
        write_strobe_i => adc_idelay_write_strobe_i,
        write_data_i => adc_idelay_write_data_i,
        read_data_o => adc_idelay_read_data_o
    );

    adc_data_inst : entity work.iddr_array generic map (
        COUNT => adc_data'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        d_i => adc_data_delay,
        signed(q1_o) => adc_data_a_o,
        signed(q2_o) => adc_data_b_o
    );


    -- DDR data to DAC output
    dac_data_inst : entity work.oddr_array generic map (
        COUNT => dac_data'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        d1_i => std_ulogic_vector(dac_data_a_i),
        d2_i => std_ulogic_vector(dac_data_b_i),
        q_o => dac_data
    );
    dac_dci_inst : entity work.oddr_array port map (
        clk_i => adc_clk_i,
        d1_i(0) => '1',
        d2_i(0) => '0',
        q_o(0) => dac_dci
    );
    -- We output the frame signal through an ODDR to ensure the same timing
    frame_inst : entity work.oddr_array port map (
        clk_i => adc_clk_i,
        d1_i(0) => dac_frame_i,
        d2_i(0) => dac_frame_i,
        q_o(0) => dac_frame
    );


    -- Connection to I/O records
    pll_clkin_sel0_out <= misc_outputs_i.pll_clkin_sel0_out;
    pll_clkin_sel0_ena <= misc_outputs_i.pll_clkin_sel0_ena;
    pll_clkin_sel1_out <= misc_outputs_i.pll_clkin_sel1_out;
    pll_clkin_sel1_ena <= misc_outputs_i.pll_clkin_sel1_ena;
    pll_sync <= misc_outputs_i.pll_sync;
    adc_pdwn <= misc_outputs_i.adc_pdwn;
    dac_rstn <= misc_outputs_i.dac_rstn;

    misc_inputs_o.vcxo_pwr_good <= vcxo_pwr_good;
    misc_inputs_o.adc_pwr_good <= adc_pwr_good;
    misc_inputs_o.dac_pwr_good <= dac_pwr_good;
    misc_inputs_o.pll_status_ld1 <= pll_status_ld1;
    misc_inputs_o.pll_status_ld2 <= pll_status_ld2;
    misc_inputs_o.pll_clkin_sel0_in <= pll_clkin_sel0_in;
    misc_inputs_o.pll_clkin_sel1_in <= pll_clkin_sel1_in;
    misc_inputs_o.pll_dclkout2 <= pll_dclkout2;
    misc_inputs_o.pll_sdclkout3 <= pll_sdclkout3;
    misc_inputs_o.dac_irqn <= dac_irqn;
    misc_inputs_o.temp_alert_n <= temp_alert_n;
end;
