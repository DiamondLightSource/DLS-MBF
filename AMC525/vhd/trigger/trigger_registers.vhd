-- Trigger register mapping

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.trigger_defs.all;

entity trigger_registers is
    port (
        clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Revolution clock synchronisation
        turn_setup_o : out turn_clock_setup_t;
        turn_readback_i : in turn_clock_readback_t;

        -- Trigger control
        soft_trigger_o : out std_logic;
        triggers_i : in std_logic_vector(TRIGGER_SET);

        blanking_interval_o : out unsigned_array(CHANNELS);

        -- Sequencer triggering
        seq_setup_o : out trigger_setup_channels;
        seq_readback_i : in trigger_readback_channels;

        -- DRAM0 triggering
        dram0_turn_select_o : out unsigned(0 downto 0);
        dram0_blanking_select_o : out std_logic_vector(CHANNELS);
        dram0_setup_o : out trigger_setup_t;
        dram0_readback_i : in trigger_readback_t
    );
end;

architecture arch of trigger_registers is
    -- Register interface
    signal strobed_bits : reg_data_t;
    signal pulsed_bits : reg_data_t;
    signal readback_registers : reg_data_array_t(CTRL_TRG_READBACK_REGS);
    signal config_registers : reg_data_array_t(CTRL_TRG_CONFIG_REGS);

    alias readback_status : reg_data_t is
        readback_registers(CTRL_TRG_READBACK_STATUS_REG);
    alias readback_sources : reg_data_t is
        readback_registers(CTRL_TRG_READBACK_SOURCES_REG);
    alias config_turn_setup : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_TURN_SETUP_REG);
    alias config_blanking : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_BLANKING_REG);
    alias config_delay_seq_0 : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_DELAY_SEQ_0_REG);
    alias config_delay_seq_1 : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_DELAY_SEQ_1_REG);
    alias config_delay_dram : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_DELAY_DRAM_REG);
    alias config_trig_seq : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_TRIG_SEQ_REG);
    alias config_trig_dram : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_TRIG_DRAM_REG);

begin
    -- -------------------------------------------------------------------------
    -- Register control interface

    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(CTRL_TRG_CONTROL_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_TRG_CONTROL_REG_W),

        strobed_bits_o => strobed_bits
    );

    pulsed_bits_inst : entity work.all_pulsed_bits port map (
        clk_i => clk_i,

        read_strobe_i => read_strobe_i(CTRL_TRG_PULSED_REG_R),
        read_data_o => read_data_o(CTRL_TRG_PULSED_REG_R),
        read_ack_o => read_ack_o(CTRL_TRG_PULSED_REG_R),

        pulsed_bits_i => pulsed_bits
    );

    read_data_o(CTRL_TRG_READBACK_REGS) <= readback_registers;
    read_ack_o(CTRL_TRG_READBACK_REGS) <= (others => '1');
    write_ack_o(CTRL_TRG_READBACK_REGS) <= (others => '1');

    register_file_inst : entity work.register_file port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(CTRL_TRG_CONFIG_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_TRG_CONFIG_REGS),
        register_data_o => config_registers
    );
    read_data_o(CTRL_TRG_CONFIG_REGS) <= config_registers;
    read_ack_o(CTRL_TRG_CONFIG_REGS) <= (others => '1');


    -- -------------------------------------------------------------------------
    -- Register mappings

    turn_setup_o.start_sync   <= strobed_bits(0);
    turn_setup_o.start_sample <= strobed_bits(1);
    seq_setup_o(0).arm        <= strobed_bits(2);
    seq_setup_o(0).disarm     <= strobed_bits(3);
    seq_setup_o(1).arm        <= strobed_bits(4);
    seq_setup_o(1).disarm     <= strobed_bits(5);
    dram0_setup_o.arm         <= strobed_bits(6);
    dram0_setup_o.disarm      <= strobed_bits(7);
    soft_trigger_o            <= strobed_bits(8);

    pulsed_bits <= (
        TRIGGER_SET => triggers_i,
        others => '0'
    );

    readback_status <= (
        -- Revolution clock readbacks
        0 => turn_readback_i.sync_busy,
        1 => turn_readback_i.sync_phase,
        2 => turn_readback_i.sync_error,
        3 => turn_readback_i.sample_busy,
        4 => turn_readback_i.sample_phase,
        5 => seq_readback_i(0).armed,
        6 => seq_readback_i(1).armed,
        7 => dram0_readback_i.armed,
        25 downto 16 => std_logic_vector(turn_readback_i.sample_count),
        others => '0'
    );

    readback_sources <= (
        6 downto 0 => seq_readback_i(0).source,
        14 downto 8 => seq_readback_i(1).source,
        22 downto 16 => dram0_readback_i.source,
        others => '0'
    );

    turn_setup_o.max_bunch <= bunch_count_t(config_turn_setup(9 downto 0));
    turn_setup_o.clock_offsets(0) <=
        bunch_count_t(config_turn_setup(19 downto 10));
    turn_setup_o.clock_offsets(1) <=
        bunch_count_t(config_turn_setup(29 downto 20));
    blanking_interval_o(0) <= unsigned(config_blanking(15 downto 0));
    blanking_interval_o(1) <= unsigned(config_blanking(31 downto 16));

    seq_setup_o(0).delay    <= unsigned(config_delay_seq_0(23 downto 0));
    seq_setup_o(1).delay    <= unsigned(config_delay_seq_1(23 downto 0));
    seq_setup_o(0).enables  <= config_trig_seq(6  downto 0);
    seq_setup_o(0).blanking <= config_trig_seq(14 downto 8);
    seq_setup_o(1).enables  <= config_trig_seq(22 downto 16);
    seq_setup_o(1).blanking <= config_trig_seq(30 downto 24);

    dram0_setup_o.delay     <= unsigned(config_delay_dram(23 downto 0));
    dram0_setup_o.enables   <= config_trig_dram(6 downto 0);
    dram0_setup_o.blanking  <= config_trig_dram(14 downto 8);
    dram0_turn_select_o     <= unsigned(config_trig_dram(16 downto 16));
    dram0_blanking_select_o <= reverse(config_trig_dram(18 downto 17));
end;
