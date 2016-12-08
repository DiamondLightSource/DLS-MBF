-- Data rate increase for bunch by bunch
--
-- In fact all we do is hold each bunch value

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir_interpolate is
    port (
        dsp_clk_i : in std_logic;
        bunch_index_i : in unsigned;
        data_valid_i : in std_logic;
        data_i : in signed;
        data_o : out signed
    );
end;

architecture bunch_fir_interpolate of bunch_fir_interpolate is
    signal read_data : signed(data_i'RANGE);

begin
    assert data_i'LENGTH = data_o'LENGTH;

    delay_inst : entity work.bunch_fir_delay generic map (
        PROCESS_DELAY => 0
    ) port map (
        clk_i => dsp_clk_i,
        bunch_index_i => bunch_index_i,
        write_strobe_i => data_valid_i,
        data_i => data_i,
        data_o => read_data
    );

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if data_valid_i then
                data_o <= data_i;
            else
                data_o <= read_data;
            end if;
        end if;
    end process;
end;