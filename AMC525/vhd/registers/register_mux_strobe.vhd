-- Multiplexes a single strobe and acknowledge, used for register read and write
-- strobe and ack.
--
-- The figure below shows the timing of two exchanges, the first with immediate
-- ack, the second delayed.
--
--  Busy/Idle   | I | I | B | I | I | I | B | B | B | I | I |
--                   ___             ___
--  strobe_i    ____/   \___________/   \____________________
--
--  address_i   XXXXX n         XXXXX n                 XXXXX
--                       ___             ___
--  strobe_o[n] ________/   \___________/   \________________
--                       ___                     ___
--  ack_i[n]    XXXXXXXXX   XXXXXXXXXXXXX_______/   XXXXXXXXX
--                           ___                     ___
--  ack_o       ____________/   \___________________/   \____

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity register_mux_strobe is
    port (
        clk_i : in std_ulogic;

        -- Register interface to demultiplex
        strobe_i : in std_ulogic;
        address_i : in unsigned;
        ack_o : out std_ulogic := '0';

        -- Multiplexed registers
        strobe_o : out std_ulogic_vector;
        ack_i : in std_ulogic_vector
    );
end;

architecture arch of register_mux_strobe is
    signal address : natural;
    signal ack_in : std_ulogic;
    signal busy : boolean := false;
    signal strobe : strobe_o'SUBTYPE := (others => '0');

begin
    assert strobe_o'LOW = 0 and ack_i'LOW = 0 severity failure;
    assert strobe_o'LENGTH = ack_i'LENGTH severity failure;
    assert strobe_o'ASCENDING and ack_i'ASCENDING severity failure;

    address <= to_integer(address_i);
    ack_in <= ack_i(address) when address <= ack_i'HIGH else '1';

    process (clk_i) begin
        if rising_edge(clk_i) then
            ack_o <= ack_in and to_std_ulogic(busy);
            if strobe_i = '1' then
                if address <= ack_i'HIGH then
                    strobe <= compute_strobe(address, strobe_o'LENGTH);
                end if;
                busy <= true;
            else
                strobe <= (others => '0');
                busy <= busy and ack_in = '0';
            end if;
        end if;
    end process;

    strobe_o <= strobe;
end;
