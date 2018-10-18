-- Group of detectors on a common data source

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.detector_defs.all;
use work.register_defs.all;

entity detector_top is
    generic (
        DATA_IN_BUFFER_LENGTH : natural;
        DATA_BUFFER_LENGTH : natural;
        NCO_BUFFER_LENGTH : natural;
        MEMORY_BUFFER_LENGTH : natural;
        CONTROL_BUFFER_LENGTH : natural
    );
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_DET_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_DET_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_DET_REGS);
        read_data_o : out reg_data_array_t(DSP_DET_REGS);
        read_ack_o : out std_ulogic_vector(DSP_DET_REGS);

        -- Data in
        adc_data_i : in signed;
        fir_data_i : in signed;
        nco_iq_i : in cos_sin_t;
        window_i : in signed;

        -- Control
        start_i : in std_ulogic;
        write_i : in std_ulogic;

        -- Data out
        mem_valid_o : out std_ulogic;
        mem_ready_i : in std_ulogic;
        mem_addr_o : out unsigned;
        mem_data_o : out std_ulogic_vector
    );
end;

architecture arch of detector_top is
    -- Register control settings
    signal data_select : std_ulogic;
    signal start_write : std_ulogic;
    signal bunch_write : std_ulogic_vector(DETECTOR_RANGE);
    signal output_scaling : unsigned_array(DETECTOR_RANGE)(0 downto 0);
    signal address_reset : std_ulogic;
    signal input_enable : std_ulogic_vector(DETECTOR_RANGE);
    -- Event feedbacks (all on DSP clock)
    signal detector_overflow : std_ulogic_vector(DETECTOR_RANGE);
    signal output_underrun : std_ulogic_vector(DETECTOR_RANGE);

    -- Internal paths
    signal data_in : signed(24 downto 0);

    -- Output data streams
    signal output_valid : std_ulogic_vector(DETECTOR_RANGE);
    signal output_ready : std_ulogic_vector(DETECTOR_RANGE);
    signal output_data : vector_array(DETECTOR_RANGE)(mem_data_o'RANGE);

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

        data_select_o => data_select,
        start_write_o => start_write,
        bunch_write_o => bunch_write,
        output_scaling_o => output_scaling,
        address_reset_o => address_reset,
        input_enable_o => input_enable,

        detector_overflow_i => detector_overflow,
        output_underrun_i => output_underrun
    );


    -- Data preparation: selection, FIR gain, and windowing
    detector_input : entity work.detector_input generic map (
        BUFFER_LENGTH => DATA_IN_BUFFER_LENGTH
    ) port map (
        clk_i => adc_clk_i,

        data_select_i => data_select,

        adc_data_i => adc_data_i,
        fir_data_i => fir_data_i,
        window_i => window_i,

        data_o => data_in
    );


    -- We have a set of detectors operating on a common data set.  Each
    -- detector will have its own set of bunches programmed, but otherwise will
    -- operate in step.
    detectors : for d in DETECTOR_RANGE generate
        signal nco_iq_in : nco_iq_i'SUBTYPE;
        signal data_delay : data_in'SUBTYPE;
        signal start : std_ulogic;
        signal write : std_ulogic;
        signal turn_clock : std_ulogic;

        signal valid : std_ulogic;
        signal ready : std_ulogic;
        signal data : mem_data_o'SUBTYPE;

        -- Annoyingly we can't assign an unconstrained output to open.
        -- Note, the VHDL range of an empty string is (1 to 0).
        signal dummy_addr : unsigned(1 to 0);

    begin
        -- Delay for NCO to allow for placement
        nco_delay : entity work.nco_delay generic map (
            DELAY => NCO_BUFFER_LENGTH
        ) port map (
            clk_i => adc_clk_i,
            cos_sin_i => nco_iq_i,
            cos_sin_o => nco_iq_in
        );

        -- Incoming data delay
        data_delay_reg : entity work.dlyreg generic map (
            DW => data_in'LENGTH,
            DLY => DATA_BUFFER_LENGTH
        ) port map (
            clk_i => adc_clk_i,
            data_i => std_ulogic_vector(data_in),
            signed(data_o) => data_delay
        );

        control_delay : entity work.dlyreg generic map (
            DW => 2,
            DLY => CONTROL_BUFFER_LENGTH
        ) port map (
            clk_i => adc_clk_i,
            data_i(0) => start_i,   data_i(1) => write_i,
            data_o(0) => start,     data_o(1) => write
        );

        turn_clock_delay : entity work.dlyreg generic map (
            DLY => CONTROL_BUFFER_LENGTH
        ) port map (
            clk_i => adc_clk_i,
            data_i(0) => turn_clock_i,
            data_o(0) => turn_clock
        );

        -- Detector
        detector_body : entity work.detector_body port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            turn_clock_i => turn_clock,

            start_write_i => start_write,
            bunch_write_i => bunch_write(d),
            write_data_i => write_data_i,

            data_i => data_delay,
            iq_i => nco_iq_in,
            start_i => start,
            write_i => write,

            detector_overflow_o => detector_overflow(d),
            output_underrun_o => output_underrun(d),

            output_scaling_i => output_scaling(d),

            valid_o => valid,
            ready_i => ready,
            data_o => data
        );

        -- Buffer to allow detector to be separated from memory
        memory_buffer : entity work.memory_buffer generic map (
            LENGTH => MEMORY_BUFFER_LENGTH
        ) port map (
            clk_i => dsp_clk_i,

            input_valid_i => valid,
            input_ready_o => ready,
            input_data_i => data,
            input_addr_i => "",

            output_valid_o => output_valid(d),
            output_ready_i => output_ready(d),
            output_data_o => output_data(d),
            output_addr_o => dummy_addr
        );
    end generate;


    -- Gather multiple output streams together into a single stream
    dram_output : entity work.detector_dram_output port map (
        clk_i => dsp_clk_i,

        address_reset_i => address_reset,
        input_enable_i => input_enable,

        input_valid_i => output_valid,
        input_ready_o => output_ready,
        input_data_i => output_data,

        output_valid_o => mem_valid_o,
        output_ready_i => mem_ready_i,
        output_addr_o => mem_addr_o,
        output_data_o => mem_data_o
    );
end;
