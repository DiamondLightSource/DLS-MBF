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

        -- Two register readout interface
        --
        -- Read the accumulated event count and swap buffers
        count_read_strobe_i : in std_logic;
        count_read_data_o : out reg_data_t;
        count_read_ack_o : out std_logic;
        -- Read repeatedly to return and reset memory bank
        mms_read_strobe_i : in std_logic;
        mms_read_data_o : out reg_data_t;
        mms_read_ack_o : out std_logic
    );
end;

architecture min_max_sum of min_max_sum is
    signal update_data_read : mms_row_channels_t;
    signal update_data_write : mms_row_channels_t;

    signal readout_data_read : mms_row_channels_t;
    signal readout_reset_data : mms_row_channels_t;

    signal switch_done : std_logic;
    signal readout_strobe : std_logic;
    signal readout_ack : std_logic;
    signal frame_count : unsigned(31 downto 0);

begin

    min_max_sum_store_inst : entity work.min_max_sum_store generic map (
        ADDR_BITS => ADDR_BITS,
        UPDATE_DELAY => 2
    ) port map (
        clk_i => dsp_clk_i,

        bunch_reset_i => bunch_reset_i,
        switch_request_i => count_read_strobe_i,
        switch_done_o => switch_done,

        update_data_o => update_data_read,
        update_data_i => update_data_write,

        readout_strobe_i => readout_strobe,
        readout_data_o => readout_data_read,
        readout_ack_o => readout_ack,
        readout_reset_data_i => readout_reset_data
    );

    readout_reset_data <= (
        0 => (min => X"7FFF", max => X"8000",
              sum => (others => '0'), sum2 => (others => '0')),
        1 => (min => X"7FFF", max => X"8000",
              sum => (others => '0'), sum2 => (others => '0'))
    );

    -- Update min/max/sum
    update_gen : for c in CHANNELS generate
        min_max_sum_update_inst : entity work.min_max_sum_update port map (
            clk_i => dsp_clk_i,
            data_i => data_i(c),
            mms_i => update_data_read(c),
            mms_o => update_data_write(c),
            delta_o => delta_o(c)
        );
    end generate;

    -- Read capture count and switch bank.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if switch_done = '1' then
                count_read_data_o <= std_logic_vector(frame_count);
                frame_count <= (others => '0');
            elsif bunch_reset_i = '1' then
                frame_count <= frame_count + 1;
            end if;
            count_read_ack_o <= switch_done;
        end if;
    end process;

    -- Readout capture
    readout_inst : entity work.min_max_sum_readout port map (
        dsp_clk_i => dsp_clk_i,
        switch_done_i => switch_done,
        data_i => readout_data_read,
        readout_strobe_o => readout_strobe,
        readout_ack_i => readout_ack,
        read_strobe_i => mms_read_strobe_i,
        read_data_o => mms_read_data_o,
        read_ack_o => mms_read_ack_o
    );
end;
