-- Core DSP calculation step of FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir_dsp is
    generic (
        TAP_COUNT : natural;
        DATA_DELAY : natural;       -- Delay data_i => accum_o
        ACCUM_DELAY : natural       -- Delay accum_i => accum_o
    );
    port (
        clk_i : in std_logic;

        tap_i : in signed;
        data_i : in signed;
        accum_i : in signed;
        accum_o : out signed        -- accum_o <= accum_i + tap_i * data_i
    );
end;

architecture arch of bunch_fir_dsp is
    -- Widths and counts derived from arguments.
    constant TAP_WIDTH : natural := tap_i'LENGTH;
    constant DATA_IN_WIDTH : natural := data_i'LENGTH;
    constant DATA_OUT_WIDTH : natural := accum_i'LENGTH;

    -- The required accumulator width is simply the width of the product plus
    -- extra bits required for accumulation of the number of taps.  So a 43 bit
    -- product (the maximum possible) allows for up to 63 taps (HEADROOM = 5),
    -- and the number of taps can be increased by reducing the input size
    -- accordingly.
    constant HEADROOM : natural := bits(TAP_COUNT) - 1;
    constant PRODUCT_WIDTH : natural := DATA_IN_WIDTH + TAP_WIDTH;
    constant ACCUM_WIDTH : natural := PRODUCT_WIDTH + HEADROOM;

    -- The accumulator input is assembled from three parts of widths as shown:
    --
    --     DATA_OUT_WIDTH     1    ACCUM_WIDTH-DATA_OUT_WIDTH-1     (widths)
    --  +-------------------+---+----------------------------+
    --  |  accum_i          | 1 |  0...0                     |
    --  +-------------------+---+----------------------------+
    --     DATA_OUT_RANGE ROUND_OFFSET       PADDING_RANGE          (ranges)
    constant ROUND_OFFSET : natural := ACCUM_WIDTH - DATA_OUT_WIDTH - 1;
    subtype DATA_OUT_RANGE is natural range ACCUM_WIDTH-1 downto ROUND_OFFSET+1;
    subtype PADDING_RANGE is natural range ROUND_OFFSET-1 downto 0;

    -- All these signals are DSP internal registers
    signal tap_in : tap_i'SUBTYPE := (others => '0');
    signal data_in : data_i'SUBTYPE := (others => '0');
    signal product : signed(PRODUCT_WIDTH-1 downto 0) := (others => '0');
    signal accum_in : signed(ACCUM_WIDTH-1 downto 0);
    signal accum : signed(ACCUM_WIDTH-1 downto 0) := (others => '0');
    signal accum_out : signed(ACCUM_WIDTH-1 downto 0) := (others => '0');

    -- Protect incoming registers from being unneccessarily absorbed into DSP
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of data_i : signal is "yes";
    attribute DONT_TOUCH of tap_i : signal is "yes";

begin
    assert accum_i'LENGTH = accum_o'LENGTH severity failure;

    -- Ensure we fit within the DSP48E1
    assert TAP_WIDTH <= 25 severity failure;
    assert DATA_IN_WIDTH <= 18 severity failure;
    assert ACCUM_WIDTH <= 48 severity failure;
    -- Assume that accumulator is larger than the delay line.
    assert DATA_OUT_WIDTH < ACCUM_WIDTH severity failure;

    -- Validate delays:
    --  data_i => data_in => product => accum_out = accum_o
    assert DATA_DELAY = 3 severity failure;
    --  accum_i = accum_in => accum => accum_out = accum_o
    assert ACCUM_DELAY = 2 severity failure;


    -- Assemble input accumulator from its components
    accum_in(DATA_OUT_RANGE) <= accum_i;
    accum_in(ROUND_OFFSET) <= '1';
    accum_in(PADDING_RANGE) <= (others => '0');

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Bring data into DSP unit
            tap_in <= tap_i;
            data_in <= data_i;

            product <= tap_in * data_in;
            accum <= accum_in;

            accum_out <= accum + product;
        end if;
    end process;

    accum_o <= accum_out(DATA_OUT_RANGE);
end;
