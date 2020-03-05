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
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;   -- start of machine revolution

        -- General register interface
        write_strobe_i : in std_ulogic_vector(DSP_ADC_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_ADC_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_ADC_REGS);
        read_data_o : out reg_data_array_t(DSP_ADC_REGS);
        read_ack_o : out std_ulogic_vector(DSP_ADC_REGS);

        -- Data flow
        data_i : in signed;
        data_o : out signed;            -- Processed ADC data
        fill_reject_o : out signed;     -- Fill pattern reject filtered data
        data_store_o : out signed;      -- Data to be stored to memory

        delta_event_o : out std_ulogic  -- bunch movement over threshold
    );
end;

architecture arch of adc_top is
    -- Maximum permissible shift for fill pattern rejection filter
    constant MAX_FILL_REJECT_SHIFT : natural := 12;

    signal input_limit : unsigned(13 downto 0);
    signal delta_limit : unsigned(15 downto 0);
    signal mms_source : std_ulogic_vector(1 downto 0);
    signal dram_source : std_ulogic_vector(1 downto 0);
    signal fill_reject_shift : unsigned(3 downto 0);

    signal write_start : std_ulogic;
    signal delta_reset : std_ulogic;

    signal input_overflow : std_ulogic;
    signal fir_overflow : std_ulogic;

    signal filtered_data : data_o'SUBTYPE;
    signal fill_reject_data : fill_reject_o'SUBTYPE;
    signal data_in : data_i'SUBTYPE;
    signal mms_data : data_o'SUBTYPE;
    signal mms_delta : unsigned(data_o'RANGE);

begin
    -- Register interface
    registers : entity work.adc_registers port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_ADC_REGISTERS_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_ADC_REGISTERS_REGS),
        read_strobe_i => read_strobe_i(DSP_ADC_REGISTERS_REGS),
        read_data_o => read_data_o(DSP_ADC_REGISTERS_REGS),
        read_ack_o => read_ack_o(DSP_ADC_REGISTERS_REGS),

        mms_source_o => mms_source,
        dram_source_o => dram_source,
        reject_shift_o => fill_reject_shift,

        input_limit_o => input_limit,
        delta_limit_o => delta_limit,

        write_start_o => write_start,
        delta_reset_o => delta_reset,

        input_overflow_i => input_overflow,
        fir_overflow_i => fir_overflow,
        delta_event_i => delta_event_o
    );


    -- Register pipeline on input to help with timing
    input_delay : entity work.dlyreg generic map (
        DLY => IN_BUFFER_LENGTH,
        DW => data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_i),
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


    -- Fill pattern rejection
    fill_reject : entity work.adc_fill_reject generic map (
        MAX_SHIFT => MAX_FILL_REJECT_SHIFT
    ) port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock_i,
        shift_i => fill_reject_shift,
        data_i => filtered_data,
        data_o => fill_reject_data
    );


    -- Select sources for stored and MMS data
    source_mux : entity work.adc_mms_dram_data_source port map (
        adc_clk_i => adc_clk_i,

        unfiltered_data_i(15 downto 0) => data_in & "00",
        filtered_data_i => filtered_data,
        fill_reject_data_i => fill_reject_data,

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
        data_i => std_ulogic_vector(filtered_data),
        signed(data_o) => data_o
    );

    reject_delay : entity work.dlyreg generic map (
        DLY => OUT_BUFFER_LENGTH,
        DW => fill_reject_o'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(fill_reject_data),
        signed(data_o) => fill_reject_o
    );
end;
