-- Core implementation of ADC fill reject filter
--
-- Implemented to separate input buffers from implementation so that we can use
-- pblock placement.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fill_reject_core is
    generic (
        MAX_SHIFT : natural
    );
    port (
        clk_i : in std_ulogic;

        turn_clock_i : in std_ulogic;
        shift_i : in unsigned(3 downto 0);

        data_i : in signed;
        data_o : out signed
    );
end;

architecture arch of adc_fill_reject_core is
    constant DATA_WIDTH : natural := data_i'LENGTH;
    constant ACCUM_WIDTH : natural := DATA_WIDTH + MAX_SHIFT;

    subtype data_t is signed(DATA_WIDTH-1 downto 0);
    subtype accum_t is signed(ACCUM_WIDTH-1 downto 0);

    signal reset_accum : std_ulogic;
    signal write_offset : std_ulogic;

    -- Assembling the rounding bit is annoyingly trick, as we seem to be
    -- fighting the language to express the required result
    signal accum_bit : signed(ACCUM_WIDTH downto 0);
    signal accum_rounding : signed(ACCUM_WIDTH downto 0);

    signal accum_summand : accum_t;
    signal accum_in : accum_t;
    signal accum_out : accum_t;

    signal offset_in : data_t;
    signal offset_out : data_t;

    -- We need to allow for an extra bit of growth in the final result
    signal data_out : signed(DATA_WIDTH downto 0);

    -- The data flow in this design requires that a number of signals be
    -- accurately aligned, as illustrated below:
    --
    -- clk          .   .   .   .   .   .   .....   .   .   .....   .   .   .
    -- turn             /                    ...    /        ...    /
    -- accum_out    ----X a X--------------- ... ---X c X---------------X   X
    --                                               _______ ... _______
    -- reset_accum  ________________________ ... ___/                   \___
    -- accum_summand -------X a X----------- ... -------X 0 X--- ...
    -- data_i       --------X b X----------- ... -------X e X----- ...
    -- accum_in     ------------X c X------- ... -----------X e X------ ...
    -- offset_in    ----------------X d X--- ... ---------------X   X---- ...
    --                               _______ ... _______________
    -- write_offset ________________/                           \___ ...
    -- offset_out   --------X e X----------- ... -------X d X------- ...
    -- data_o       ------------X f X------- ... -----------X g X--- ...
    --
    -- The flow is annoying complex to capture, and the timing diagram above
    -- does a pretty poor job.  The essential idea is that each bunch is
    -- accumulated for 2^N turns.  In the figure above we see the turn-around
    -- at the end of this accumulation process.
    --
    -- Key:
    --  a - last value to add to in accumulator, a = sum of last N-1 bunches
    --  b - last bunch value to accumulate for this round
    --  c - total sum of last N bunches.  This is divided by N to produce
    --  d - mean of last N bunches.  This will be written to the offset memory
    --  e - last value out of offset memory to be subracted from data_i
    --  f - generated result for last turn of accumulation round
    --  g - generated result for first turn of next round
    --
    -- The two PROCESS_ delays below align the delay lines so that inputs and
    -- outputs line up, and the WRITE_OFFSET_DELAY is used as a skew between the
    -- two control signals.
    constant WRITE_OFFSET_DELAY : natural := 3;
    constant PROCESS_ACCUM_DELAY : natural := 2;
    constant PROCESS_OFFSET_DELAY : natural := 2;

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;

    -- Generates one turn accumulator reset every 2^shift_i turns
    counter : entity work.adc_fill_reject_counter generic map (
        MAX_SHIFT => MAX_SHIFT,
        WRITE_DELAY => WRITE_OFFSET_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock_i,
        shift_i => shift_i,
        reset_accum_o => reset_accum,
        write_offset_o => write_offset
    );

    -- Storage for accumulators
    accum_memory : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => PROCESS_ACCUM_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock_i,
        write_strobe_i => '1',
        data_i => accum_in,
        data_o => accum_out
    );

    -- Storage for computed baseline offsets
    offset_memory : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => PROCESS_OFFSET_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock_i,
        write_strobe_i => write_offset,
        data_i => offset_in,
        data_o => offset_out
    );


    accum_bit <= (0 => '1', others => '0');
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Accumulator
            accum_rounding <= shift_left(accum_bit, to_integer(shift_i));
            if reset_accum = '1' then
                accum_summand <= accum_rounding(ACCUM_WIDTH downto 1);
            else
                accum_summand <= accum_out;
            end if;
            accum_in <= resize(data_i, ACCUM_WIDTH) + accum_summand;

            offset_in <= resize(
                shift_right(accum_in, to_integer(shift_i)), DATA_WIDTH);

            data_out <=
                resize(data_i, DATA_WIDTH + 1) -
                resize(offset_out, DATA_WIDTH + 1) + 1;
        end if;
    end process;

    data_o <= data_out(DATA_WIDTH downto 1);
end;
