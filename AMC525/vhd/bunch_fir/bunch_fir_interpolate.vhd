-- Data rate increase for bunch by bunch
--
-- In fact all we do is hold each bunch value

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir_interpolate is
    port (
        clk_i : in std_logic;
        turn_clock_i : in std_logic;
        data_valid_i : in std_logic;
        data_i : in signed;
        data_o : out signed
    );
end;

architecture arch of bunch_fir_interpolate is
    -- Input pipeline
    constant INPUT_DELAY : natural := 4;
    signal data_in : data_i'SUBTYPE;
    signal data_valid_in : std_logic;

    signal read_data : data_i'SUBTYPE := (others => '0');
    signal data_out : data_o'SUBTYPE := (others => '0');

begin
    assert data_i'LENGTH = data_o'LENGTH severity failure;

    -- Pipeline input
    input_pipeline : entity work.dlyreg generic map (
        DLY => INPUT_DELAY,
        DW => data_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i),
        signed(data_o) => data_in
    );

    valid_pipeline : entity work.dlyreg generic map (
        DLY => INPUT_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => data_valid_i,
        data_o(0) => data_valid_in
    );

    -- Hold data for interpolation
    bunch_delay : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => 0
    ) port map (
        clk_i => clk_i,
        turn_clock_i => turn_clock_i,
        write_strobe_i => data_valid_in,
        data_i => data_in,
        data_o => read_data
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            if data_valid_in then
                data_out <= data_in;
            else
                data_out <= read_data;
            end if;
        end if;
    end process;

    data_o <= data_out;
end;
