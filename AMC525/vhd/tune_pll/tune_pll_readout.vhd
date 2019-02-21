-- Supports Tune PLL readback

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.detector_defs.all;

entity tune_pll_readout is
    port (
        clk_i : in std_ulogic;

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);
        read_data_o : out reg_data_array_t(DSP_TUNE_PLL_READOUT_REGS);
        read_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_READOUT_REGS);

        -- Detector output
        detector_done_i : in std_ulogic;
        iq_i : in cos_sin_32_t;

        -- Feedback output
        feedback_done_i : in std_ulogic;
        frequency_offset_i : in signed;

        interrupt_o : out std_ulogic
    );
end;

architecture arch of tune_pll_readout is
    constant FIFO_ADDRESS_BITS : natural := 10;

    -- Data readout
    signal offset_data : reg_data_t;
    signal read_offset_data : std_ulogic;
    signal debug_data : reg_data_t;
    signal read_debug_data : std_ulogic;

    -- Status readbacks
    signal offset_fifo_depth : unsigned(10 downto 0);
    signal debug_fifo_depth : unsigned(10 downto 0);
    signal offset_fifo_overrun : std_ulogic;
    signal debug_fifo_overrun : std_ulogic;
    signal read_error : std_ulogic_vector(1 downto 0) := "00";

    -- Command strobes
    signal reset_offset_fifo : std_ulogic;
    signal reset_debug_fifo : std_ulogic;
    signal enable_offset_interrupt : std_ulogic;
    signal enable_debug_interrupt : std_ulogic;
    signal reset_read_error : std_ulogic_vector(1 downto 0);

    -- Overall control
    signal offset_interrupt : std_ulogic;
    signal debug_interrupt : std_ulogic;
    signal detector_done_in : std_ulogic := '0';
    signal debug_write : std_ulogic := '0';
    signal debug_data_in : reg_data_t;

    -- Read error detection
    signal read_error_event : std_ulogic_vector(1 downto 0);

begin
    registers : entity work.tune_pll_readout_registers port map (
        clk_i => clk_i,
        -- Register interface
        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,
        -- Data readout and read strobes.
        offset_data_i => offset_data,
        read_offset_data_o => read_offset_data,
        debug_data_i => debug_data,
        read_debug_data_o => read_debug_data,
        -- Status readbacks
        offset_fifo_depth_i => offset_fifo_depth,
        debug_fifo_depth_i => debug_fifo_depth,
        offset_fifo_overrun_i => offset_fifo_overrun,
        debug_fifo_overrun_i => debug_fifo_overrun,
        read_error_i => read_error,
        -- Command strobes
        reset_offset_fifo_o => reset_offset_fifo,
        reset_debug_fifo_o => reset_debug_fifo,
        enable_offset_interrupt_o => enable_offset_interrupt,
        enable_debug_interrupt_o => enable_debug_interrupt,
        reset_read_error_o => reset_read_error
    );

    offset_fifo : entity work.tune_pll_readout_fifo port map (
        clk_i => clk_i,
        -- Simple read/write interface
        data_i => std_logic_vector(frequency_offset_i),
        write_i => feedback_done_i,
        -- Data is assumed to be valid at the time of reading
        data_o => offset_data,
        read_i => read_offset_data,
        -- Status and control
        fifo_depth_o => offset_fifo_depth,
        overrun_o => offset_fifo_overrun,
        read_error_o => read_error_event(0),
        reset_i => reset_offset_fifo,
        -- Interrupt management
        enable_interrupt_i => enable_offset_interrupt,
        interrupt_o => offset_interrupt
    );

    debug_fifo : entity work.tune_pll_readout_fifo port map (
        clk_i => clk_i,
        -- Simple read/write interface
        data_i => debug_data_in,
        write_i => debug_write,
        -- Data is assumed to be valid at the time of reading
        data_o => debug_data,
        read_i => read_debug_data,
        -- Status and control
        fifo_depth_o => debug_fifo_depth,
        overrun_o => debug_fifo_overrun,
        read_error_o => read_error_event(1),
        reset_i => reset_debug_fifo,
        -- Interrupt management
        enable_interrupt_i => enable_debug_interrupt,
        interrupt_o => debug_interrupt
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            interrupt_o <= offset_interrupt or debug_interrupt;

            detector_done_in <= detector_done_i;
            if detector_done_i = '1' then
                debug_data_in <= std_logic_vector(iq_i.cos);
                debug_write <= '1';
            elsif detector_done_in = '1' then
                debug_data_in <= std_logic_vector(iq_i.sin);
                debug_write <= '1';
            else
                debug_write <= '0';
            end if;

            -- Accumulate read errors unless reset
            read_error <=
                (read_error or read_error_event) and not reset_read_error;
        end if;
    end process;
end;
