-- All system control registers are processed through this entity.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.version.all;

entity system_registers is
    port (
        reg_clk_i : in std_ulogic;       -- Register clock
        ref_clk_i : in std_ulogic;       -- Timing reference clock
        ref_clk_ok_i : in std_ulogic;

        -- System register interface on REG clock
        write_strobe_i : in std_ulogic_vector(SYS_REGS_RANGE);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(SYS_REGS_RANGE);
        read_strobe_i : in std_ulogic_vector(SYS_REGS_RANGE);
        read_data_o : out reg_data_array_t(SYS_REGS_RANGE);
        read_ack_o : out std_ulogic_vector(SYS_REGS_RANGE);

        -- General system status bits
        version_read_data_i : in reg_data_t;
        git_version_read_data_i : in reg_data_t;
        info_read_data_i : in reg_data_t;
        status_read_data_i : in reg_data_t;

        -- Generic miscellaneous control bits
        control_data_o : out reg_data_t;

        -- ADC IDELAY control register on REF clock.  No ack on this interface,
        -- no read strobe required.
        adc_idelay_write_strobe_o : out std_ulogic;
        adc_idelay_write_data_o : out reg_data_t;
        adc_idelay_read_data_i : in reg_data_t;
        -- Revolution clock IDELAY control, same as above
        rev_idelay_write_strobe_o : out std_ulogic;
        rev_idelay_write_data_o : out reg_data_t;
        rev_idelay_read_data_i : in reg_data_t;

        -- FMC500 SPI control
        fmc500m_spi_write_strobe_o : out std_ulogic;
        fmc500m_spi_write_data_o : out reg_data_t;
        fmc500m_spi_write_ack_i : in std_ulogic;
        fmc500m_spi_read_strobe_o : out std_ulogic;
        fmc500m_spi_read_data_i : in reg_data_t;
        fmc500m_spi_read_ack_i : in std_ulogic
    );
end;

architecture arch of system_registers is
    signal status_read_data : reg_data_t;

    constant STATUS_PIPELINE : natural := 4;

begin
    -- Version registers, read only.
    write_ack_o(SYS_VERSION_REG) <= '1';
    read_data_o(SYS_VERSION_REG) <= version_read_data_i;
    read_ack_o(SYS_VERSION_REG) <= '1';
    write_ack_o(SYS_GIT_VERSION_REG) <= '1';
    read_data_o(SYS_GIT_VERSION_REG) <= git_version_read_data_i;
    read_ack_o(SYS_GIT_VERSION_REG) <= '1';

    -- Configuration info register, read only.
    write_ack_o(SYS_INFO_REG) <= '1';
    read_data_o(SYS_INFO_REG) <= info_read_data_i;
    read_ack_o(SYS_INFO_REG) <= '1';

    -- Status bits register, read only.
    write_ack_o(SYS_STATUS_REG) <= '1';
    read_data_o(SYS_STATUS_REG) <= status_read_data;
    read_ack_o(SYS_STATUS_REG) <= '1';
    -- Pipeline the status to avoid annoying timing problems.
    status_dly_inst : entity work.dlyreg generic map (
        DW => 32,
        DLY => STATUS_PIPELINE
    ) port map (
        clk_i => reg_clk_i,
        data_i => status_read_data_i,
        data_o => status_read_data
    );

    -- Seed register, read only
    write_ack_o(SYS_SEED_VALUE_REG) <= '1';
    read_data_o(SYS_SEED_VALUE_REG) <=
        to_std_ulogic_vector(FPGA_SEED_VALUE, 32);
    read_ack_o(SYS_SEED_VALUE_REG) <= '1';

    -- Control bits register
    control_inst : entity work.register_file port map (
        clk_i => reg_clk_i,
        write_strobe_i(0) => write_strobe_i(SYS_CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(SYS_CONTROL_REG),
        register_data_o(0) => control_data_o
    );
    read_data_o(SYS_CONTROL_REG) <= control_data_o;
    read_ack_o(SYS_CONTROL_REG) <= '1';


    -- Clock domain crossing for ADC IDELAY control.
    adc_idelay_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => ref_clk_i,
        out_clk_ok_i => ref_clk_ok_i,

        reg_write_strobe_i => write_strobe_i(SYS_ADC_IDELAY_REG),
        reg_write_data_i => write_data_i,
        reg_write_ack_o => write_ack_o(SYS_ADC_IDELAY_REG),
        out_write_strobe_o => adc_idelay_write_strobe_o,
        out_write_data_o => adc_idelay_write_data_o,
        out_write_ack_i => '1',

        reg_read_strobe_i => read_strobe_i(SYS_ADC_IDELAY_REG),
        reg_read_data_o => read_data_o(SYS_ADC_IDELAY_REG),
        reg_read_ack_o => read_ack_o(SYS_ADC_IDELAY_REG),
        out_read_strobe_o => open,
        out_read_data_i => adc_idelay_read_data_i,
        out_read_ack_i => '1'
    );

    -- Clock domain crossing for revolution clock IDELAY control.
    rev_idelay_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => ref_clk_i,
        out_clk_ok_i => ref_clk_ok_i,

        reg_write_strobe_i => write_strobe_i(SYS_REV_IDELAY_REG),
        reg_write_data_i => write_data_i,
        reg_write_ack_o => write_ack_o(SYS_REV_IDELAY_REG),
        out_write_strobe_o => rev_idelay_write_strobe_o,
        out_write_data_o => rev_idelay_write_data_o,
        out_write_ack_i => '1',

        reg_read_strobe_i => read_strobe_i(SYS_REV_IDELAY_REG),
        reg_read_data_o => read_data_o(SYS_REV_IDELAY_REG),
        reg_read_ack_o => read_ack_o(SYS_REV_IDELAY_REG),
        out_read_strobe_o => open,
        out_read_data_i => rev_idelay_read_data_i,
        out_read_ack_i => '1'
    );

    -- FMC SPI register
    fmc500m_spi_write_strobe_o <= write_strobe_i(SYS_FMC_SPI_REG);
    fmc500m_spi_write_data_o <= write_data_i;
    write_ack_o(SYS_FMC_SPI_REG) <= fmc500m_spi_write_ack_i;
    fmc500m_spi_read_strobe_o <= read_strobe_i(SYS_FMC_SPI_REG);
    read_data_o(SYS_FMC_SPI_REG) <= fmc500m_spi_read_data_i;
    read_ack_o(SYS_FMC_SPI_REG) <= fmc500m_spi_read_ack_i;
end;
