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
        write_strobe_i : in std_logic_vector(CTRL_TRG_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(CTRL_TRG_REGS);
        read_strobe_i : in std_logic_vector(CTRL_TRG_REGS);
        read_data_o : out reg_data_array_t(CTRL_TRG_REGS);
        read_ack_o : out std_logic_vector(CTRL_TRG_REGS);

        -- Revolution clock synchronisation
        turn_setup_o : out turn_clock_setup_t;
        turn_readback_i : in turn_clock_readback_t;

        -- Trigger control
        soft_trigger_o : out std_logic;
        triggers_i : in std_logic_vector(TRIGGER_SET);
        blanking_trigger_i : in std_logic;

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
    signal readback_status : reg_data_t;
    signal readback_sources : reg_data_t;
    signal config_registers : reg_data_array_t(CTRL_TRG_CONFIG_REGS);

    alias config_turn_setup : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_TURN_REG);
    alias config_blanking : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_BLANKING_REG);
    alias config_delay_seq_0 : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_SEQ0_REG);
    alias config_delay_seq_1 : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_SEQ1_REG);
    alias config_delay_dram : reg_data_t is
        config_registers(CTRL_TRG_CONFIG_DRAM0_REG);
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

    read_data_o(CTRL_TRG_STATUS_REG) <= readback_status;
    read_ack_o(CTRL_TRG_STATUS_REG) <= '1';
    write_ack_o(CTRL_TRG_STATUS_REG) <= '1';

    read_data_o(CTRL_TRG_SOURCES_REG) <= readback_sources;
    read_ack_o(CTRL_TRG_SOURCES_REG) <= '1';
    write_ack_o(CTRL_TRG_SOURCES_REG) <= '1';

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

    turn_setup_o.start_sync  <= strobed_bits(CTRL_TRG_CONTROL_SYNC_TURN_BIT);
    turn_setup_o.start_sample <= strobed_bits(CTRL_TRG_CONTROL_SAMPLE_TURN_BIT);
    seq_setup_o(0).arm       <= strobed_bits(CTRL_TRG_CONTROL_SEQ0_ARM_BIT);
    seq_setup_o(0).disarm    <= strobed_bits(CTRL_TRG_CONTROL_SEQ0_DISARM_BIT);
    seq_setup_o(1).arm       <= strobed_bits(CTRL_TRG_CONTROL_SEQ1_ARM_BIT);
    seq_setup_o(1).disarm    <= strobed_bits(CTRL_TRG_CONTROL_SEQ1_DISARM_BIT);
    dram0_setup_o.arm        <= strobed_bits(CTRL_TRG_CONTROL_DRAM0_ARM_BIT);
    dram0_setup_o.disarm     <= strobed_bits(CTRL_TRG_CONTROL_DRAM0_DISARM_BIT);
    soft_trigger_o           <= strobed_bits(CTRL_TRG_CONTROL_TRIGGER_BIT);

    pulsed_bits <= (
        CTRL_TRG_PULSED_TRIGGERS_BITS => triggers_i,
        CTRL_TRG_PULSED_BLANKING_BIT => blanking_trigger_i,
        others => '0'
    );

    readback_status <= (
        -- Revolution clock readbacks
        CTRL_TRG_STATUS_SYNC_BUSY_BIT    => turn_readback_i.sync_busy,
        CTRL_TRG_STATUS_SYNC_PHASE_BIT   => turn_readback_i.sync_phase,
        CTRL_TRG_STATUS_SYNC_ERROR_BIT   => turn_readback_i.sync_error,
        CTRL_TRG_STATUS_SAMPLE_BUSY_BIT  => turn_readback_i.sample_busy,
        CTRL_TRG_STATUS_SAMPLE_PHASE_BIT => turn_readback_i.sample_phase,
        CTRL_TRG_STATUS_SEQ0_ARMED_BIT   => seq_readback_i(0).armed,
        CTRL_TRG_STATUS_SEQ1_ARMED_BIT   => seq_readback_i(1).armed,
        CTRL_TRG_STATUS_DRAM0_ARMED_BIT  => dram0_readback_i.armed,
        CTRL_TRG_STATUS_SAMPLE_BITS =>
            std_logic_vector(turn_readback_i.sample_count),
        others => '0'
    );

    readback_sources <= (
        CTRL_TRG_SOURCES_SEQ0_BITS  => seq_readback_i(0).source,
        CTRL_TRG_SOURCES_SEQ1_BITS  => seq_readback_i(1).source,
        CTRL_TRG_SOURCES_DRAM0_BITS => dram0_readback_i.source,
        others => '0'
    );

    turn_setup_o.max_bunch <=
        bunch_count_t(config_turn_setup(CTRL_TRG_CONFIG_TURN_MAX_BUNCH_BITS));
    turn_setup_o.clock_offsets(0) <=
        bunch_count_t(config_turn_setup(CTRL_TRG_CONFIG_TURN_DSP0_OFFSET_BITS));
    turn_setup_o.clock_offsets(1) <=
        bunch_count_t(config_turn_setup(CTRL_TRG_CONFIG_TURN_DSP1_OFFSET_BITS));
    blanking_interval_o(0) <=
        unsigned(config_blanking(CTRL_TRG_CONFIG_BLANKING_DSP0_BITS));
    blanking_interval_o(1) <=
        unsigned(config_blanking(CTRL_TRG_CONFIG_BLANKING_DSP1_BITS));

    seq_setup_o(0).delay <=
        unsigned(config_delay_seq_0(CTRL_TRG_CONFIG_SEQ0_DELAY_BITS));
    seq_setup_o(1).delay <=
        unsigned(config_delay_seq_1(CTRL_TRG_CONFIG_SEQ1_DELAY_BITS));
    seq_setup_o(0).enables <=
        config_trig_seq(CTRL_TRG_CONFIG_TRIG_SEQ_ENABLE0_BITS);
    seq_setup_o(0).blanking <=
        config_trig_seq(CTRL_TRG_CONFIG_TRIG_SEQ_BLANKING0_BITS);
    seq_setup_o(1).enables <=
        config_trig_seq(CTRL_TRG_CONFIG_TRIG_SEQ_ENABLE1_BITS);
    seq_setup_o(1).blanking <=
        config_trig_seq(CTRL_TRG_CONFIG_TRIG_SEQ_BLANKING1_BITS);

    dram0_setup_o.delay <=
        unsigned(config_delay_dram(CTRL_TRG_CONFIG_DRAM0_DELAY_BITS));
    dram0_setup_o.enables <=
        config_trig_dram(CTRL_TRG_CONFIG_TRIG_DRAM_ENABLE_BITS);
    dram0_setup_o.blanking <=
        config_trig_dram(CTRL_TRG_CONFIG_TRIG_DRAM_BLANKING_BITS);
    dram0_turn_select_o <=
        unsigned(config_trig_dram(CTRL_TRG_CONFIG_TRIG_DRAM_TURN_SEL_BITS));
    dram0_blanking_select_o <=
        reverse(config_trig_dram(CTRL_TRG_CONFIG_TRIG_DRAM_BLANKING_SEL_BITS));
end;
