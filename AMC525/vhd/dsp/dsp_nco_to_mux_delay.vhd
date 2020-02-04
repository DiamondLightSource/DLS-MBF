-- Delay line with NCO, gain, enable

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.dsp_defs.all;

entity dsp_nco_to_mux_delay is
    generic (
        DELAY : natural
    );
    port (
        clk_i : in std_ulogic;
        data_i : in dsp_nco_to_mux_t;
        data_o : out dsp_nco_to_mux_t
    );
end;

architecture arch of dsp_nco_to_mux_delay is
begin
    nco_delay : entity work.nco_delay generic map (
        DELAY => DELAY
    ) port map (
        clk_i => clk_i,
        cos_sin_i => data_i.nco,
        cos_sin_o => data_o.nco
    );

    gain_delay : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => data_i.gain'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(data_i.gain),
        unsigned(data_o) => data_o.gain
    );
end;
