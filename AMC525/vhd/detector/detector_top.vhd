-- Group of detectors on a common data source

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.detector_defs.all;

entity detector_top is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Data in
        adc_data_i : in signed;
        fir_data_i : in signed;
        nco_iq_i : in cos_sin_t;
        window_i : in signed;

        -- Control
        start_i : in std_logic;
        write_i : in std_logic;

        -- Data out
        mem_valid_o : out std_logic;
        mem_ready_i : in std_logic;
        mem_addr_o : out unsigned;
        mem_data_o : out std_logic_vector
    );
end;

architecture arch of detector_top is
    signal enable : std_logic_vector(DETECTOR_RANGE);

    -- Memory multiplexing
    signal mem_valid : std_logic_vector(DETECTOR_RANGE);
    signal mem_ready : std_logic_vector(DETECTOR_RANGE);
    signal mem_addr : unsigned_array(DETECTOR_RANGE)(mem_addr_o'RANGE);
    signal mem_data : vector_array(DETECTOR_RANGE)(mem_data_o'RANGE);

begin
    -- Register interface
    registers : entity work.detector_registers port map (
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,
        read_strobe_i => read_strobe_i,
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,

        fir_overflow_i => fir_overflow,
        det_overflow_i => det_overflow,
        write_underrun_i => write_underrun,

        fir_gain_o => fir_gain,
        detector_gains_o => detector_gains,

        start_write_o => start_write,
        bunch_write_o => bunch_write,

        dram_reset_o => dram_reset,
        dram_enables_o => detector_enables
    );


    -- Data preparation: selection, FIR gain, and windowing
    detector_input : entity work.detector_input port map (
        clk_i => adc_clk_i,

        fir_gain_i => fir_gain,
        data_select_i => data_select,

        adc_data_i => adc_data_i,
        fir_data_i => fir_data_i,
        window_i => window_i,

        data_o => data_in,
        fir_overflow_o => fir_overflow_in
    );


    -- We have a set of detectors operating on a common data set.  Each
    -- detector will have its own set of bunches programmed, but otherwise will
    -- operate in step.
    detectors : for d in DETECTOR_RANGE generate
        detector_body : entity work.detector_body generic map (
            BUFFER_LENGTH => BUFFER_LENGTH,
        ) port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock_i,

            start_write_i => start_write,
            bunch_write_i => bunch_write(d),
            write_data_i => write_data_i,

            data_i => data_in,
            iq_i => iq_i,
            start_i => start_i,
            write_i => write_i,
            data_overflow_i => fir_overflow_in,

            data_overflow_o => fir_overflow(d),
            detector_overflow_o => detector_overflow(d),
            output_underrun_o => output_underrun(d),

            output_scaling_i => output_scaling(d),

            valid_o => output_valid(d),
            ready_i => output_ready(d),
            data_o => output_data(d)
        );
    end generate;


    dram_output : entity work.detector_dram_output port map (
        clk_i => dsp_clk_i,

        output_reset_i => output_reset,
        output_enables_i => output_enables,

        input_valid_i => output_valid,
        input_ready_o => output_ready,
        input_data_i => output_data,

        output_valid_o => mem_valid_o,
        output_ready_i => mem_ready_i,
        output_addr_o => mem_addr_o,
        output_data_o => mem_data_o
    );
end;
