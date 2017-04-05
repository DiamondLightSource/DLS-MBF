-- General signal gain control.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity gain_control is
    generic (
        INTERVAL : natural := 1;        -- Shift interval in bits
        EXTRA_SHIFT : natural := 0      -- Low order bits to discard
    );
    port (
        clk_i : in std_logic;
        gain_sel_i : in unsigned;
        data_i : in signed;
        data_o : out signed;
        overflow_o : out std_logic
    );
end;

architecture arch of gain_control is
    constant WIDTH_IN : natural := data_i'LENGTH;
    constant WIDTH_OUT : natural := data_o'LENGTH;
    constant SEL_BITS : natural := gain_sel_i'LENGTH;
    constant SEL_COUNT : natural := 2**SEL_BITS;

    -- Compute working input width to be long enough to accomodate all possible
    -- shifts of the input data
    constant WIDTH_IN_MIN : natural :=
        WIDTH_OUT + (SEL_COUNT - 1) * INTERVAL + EXTRA_SHIFT;
    constant WIDTH_IN_MAX : natural := maximum(WIDTH_IN_MIN, WIDTH_IN);

    -- Input shifting using a generated barrel shifter.
    signal gain : natural range 0 to SEL_COUNT-1;
    signal data_in : signed(WIDTH_IN_MAX downto 0);
    signal data_sel : signed(WIDTH_IN_MAX downto 0) := (others => '0');

begin
    -- Zero pad data in for uniform rounding.
    data_in <= resize(data_i, WIDTH_IN_MAX) & '0';
    gain <= to_integer(gain_sel_i);

    process (clk_i) begin
        if rising_edge(clk_i) then
            data_sel <= shift_right(data_in, gain * INTERVAL + EXTRA_SHIFT);
        end if;
    end process;

    -- Truncation, rounding and overflow detection of result
    extract : entity work.extract_signed generic map (
        OFFSET => 1,
        EXTRA => 1
    ) port map (
        clk_i => clk_i,
        data_i => data_sel,
        data_o => data_o,
        overflow_o => overflow_o
    );
end;
