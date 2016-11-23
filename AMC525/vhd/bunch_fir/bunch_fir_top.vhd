-- Top level control for bunch by bunch FIR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity bunch_fir_top is
    generic (
        TAP_COUNT : natural
    );
    port (
        dsp_clk_i : in std_logic;

        data_i : in signed_array;
        data_o : out signed_array;

        -- General register interface
        write_strobe_i : in std_logic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 1);
        read_strobe_i : in std_logic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_logic_vector(0 to 1);

        -- Pulse events
        write_start_i : in std_logic        -- For register block writes
    );
end;

architecture bunch_fir_top of bunch_fir_top is
begin
    -- Dummy empty implementation
    data_o <= data_i;
    write_ack_o <= (others => '1');
    read_ack_o <= (others => '1');
end;
