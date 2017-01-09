-- Bit array of single clock events.
-- Each single clock event is recorded and can then be read out via a register
-- interface.
--
-- A two stage readout is needed: first write to the register to latch the
-- current state of the accumulated bits and reset selected bits; then the
-- latched state can be read.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity pulsed_bits is
    port (
        clk_i : in std_logic;

        -- Control register interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t := (others => '0');
        read_ack_o : out std_logic;

        -- Input pulsed bits
        pulsed_bits_i : in reg_data_t
    );
end;

architecture pulsed_bits of pulsed_bits is
    signal pulsed_bits : reg_data_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                read_data_o <= pulsed_bits;
                pulsed_bits <=
                    pulsed_bits_i or (pulsed_bits and not write_data_i);
            else
                pulsed_bits <= pulsed_bits_i or pulsed_bits;
            end if;
        end if;
    end process;

    write_ack_o <= '1';
    read_ack_o <= '1';
end;
