-- Extracts a signed subfield with rounding, overflow detection and saturation,
-- with the appropriate pipeline stages.

-- The OFFSET argument determines how many least significant bits are discarded
-- and rounded, and EXTRA can be set to 1 if an extra bit might be required to
-- handle word growth during rounding.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity extract_signed is
    generic (
        OFFSET : natural;
        EXTRA : natural := 0
    );
    port (
        clk_i : in std_logic;

        data_i : in signed;
        data_o : out signed;
        overflow_o : out std_logic
    );
end;

architecture extract_signed of extract_signed is
    constant BIT_WIDTH_IN  : natural := data_i'LEFT - data_i'RIGHT + 1;
    constant BIT_WIDTH_OUT : natural := data_o'LEFT - data_o'RIGHT + 1;
    constant ROUNDED_WIDTH : natural := BIT_WIDTH_IN - OFFSET + EXTRA;

    signal sign : std_logic;
    signal rounded : signed(ROUNDED_WIDTH-1 downto 0);
    signal truncated : signed(data_o'RANGE);
    signal overflow : std_logic;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Round the incoming value
            rounded <= round(data_i, ROUNDED_WIDTH);

            -- Extract the output and check for overflow.
            sign <= rounded(rounded'LEFT);
            truncate_result(truncated, overflow, rounded);

            -- Saturate the result if necessary
            data_o <= saturate(truncated, overflow, sign);
            overflow_o <= overflow;
        end if;
    end process;
end;
