-- Top level ADC input processing.
--
-- Includes ADC compenstation filter for compensating for cabling and front end
-- frequency shifts, capture of bunch by bunch min/max/sum data, and conversion
-- to DSP clock data rate.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

entity adc_top is
    generic (
        TAP_COUNT : natural;
        IN_BUFFER_LENGTH : natural := 4;
        OUT_BUFFER_LENGTH : natural := 4
    );
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;    -- start of machine revolution

        -- Data flow
        data_i : in signed;
        data_o : out signed;
        data_store_o : out signed;      -- Data to be stored to memory

        -- General register interface
        write_strobe_i : in std_logic_vector(DSP_ADC_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(DSP_ADC_REGS);
        read_strobe_i : in std_logic_vector(DSP_ADC_REGS);
        read_data_o : out reg_data_array_t(DSP_ADC_REGS);
        read_ack_o : out std_logic_vector(DSP_ADC_REGS);

        delta_event_o : out std_logic       -- bunch movement over threshold
    );
end;

architecture arch of adc_top is
    signal config_register : reg_data_t;
    signal input_limit : unsigned(13 downto 0);
    signal delta_limit : unsigned(15 downto 0);
    signal mms_source : std_logic;
    signal dram_source : std_logic;

    signal command_bits : reg_data_t;
    signal write_start : std_logic;
    signal delta_reset : std_logic;

    signal event_bits : reg_data_t;
    signal input_overflow : std_logic;
    signal fir_overflow : std_logic;

    signal filtered_data : data_o'SUBTYPE;
    signal data_in : data_i'SUBTYPE;
    signal mms_data : data_o'SUBTYPE;
    signal mms_delta : unsigned(data_o'RANGE);

begin
    -- Limit register.
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_ADC_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_ADC_CONFIG_REG),
        register_data_o(0) => config_register
    );
    read_data_o(DSP_ADC_CONFIG_REG) <= (others => '0');
    read_ack_o(DSP_ADC_CONFIG_REG) <= '1';

    -- Command register: start write and reset limit
    command : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_ADC_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_ADC_COMMAND_REG_W),
        strobed_bits_o => command_bits
    );

    -- Event detection register
    events : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(DSP_ADC_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_ADC_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_ADC_EVENTS_REG_R),
        pulsed_bits_i => event_bits
    );

    input_limit <= unsigned(config_register(DSP_ADC_CONFIG_THRESHOLD_BITS));
    mms_source  <= config_register(DSP_ADC_CONFIG_MMS_SOURCE_BIT);
    dram_source  <= config_register(DSP_ADC_CONFIG_DRAM_SOURCE_BIT);
    delta_limit <= unsigned(config_register(DSP_ADC_CONFIG_DELTA_BITS));

    write_start <= command_bits(DSP_ADC_COMMAND_WRITE_BIT);
    delta_reset <= command_bits(DSP_ADC_COMMAND_RESET_DELTA_BIT);

    event_bits <= (
        DSP_ADC_EVENTS_INP_OVF_BIT => input_overflow,
        DSP_ADC_EVENTS_FIR_OVF_BIT => fir_overflow,
        DSP_ADC_EVENTS_DELTA_BIT   => delta_event_o,
        others => '0'
    );


    -- Register pipeline on input to help with timing
    input_delay : entity work.dlyreg generic map (
        DLY => IN_BUFFER_LENGTH,
        DW => data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_in
    );


    -- Input overflow check
    adc_overflow : entity work.adc_overflow port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        data_i => data_in,
        limit_i => input_limit,
        overflow_o => input_overflow
    );


    -- Compensation filter
    fast_fir : entity work.fast_fir_top generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_start_i => write_start,
        write_strobe_i => write_strobe_i(DSP_ADC_TAPS_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_ADC_TAPS_REG),

        data_i => data_in,
        data_o => filtered_data,
        overflow_o => fir_overflow
    );
    read_data_o(DSP_ADC_TAPS_REG) <= (others => '0');
    read_ack_o(DSP_ADC_TAPS_REG) <= '1';


    -- Select sources for stored and MMS data
    source_mux : entity work.mms_dram_data_source port map (
        adc_clk_i => adc_clk_i,

        unfiltered_data_i(15 downto 0) => data_in & "00",
        filtered_data_i => filtered_data,

        mms_source_i => mms_source,
        mms_data_o => mms_data,

        dram_source_i => dram_source,
        dram_data_o => data_store_o
    );



    -- Min/Max/Sum
    min_max_sum : entity work.min_max_sum port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        data_i => mms_data,
        delta_o => mms_delta,

        read_strobe_i => read_strobe_i(DSP_ADC_MMS_REGS),
        read_data_o => read_data_o(DSP_ADC_MMS_REGS),
        read_ack_o => read_ack_o(DSP_ADC_MMS_REGS)
    );
    write_ack_o(DSP_ADC_MMS_REGS) <= (others => '1');

    -- Bunch movement detection
    min_max_limit : entity work.min_max_limit port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        delta_i => mms_delta,
        limit_i => delta_limit,
        reset_event_i => delta_reset,

        limit_event_o => delta_event_o
    );


    -- Output for further processing
    output_delay : entity work.dlyreg generic map (
        DLY => OUT_BUFFER_LENGTH,
        DW => data_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(filtered_data),
        signed(data_o) => data_o
    );
end;
