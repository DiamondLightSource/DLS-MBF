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
        bunch_reset_i : in std_logic;

        data_i : in signed_array;
        delta_o : out unsigned_array;
        overflow_o : out std_logic;

        -- Two register readout interface:
        -- First returns the accumulated event count and swaps buffers
        -- Read second repeatedly to return and reset memory bank
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector
    );
end;

architecture min_max_sum of min_max_sum is
    -- Register indices.
    constant COUNT_REG : natural := read_strobe_i'LOW;
    constant READOUT_REG : natural := COUNT_REG + 1;

    -- Delay from bank selection and update address in to _store to
    -- update_data_read valid.
    constant READ_DELAY : natural := 4;
    -- Delay from update_data_read to update_data_write.
    constant UPDATE_DELAY : natural := 2;

    signal bank_select : std_logic;
    signal update_addr : unsigned(ADDR_BITS-1 downto 0);
    signal readout_addr : unsigned(ADDR_BITS-1 downto 0);

    signal update_data_read : mms_row_channels_t;
    signal update_data_write : mms_row_channels_t;

    signal readout_data_read : mms_row_channels_t;
    signal readout_reset_data : mms_row_channels_t;

    signal sum_overflow_chan : std_logic_vector(CHANNELS);
    signal sum2_overflow_chan : std_logic_vector(CHANNELS);
    signal sum_overflow : std_logic;
    signal sum2_overflow : std_logic;

    signal readout_strobe : std_logic;
    signal readout_ack : std_logic;

begin
    assert read_strobe_i'LENGTH = 2;
    assert read_strobe_i'LOW = read_data_o'LOW;
    assert read_strobe_i'HIGH = read_data_o'HIGH;

    -- Address control and bank switching
    min_max_sum_bank_inst : entity work.min_max_sum_bank generic map (
        READ_DELAY => READ_DELAY,
        UPDATE_DELAY => UPDATE_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        bunch_reset_i => bunch_reset_i,

        count_read_strobe_i => read_strobe_i(COUNT_REG),
        count_read_data_o => read_data_o(COUNT_REG),
        count_read_ack_o => read_ack_o(COUNT_REG),

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
        clk_i => dsp_clk_i,

        bank_select_i => bank_select,

        update_addr_i => update_addr,
        update_data_o => update_data_read,
        update_data_i => update_data_write,

        readout_strobe_i => readout_strobe,
        readout_addr_i => readout_addr,
        readout_data_o => readout_data_read,
        readout_ack_o => readout_ack,
        readout_reset_data_i => readout_reset_data
    );

    readout_reset_data <= (others => mms_reset_value);

    -- Update min/max/sum
    update_gen : for c in CHANNELS generate
        min_max_sum_update_inst : entity work.min_max_sum_update port map (
            clk_i => dsp_clk_i,
            data_i => data_i(c),
            mms_i => update_data_read(c),
            mms_o => update_data_write(c),
            sum_overflow_o => sum_overflow_chan(c),
            sum2_overflow_o => sum2_overflow_chan(c),
            delta_o => delta_o(c)
        );
    end generate;
    sum_overflow  <= vector_or(sum_overflow_chan);
    sum2_overflow <= vector_or(sum2_overflow_chan);
    overflow_o <= sum_overflow or sum2_overflow;

    -- Readout capture
    readout_inst : entity work.min_max_sum_readout port map (
        dsp_clk_i => dsp_clk_i,
        reset_readout_i => read_strobe_i(COUNT_REG),
        data_i => readout_data_read,
        readout_strobe_o => readout_strobe,
        readout_ack_i => readout_ack,
        read_strobe_i => read_strobe_i(READOUT_REG),
        read_data_o => read_data_o(READOUT_REG),
        read_ack_o => read_ack_o(READOUT_REG)
    );
end;
