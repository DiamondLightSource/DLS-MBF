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

entity adc_top is
    generic (
        TAP_COUNT : natural
    );
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;
        turn_clock_i : in std_logic;       -- start of machine revolution

        -- Data flow
        data_i : in signed;                 -- at ADC data rate
        data_o : out signed_array;          -- paired at DSP data rate

        -- General register interface
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        -- Pulse events
        write_start_i : in std_logic;       -- For register block writes
        delta_reset_i : in std_logic;       -- Reenable delta limit event

        -- Event outputs
        input_overflow_o : out std_logic;
        fir_overflow_o : out std_logic;     -- FIR overflow detect
        mms_overflow_o : out std_logic;     -- If an mms accumulator overflows
        delta_event_o : out std_logic       -- bunch movement over threshold
    );
end;

architecture adc_top of adc_top is
    -- Our registers are overlaid as follows:
    --
    --  0   R   31:0    Read MMS count and switch banks
    --  1   R   31:0    Read and reset MMS bunch entries
    --  0   W   13:0    Configure data input limit
    --  0   W   15      Configure ADC fine delay
    --  0   W   31:16   Configure MMS event limit
    --  1   W   31:7    Write FIR taps
    --
    subtype MMS_REGS_R is natural range 0 to 1;
    constant LIMIT_REG_W : natural := 0;
    constant TAPS_REG_W : natural := 1;

    subtype DATA_OUT_RANGE is natural range data_o(0)'RANGE;

    signal limit_register_in : reg_data_t;
    signal limit_register : reg_data_t;
    signal input_limit : unsigned(13 downto 0);
    signal delta_limit : unsigned(15 downto 0);
    signal data_delay : unsigned(0 downto 0);

    signal filtered_data : signed(DATA_OUT_RANGE);
    signal data_in : signed(data_i'RANGE);
    signal delayed_data : signed(data_i'RANGE);
    signal dsp_data : signed_array(LANES)(DATA_OUT_RANGE);
    signal mms_delta : unsigned_array(LANES)(DATA_OUT_RANGE);

begin
    -- Limit register.
    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(LIMIT_REG_W),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(LIMIT_REG_W),
        register_data_o(0) => limit_register_in
    );
    -- Make these control settings untimed to help with FPGA timing
    untimed_inst : entity work.untimed_reg generic map (
        WIDTH => REG_DATA_WIDTH
    ) port map (
        clk_i => dsp_clk_i,
        write_i => '1',
        data_i => limit_register_in,
        data_o => limit_register
    );

    input_limit <= unsigned(limit_register(13 downto 0));
    data_delay  <= unsigned(limit_register(15 downto 15));
    delta_limit <= unsigned(limit_register(31 downto 16));


    -- Register pipeline on input to help with timing
    adc_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_in
    );


    -- One bit data skew to allow for clock shift
    adc_delay_inst : entity work.short_delay generic map (
        WIDTH => data_i'LENGTH
    ) port map (
        clk_i => adc_clk_i,
        delay_i => data_delay,
        data_i => std_logic_vector(data_in),
        signed(data_o) => delayed_data
    );


    -- Input overflow check
    adc_overflow_inst : entity work.adc_overflow port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        data_i => delayed_data,
        limit_i => input_limit,
        overflow_o => input_overflow_o
    );


    -- Compensation filter
    fast_fir_inst : entity work.fast_fir_top generic map (
        TAP_COUNT => TAP_COUNT
    ) port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        write_start_i => write_start_i,
        write_strobe_i => write_strobe_i(TAPS_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(TAPS_REG_W),

        data_i => delayed_data,
        data_o => filtered_data,
        overflow_o => fir_overflow_o
    );


    -- Bring the filtered data over to the DSP clock
    adc_to_dsp_inst : entity work.adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase_i,

        adc_data_i => filtered_data,
        dsp_data_o => dsp_data
    );


    -- Min/Max/Sum
    min_max_sum_inst : entity work.min_max_sum port map (
        dsp_clk_i => dsp_clk_i,
        turn_clock_i => turn_clock_i,

        data_i => dsp_data,
        delta_o => mms_delta,
        overflow_o => mms_overflow_o,

        read_strobe_i => read_strobe_i(MMS_REGS_R),
        read_data_o => read_data_o(MMS_REGS_R),
        read_ack_o => read_ack_o(MMS_REGS_R)
    );

    -- Bunch movement detection
    min_max_limit_inst : entity work.min_max_limit port map (
        dsp_clk_i => dsp_clk_i,

        delta_i => mms_delta,
        limit_i => delta_limit,
        reset_event_i => delta_reset_i,

        limit_event_o => delta_event_o
    );

    -- Output for further processing
    data_o <= dsp_data;
end;
