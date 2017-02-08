-- Trigger register mapping

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.trigger_defs.all;

entity triggers_registers is
    port (
        clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector(0 to 8);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 8);
        read_strobe_i : in std_logic_vector(0 to 8);
        read_data_o : out reg_data_array_t(0 to 8);
        read_ack_o : out std_logic_vector(0 to 8);

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

architecture triggers_registers of triggers_registers is
    constant CONTROL_REG : natural := 0;
    constant PULSED_REG : natural := 1;
    subtype CONFIG_REGS is natural range 2 to 8;

    -- Register interface
    signal strobed_bits : reg_data_t;
    signal pulsed_bits : reg_data_t;
    signal register_data : reg_data_array_t(0 to 6);
    signal readback_register : reg_data_t;

begin
    -- -------------------------------------------------------------------------
    -- Register control interface

    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONTROL_REG),
        strobed_bits_o => strobed_bits
    );

    read_data_o(CONTROL_REG) <= readback_register;
    read_ack_o(CONTROL_REG) <= '1';

    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => clk_i,

        write_strobe_i => write_strobe_i(PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(PULSED_REG),
        read_strobe_i => read_strobe_i(PULSED_REG),
        read_data_o => read_data_o(PULSED_REG),
        read_ack_o => read_ack_o(PULSED_REG),

        pulsed_bits_i => pulsed_bits
    );

    register_file_inst : entity work.register_file port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(CONFIG_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONFIG_REGS),
        register_data_o => register_data
    );
    read_data_o(CONFIG_REGS) <= register_data;
    read_ack_o(CONFIG_REGS) <= (others => '1');


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

    readback_register <= (
        -- Revolution clock readbacks
        0 => turn_readback_i.sync_busy,
        1 => turn_readback_i.sync_phase,
        2 => turn_readback_i.sync_error,
        3 => turn_readback_i.sample_busy,
        4 => turn_readback_i.sample_phase,
        13 downto 5 => std_logic_vector(turn_readback_i.sample_count),
        16 => seq_readback_i(0).armed,
        17 => seq_readback_i(1).armed,
        18 => dram0_readback_i.armed,
        others => '0'
    );

    pulsed_bits <= (
        TRIGGER_SET => triggers_i,
        others => '0'
    );

    turn_setup_o.max_bunch <= bunch_count_t(register_data(0)(8 downto 0));
    turn_setup_o.clock_offsets(0) <=
        bunch_count_t(register_data(0)(18 downto 10));
    turn_setup_o.clock_offsets(1) <=
        bunch_count_t(register_data(0)(28 downto 20));
    blanking_interval_o(0) <= unsigned(register_data(1)(15 downto 0));
    blanking_interval_o(1) <= unsigned(register_data(1)(31 downto 16));

    seq_setup_o(0).delay    <= unsigned(register_data(2)(23 downto 0));
    seq_setup_o(1).delay    <= unsigned(register_data(3)(23 downto 0));
    seq_setup_o(0).enables  <= register_data(4)(6  downto 0);
    seq_setup_o(0).blanking <= register_data(4)(14 downto 8);
    seq_setup_o(1).enables  <= register_data(4)(22 downto 16);
    seq_setup_o(1).blanking <= register_data(4)(30 downto 24);

    dram0_setup_o.delay     <= unsigned(register_data(5)(23 downto 0));
    dram0_setup_o.enables   <= register_data(6)(6 downto 0);
    dram0_setup_o.blanking  <= register_data(6)(14 downto 8);
    dram0_turn_select_o     <= unsigned(register_data(6)(16 downto 16));
    dram0_blanking_select_o <= reverse(register_data(6)(18 downto 17));
end;
