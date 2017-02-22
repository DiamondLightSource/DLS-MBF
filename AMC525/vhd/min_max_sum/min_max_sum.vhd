-- Bunch by bunch min/max/sum accumulation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.min_max_sum_defs.all;

entity min_max_sum is
    generic (
        ADDR_BITS : natural := 9
    );
    port (
        dsp_clk_i : in std_logic;
        adc_clk_i : in std_logic;
        adc_phase_i : in std_logic;
        turn_clock_adc_i : in std_logic;

        data_i : in signed(15 downto 0);
        delta_o : out unsigned(15 downto 0);
        overflow_o : out std_logic;

        -- Two register readout interface:
        -- First returns the accumulated event count and swaps buffers
        -- Read second repeatedly to return and reset memory bank
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1)
    );
end;

architecture min_max_sum of min_max_sum is
    -- Register indices.
    constant COUNT_REG : natural := 0;
    constant READOUT_REG : natural := 1;

    -- Delay from bank selection and update address in to _store to
    -- update_data_read valid.
    constant READ_DELAY : natural := 4;
    -- Delay from update_data_read to update_data_write.
    constant UPDATE_DELAY : natural := 2;

    signal adc_phase : std_logic;
    signal turn_clock_adc : std_logic;
    signal data : signed(15 downto 0);

    signal read_strobe : std_logic_vector(0 to 1);
    signal read_data : reg_data_array_t(0 to 1);
    signal read_ack : std_logic_vector(0 to 1);

    signal bank_select : std_logic;
    signal update_addr : unsigned(ADDR_BITS-1 downto 0);
    signal readout_addr : unsigned(ADDR_BITS-1 downto 0);

    signal update_data_read : mms_row_t;
    signal update_data_write : mms_row_t;

    signal readout_data_read : mms_row_t;

    signal sum_overflow : std_logic;
    signal sum2_overflow : std_logic;
    signal delta : unsigned(15 downto 0);
    signal overflow : std_logic;

    signal readout_strobe : std_logic;
    signal readout_ack : std_logic;

begin
    -- -------------------------------------------------------------------------
    -- Pipelines for all inputs and outputs

    adc_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => 2
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => adc_phase_i,   data_i(1) => turn_clock_adc_i,
        data_o(0) => adc_phase,     data_o(1) => turn_clock_adc
    );

    data_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data
    );

    delta_delay : entity work.dlyreg generic map (
        DLY => 2,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_logic_vector(delta),
        unsigned(data_o) => delta_o
    );

    overflow_delay : entity work.dlyreg generic map (
        DLY => 2
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => overflow,
        data_o(0) => overflow_o
    );


    -- Map register read across from DSP to ADC clock domain
    register_read_adc : entity work.register_read_adc port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,
        adc_phase_i => adc_phase,

        dsp_read_strobe_i => read_strobe_i,
        dsp_read_data_o => read_data_o,
        dsp_read_ack_o => read_ack_o,

        adc_read_strobe_o => read_strobe,
        adc_read_data_i => read_data,
        adc_read_ack_i => read_ack
    );


    -- -------------------------------------------------------------------------

    -- Address control and bank switching
    min_max_sum_bank_inst : entity work.min_max_sum_bank generic map (
        READ_DELAY => READ_DELAY,
        UPDATE_DELAY => UPDATE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock_adc,

        count_read_strobe_i => read_strobe(COUNT_REG),
        count_read_data_o => read_data(COUNT_REG),
        count_read_ack_o => read_ack(COUNT_REG),

        bank_select_o => bank_select,
        update_addr_o => update_addr,

        readout_strobe_i => readout_strobe,
        readout_addr_o => readout_addr,

        sum_overflow_i => sum_overflow,
        sum2_overflow_i => sum2_overflow
    );

    -- Core memory interface and multiplexing
    min_max_sum_store_inst : entity work.min_max_sum_store generic map (
        UPDATE_DELAY => UPDATE_DELAY
    ) port map (
        clk_i => adc_clk_i,

        bank_select_i => bank_select,

        update_addr_i => update_addr,
        update_data_o => update_data_read,
        update_data_i => update_data_write,

        readout_strobe_i => readout_strobe,
        readout_addr_i => readout_addr,
        readout_data_o => readout_data_read,
        readout_ack_o => readout_ack
    );


    -- Update min/max/sum
    min_max_sum_update_inst : entity work.min_max_sum_update port map (
        clk_i => adc_clk_i,
        data_i => data,
        mms_i => update_data_read,
        mms_o => update_data_write,
        sum_overflow_o => sum_overflow,
        sum2_overflow_o => sum2_overflow,
        delta_o => delta
    );

    -- Convert ADC pulse to DSP pulse
    pulse_adc_to_dsp_inst : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_i => adc_phase,

        pulse_i => sum_overflow or sum2_overflow,
        pulse_o => overflow
    );


    -- Readout capture
    readout_inst : entity work.min_max_sum_readout port map (
        clk_i => adc_clk_i,
        reset_readout_i => read_strobe(COUNT_REG),
        data_i => readout_data_read,
        readout_strobe_o => readout_strobe,
        readout_ack_i => readout_ack,
        read_strobe_i => read_strobe(READOUT_REG),
        read_data_o => read_data(READOUT_REG),
        read_ack_o => read_ack(READOUT_REG)
    );
end;
