-- Data rate reduction for bunch by bunch data.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_fir_decimate is
    port (
        dsp_clk_i : in std_logic;

        bunch_index_i : in bunch_count_t;
        decimation_shift_i : in unsigned;

        first_turn_i : in std_logic;
        last_turn_i : in std_logic;
        data_i : in signed;
        data_o : out signed;
        data_valid_o : out std_logic
    );
end;

architecture bunch_fir_decimate of bunch_fir_decimate is
    -- We can accumulate up to the maximum value of decimation_shift_i extra
    -- bits.
    constant ACCUM_BITS : natural :=
        data_i'LENGTH + 2**decimation_shift_i'LENGTH - 1;

    -- One tick internal processing delay, needed for memory delay line
    constant PROCESS_DELAY : natural := 1;

    signal data_in : signed(ACCUM_BITS-1 downto 0);
    signal read_data : signed(ACCUM_BITS-1 downto 0);
    signal write_data : signed(ACCUM_BITS-1 downto 0);
    signal data_out : signed(ACCUM_BITS-1 downto 0);
    -- The data valid is derived from last_turn_i with a two tick delay
    signal data_valid : std_logic;

begin
    -- Bunch memory for accumulator
    accum_inst : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => PROCESS_DELAY
    ) port map (
        clk_i => dsp_clk_i,
        bunch_index_i => bunch_index_i,
        write_strobe_i => '1',
        data_i => write_data,
        data_o => read_data
    );

    data_in <= resize(data_i, ACCUM_BITS);
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- On first turn we reset the accumulator, otherwise accumulate
            if first_turn_i = '1' then
                write_data <= data_in;
            else
                write_data <= data_in + read_data;
            end if;
            data_valid <= last_turn_i;

            -- Always output the shifted data
            data_out <= shift_right(write_data, to_integer(decimation_shift_i));
            data_valid_o <= data_valid;
        end if;
    end process;

    data_o <= data_out(data_o'RANGE);
end;
