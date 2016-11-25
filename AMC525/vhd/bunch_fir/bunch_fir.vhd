-- Bunch by bunch filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir is
    port (
        dsp_clk_i : in std_logic;
        bunch_index_i : in unsigned;
        taps_i : in signed_array;

        data_valid_i : in std_logic;
        data_i : in signed;
        data_valid_o : out std_logic;
        data_o : out signed
    );
end;

architecture bunch_fir of bunch_fir is
    -- Widths and counts derived from arguments.
    constant TAP_COUNT : natural := taps_i'LENGTH;
    constant TAP_WIDTH : natural := taps_i(0)'LENGTH;
    constant DATA_IN_WIDTH : natural := data_i'LENGTH;
    constant DATA_OUT_WIDTH : natural := data_o'LENGTH;

    -- The required accumulator width is simply the width of the product plus
    -- extra bits required for accumulation of the number of taps.  So a 43 bit
    -- product (the maximum possible) allows for up to 63 taps (HEADROOM = 5),
    -- and the number of taps can be increased by reducing the input size
    -- accordingly.
    constant HEADROOM : natural := bits(TAP_COUNT) - 1;
    constant PRODUCT_WIDTH : natural := DATA_IN_WIDTH + TAP_WIDTH;
    constant ACCUM_WIDTH : natural := PRODUCT_WIDTH + HEADROOM;
    -- The delay line between taps is limited to 36 bits to fit into BRAM, and
    -- for simplicity we assume that we'll have to clip to fit into the delay.
    constant DELAY_WIDTH : natural := 36;

    -- Signal processing chain
    subtype TAPS_RANGE is natural range 0 to TAP_COUNT-1;
    signal taps : signed_array(TAPS_RANGE)(TAP_WIDTH-1 downto 0);
    signal data_in : signed_array(TAPS_RANGE)(DATA_IN_WIDTH-1 downto 0);
    signal product : signed_array(TAPS_RANGE)(PRODUCT_WIDTH-1 downto 0);
    signal accum_in : signed_array(TAPS_RANGE)(ACCUM_WIDTH-1 downto 0);
    signal accum_out : signed_array(TAPS_RANGE)(ACCUM_WIDTH-1 downto 0);
    -- Data delay line
    signal delay_out : signed_array(TAPS_RANGE)(DELAY_WIDTH-1 downto 0);

    -- The accumulator input is assembled from three parts of widths as shown:
    --
    --     DELAY_WIDTH        1    ACCUM_WIDTH-DELAY_WIDTH-1        (widths)
    --  +-------------------+---+----------------------------+
    --  |  delay_out(t)     | 1 |  0...0                     |
    --  +-------------------+---+----------------------------+
    --     DELAY_RANGE   ROUND_OFFSET       PADDING_RANGE           (ranges)
    constant ROUND_OFFSET : natural := ACCUM_WIDTH - DELAY_WIDTH - 1;
    subtype DELAY_RANGE is natural range ACCUM_WIDTH-1 downto ROUND_OFFSET+1;
    subtype PADDING_RANGE is natural range ROUND_OFFSET-1 downto 0;

    -- Delay from data in valid to accum_out valid.  This is derived from the
    -- following data path:
    --      data_i => data_in => product => accum_out
    constant DATA_VALID_DELAY : natural := 3;
    -- Data valid for data out and updating delay line
    signal accum_out_valid : std_logic;

    -- Delay from delay_out to accum_out, used for delay line, derived from
    -- this data path:
    --      delay_out => accum_in => accum_out
    constant PROCESS_DELAY : natural := 2;

begin
    -- Ensure we fit within the DSP48E1
    assert TAP_WIDTH <= 25;
    assert DATA_IN_WIDTH <= 18;
    assert ACCUM_WIDTH <= 48;
    -- Assume that accumulator is larger than the delay line.
    assert DELAY_WIDTH < ACCUM_WIDTH;

    -- Core processing DSP chain
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            delay_out(0) <= (others => '0');
            for t in TAPS_RANGE loop
                -- Accumulator optimised for DSP unit
                taps(t) <= taps_i(t);
                data_in(t) <= data_i;
                product(t) <= taps(t) * data_in(t);
                accum_out(t) <= accum_in(t) + product(t);

                -- Assemble input accumulator from its components
                accum_in(t)(DELAY_RANGE) <= delay_out(t);
                accum_in(t)(ROUND_OFFSET) <= '1';
                accum_in(t)(PADDING_RANGE) <= (others => '0');
            end loop;

            data_o <= round(accum_out(TAP_COUNT-1), DATA_OUT_WIDTH);
            data_valid_o <= accum_out_valid;
        end if;
    end process;

    valid_delay_inst : entity work.dlyline generic map (
        DLY => DATA_VALID_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => data_valid_i,
        data_o(0) => accum_out_valid
    );

    -- Delay lines between each bunch
    delay_gen : for t in 1 to TAP_COUNT-1 generate
        data_delay_inst : entity work.bunch_fir_delay generic map (
            PROCESS_DELAY => PROCESS_DELAY
        ) port map (
            clk_i => dsp_clk_i,
            bunch_index_i => bunch_index_i,
            write_strobe_i => accum_out_valid,
            data_i => accum_out(t-1)(DELAY_RANGE),
            data_o => delay_out(t)
        );
    end generate;
end;
