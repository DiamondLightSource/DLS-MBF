-- Delay line for NCO data

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
    signal data_in : std_ulogic_vector(BUNCH_CONFIG_BITS-1 downto 0);
    signal data_out : std_ulogic_vector(BUNCH_CONFIG_BITS-1 downto 0);

begin
    data_in <= (
        1 downto 0 => std_logic_vector(data_i.fir_select),
        2 => data_i.fir_enable,
        3 => data_i.nco_0_enable,
        4 => data_i.nco_1_enable,
        5 => data_i.nco_2_enable,
        23 downto 6 => std_logic_vector(data_i.gain)
    );

    delay_line : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => BUNCH_CONFIG_BITS
    ) port map (
        clk_i => clk_i,
        data_i => data_in,
        data_o => data_out
    );

    data_o <= (
        fir_select => unsigned(data_out(1 downto 0)),
        fir_enable => data_out(2),
        nco_0_enable => data_out(3),
        nco_1_enable => data_out(4),
        nco_2_enable => data_out(5),
        gain => signed(data_out(23 downto 6))
    );
end;
