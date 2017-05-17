-- Update of min/max/sum/sum2 value with accumulator overflow detection.

-- The delay from mms_i to mms_o is 2 ticks:
--
--                              | ----- 2 ----> |
--  clk_i               /       /       /       /       /       /       /
--  data_i          ----< d     >------------------------------------------
--  data_in         ------------< d     >----------------------------------
--  mms_i.min/max   ------------< mm    >----------------------------------
--  mms_i.sum       ------------< s     >----------------------------------
--  mms_i.sum2      ------------< s2    >----------------------------------
--  mms.min/max     --------------------< mm(d) >--------------------------
--  mms.sum         --------------------< s+d   >--------------------------
--  mms.sum2        --------------------< s2    >--------------------------
--  product         --------------------< d*d   >--------------------------
--  mms_o.min/max   ----------------------------< mm(d) >------------------
--  mms_o.sum       ----------------------------< s+d   >------------------
--  mms_o.sum2      ----------------------------< s2+dd >------------------
--  sum_overflow    ----------------------------< s ovf >------------------
--  sum_overflow_o  ------------------------------------< s ovf >----------
--  sum2_overflow_o ------------------------------------< s2 of >----------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.min_max_sum_defs.all;

entity min_max_sum_update is
    generic (
        UPDATE_DELAY : natural
    );
    port (
        clk_i : in std_logic;

        data_i : in signed(15 downto 0);
        mms_i : in mms_row_t;
        mms_o : out mms_row_t := mms_reset_value;

        sum_overflow_o : out std_logic := '0';
        sum2_overflow_o : out std_logic := '0';
        delta_o : out unsigned(15 downto 0) := (others => '0')
    );
end;

architecture arch of min_max_sum_update is
    -- We hang onto the computed min and max values so that the delta can be
    -- computed accurately now, and not one turn later -- we could even miss an
    -- event if a buffer swap occurred at the wrong time!
    signal data_in : data_i'SUBTYPE := (others => '0');
    signal data_delay : data_i'SUBTYPE := (others => '0');
    signal mms : mms_row_t := mms_reset_value;
    signal product : signed(31 downto 0) := (others => '0');
    signal data_small : boolean := false;
    signal data_large : boolean := false;

    -- Overflow detection
    signal old_sum_top : std_logic_vector(1 downto 0) := "00";
    signal delta_sum_top : std_logic_vector(3 downto 0) := "0000";
    signal old_sum2_top : std_logic := '0';
    signal delta_sum2_top : std_logic_vector(1 downto 0) := "00";
    signal sum_overflow : std_logic := '0';

    -- Prevent DSP unit for consuming an extra input register!
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of data_i : signal is "yes";

begin
    -- Delay mms_i => mms_o
    --  mms_i
    --      => mms
    --      => mms_o
    assert UPDATE_DELAY = 2 severity failure;

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Data pipeline
            data_in <= data_i;
            data_delay <= data_in;

            -- Min/Max
            data_small <= data_in < mms_i.min;
            mms.min <= mms_i.min;
            if data_small then
                mms_o.min <= data_delay;
            else
                mms_o.min <= mms.min;
            end if;

            data_large <= data_in > mms_i.max;
            mms.max <= mms_i.max;
            if data_large then
                mms_o.max <= data_delay;
            else
                mms_o.max <= mms.max;
            end if;

            -- Compute sum
            mms.sum <= mms_i.sum + data_in;
            mms_o.sum <= mms.sum;

            -- Compute sum of squares
            product <= data_in * data_in;
            mms.sum2 <= mms_i.sum2;
            -- To ensure the accumulator stays inside the DSP48E1 unit we fake
            -- it to perform signed arithmetic.  Doesn't change the results.
            mms_o.sum2 <= unsigned(product + signed(mms.sum2));

            delta_o <= unsigned(mms_o.max - mms_o.min);


            -- Overflow detection.  This is not synchronised to the outgoing
            -- result as this is not needed, but we do want the two overflows
            -- to be synchronised.

            -- Detect signed overflow if large positive number goes negative or
            -- large negative number goes positive.
            old_sum_top <= std_logic_vector(mms_i.sum(31 downto 30));
            sum_overflow <= to_std_logic(
                delta_sum_top = "0110" or delta_sum_top = "1001");
            sum_overflow_o <= sum_overflow;

            -- Unsigned overflow if top bit goes from 1 to 0.
            old_sum2_top <= mms.sum2(47);
            sum2_overflow_o <= to_std_logic(delta_sum2_top = "10");
        end if;
    end process;

    -- Concatenate old and new versions of top bits of accumulators for fast
    -- overflow detection.
    delta_sum_top <= old_sum_top & std_logic_vector(mms.sum(31 downto 30));
    delta_sum2_top <= old_sum2_top & mms_o.sum2(47);
end;
