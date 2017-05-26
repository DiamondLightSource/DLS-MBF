-- Top level register interface for detector control.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;
use work.register_defs.all;

entity detector_registers is
    generic (
        COMMAND_BUFFER_LENGTH : natural
    );
    port (
        dsp_clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector(DSP_DET_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(DSP_DET_REGS);
        read_strobe_i : in std_logic_vector(DSP_DET_REGS);
        read_data_o : out reg_data_array_t(DSP_DET_REGS);
        read_ack_o : out std_logic_vector(DSP_DET_REGS);

        -- Controls
        fir_gain_o : out unsigned(0 downto 0);
        data_select_o : out std_logic;
        start_write_o : out std_logic;
        bunch_write_o : out std_logic_vector(DETECTOR_RANGE);
        output_scaling_o : out unsigned_array(DETECTOR_RANGE)(2 downto 0);
        address_reset_o : out std_logic;
        input_enable_o : out std_logic_vector(DETECTOR_RANGE);

        -- Error event inputs
        fir_overflow_i : in std_logic_vector(DETECTOR_RANGE);
        detector_overflow_i : in std_logic_vector(DETECTOR_RANGE);
        output_underrun_i : in std_logic_vector(DETECTOR_RANGE)
    );
end;

architecture arch of detector_registers is
    signal register_file : reg_data_t;
    signal command_bits : reg_data_t;
    signal event_bits : reg_data_t;

    signal bunch_write_index : DETECTOR_RANGE;

begin
    -- -------------------------------------------------------------------------
    -- Register mapping

    -- Configuration register
    registers : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_DET_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_DET_CONFIG_REG),
        register_data_o(0) => register_file
    );
    read_data_o(DSP_DET_CONFIG_REG) <= register_file;
    read_ack_o(DSP_DET_CONFIG_REG) <= '1';

    -- Command bits for triggering events
    command : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_DET_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_DET_COMMAND_REG_W),
        strobed_bits_o => command_bits
    );

    -- Event sensing bits
    events : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(DSP_DET_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_DET_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_DET_EVENTS_REG_R),
        pulsed_bits_i => event_bits
    );

    -- The detector bunch register is treated specially below
    write_ack_o(DSP_DET_BUNCH_REG) <= '1';
    read_data_o(DSP_DET_BUNCH_REG) <= (others => '0');
    read_ack_o(DSP_DET_BUNCH_REG) <= '1';


    -- -------------------------------------------------------------------------
    -- Field management

    -- Incoming events
    event_bits <= (
        DSP_DET_EVENTS_OUTPUT_OVFL_BITS => detector_overflow_i,
        DSP_DET_EVENTS_UNDERRUN_BITS => output_underrun_i,
        DSP_DET_EVENTS_FIR_OVFL_BITS => fir_overflow_i,
        others => '0'
    );

    -- Outgoing events
    start_write_o <= command_bits(DSP_DET_COMMAND_WRITE_BIT);
    address_reset_o <= command_bits(DSP_DET_COMMAND_RESET_BIT);

    -- Control fields
    fir_gain_o <= unsigned(register_file(DSP_DET_CONFIG_FIR_GAIN_BITS));
    data_select_o <= register_file(DSP_DET_CONFIG_SELECT_BIT);
    output_scaling_o(0) <= unsigned(register_file(DSP_DET_CONFIG_SCALE0_BITS));
    input_enable_o(0) <= register_file(DSP_DET_CONFIG_ENABLE0_BIT);
    output_scaling_o(1) <= unsigned(register_file(DSP_DET_CONFIG_SCALE1_BITS));
    input_enable_o(1) <= register_file(DSP_DET_CONFIG_ENABLE1_BIT);
    output_scaling_o(2) <= unsigned(register_file(DSP_DET_CONFIG_SCALE2_BITS));
    input_enable_o(2) <= register_file(DSP_DET_CONFIG_ENABLE2_BIT);
    output_scaling_o(3) <= unsigned(register_file(DSP_DET_CONFIG_SCALE3_BITS));
    input_enable_o(3) <= register_file(DSP_DET_CONFIG_ENABLE3_BIT);

    -- Bunch write strobe
    bunch_write_index <=
        to_integer(unsigned(register_file(DSP_DET_CONFIG_BANK_BITS)));
    compute_strobe(
        bunch_write_o, bunch_write_index, write_strobe_i(DSP_DET_BUNCH_REG));
end;
