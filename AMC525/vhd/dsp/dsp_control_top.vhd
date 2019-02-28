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
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Control register interface
        write_strobe_i : in std_ulogic_vector(CTRL_REGS_RANGE);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(CTRL_REGS_RANGE);
        read_strobe_i : in std_ulogic_vector(CTRL_REGS_RANGE);
        read_data_o : out reg_data_array_t(CTRL_REGS_RANGE);
        read_ack_o : out std_ulogic_vector(CTRL_REGS_RANGE);

        -- DSP controls and data streams from DSP units
        control_to_dsp_o : out control_to_dsp_array_t;
        dsp_to_control_i : in dsp_to_control_array_t;
        loopback_o : out std_ulogic_vector(CHANNELS);
        output_enable_o : out std_ulogic_vector(CHANNELS);

        -- DRAM0 capture control
        dram0_capture_enable_o : out std_ulogic;
        dram0_data_ready_i : in std_ulogic;
        dram0_capture_address_i : in std_ulogic_vector;
        dram0_data_valid_o : out std_ulogic;
        dram0_data_o : out std_ulogic_vector;
        dram0_data_error_i : in std_ulogic;
        dram0_addr_error_i : in std_ulogic;
        dram0_brsp_error_i : in std_ulogic;

        -- DRAM1 data and control (on DSP clock)
        dram1_address_o : out unsigned;
        dram1_data_o : out std_ulogic_vector;
        dram1_data_valid_o : out std_ulogic;
        dram1_data_ready_i : in std_ulogic;
        dram1_brsp_error_i : in std_ulogic;

        -- External triggers
        revolution_clock_i : in std_ulogic;
        event_trigger_i : in std_ulogic;
        postmortem_trigger_i : in std_ulogic;
        blanking_trigger_i : in std_ulogic;

        interrupts_o : out std_ulogic_vector
    );
end;

