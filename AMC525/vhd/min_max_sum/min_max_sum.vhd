-- Bunch by bunch min/max/sum accumulation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.min_max_sum_defs.all;

use work.register_defs.all;

entity min_max_sum is
    generic (
        ADDR_BITS : natural := BUNCH_NUM_BITS
    );
    port (
        dsp_clk_i : in std_ulogic;
        adc_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;

        data_i : in signed(15 downto 0);
        delta_o : out unsigned(15 downto 0);

        -- Two register readout interface:
        -- First returns the accumulated event count and swaps buffers
        -- Read second repeatedly to return and reset memory bank
        read_strobe_i : in std_ulogic_vector(MMS_REGS_RANGE);
        read_data_o : out reg_data_array_t(MMS_REGS_RANGE);
        read_ack_o : out std_ulogic_vector(MMS_REGS_RANGE)
    );
end;

architecture arch of min_max_sum is
    -- Delay from bank selection and update address in to _store to
    -- update_data_read valid.
    constant READ_DELAY : natural := 4;
    -- Delay from update_data_read to update_data_write.
    constant UPDATE_DELAY : natural := 2;

    signal turn_clock : std_ulogic;
    signal data : signed(15 downto 0);

    signal read_strobe : std_ulogic_vector(MMS_REGS_RANGE);
    signal read_data : reg_data_array_t(MMS_REGS_RANGE);
    signal read_ack : std_ulogic_vector(MMS_REGS_RANGE);

    signal bank_select : std_ulogic;
    signal update_addr : unsigned(ADDR_BITS-1 downto 0);
    signal readout_addr : unsigned(ADDR_BITS-1 downto 0);

    signal update_data_read : mms_row_t;
    signal update_data_write : mms_row_t;

    signal readout_data_read : mms_row_t;

    signal sum_overflow : std_ulogic;
    signal sum2_overflow : std_ulogic;
    signal delta : unsigned(15 downto 0);

    signal readout_strobe : std_ulogic;
    signal readout_ack : std_ulogic;

    -- Pipeline delays
    constant TURN_CLOCK_PIPELINE : natural := 4;
    constant DATA_PIPELINE : natural := 4;
    constant DELTA_PIPELINE : natural := 2;

begin
    -- -------------------------------------------------------------------------
    -- Pipelines for all inputs and outputs

    turn_clock_delay : entity work.dlyreg generic map (
        DLY => TURN_CLOCK_PIPELINE
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );

    data_delay : entity work.dlyreg generic map (
        DLY => DATA_PIPELINE,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(data_i),
        signed(data_o) => data
    );

    delta_delay : entity work.dlyreg generic map (
        DLY => DELTA_PIPELINE,
        DW => 16
    ) port map (
        clk_i => adc_clk_i,
        data_i => std_ulogic_vector(delta),
        unsigned(data_o) => delta_o
    );


    -- Map register read across from DSP to ADC clock domain
    register_read_adc : entity work.register_read_adc port map (
        dsp_clk_i => dsp_clk_i,
        adc_clk_i => adc_clk_i,

        dsp_read_strobe_i => read_strobe_i,
        dsp_read_data_o => read_data_o,
        dsp_read_ack_o => read_ack_o,

        adc_read_strobe_o => read_strobe,
        adc_read_data_i => read_data,
        adc_read_ack_i => read_ack
    );


    -- -------------------------------------------------------------------------

    -- Address control and bank switching
    bank : entity work.min_max_sum_bank generic map (
        READ_DELAY => READ_DELAY,
        UPDATE_DELAY => UPDATE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock,

        count_read_strobe_i => read_strobe(MMS_COUNT_REG),
        count_read_data_o => read_data(MMS_COUNT_REG),
        count_read_ack_o => read_ack(MMS_COUNT_REG),

        bank_select_o => bank_select,
        update_addr_o => update_addr,

        readout_strobe_i => readout_strobe,
        readout_addr_o => readout_addr,

        sum_overflow_i => sum_overflow,
        sum2_overflow_i => sum2_overflow
    );

    -- Core memory interface and multiplexing
    store : entity work.min_max_sum_store generic map (
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
    update : entity work.min_max_sum_update generic map (
        UPDATE_DELAY => UPDATE_DELAY
    ) port map (
        clk_i => adc_clk_i,
        data_i => data,
        mms_i => update_data_read,
        mms_o => update_data_write,
        sum_overflow_o => sum_overflow,
        sum2_overflow_o => sum2_overflow,
        delta_o => delta
    );


    -- Readout capture
    readout_inst : entity work.min_max_sum_readout port map (
        clk_i => adc_clk_i,
        reset_readout_i => read_strobe(MMS_COUNT_REG),
        data_i => readout_data_read,
        readout_strobe_o => readout_strobe,
        readout_ack_i => readout_ack,
        read_strobe_i => read_strobe(MMS_READOUT_REG),
        read_data_o => read_data(MMS_READOUT_REG),
        read_ack_o => read_ack(MMS_READOUT_REG)
    );
end;
