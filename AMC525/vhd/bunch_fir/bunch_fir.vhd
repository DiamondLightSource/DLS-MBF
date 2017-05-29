-- Bunch by bunch filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir is
    port (
        clk_i : in std_logic;
        turn_clock_i : in std_logic;
        taps_i : in signed_array;

        data_valid_i : in std_logic;
        data_i : in signed;
        data_valid_o : out std_logic := '0';
        data_o : out signed
    );
end;

architecture arch of bunch_fir is
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
    -- Path from DSP to memory
    signal accum_out : signed_array(TAPS_RANGE)(ACCUM_WIDTH-1 downto 0)
        := (others => (others => '0'));
    -- Path from memory to DSP
    signal delay_out : signed_array(TAPS_RANGE)(DELAY_WIDTH-1 downto 0)
        := (others => (others => '0'));

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

    constant DISTRIBUTION_DELAY : natural := 4;

    -- Delay from data in valid to accum_out valid.  This is derived from the
    -- following data path:
    --  data_i
    --      =(DISTRIBUTION_DELAY)=> data_in
    --      => product
    --      => accum_out
    constant DATA_VALID_DELAY : natural := DISTRIBUTION_DELAY + 2;
    -- Data valid for data out and updating delay line
    signal accum_out_valid : std_logic;

    -- Delay from delay_out to accum_out, used for delay line, derived from
    -- this data path:
    --  delay_out
    --      => accum_in
    --      => accum
    --      => accum_out
    constant PROCESS_DELAY : natural := 3;

    subtype DATA_OUT_RANGE is natural
        range ACCUM_WIDTH-1 downto ACCUM_WIDTH - DATA_OUT_WIDTH;
    signal data_out : data_o'SUBTYPE := (others => '0');

begin
    -- Ensure we fit within the DSP48E1
    assert TAP_WIDTH <= 25 severity failure;
    assert DATA_IN_WIDTH <= 18 severity failure;
    assert ACCUM_WIDTH <= 48 severity failure;
    -- Assume that accumulator is larger than the delay line.
    assert DELAY_WIDTH < ACCUM_WIDTH severity failure;


    -- Core processing DSP chain
    taps_gen : for t in TAPS_RANGE generate
        signal data_in : signed(data_i'RANGE);
        signal tap_in : signed(TAP_WIDTH-1 downto 0) := (others => '0');
        signal tap : signed(TAP_WIDTH-1 downto 0) := (others => '0');
        signal product : signed(PRODUCT_WIDTH-1 downto 0) := (others => '0');
        signal accum_in : signed(ACCUM_WIDTH-1 downto 0) := (others => '0');

    begin
        -- Data distribution delays.  Some of this will be absorbed into the
        -- destination DSP units.
        delays : entity work.dlyreg generic map (
            DLY => DISTRIBUTION_DELAY,
            DW => data_i'LENGTH
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(data_i),
            signed(data_o) => data_in
        );

        process (clk_i) begin
            if rising_edge(clk_i) then
                -- Three stages of pipeline are needed for the DSP48E1
                tap_in <= taps_i(TAP_COUNT-1 - t);     -- Taps in reverse order
                tap <= tap_in;

                product <= tap * data_in;
                -- Assemble input accumulator from its components
                accum_in(DELAY_RANGE) <= delay_out(t);
                accum_in(ROUND_OFFSET) <= '1';
                accum_in(PADDING_RANGE) <= (others => '0');

                accum_out(t) <= accum_in + product;
            end if;
        end process;
    end generate;


    -- Data extraction from processing chain (and empty initial accumulator)
    process (clk_i) begin
        if rising_edge(clk_i) then
            delay_out(0) <= (others => '0');
            data_out <= accum_out(TAP_COUNT-1)(DATA_OUT_RANGE);
            data_valid_o <= accum_out_valid;
        end if;
    end process;
    data_o <= data_out;


    -- Line up data valid with data
    valid_delay_inst : entity work.dlyline generic map (
        DLY => DATA_VALID_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => data_valid_i,
        data_o(0) => accum_out_valid
    );

    -- Delay lines between each bunch
    delay_gen : for t in 1 to TAP_COUNT-1 generate
        data_delay_inst : entity work.bunch_fir_delay generic map (
            PROCESS_DELAY => PROCESS_DELAY
        ) port map (
            clk_i => clk_i,
            turn_clock_i => turn_clock_i,
            write_strobe_i => accum_out_valid,
            data_i => accum_out(t-1)(DELAY_RANGE),
            data_o => delay_out(t)
        );
    end generate;
end;
