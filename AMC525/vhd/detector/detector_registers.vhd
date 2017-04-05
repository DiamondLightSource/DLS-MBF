-- Top level register interface for detector control.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;
use work.register_defs.all;

entity detector_registers is
    port (
        dsp_clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Controls
        fir_gain_o : out unsigned(0 downto 0);
        data_select_o : out std_logic;
        start_write_o : out std_logic;
        bunch_write_o : out std_logic_vector(DETECTOR_RANGE);
        output_scaling_o : out unsigned_array(DETECTOR_RANGE)(2 downto 0);
        output_reset_o : out std_logic;
        output_enables_o : out std_logic_vector(DETECTOR_RANGE);

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


    -- Bunch memory writes forwarded to corresponding detector
    bunch_write_o <= write_strobe_i(DSP_DET_BUNCH_REGS);
    write_ack_o(DSP_DET_BUNCH_REGS) <= (others => '1');
    read_data_o(DSP_DET_BUNCH_REGS) <= (others => (others => '0'));
    read_ack_o(DSP_DET_BUNCH_REGS) <= (others => '1');


    -- -------------------------------------------------------------------------
    -- Field management

    -- Incoming events
    event_bits <= (
        3 downto 0 => detector_overflow_i,
        7 downto 4 => output_underrun_i,
        11 downto 8 => fir_overflow_i,
        others => '0'
    );

    -- Outgoing events
    start_write_o <= command_bits(0);
    output_reset_o <= command_bits(1);

    -- Control fields
    fir_gain_o <= unsigned(register_file(0 downto 0));
    data_select_o <= register_file(1);
    output_scaling_o(0) <= unsigned(register_file(4 downto 2));
    output_scaling_o(1) <= unsigned(register_file(7 downto 5));
    output_scaling_o(2) <= unsigned(register_file(10 downto 8));
    output_scaling_o(3) <= unsigned(register_file(13 downto 11));
    output_enables_o <= register_file(17 downto 14);
end;
