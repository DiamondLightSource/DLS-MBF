-- Top level controller for DSP units.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.dsp_defs.all;

entity dsp_control_top is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- Control register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- DSP controls
        control_to_dsp_o : out control_to_dsp_array_t;
        dsp_to_control_i : in dsp_to_control_array_t;

        -- DRAM0 capture control
        dram0_capture_enable_o : out std_logic;
        dram0_data_ready_i : in std_logic;
        dram0_capture_address_i : in std_logic_vector;
        dram0_data_valid_o : out std_logic;
        dram0_data_o : out std_logic_vector;
        dram0_data_error_i : in std_logic;
        dram0_addr_error_i : in std_logic;
        dram0_brsp_error_i : in std_logic;

        -- DRAM1 data and control (on DSP clock)
        dram1_address_o : out unsigned;
        dram1_data_o : out std_logic_vector;
        dram1_data_valid_o : out std_logic;
        dram1_data_ready_i : in std_logic;
        dram1_brsp_error_i : in std_logic;

        -- External triggers
        revolution_clock_i : in std_logic;
        event_trigger_i : in std_logic;
        postmortem_trigger_i : in std_logic;
        blanking_trigger_i : in std_logic
    );
end;

architecture dsp_control_top of dsp_control_top is
    signal pulsed_bits : reg_data_t;
    signal control_register : reg_data_t;

    signal adc_mux : std_logic;
    signal nco_0_mux : std_logic;
    signal nco_1_mux : std_logic;
    signal mux_adc_out   : signed_array(CHANNELS)(ADC_DATA_RANGE);
    signal mux_nco_0_out : signed_array(CHANNELS)(NCO_DATA_RANGE);
    signal mux_nco_1_out : signed_array(CHANNELS)(NCO_DATA_RANGE);

    -- DRAM1 interface
    signal dram1_strobe : std_logic_vector(CHANNELS);
    signal dram1_error : std_logic_vector(CHANNELS);
    signal dram1_address : unsigned_array(CHANNELS)(DRAM1_ADDR_RANGE);
    signal dram1_data : vector_array(CHANNELS)(dram1_data_o'RANGE);

    -- Triggering and events interface
    signal adc_trigger : std_logic_vector(CHANNELS);
    signal seq_trigger : std_logic_vector(CHANNELS);
    signal blanking_window : std_logic_vector(CHANNELS);
    signal turn_clock_adc : std_logic_vector(CHANNELS);
    signal turn_clock_dsp : std_logic_vector(CHANNELS);
    signal seq_start : std_logic_vector(CHANNELS);
    signal dram0_trigger : std_logic;

begin
    -- Capture of pulsed bits.
    pulsed_bits_inst : entity work.pulsed_bits port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(CTRL_PULSED_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_PULSED_REG),
        read_strobe_i => read_strobe_i(CTRL_PULSED_REG),
        read_data_o => read_data_o(CTRL_PULSED_REG),
        read_ack_o => read_ack_o(CTRL_PULSED_REG),

        pulsed_bits_i => pulsed_bits
    );

    -- General control register
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(CTRL_CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(CTRL_CONTROL_REG),
        register_data_o(0) => control_register
    );
    read_data_o(CTRL_CONTROL_REG) <= control_register;
    read_ack_o(CTRL_CONTROL_REG) <= '1';


    pulsed_bits <= (
        0 => dram1_brsp_error_i,
        others => '0'
    );


    -- Channel data multiplexing control
    adc_mux <= control_register(0);
    nco_0_mux <= control_register(1);
    nco_1_mux <= control_register(2);
    dsp_control_mux_inst : entity work.dsp_control_mux port map (
        clk_i => adc_clk_i,

        adc_mux_i => adc_mux,
        nco_0_mux_i => nco_0_mux,
        nco_1_mux_i => nco_1_mux,

        dsp_to_control_i => dsp_to_control_i,

        adc_o => mux_adc_out,
        nco_0_o => mux_nco_0_out,
        nco_1_o => mux_nco_1_out
    );
    mux_gen : for c in CHANNELS generate
        control_to_dsp_o(c).adc_data <= mux_adc_out(c);
        control_to_dsp_o(c).nco_0_data <= mux_nco_0_out(c);
        control_to_dsp_o(c).nco_1_data <= mux_nco_1_out(c);
    end generate;


    -- DRAM0 capture control
    fast_memory_top_inst : entity work.fast_memory_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(CTRL_MEM_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_MEM_REGS),
        read_strobe_i => read_strobe_i(CTRL_MEM_REGS),
        read_data_o => read_data_o(CTRL_MEM_REGS),
        read_ack_o => read_ack_o(CTRL_MEM_REGS),

        dsp_to_control_i => dsp_to_control_i,
        memory_trigger_i => dram0_trigger,

        capture_enable_o => dram0_capture_enable_o,
        data_ready_i => dram0_data_ready_i,
        capture_address_i => dram0_capture_address_i,
        data_valid_o => dram0_data_valid_o,
        data_o => dram0_data_o,
        data_error_i => dram0_data_error_i,
        addr_error_i => dram0_addr_error_i,
        brsp_error_i => dram0_brsp_error_i
    );


    -- DRAM1 memory multiplexer
    chan_gen : for c in CHANNELS generate
        dram1_strobe(c) <= dsp_to_control_i(c).dram1_strobe;
        dram1_address(c) <= dsp_to_control_i(c).dram1_address;
        dram1_data(c) <= dsp_to_control_i(c).dram1_data;
        control_to_dsp_o(c).dram1_error <= dram1_error(c);
    end generate;
    slow_memory_top_inst : entity work.slow_memory_top port map (
        dsp_clk_i => dsp_clk_i,

        dsp_strobe_i => dram1_strobe,
        dsp_address_i => dram1_address,
        dsp_data_i => dram1_data,
        dsp_error_o => dram1_error,

        dram1_address_o => dram1_address_o,
        dram1_data_o => dram1_data_o,
        dram1_data_valid_o => dram1_data_valid_o,
        dram1_data_ready_i => dram1_data_ready_i
    );


    -- Triggers and event generation
    trigger_inst : entity work.trigger_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(CTRL_TRIGGER_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_TRIGGER_REGS),
        read_strobe_i => read_strobe_i(CTRL_TRIGGER_REGS),
        read_data_o => read_data_o(CTRL_TRIGGER_REGS),
        read_ack_o => read_ack_o(CTRL_TRIGGER_REGS),

        revolution_clock_i => revolution_clock_i,
        event_trigger_i => event_trigger_i,
        postmortem_trigger_i => postmortem_trigger_i,
        blanking_trigger_i => blanking_trigger_i,

        adc_trigger_i => adc_trigger,
        seq_trigger_i => seq_trigger,

        blanking_window_o => blanking_window,
        turn_clock_adc_o => turn_clock_adc,
        turn_clock_dsp_o => turn_clock_dsp,
        seq_start_o => seq_start,
        dram0_trigger_o => dram0_trigger
    );
    -- Map events to individual DSP units
    triggers_gen : for c in CHANNELS generate
        adc_trigger(c) <= dsp_to_control_i(c).adc_trigger;
        seq_trigger(c) <= dsp_to_control_i(c).seq_trigger;
        control_to_dsp_o(c).blanking <= blanking_window(c);
        control_to_dsp_o(c).turn_clock_adc <= turn_clock_adc(c);
        control_to_dsp_o(c).turn_clock_dsp <= turn_clock_dsp(c);
        control_to_dsp_o(c).seq_start <= seq_start(c);
    end generate;
end;
