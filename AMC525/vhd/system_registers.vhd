-- All system control registers are processed through this entity.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity system_registers is
    port (
        reg_clk_i : in std_logic;       -- Register clock
        reg_clk_ok_i : in std_logic;
        ref_clk_i : in std_logic;       -- Timing reference clock
        ref_clk_ok_i : in std_logic;

        -- System register interface on REG clock
        write_strobe_i : in reg_strobe_t;
        write_data_i : in reg_data_t;
        write_ack_o : out reg_strobe_t;
        read_strobe_i : in reg_strobe_t;
        read_data_o : out reg_data_array_t;
        read_ack_o : out reg_strobe_t;

        -- General system status bits
        version_read_data_i : in reg_data_t;
        status_read_data_i : in reg_data_t;

        -- Generic miscellaneous control bits
        control_data_o : out reg_data_t;

        -- IDELAY control register on REF clock.  No ack on this interface, no
        -- read strobe required.
        idelay_write_strobe_o : out std_logic;
        idelay_write_data_o : out reg_data_t;
        idelay_read_data_i : in reg_data_t;

        -- FMC500 SPI control
        fmc500m_spi_write_strobe_o : out std_logic;
        fmc500m_spi_write_data_o : out reg_data_t;
        fmc500m_spi_write_ack_i : in std_logic;
        fmc500m_spi_read_strobe_o : out std_logic;
        fmc500m_spi_read_data_i : in reg_data_t;
        fmc500m_spi_read_ack_i : in std_logic;

        -- DAC test pattern
        dac_test_pattern_o : out reg_data_array_t(0 to 1)
    );
end;

architecture system_registers of system_registers is
    constant VERSION_REG : natural := 0;
    constant STATUS_REG : natural := 1;
    constant CONTROL_REG : natural := 2;
    constant IDELAY_REG : natural := 3;
    constant FMC_SPI_REG : natural := 4;
    subtype DAC_TEST_REG is natural range 5 to 6;
    subtype UNUSED_REG is natural range 7 to REG_ADDR_COUNT-1;

    signal status_read_data : reg_data_t;

begin
    -- Version register, read only.
    write_ack_o(VERSION_REG) <= '1';
    read_data_o(VERSION_REG) <= version_read_data_i;
    read_ack_o(VERSION_REG) <= '1';

    -- Status bits register, read only.
    write_ack_o(STATUS_REG) <= '1';
    read_data_o(STATUS_REG) <= status_read_data;
    read_ack_o(STATUS_REG) <= '1';
    -- Pipeline the status to avoid annoying timing problems.
    status_dly_inst : entity work.dlyreg generic map (
        DW => 32, DLY => 1
    ) port map (
        clk_i => reg_clk_i,
        data_i => status_read_data_i,
        data_o => status_read_data
    );

    -- Control bits register, write only.
    control_inst : entity work.single_register port map (
        clk_i => reg_clk_i,
        write_strobe_i => write_strobe_i(CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONTROL_REG),
        read_strobe_i => read_strobe_i(CONTROL_REG),
        read_data_o => read_data_o(CONTROL_REG),
        read_ack_o => read_ack_o(CONTROL_REG),

        register_o => control_data_o
    );

    -- Clock domain crossing for IDELAY control.
    idelay_register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk_i,
        out_clk_i => ref_clk_i,
        out_clk_ok_i => ref_clk_ok_i,

        reg_write_strobe_i => write_strobe_i(IDELAY_REG),
        reg_write_data_i => write_data_i,
        reg_write_ack_o => write_ack_o(IDELAY_REG),
        out_write_strobe_o => idelay_write_strobe_o,
        out_write_data_o => idelay_write_data_o,
        out_write_ack_i => '1',

        reg_read_strobe_i => read_strobe_i(IDELAY_REG),
        reg_read_data_o => read_data_o(IDELAY_REG),
        reg_read_ack_o => read_ack_o(IDELAY_REG),
        out_read_strobe_o => open,
        out_read_data_i => idelay_read_data_i,
        out_read_ack_i => '1'
    );

    -- FMC SPI register
    fmc500m_spi_write_strobe_o <= write_strobe_i(FMC_SPI_REG);
    fmc500m_spi_write_data_o <= write_data_i;
    write_ack_o(FMC_SPI_REG) <= fmc500m_spi_write_ack_i;
    fmc500m_spi_read_strobe_o <= read_strobe_i(FMC_SPI_REG);
    read_data_o(FMC_SPI_REG) <= fmc500m_spi_read_data_i;
    read_ack_o(FMC_SPI_REG) <= fmc500m_spi_read_ack_i;

    -- DAC test pattern
    dac_test_pattern_inst : entity work.register_file port map (
        clk_i => reg_clk_i,
        write_strobe_i => write_strobe_i(DAC_TEST_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DAC_TEST_REG),
        read_strobe_i => read_strobe_i(DAC_TEST_REG),
        read_data_o => read_data_o(DAC_TEST_REG),
        read_ack_o => read_ack_o(DAC_TEST_REG),
        register_data_o => dac_test_pattern_o
    );

    -- Unused registers
    write_ack_o(UNUSED_REG) <= (others => '1');
    read_data_o(UNUSED_REG) <= (others => (others => '0'));
    read_ack_o(UNUSED_REG) <= (others => '1');

end;
