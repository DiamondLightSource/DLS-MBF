-- Implements detector bunch selection and output scaling

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.detector_defs.all;

entity detector_body is
    generic (
        BUFFER_LENGTH : natural
    );
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        -- Bunch selection control on DSP clock
        start_write_i : in std_logic;
        bunch_write_i : in std_logic;
        write_data_i : in reg_data_t;

        -- Data in, all on ADC clock
        data_i : in signed(24 downto 0);
        iq_i : in cos_sin_18_t;
        start_i : in std_logic;
        write_i : in std_logic;
        data_overflow_i : in std_logic;

        -- Error events, all on DSP clock
        data_overflow_o : out std_logic;
        detector_overflow_o : out std_logic;
        output_underrun_o : out std_logic;

        -- Output scaling control on DSP clock
        output_scaling_i : in unsigned(2 downto 0);

        -- Detector data out, all on ADC clock, with AXI style handshake
        valid_o : out std_logic;
        ready_i : in std_logic;
        data_o : out std_logic_vector(63 downto 0)
    );
end;

architecture arch of detector_body is
    signal bunch_enable : std_logic;

    signal data_overflow : std_logic;
    signal det_write : std_logic;
    signal det_iq : cos_sin_96_t;

    signal output_valid : std_logic;
    signal output_ready : std_logic;
    signal output_data : data_o'SUBTYPE;
    signal dummy_addr : unsigned(-1 downto 0);

begin
    -- Bunch selection
    bunch_select : entity work.detector_bunch_select port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        start_write_i => start_write_i,
        write_strobe_i => bunch_write_i,
        write_data_i => write_data_i,

        bunch_enable_o => bunch_enable
    );


    -- IQ Detector
    detector : entity work.detector_core port map (
        clk_i => adc_clk_i,

        data_i => data_i,
        iq_i => iq_i,
        bunch_enable_i => bunch_enable,
        overflow_i => data_overflow_i,
        overflow_o => data_overflow,

        start_i => start_i,
        write_i => write_i,
        write_o => det_write,
        iq_o => det_iq
    );


    -- Bring data overflow over to DSP clock
    adc_to_dsp : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        pulse_i => data_overflow,
        pulse_o => data_overflow_o
    );


    -- Scale and make output available to DRAM
    output : entity work.detector_output port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        scaling_i => output_scaling_i,
        overflow_o => detector_overflow_o,
        write_i => det_write,
        data_i => det_iq,

        output_valid_o => output_valid,
        output_ready_i => output_ready,
        output_data_o => output_data,
        output_underrun_o => output_underrun_o
    );


    -- Buffer to allow detector to be separated from memory
    memory_buffer : entity work.memory_buffer generic map (
        LENGTH => BUFFER_LENGTH
    ) port map (
        clk_i => dsp_clk_i,

        input_valid_i => output_valid,
        input_ready_o => output_ready,
        input_data_i => output_data,
        input_addr_i(dummy_addr'RANGE) => "",

        output_valid_o => valid_o,
        output_ready_i => ready_i,
        output_data_o => data_o,
        output_addr_o => dummy_addr
    );
end;
