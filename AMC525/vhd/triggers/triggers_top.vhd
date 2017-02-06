-- Trigger handling and revolution clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity triggers_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector(0 to 3);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 3);
        read_strobe_i : in std_logic_vector(0 to 3);
        read_data_o : out reg_data_array_t(0 to 3);
        read_ack_o : out std_logic_vector(0 to 3);

        -- External trigger sources
        revolution_clock_i : in std_logic;
        event_trigger_i : in std_logic;
        postmortem_trigger_i : in std_logic;
        blanking_trigger_i : in std_logic;

        -- Internal trigger sources
        adc_trigger_i : in std_logic_vector(CHANNELS);
        seq_trigger_i : in std_logic_vector(CHANNELS);

        -- Trigger outputs
        blanking_o : out std_logic_vector(CHANNELS);
        turn_clock_o : out std_logic_vector(CHANNELS);
        seq_start_o : out std_logic_vector(CHANNELS);
        dram0_trigger_o : out std_logic
    );
end;

architecture triggers_top of triggers_top is
    constant CONTROL_REG : natural := 0;
    constant PULSED_REG : natural := 1;
    subtype CONFIG_REGS is natural range 2 to 3;

    -- Register interface
    signal strobed_bits : reg_data_t;
    signal pulsed_bits : reg_data_t;
    signal register_data : reg_data_array_t(0 to 1);
    signal readback_register : reg_data_t;

    -- Revolution clock control
    signal start_sync : std_logic;
    signal start_sample : std_logic;
    signal max_bunch : bunch_count_t;
    signal clock_offsets : unsigned_array(CHANNELS)(bunch_count_t'RANGE);
    signal sync_done : std_logic;
    signal sync_phase : std_logic;
    signal sync_error : std_logic;
    signal sample_done : std_logic;
    signal sample_phase : std_logic;
    signal sample_count : bunch_count_t;

    signal event_trigger : std_logic;
    signal postmortem_trigger : std_logic;
    signal blanking_trigger : std_logic;

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

    start_sync <= strobed_bits(0);
    start_sample <= strobed_bits(1);

    readback_register <= (
        -- Revolution clock readbacks
        0 => sync_done,
        1 => sync_phase,
        2 => sync_error,
        3 => sample_done,
        4 => sample_phase,
        13 downto 5 => std_logic_vector(sample_count),
        others => '0'
    );

    pulsed_bits <= (
        others => '0'
    );

    max_bunch <= bunch_count_t(register_data(0)(8 downto 0));
    clock_offsets(0) <= bunch_count_t(register_data(0)(18 downto 10));
    clock_offsets(1) <= bunch_count_t(register_data(0)(28 downto 20));


    -- -------------------------------------------------------------------------
    -- Revolution clock

    turn_clock_inst : entity work.triggers_turn_clock port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        start_sync_i => start_sync,
        start_sample_i => start_sample,
        max_bunch_i => max_bunch,
        clock_offsets_i => clock_offsets,

        sync_done_o => sync_done,
        sync_phase_o => sync_phase,
        sync_error_o => sync_error,
        sample_done_o => sample_done,
        sample_phase_o => sample_phase,
        sample_count_o => sample_count,

        revolution_clock_i => revolution_clock_i,
        turn_clock_o => turn_clock_o
    );

    -- Signal conditioning for asynchronous inputs
    event_condition_inst : entity work.triggers_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => event_trigger_i,
        trigger_o => event_trigger
    );
    postmortem_condition_inst : entity work.triggers_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => postmortem_trigger_i,
        trigger_o => postmortem_trigger
    );
    blanking_condition_inst : entity work.triggers_condition port map (
        clk_i => dsp_clk_i,
        trigger_i => blanking_trigger_i,
        trigger_o => blanking_trigger
    );


    seq_start_o <= (others => '0');
    dram0_trigger_o <= '0';
end;
