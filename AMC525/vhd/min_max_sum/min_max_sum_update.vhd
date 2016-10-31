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

        delta_o : out unsigned
    );
end;

architecture min_max_sum_update of min_max_sum_update is
    -- We hang onto the computed min and max values so that the delta can be
    -- computed accurately now, and not one turn later -- we could even miss an
    -- event if a buffer swap occurred at the wrong time!
    signal data : signed(data_i'RANGE);
    signal mms : mms_row_t;
    signal product : unsigned(31 downto 0);

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Pipeline input data to help DSP unit
            data <= data_i;

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
            product <= unsigned(data * data);
            mms_o.sum2 <= resize(product, 48) + mms.sum2;

            -- All outputs are generated together
            mms_o.min <= mms.min;
            mms_o.max <= mms.max;
            mms_o.sum <= mms.sum;

            delta_o <= unsigned(mms.max - mms.min);
        end if;
    end process;
end;
