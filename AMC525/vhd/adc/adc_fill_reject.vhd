-- ADC fill pattern rejection filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fill_reject is
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

architecture arch of adc_fill_reject is
    constant DATA_WIDTH : natural := data_i'LENGTH;
    constant ACCUM_WIDTH : natural := DATA_WIDTH + MAX_SHIFT;

    subtype data_t is signed(DATA_WIDTH-1 downto 0);
    subtype accum_t is signed(ACCUM_WIDTH-1 downto 0);

    signal data_in : data_t;
    signal turn_clock : std_ulogic;

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

    -- The data flow in this design requires that a number of signals be
    -- accurately aligned, as illustrated below:
    constant WRITE_OFFSET_DELAY : natural := 2;
    constant PROCESS_ACCUM_DELAY : natural := 2;
    constant PROCESS_OFFSET_DELAY : natural := 2;

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;

    -- Turn clock and data in are pipelined for safety
    data_in_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW => DATA_WIDTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_in
    );

    turn_clock_delay : entity work.dlyreg generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => turn_clock_i,
        data_o(0) => turn_clock
    );


    -- Generates one turn accumulator reset every 2^shift_i turns
    counter : entity work.adc_fill_reject_counter generic map (
        MAX_SHIFT => MAX_SHIFT,
        WRITE_DELAY => WRITE_OFFSET_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock,
        shift_i => shift_i,
        reset_accum_o => reset_accum,
        write_offset_o => write_offset
    );

    -- Storage for accumulators
    accum_memory : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => PROCESS_ACCUM_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock,
        write_strobe_i => '1',
        data_i => accum_in,
        data_o => accum_out
    );

    -- Storage for computed baseline offsets
    offset_memory : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => PROCESS_OFFSET_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock,
        write_strobe_i => write_offset,
        data_i => offset_in,
        data_o => offset_out
    );


    accum_bit <= (0 => '1', others => '0');
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Accumulator
            accum_rounding <=
                shift_left(accum_bit, to_integer(shift_i), MAX_SHIFT);
            if reset_accum = '1' then
                accum_summand <= accum_rounding(ACCUM_WIDTH downto 1);
            else
                accum_summand <= accum_out;
            end if;
            accum_in <= resize(data_in, ACCUM_WIDTH) + accum_summand;

            offset_in <= resize(
                shift_right(accum_in, to_integer(shift_i), MAX_SHIFT),
                DATA_WIDTH);

            data_o <= data_in - offset_out;
        end if;
    end process;
end;
