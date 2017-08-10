-- Trigger handling and revolution clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.trigger_defs.all;
use work.register_defs.all;

entity trigger_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector(CTRL_TRG_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(CTRL_TRG_REGS);
        read_strobe_i : in std_logic_vector(CTRL_TRG_REGS);
        read_data_o : out reg_data_array_t(CTRL_TRG_REGS);
        read_ack_o : out std_logic_vector(CTRL_TRG_REGS);

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
        turn_clock_adc_o : out std_logic_vector(CHANNELS);
        seq_start_o : out std_logic_vector(CHANNELS);
        dram0_trigger_o : out std_logic
    );
end;

architecture arch of trigger_top is
    -- Input signals converted to synchronous rising edge pulse
    signal revolution_clock : std_logic;    -- On ADC clock
    signal blanking_trigger : std_logic;

    -- Revolution clock control
    signal turn_setup : turn_clock_setup_t;
    signal turn_readback : turn_clock_readback_t;
    signal turn_clock_dsp : std_logic_vector(CHANNELS);

    -- Blanking
    signal blanking_interval : unsigned_array(CHANNELS)(15 downto 0);

    -- Triggers
    signal soft_trigger : std_logic;
    signal triggers : std_logic_vector(TRIGGER_SET);

    -- Sequencer triggering
    signal seq_setup : trigger_setup_channels;
    signal seq_readback : trigger_readback_channels;

    -- DRAM triggering
    signal dram0_setup : trigger_setup_t;
    signal dram0_readback : trigger_readback_t;

    signal dram0_turn_select : unsigned(0 downto 0);
    signal dram0_turn_clock : std_logic;
    signal dram0_blanking_select : std_logic_vector(CHANNELS);
    signal dram0_blanking_window : std_logic;

begin
    -- Register control interface
    registers : entity work.trigger_registers port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,

        turn_setup_o => turn_setup,
        turn_readback_i => turn_readback,

        soft_trigger_o => soft_trigger,
        triggers_i => triggers,
        blanking_trigger_i => blanking_trigger,

        blanking_interval_o => blanking_interval,

        seq_setup_o => seq_setup,
        seq_readback_i => seq_readback,

        dram0_turn_select_o => dram0_turn_select,
        dram0_blanking_select_o => dram0_blanking_select,
        dram0_setup_o => dram0_setup,
        dram0_readback_i => dram0_readback
    );


    -- Signal conditioning for asynchronous inputs
    setup : entity work.trigger_setup port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        revolution_clock_i => revolution_clock_i,
        event_trigger_i => event_trigger_i,
        postmortem_trigger_i => postmortem_trigger_i,
        blanking_trigger_i => blanking_trigger_i,

        soft_trigger_i => soft_trigger,
        adc_trigger_i => adc_trigger_i,
        seq_trigger_i => seq_trigger_i,

        blanking_trigger_o => blanking_trigger,
        revolution_clock_o => revolution_clock,
        trigger_set_o => triggers
    );


    -- Revolution clock
    turn_clock : entity work.trigger_turn_clock port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        setup_i => turn_setup,
        readback_o => turn_readback,

        revolution_clock_i => revolution_clock,
        turn_clock_o => turn_clock_adc_o
    );


    -- Blanking window
    blanking : entity work.trigger_blanking port map (
        dsp_clk_i => dsp_clk_i,

        blanking_i => blanking_trigger,
        blanking_interval_i => blanking_interval,
        turn_clock_i => turn_clock_dsp,
        blanking_window_o => blanking_window_o
    );


    -- Sequence triggers
    gen : for c in CHANNELS generate
        -- We need a DSP clocked version of the turn clock for the rest of our
        -- trigger processing
        turn_clock : entity work.pulse_adc_to_dsp port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            pulse_i => turn_clock_adc_o(c),
            pulse_o => turn_clock_dsp(c)
        );

        seq_trigger : entity work.trigger_target port map (
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock_dsp(c),

            triggers_i => triggers,
            blanking_window_i => blanking_window_o(c),
            setup_i => seq_setup(c),

            readback_o => seq_readback(c),
            trigger_o => seq_start_o(c)
        );
    end generate;


    -- For the DRAM0 trigger we need a choice of turn clock and blanking
    dram0_turn_clock <= turn_clock_dsp(to_integer(dram0_turn_select));
    dram0_blanking_window <=
        vector_or(blanking_window_o and dram0_blanking_select);

    -- Memory capture trigger
    dram0_trigger : entity work.trigger_target port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => dram0_turn_clock,

        triggers_i => triggers,
        blanking_window_i => dram0_blanking_window,
        setup_i => dram0_setup,

        readback_o => dram0_readback,
        trigger_o => dram0_trigger_o
    );
end;
