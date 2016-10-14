-- Fast FIR designed to run at ADC clock rate using DSP48E1

-- Enough bits are used internally to avoid any loss of accuracy or overflow,
-- and the output is rounded and truncated with overflow detection.

-- Handle the bits as follows, where L.R means L+R bits with an integer range of
-- L bits and a fraction of R bits.  In particular a signed L.R value has range
-- covering [-2^(L-1) .. 2^(L-1)-2^-R]
--
--      Value       Bits
--      -----       ----
--      data_i      1.N     N + 1 = BIT_WIDTH_IN
--      taps_i      1.M     M + 1 = TAP_WIDTH
--      data_o      L.R     L = EXTRA_BITS + 1, L + R = BIT_WIDTH_OUT
--
-- Internally we accumulate with H+2.N+M bits where H is headroom computed so
-- no overflow can occur during filter accumulation.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fast_fir is
    generic (
        EXTRA_BITS : natural := 0;
        TAP_WIDTH : natural := 18;
        TAP_COUNT : natural
    );
    port (
        adc_clk_i : in std_logic;

        taps_i : in reg_data_array_t(0 to TAP_COUNT-1);

        data_i : in signed;
        data_o : out signed;
        overflow_o : out std_logic
    );
end;

architecture fast_fir of fast_fir is
    -- Extract data in and out dimensions from arguments
    constant BIT_WIDTH_IN  : natural := data_i'LEFT - data_i'RIGHT + 1;
    constant BIT_WIDTH_OUT : natural := data_o'LEFT - data_o'RIGHT + 1;

    constant PRODUCT_WIDTH : natural := BIT_WIDTH_IN + TAP_WIDTH;   -- 2.N+M
    -- The required headroom follows from the number of taps
    constant HEADROOM : natural := bits(TAP_COUNT) - 1;
    constant SUM_WIDTH : natural := PRODUCT_WIDTH + HEADROOM;       -- H+2.N+M

    -- The offset extraction is somewhat involved: to the left of the final
    -- output we have headroom from which we extract our extra bits.
    constant EXTRACT_OFFSET : natural :=
        SUM_WIDTH - BIT_WIDTH_OUT - HEADROOM - EXTRA_BITS - 1;

    subtype TAP_RANGE is natural range 0 to TAP_COUNT-1;
    subtype TAP_RANGE_1 is natural range 0 to TAP_COUNT;

    signal taps_in : signed_array(TAP_RANGE)(TAP_WIDTH-1 downto 0);
    signal taps_pl : signed_array(TAP_RANGE)(TAP_WIDTH-1 downto 0);
    signal taps : signed_array(TAP_RANGE)(TAP_WIDTH-1 downto 0);
    signal data_in : signed_array(TAP_RANGE)(BIT_WIDTH_IN-1 downto 0);
    signal product : signed_array(TAP_RANGE)(PRODUCT_WIDTH-1 downto 0);
    signal sum : signed_array(TAP_RANGE_1)(SUM_WIDTH-1 downto 0);
    signal sum_out : signed(SUM_WIDTH-1 downto 0);

    -- A pipeline to help with timing and fanout
    signal data_in_delay : signed(BIT_WIDTH_IN-1 downto 0);


begin
    -- Ensure we're not make an unrealistic request
    assert EXTRA_BITS <= HEADROOM + 1;      -- Ensure L <= H+2

    sum(0) <= (others => '0');
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            -- Pipeline on input
            data_in_delay <= data_i;

            -- The filter structured so that the DSP48E1 will work optimally:
            -- for this it's important to pipeline with the correct number of
            -- registers.
            for i in 0 to TAP_COUNT-1 loop
                -- Bring the taps close to the DSP and on the right clock.
                taps_in(i) <= signed(taps_i(i)(
                    REG_DATA_WIDTH-1 downto REG_DATA_WIDTH-TAP_WIDTH));

                -- All of the following registers are inside the DSP48E1,
                -- including taps_pl!
                taps_pl(i) <= taps_in(i);
                taps(i) <= taps_pl(i);
                data_in(i) <= data_in_delay;
                product(i) <= taps(i) * data_in(i);
                sum(i + 1) <= sum(i) + product(i);
            end loop;

            sum_out <= sum(TAP_COUNT);
        end if;
    end process;

    -- Finally extract the result with rounding, overflow detection and
    -- saturation if necessary.
    extract_signed_inst : entity work.extract_signed generic map (
        OFFSET => EXTRACT_OFFSET
    ) port map (
        clk_i => adc_clk_i,
        data_i => sum_out,
        data_o => data_o,
        overflow_o => overflow_o
    );
end;
