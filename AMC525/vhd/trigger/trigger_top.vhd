-- Trigger handling and revolution clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity trigger_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector(0 to 8);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 8);
        read_strobe_i : in std_logic_vector(0 to 8);
        read_data_o : out reg_data_array_t(0 to 8);
        read_ack_o : out std_logic_vector(0 to 8);

        -- External trigger sources
        revolution_clock_i : in std_logic;
        event_trigger_i : in std_logic;
        postmortem_trigger_i : in std_logic;
        blanking_trigger_i : in std_logic;

        -- Internal trigger sources
        adc_trigger_i : in std_logic_vector(CHANNELS);
        seq_trigger_i : in std_logic_vector(CHANNELS);

        -- Trigger outputs
        blanking_window_o : out std_logic_vector(CHANNELS);
        turn_clock_o : out std_logic_vector(CHANNELS);
        seq_start_o : out std_logic_vector(CHANNELS);
        dram0_trigger_o : out std_logic
    );
end;

architecture trigger_top of trigger_top is
    constant CONTROL_REG : natural := 0;
    constant PULSED_REG : natural := 1;
    subtype CONFIG_REGS is natural range 2 to 8;

    -- Register interface
    signal strobed_bits : reg_data_t;
    signal pulsed_bits : reg_data_t;
    signal register_data : reg_data_array_t(0 to 6);
    signal readback_register : reg_data_t;

    -- Input signals converted to synchronous rising edge pulse
    signal revolution_clock : std_logic;    -- On ADC clock
    signal event_trigger : std_logic;
    signal postmortem_trigger : std_logic;
    signal blanking_trigger : std_logic;

    -- Revolution clock control
    signal start_sync : std_logic;
    signal start_sample : std_logic;
    signal max_bunch : bunch_count_t;
    signal clock_offsets : unsigned_array(CHANNELS)(bunch_count_t'RANGE);
    signal sync_busy : std_logic;
    signal sync_phase : std_logic;
    signal sync_error : std_logic;
    signal sample_busy : std_logic;
    signal sample_phase : std_logic;
    signal sample_count : bunch_count_t;

    -- Blanking
    signal blanking_interval : unsigned_array(CHANNELS)(15 downto 0);

    subtype TRIGGER_SET is natural range 6 downto 0;
    signal soft_trigger : std_logic;
    signal soft_trigger_delay : std_logic;
    signal triggers : std_logic_vector(TRIGGER_SET);

    -- Sequencer triggering
    signal seq_arm : std_logic_vector(CHANNELS);
    signal seq_disarm : std_logic_vector(CHANNELS);
    signal seq_delay : unsigned_array(CHANNELS)(23 downto 0);
    signal seq_armed : std_logic_vector(CHANNELS);
    signal seq_enables : vector_array(CHANNELS)(TRIGGER_SET);
    signal seq_blanking : vector_array(CHANNELS)(TRIGGER_SET);
    signal seq_source : vector_array(CHANNELS)(TRIGGER_SET);

    -- DRAM triggering
    signal dram0_arm : std_logic;
    signal dram0_disarm : std_logic;
    signal dram0_delay : unsigned(23 downto 0);
    signal dram0_armed : std_logic;
    signal dram0_enables : std_logic_vector(TRIGGER_SET);
    signal dram0_blanking : std_logic_vector(TRIGGER_SET);
    signal dram0_source : std_logic_vector(TRIGGER_SET);

    signal dram0_turn_select : unsigned(0 downto 0);
    signal dram0_turn_clock : std_logic;
    signal dram0_blanking_select : std_logic_vector(CHANNELS);
    signal dram0_blanking_window : std_logic;

begin
    -- -------------------------------------------------------------------------
    -- Register control interface

    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONTROL_REG),
        strobed_bits_o => strobed_bits
    );

    read_data_o(CONTROL_REG) <= readback_register;
    read_ack_o(CONTROL_REG) <= '1';

    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(PULSED_REG),
        read_strobe_i => read_strobe_i(PULSED_REG),
        read_data_o => read_data_o(PULSED_REG),
        read_ack_o => read_ack_o(PULSED_REG),

        pulsed_bits_i => pulsed_bits
    );

    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(CONFIG_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONFIG_REGS),
        register_data_o => register_data
    );
    read_data_o(CONFIG_REGS) <= register_data;
    read_ack_o(CONFIG_REGS) <= (others => '1');


    -- -------------------------------------------------------------------------
    -- Register mappings

    start_sync      <= strobed_bits(0);
    start_sample    <= strobed_bits(1);
    seq_arm(0)      <= strobed_bits(2);
    seq_arm(1)      <= strobed_bits(3);
    seq_disarm(0)   <= strobed_bits(4);
    seq_disarm(1)   <= strobed_bits(5);
    dram0_arm       <= strobed_bits(6);
    dram0_disarm    <= strobed_bits(7);
    soft_trigger    <= strobed_bits(8);

    readback_register <= (
        -- Revolution clock readbacks
        0 => sync_busy,
        1 => sync_phase,
        2 => sync_error,
        3 => sample_busy,
        4 => sample_phase,
        13 downto 5 => std_logic_vector(sample_count),
        16 => seq_armed(0),
        17 => seq_armed(1),
        18 => dram0_armed,
        others => '0'
    );

    pulsed_bits <= (
        TRIGGER_SET => triggers,
        others => '0'
    );

    max_bunch <= bunch_count_t(register_data(0)(8 downto 0));
    clock_offsets(0) <= bunch_count_t(register_data(0)(18 downto 10));
    clock_offsets(1) <= bunch_count_t(register_data(0)(28 downto 20));
    blanking_interval(0) <= unsigned(register_data(1)(15 downto 0));
    blanking_interval(1) <= unsigned(register_data(1)(31 downto 16));

    seq_delay(0) <= unsigned(register_data(2)(23 downto 0));
    seq_delay(1) <= unsigned(register_data(3)(23 downto 0));
    seq_enables(0)  <= register_data(4)(6 downto 0);
    seq_blanking(0) <= register_data(4)(14 downto 8);
    seq_enables(1)  <= register_data(4)(22 downto 16);
    seq_blanking(1) <= register_data(4)(30 downto 24);

    dram0_delay  <= unsigned(register_data(5)(23 downto 0));
    dram0_enables   <= register_data(6)(6 downto 0);
    dram0_blanking  <= register_data(6)(14 downto 8);
    dram0_turn_select <= unsigned(register_data(6)(16 downto 16));
    dram0_blanking_select <= reverse(register_data(6)(18 downto 17));



    -- -------------------------------------------------------------------------
    -- Signal conditioning for asynchronous inputs

    -- Note the revolution clock is synchronised to the ADC clock
    revolution_condition_inst : entity work.trigger_condition port map (
        clk_i => adc_clk_i,
        trigger_i => revolution_clock_i,
        trigger_o => revolution_clock
    );

    event_condition_inst : entity work.trigger_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => event_trigger_i,
        trigger_o => event_trigger
    );

    postmortem_condition_inst : entity work.trigger_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => postmortem_trigger_i,
        trigger_o => postmortem_trigger
    );

    blanking_condition_inst : entity work.trigger_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => blanking_trigger_i,
        trigger_o => blanking_trigger
    );


    -- -------------------------------------------------------------------------
    -- Revolution clock

    turn_clock_inst : entity work.trigger_turn_clock port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        start_sync_i => start_sync,
        start_sample_i => start_sample,
        max_bunch_i => max_bunch,
        clock_offsets_i => clock_offsets,

        sync_busy_o => sync_busy,
        sync_phase_o => sync_phase,
        sync_error_o => sync_error,
        sample_busy_o => sample_busy,
        sample_phase_o => sample_phase,
        sample_count_o => sample_count,

        revolution_clock_i => revolution_clock,
        turn_clock_o => turn_clock_o
    );


    -- -------------------------------------------------------------------------
    -- General triggers and blanking

    trigger_blanking_inst : entity work.trigger_blanking port map (
        dsp_clk_i => dsp_clk_i,

        blanking_i => blanking_trigger,
        blanking_interval_i => blanking_interval,
        turn_clock_i => turn_clock_o,
        blanking_window_o => blanking_window_o
    );

    -- Delay the soft trigger so we can strobe arm and trigger together
    soft_delay_inst : entity work.dlyline port map (
        clk_i => dsp_clk_i,
        data_i(0) => soft_trigger,
        data_o(0) => soft_trigger_delay
    );

    triggers <= (
        0 => soft_trigger_delay,
        1 => event_trigger,
        2 => postmortem_trigger,
        3 => adc_trigger_i(0),
        4 => adc_trigger_i(1),
        5 => seq_trigger_i(0),
        6 => seq_trigger_i(1)
    );

    gen : for c in CHANNELS generate
        seq_trigger_inst : entity work.trigger_sources port map (
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock_o(c),

            triggers_i => triggers,
            blanking_window_i => blanking_window_o(c),

            arm_i => seq_arm(c),
            disarm_i => seq_disarm(c),
            delay_i => seq_delay(c),
            trigger_o => seq_start_o(c),
            armed_o => seq_armed(c),

            enables_i => seq_enables(c),
            blanking_i => seq_blanking(c),
            source_o => seq_source(c)
        );
    end generate;

    -- For the DRAM0 trigger we need a choice of turn clock and blanking
    dram0_turn_clock <= turn_clock_o(to_integer(dram0_turn_select));
    dram0_blanking_window <=
        vector_or(blanking_window_o and dram0_blanking_select);

    dram0_trigger_inst : entity work.trigger_sources port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => dram0_turn_clock,

        triggers_i => triggers,
        blanking_window_i => dram0_blanking_window,

        arm_i => dram0_arm,
        disarm_i => dram0_disarm,
        delay_i => dram0_delay,
        trigger_o => dram0_trigger_o,
        armed_o => dram0_armed,

        enables_i => dram0_enables,
        blanking_i => dram0_blanking,
        source_o => dram0_source
    );
end;
