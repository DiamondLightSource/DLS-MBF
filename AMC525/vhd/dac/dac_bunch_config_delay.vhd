-- Delay line for NCO data
--
-- Seems kind of redundant now we've added the bunch config conversions.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bunch_defs.all;

entity dac_bunch_config_delay is
    generic (
        DELAY : natural
    );
    port (
        clk_i : in std_ulogic;
        data_i : in bunch_config_t;
        data_o : out bunch_config_t
    );
end;

architecture arch of dac_bunch_config_delay is
    signal data_out : bunch_config_bits_t;

begin
    delay_line : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => BUNCH_CONFIG_BITS
    ) port map (
        clk_i => clk_i,
        data_i => from_bunch_config_t(data_i),
        data_o => data_out
    );

    data_o <= to_bunch_config_t(data_out);
end;
