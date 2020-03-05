-- Register interface for Tune PLL readback

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;

entity tune_pll_readout_registers is
    port (
        clk_i : in std_ulogic;

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);
        read_data_o : out reg_data_array_t(DSP_TUNE_PLL_READOUT_REGS);
        read_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);

        -- Data readout and read strobes.  The data is assumed to already be
        -- ready to read out.
        offset_data_i : in reg_data_t;
        read_offset_data_o : out std_ulogic;
        debug_data_i : in reg_data_t;
        read_debug_data_o : out std_ulogic;

        -- Status readbacks
        offset_fifo_depth_i : in unsigned(10 downto 0);
        debug_fifo_depth_i : in unsigned(10 downto 0);
        offset_fifo_overrun_i : in std_ulogic;
        debug_fifo_overrun_i : in std_ulogic;
        read_error_i : in std_ulogic_vector(1 downto 0);

        -- Command strobes
        reset_offset_fifo_o : out std_ulogic;
        reset_debug_fifo_o : out std_ulogic;
        enable_offset_interrupt_o : out std_ulogic;
        enable_debug_interrupt_o : out std_ulogic;
        reset_read_error_o : out std_ulogic_vector(1 downto 0)
    );
end;

architecture arch of tune_pll_readout_registers is
    -- Register interface
    signal command_register : reg_data_t;
    signal status_register : reg_data_t;

begin
    -- Command register
    command : entity work.strobed_bits port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(DSP_TUNE_PLL_READOUT_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_TUNE_PLL_READOUT_COMMAND_REG_W),
        strobed_bits_o => command_register
    );

    read_data_o(DSP_TUNE_PLL_READOUT_STATUS_REG_R) <= status_register;
    read_ack_o(DSP_TUNE_PLL_READOUT_STATUS_REG_R) <= '1';

    read_data_o(DSP_TUNE_PLL_READOUT_OFFSET_FIFO_REG) <= offset_data_i;
    read_ack_o(DSP_TUNE_PLL_READOUT_OFFSET_FIFO_REG) <= '1';
    write_ack_o(DSP_TUNE_PLL_READOUT_OFFSET_FIFO_REG) <= '1';
    read_data_o(DSP_TUNE_PLL_READOUT_DEBUG_FIFO_REG) <= debug_data_i;
    read_ack_o(DSP_TUNE_PLL_READOUT_DEBUG_FIFO_REG) <= '1';
    write_ack_o(DSP_TUNE_PLL_READOUT_DEBUG_FIFO_REG) <= '1';

    read_offset_data_o <= read_strobe_i(DSP_TUNE_PLL_READOUT_OFFSET_FIFO_REG);
    read_debug_data_o  <= read_strobe_i(DSP_TUNE_PLL_READOUT_DEBUG_FIFO_REG);

    status_register <= (
        DSP_TUNE_PLL_READOUT_STATUS_OFFSET_COUNT_BITS =>
            std_ulogic_vector(offset_fifo_depth_i),
        DSP_TUNE_PLL_READOUT_STATUS_DEBUG_COUNT_BITS =>
            std_ulogic_vector(debug_fifo_depth_i),
        DSP_TUNE_PLL_READOUT_STATUS_OFFSET_OVERRUN_BIT => offset_fifo_overrun_i,
        DSP_TUNE_PLL_READOUT_STATUS_DEBUG_OVERRUN_BIT => debug_fifo_overrun_i,
        DSP_TUNE_PLL_READOUT_STATUS_READ_ERROR_BITS => read_error_i,
        others => '0'
    );

    reset_offset_fifo_o <=
        command_register(DSP_TUNE_PLL_READOUT_COMMAND_RESET_OFFSET_BIT);
    reset_debug_fifo_o <=
        command_register(DSP_TUNE_PLL_READOUT_COMMAND_RESET_DEBUG_BIT);
    enable_offset_interrupt_o <=
        command_register(DSP_TUNE_PLL_READOUT_COMMAND_ENABLE_OFFSET_BIT);
    enable_debug_interrupt_o <=
        command_register(DSP_TUNE_PLL_READOUT_COMMAND_ENABLE_DEBUG_BIT);
    reset_read_error_o <=
        command_register(DSP_TUNE_PLL_READOUT_COMMAND_RESET_READ_ERROR_BITS);
end;
