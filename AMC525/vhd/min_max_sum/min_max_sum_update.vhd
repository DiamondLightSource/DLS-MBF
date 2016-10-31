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
    signal mms : mms_row_t;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if data_i < mms_i.min then
                mms.min <= data_i;
            else
                mms.min <= mms_i.min;
            end if;
            if data_i > mms_i.max then
                mms.max <= data_i;
            else
                mms.max <= mms_i.max;
            end if;
            mms.sum <= mms_i.sum + resize(data_i, 32);

            mms_o <= mms;
            delta_o <= unsigned(mms.max - mms.min);
        end if;
    end process;
end;
