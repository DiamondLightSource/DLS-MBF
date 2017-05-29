-- Data rate reduction for bunch by bunch data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_fir_decimate is
    port (
        clk_i : in std_logic;

        turn_clock_i : in std_logic;
        decimation_shift_i : in unsigned;
        decimation_limit_i : in unsigned;

        data_i : in signed;
        data_o : out signed;
        data_valid_o : out std_logic := '0'
    );
end;

architecture arch of bunch_fir_decimate is
    -- We can accumulate up to the maximum value of decimation_shift_i extra
    -- bits.
    constant ACCUM_BITS : natural :=
        data_i'LENGTH + 2**decimation_shift_i'LENGTH - 1;

    -- Internal processing delay, needed for memory delay line
    --  accum.data_o = read_data_pl
    --      => read_data
    --      => accumulator = accum.data_i
    constant PROCESS_DELAY : natural := 2;

    signal decimation_counter : decimation_limit_i'SUBTYPE;
    signal first_turn : boolean := false;
    signal last_turn : boolean := false;

    signal data_in : signed(ACCUM_BITS-1 downto 0) := (others => '0');
    signal read_data : signed(ACCUM_BITS-1 downto 0) := (others => '0');
    signal read_data_pl : signed(ACCUM_BITS-1 downto 0);
    signal accumulator : signed(ACCUM_BITS-1 downto 0) := (others => '0');
    signal write_data : signed(ACCUM_BITS-1 downto 0) := (others => '0');
    signal data_out : signed(ACCUM_BITS-1 downto 0) := (others => '0');
    -- The data valid is derived from last_turn with a two tick delay
    signal data_valid : std_logic := '0';

begin
    -- Bunch memory for accumulator
    accum_inst : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => PROCESS_DELAY
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock_i,
        write_strobe_i => '1',
        data_i => accumulator,
        data_o => read_data_pl
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- First and last turn computation
            if turn_clock_i = '1' then
                if decimation_counter = 0 then
                    decimation_counter <= decimation_limit_i;
                else
                    decimation_counter <= decimation_counter - 1;
                end if;
                last_turn <= decimation_counter = 0;
                first_turn <= last_turn;
            end if;

            data_in <= resize(data_i, ACCUM_BITS);

            -- On first turn we reset the accumulator, otherwise accumulate
            read_data <= read_data_pl;
            if first_turn then
                accumulator <= data_in;
            else
                accumulator <= data_in + read_data;
            end if;
            write_data <= accumulator;

            -- Always output the shifted data
            data_out <= shift_right(write_data, to_integer(decimation_shift_i));

            -- Delay last turn to match data delay
            data_valid <= to_std_logic(last_turn);
            data_valid_o <= data_valid;
        end if;
    end process;

    data_o <= data_out(data_o'RANGE);
end;
