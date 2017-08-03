-- Delay line for NCO data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.dsp_defs.all;

entity dac_nco_delay is
    generic (
        DELAY : natural
    );
    port (
        clk_i : in std_logic;
        data_i : in dsp_nco_from_mux_t;
        data_o : out dsp_nco_from_mux_t
    );
end;

architecture arch of dac_nco_delay is
begin
    nco_delay : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => data_i.nco'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i.nco),
        signed(data_o) => data_o.nco
    );

    gain_delay : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => data_i.gain'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i.gain),
        unsigned(data_o) => data_o.gain
    );

    enable_delay : entity work.dlyreg generic map (
        DLY => DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => data_i.enable,
        data_o(0) => data_o.enable
    );
end;
