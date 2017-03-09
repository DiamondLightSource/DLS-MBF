-- Pipeline of data to fast memory

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.dsp_defs.all;

entity fast_memory_pipeline is
    port (
        clk_i : in std_logic;

        dsp_to_control_i : in dsp_to_control_array_t;
        adc_o : out signed_array;
        fir_o : out signed_array;
        dac_o : out signed_array
    );
end;

architecture arch of fast_memory_pipeline is
begin
    channel_gen : for c in CHANNELS generate
        -- Because of a bug in Questa Sim we can't assign directly to output!
        signal adc : signed(15 downto 0);
        signal dac : signed(15 downto 0);
        signal fir : signed(FIR_DATA_RANGE);
    begin
        adc_dly : entity work.dlyreg generic map (
            DLY => 4,
            DW => 16
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(dsp_to_control_i(c).adc_data),
            signed(data_o) => adc
        );
        adc_o(c) <= adc;

        dac_dly : entity work.dlyreg generic map (
            DLY => 4,
            DW => 16
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(dsp_to_control_i(c).dac_data),
            signed(data_o) => dac
        );
        dac_o(c) <= dac;

        fir_dly : entity work.dlyreg generic map (
            DLY => 4,
            DW => FIR_DATA_WIDTH
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(dsp_to_control_i(c).fir_data),
            signed(data_o) => fir
        );
        fir_o(c) <= fir;
    end generate;
end;
