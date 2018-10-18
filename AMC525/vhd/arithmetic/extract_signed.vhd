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
        EXTRA : natural := 0;
        PROCESS_DELAY : natural := 3
    );
    port (
        clk_i : in std_ulogic;

        data_i : in signed;
        data_o : out signed;
        overflow_o : out std_ulogic := '0'
    );
end;

architecture arch of extract_signed is
    constant BIT_WIDTH_IN  : natural := data_i'LENGTH;
    constant BIT_WIDTH_OUT : natural := data_o'LENGTH;
    constant ROUNDED_WIDTH : natural := BIT_WIDTH_IN - OFFSET + EXTRA;

    signal sign : std_ulogic := '0';
    signal rounded : signed(ROUNDED_WIDTH-1 downto 0) := (others => '0');
    signal truncated : data_o'SUBTYPE := (others => '0');
    signal data_out : data_o'SUBTYPE := (others => '0');
    signal overflow : std_ulogic := '0';

begin
    -- Process delay check when needed by caller
    --  data_i => rounded => truncated,overflow => data_out = data_o
    assert PROCESS_DELAY = 3 severity failure;

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Round the incoming value
            rounded <= round(data_i, ROUNDED_WIDTH - EXTRA, EXTRA);

            -- Extract the output and check for overflow.
            sign <= sign_bit(rounded);
            truncate_result(truncated, overflow, rounded);

            -- Saturate the result if necessary
            data_out <= saturate(truncated, overflow, sign);
            overflow_o <= overflow;
        end if;
    end process;
    data_o <= data_out;
end;
