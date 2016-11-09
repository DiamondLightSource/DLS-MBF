-- Definitions for min/max/sum

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package min_max_sum_defs is

    type mms_row_t is record
        min : signed(15 downto 0);
        max : signed(15 downto 0);
        sum : signed(31 downto 0);
        sum2 : unsigned(47 downto 0);
    end record;

    type mms_row_channels_t is array(CHANNELS) of mms_row_t;

    constant mms_reset_value : mms_row_t := (
        min => X"7FFF", max => X"8000",
        sum => (others => '0'), sum2 => (others => '0'));

end package;
