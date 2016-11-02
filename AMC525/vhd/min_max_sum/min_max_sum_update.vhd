-- Update of min/max/sum value

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.min_max_sum_defs.all;

entity min_max_sum_update is
    port (
        clk_i : in std_logic;

        data_i : in signed;
        mms_i : in mms_row_t;
        mms_o : out mms_row_t;

        overflow_o : out std_logic;
        delta_o : out unsigned
    );
end;

architecture min_max_sum_update of min_max_sum_update is
    -- We hang onto the computed min and max values so that the delta can be
    -- computed accurately now, and not one turn later -- we could even miss an
    -- event if a buffer swap occurred at the wrong time!
    signal data_pl : signed(data_i'RANGE);
    signal data : signed(data_i'RANGE);
    signal mms : mms_row_t;
    signal product : signed(31 downto 0);

    -- Overflow detection
    signal old_sum_top : std_logic_vector(1 downto 0);
    signal delta_sum_top : std_logic_vector(3 downto 0);
    signal old_sum2_top : std_logic;
    signal delta_sum2_top : std_logic_vector(1 downto 0);
    signal sum_overflow : std_logic;
    signal sum2_overflow : std_logic;

begin
    -- Start with a data pipeline protected from being eaten by the DSP unit.
    dlyreg_inst : entity work.dlyreg generic map (
        DW => data_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_pl
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Pipeline input data to help DSP unit
            data <= data_pl;

            -- Min/Max
            if data < mms_i.min then
                mms.min <= data;
            else
                mms.min <= mms_i.min;
            end if;
            if data > mms_i.max then
                mms.max <= data;
            else
                mms.max <= mms_i.max;
            end if;

            -- Compute sum and pipeline sum of squares
            mms.sum <= mms_i.sum + resize(data, 32);
            mms.sum2 <= mms_i.sum2;

            -- Compute sum of squares
            product <= data * data;
            -- To ensure the accumulator stays inside the DSP48E1 unit we fake
            -- it to perform signed arithmetic.  Doesn't change the results.
            mms_o.sum2 <= unsigned(resize(product, 48) + signed(mms.sum2));

            -- All outputs are generated together
            mms_o.min <= mms.min;
            mms_o.max <= mms.max;
            mms_o.sum <= mms.sum;

            delta_o <= unsigned(mms.max - mms.min);


            -- Overflow detection.  This is not synchronised to the outgoing
            -- result as this is not needed.

            -- Detect signed overflow if large positive number goes negative or
            -- large negative number goes positive.
            old_sum_top <= std_logic_vector(mms.sum(31 downto 30));
            sum_overflow <= to_std_logic(
                delta_sum_top = "0110" or delta_sum_top = "1001");

            -- Unsigned overflow if top bit goes from 1 to 0.
            old_sum2_top <= mms.sum2(47);
            sum2_overflow <= to_std_logic(delta_sum2_top = "10");

            overflow_o <= sum_overflow or sum2_overflow;
        end if;
    end process;

    delta_sum2_top <= old_sum2_top & mms_o.sum2(47);
    delta_sum_top <= old_sum_top & std_logic_vector(mms_o.sum(31 downto 30));
end;
