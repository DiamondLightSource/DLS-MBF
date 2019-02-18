-- Simple one pole filter with pole at 1-2^-N.
--
-- The IIR increment step should be:
--      y <= x + y - abs_ceiling(y >> N) = x + (1-2^-N) y
-- where
--      abs_ceiling(y) = ceiling(y)     for y >= 0
--      abs_ceiling(y) = floor(y)       for y < 0
--
-- Performing this extra adjustment ensures that the accumulator always
-- decreases and helps to ensure that the accumulator will never overflow.

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity one_pole_iir is
    generic (
        SHIFT_STEP : natural := 1       -- Interval between shifts
    );
    port (
        clk_i : in std_logic;

        data_i : in signed;
        iir_shift_i : in unsigned;
        start_i : in std_logic;

        data_o : out signed;
        done_o : out std_logic
    );
end;

architecture one_pole_iir of one_pole_iir is
    constant DATA_BITS_IN : natural := data_i'LENGTH;
    constant SHIFT_BITS : natural := iir_shift_i'LENGTH;
    constant DATA_BITS_OUT : natural := data_o'LENGTH;

    -- Allow for scaling increase.  If we've done our reckoning right there
    -- should be no overflow.
    constant MAX_SHIFT_VALUE : natural := 2**SHIFT_BITS - 1;
    constant MAX_SHIFT : natural := MAX_SHIFT_VALUE * SHIFT_STEP;
    constant ACCUM_BITS : natural := DATA_BITS_IN + MAX_SHIFT;

    -- Accumulator and shifted accumulator
    subtype accum_t is signed(ACCUM_BITS-1 downto 0);
    signal iir_accum : accum_t := (others => '0');
    signal shifted_accum : accum_t := (others => '0');
    signal updated_accum : accum_t := (others => '0');
    signal extended_data : accum_t := (others => '0');
    signal shifted_data : accum_t := (others => '0');

    signal data_shift : unsigned(SHIFT_BITS-1 downto 0) := (others => '0');

    -- The or of the bits shifted out from the bottom of the accumulator is
    -- needed for the abs_ceiling calculation, which is in turn needed to ensure
    -- that when the filter is sufficiently small it does shrink correctly.
    signal bottom_bits : std_logic_vector(MAX_SHIFT_VALUE downto 0);
    signal abs_ceiling : signed(1 downto 0) := (others => '0');

    signal data_ready : std_logic := '0';

begin
    -- Assign bottom bits from accumulator before shift
    bottom_bits(0) <= '0';
    gen_bits : for i in 1 to MAX_SHIFT_VALUE generate
        bottom_bits(i) <= vector_or(iir_accum(i*SHIFT_STEP-1 downto 0));
    end generate;

    -- Input data sign extended to accumulator width
    extended_data <= resize(data_i, ACCUM_BITS);

    process (clk_i) begin
        if rising_edge(clk_i) then

            -- Shifted version of accumulator.
            shifted_accum <= shift_right(
                iir_accum, to_integer(iir_shift_i * SHIFT_STEP));

            if bottom_bits(to_integer(iir_shift_i)) = '1' and
               iir_accum >= 0 then
                abs_ceiling <= to_signed(1, 2);
            else
                abs_ceiling <= to_signed(0, 2);
            end if;

            data_shift <= not iir_shift_i;
            shifted_data <= shift_left(
                extended_data, to_integer(data_shift * SHIFT_STEP));

            -- Updated version of accumulator ready and waiting for data update.
            updated_accum <= iir_accum - shifted_accum - abs_ceiling;
            if data_ready = '1' then
                iir_accum <= updated_accum + shifted_data;
            end if;

            -- Ready flag percolates through
            data_ready <= start_i;
            done_o <= data_ready;
        end if;
    end process;

    data_o <= iir_accum(ACCUM_BITS-1 downto ACCUM_BITS-DATA_BITS_OUT);
end;
