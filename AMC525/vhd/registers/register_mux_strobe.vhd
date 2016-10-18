-- Multiplexes a single strobe and acknowledge, used for register read and write
-- strobe and ack.
--
-- The figure below shows the timing of two exchanges, the first with immediate
-- ack, the second delayed.
--
--  Busy/Idle   | I | I | B | I | I | I | B | B | B | I | I |
--                   ___             ___
--  strobe_i    ____/   \___________/   \____________________
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
        clk_i : in std_logic;

        -- Register interface to demultiplex
        strobe_i : in std_logic;
        address_i : in reg_addr_t;
        ack_o : out std_logic := '0';

        -- Multiplexed registers
        strobe_o : out reg_strobe_t := (others => '0');
        ack_i : in reg_strobe_t
    );
end;

architecture register_mux_strobe of register_mux_strobe is
    signal address : natural;
    signal ack_in : std_logic;
    signal busy : boolean := false;

    -- Decodes an address into a single bit strobe
    function compute_strobe(index : natural; value : std_logic)
        return reg_strobe_t
    is
        variable result : reg_strobe_t := (others => '0');
    begin
        result(index) := value;
        return result;
    end;

begin
    address <= to_integer(address_i);
    ack_in <= ack_i(address);

    process (clk_i) begin
        if rising_edge(clk_i) then
            ack_o <= ack_in and to_std_logic(busy);
            strobe_o <= compute_strobe(address, strobe_i);
            if strobe_i = '1' then
                busy <= true;
            else
                busy <= busy and ack_in = '0';
            end if;
        end if;
    end process;
end;