architecture arch of dsp_control_top is
    signal pulsed_bits : reg_data_t;
    signal control_register : reg_data_t;

    signal adc_mux : std_ulogic;
    signal nco_0_mux : std_ulogic;
    signal nco_1_mux : std_ulogic;
    signal nco_2_mux : std_ulogic;
    signal bank_mux : std_ulogic;
    signal mux_adc_out   : signed_array(CHANNELS)(ADC_DATA_RANGE);
    signal mux_nco_0_out : dsp_nco_from_mux_array_t;
    signal mux_nco_1_out : dsp_nco_from_mux_array_t;
    signal mux_nco_2_out : dsp_nco_from_mux_array_t;
    signal bank_select_out : unsigned_array(CHANNELS)(1 downto 0);

    -- DRAM1 interface
    signal dsp_dram1_valid : std_ulogic_vector(CHANNELS);
    signal dsp_dram1_ready : std_ulogic_vector(CHANNELS);
    signal dsp_dram1_address : unsigned_array(CHANNELS)(dram1_address_o'RANGE);
    signal dsp_dram1_data : vector_array(CHANNELS)(dram1_data_o'RANGE);
    signal dram1_valid : std_ulogic;
    signal dram1_ready : std_ulogic;
    signal dram1_address : dram1_address_o'SUBTYPE;
    signal dram1_data : dram1_data_o'SUBTYPE;

    -- Triggering and events interface
    signal adc_trigger : std_ulogic_vector(CHANNELS);
    signal seq_trigger : std_ulogic_vector(CHANNELS);
    signal blanking_window : std_ulogic;
    signal turn_clock : std_ulogic;
    signal seq_start : std_ulogic_vector(CHANNELS);
    signal seq_busy : std_ulogic_vector(CHANNELS);
    signal dram0_trigger : std_ulogic;
    signal dram0_phase : std_ulogic;
    signal tune_pll_ready : vector_array(CHANNELS)(1 downto 0);

begin
    -- Capture of pulsed bits.
    pulsed_bits_inst : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(CTRL_PULSED_REG),
        read_data_o => read_data_o(CTRL_PULSED_REG),
        read_ack_o => read_ack_o(CTRL_PULSED_REG),
        pulsed_bits_i => pulsed_bits
    );
    write_ack_o(CTRL_PULSED_REG) <= '1';

    -- General control register
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(CTRL_CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(CTRL_CONTROL_REG),
        register_data_o(0) => control_register
    );
    read_data_o(CTRL_CONTROL_REG) <= control_register;
    read_ack_o(CTRL_CONTROL_REG) <= '1';


    pulsed_bits <= (
        CTRL_PULSED_DRAM1_ERROR_BIT => dram1_brsp_error_i,
        others => '0'
    );

    -- A little annoyance here: the outputs are indexed by CHANNELS which grows
    -- up, but these are software interface registers which really ought to grow
    -- downwards.  To reduce confusion elsewhere we reorder right away.
    loopback_o      <= reverse(control_register(CTRL_CONTROL_LOOPBACK_BITS));
    output_enable_o <= reverse(control_register(CTRL_CONTROL_OUTPUT_BITS));


    -- Channel data multiplexing control
    adc_mux   <= control_register(CTRL_CONTROL_ADC_MUX_BIT);
    nco_0_mux <= control_register(CTRL_CONTROL_NCO0_MUX_BIT);
    nco_1_mux <= control_register(CTRL_CONTROL_NCO1_MUX_BIT);
    nco_2_mux <= control_register(CTRL_CONTROL_NCO2_MUX_BIT);
    bank_mux  <= control_register(CTRL_CONTROL_BANK_MUX_BIT);
    dsp_control_mux : entity work.dsp_control_mux port map (
        clk_i => adc_clk_i,

        adc_mux_i => adc_mux,
        nco_0_mux_i => nco_0_mux,
        nco_1_mux_i => nco_1_mux,
        nco_2_mux_i => nco_2_mux,
        bank_mux_i => bank_mux,

        dsp_to_control_i => dsp_to_control_i,

        adc_o => mux_adc_out,
        nco_0_o => mux_nco_0_out,
        nco_1_o => mux_nco_1_out,
        nco_2_o => mux_nco_2_out,
        bank_select_o => bank_select_out
    );
    mux_gen : for c in CHANNELS generate
        control_to_dsp_o(c).adc_data <= mux_adc_out(c);
        control_to_dsp_o(c).nco_0_data <= mux_nco_0_out(c);
        control_to_dsp_o(c).nco_1_data <= mux_nco_1_out(c);
        control_to_dsp_o(c).nco_2_data <= mux_nco_2_out(c);
        control_to_dsp_o(c).bank_select <= bank_select_out(c);
    end generate;


    -- DRAM0 capture control
    fast_memory_top : entity work.fast_memory_top port map (
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
        memory_phase_i => dram0_phase,

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
        dsp_dram1_valid(c) <= dsp_to_control_i(c).dram1_valid;
        control_to_dsp_o(c).dram1_ready <= dsp_dram1_ready(c);
        -- The top bit of each address identifies the generating DSP unit
        dsp_dram1_address(c) <= unsigned(
            to_std_ulogic(c) &
            std_ulogic_vector(dsp_to_control_i(c).dram1_address));
        dsp_dram1_data(c) <= dsp_to_control_i(c).dram1_data;
    end generate;

    memory_mux : entity work.memory_mux_priority port map (
        clk_i => dsp_clk_i,

        input_valid_i => dsp_dram1_valid,
        input_ready_o => dsp_dram1_ready,
        data_i => dsp_dram1_data,
        addr_i => dsp_dram1_address,

        output_ready_i => dram1_ready,
        output_valid_o => dram1_valid,
        data_o => dram1_data,
        addr_o => dram1_address
    );

    dram1_buffer : entity work.memory_buffer generic map (
        LENGTH => 2
    ) port map (
        clk_i => dsp_clk_i,

        input_valid_i => dram1_valid,
        input_ready_o => dram1_ready,
        input_data_i => dram1_data,
        input_addr_i => dram1_address,

        output_ready_i => dram1_data_ready_i,
        output_valid_o => dram1_data_valid_o,
        output_data_o => dram1_data_o,
        output_addr_o => dram1_address_o
    );


    -- Triggers and event generation
    trigger : entity work.trigger_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(CTRL_TRG_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CTRL_TRG_REGS),
        read_strobe_i => read_strobe_i(CTRL_TRG_REGS),
        read_data_o => read_data_o(CTRL_TRG_REGS),
        read_ack_o => read_ack_o(CTRL_TRG_REGS),

        revolution_clock_i => revolution_clock_i,
        event_trigger_i => event_trigger_i,
        postmortem_trigger_i => postmortem_trigger_i,
        blanking_trigger_i => blanking_trigger_i,

        adc_trigger_i => adc_trigger,
        seq_trigger_i => seq_trigger,

        blanking_window_o => blanking_window,
        turn_clock_o => turn_clock,
        seq_start_o => seq_start,
        dram0_trigger_o => dram0_trigger,
        dram0_phase_o => dram0_phase,

        start_tune_pll0_o => control_to_dsp_o(0).start_tune_pll,
        start_tune_pll1_o => control_to_dsp_o(1).start_tune_pll,
        stop_tune_pll0_o => control_to_dsp_o(0).stop_tune_pll,
        stop_tune_pll1_o => control_to_dsp_o(1).stop_tune_pll
    );

    -- Map events to individual DSP units
    gen_channels: for c in CHANNELS generate
        -- ADC clocked signals
        adc_trigger(c) <= dsp_to_control_i(c).adc_trigger;
        seq_trigger(c) <= dsp_to_control_i(c).seq_trigger;
        seq_busy(c)    <= dsp_to_control_i(c).seq_busy;
        tune_pll_ready(c) <= dsp_to_control_i(c).tune_pll_ready;
        control_to_dsp_o(c).blanking <= blanking_window;
        control_to_dsp_o(c).seq_start <= seq_start(c);

        -- DSP clocked signals
        control_to_dsp_o(c).turn_clock <= turn_clock;
    end generate;


    -- Generate appropriate interrupt signals
    interrupts : entity work.dsp_interrupts port map (
        dsp_clk_i => dsp_clk_i,

        dram0_capture_enable_i => dram0_capture_enable_o,
        dram0_trigger_i => dram0_trigger,
        seq_start_i => seq_start,
        seq_busy_i => seq_busy,
        tune_pll_ready_i => tune_pll_ready,

        interrupts_o => interrupts_o
    );
end;
