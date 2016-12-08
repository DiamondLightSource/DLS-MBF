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
    constant MMS_ROW_BITS : natural := 16 + 16 + 32 + 48;

    type mms_row_lanes_t is array(LANES) of mms_row_t;

    constant mms_reset_value : mms_row_t := (
        min => X"7FFF", max => X"8000",
        sum => (others => '0'), sum2 => (others => '0'));

    -- Conversion between packed and unpacked representation
    function mms_row_to_bits(data : mms_row_t) return std_logic_vector;
    function bits_to_mms_row(data : std_logic_vector) return mms_row_t;
end;

package body min_max_sum_defs is
    function mms_row_to_bits(data : mms_row_t) return std_logic_vector is
        variable result : std_logic_vector(MMS_ROW_BITS-1 downto 0);
    begin
        result(15 downto 0)   := std_logic_vector(data.min);
        result(31 downto 16)  := std_logic_vector(data.max);
        result(63 downto 32)  := std_logic_vector(data.sum);
        result(111 downto 64) := std_logic_vector(data.sum2);
        return result;
    end;

    function bits_to_mms_row(data : std_logic_vector) return mms_row_t is
        variable result : mms_row_t;
    begin
        result.min  := signed(data(15 downto  0));
        result.max  := signed(data(31 downto 16));
        result.sum  := signed(data(63 downto 32));
        result.sum2 := unsigned(data(111 downto 64));
        return result;
    end;
end;
