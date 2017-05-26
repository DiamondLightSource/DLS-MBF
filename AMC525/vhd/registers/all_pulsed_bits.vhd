-- This is similar in behaviour to pulsed_bits, but is simpler to use: readout
-- always returns all changed bits and no associated write cycle is needed.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity all_pulsed_bits is
    generic (
        BUFFER_LENGTH : natural := 4
    );
    port (
        clk_i : in std_logic;

        -- Control register interface
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t := (others => '0');
        read_ack_o : out std_logic := '0';

        -- Input pulsed bits
        pulsed_bits_i : in reg_data_t
    );
end;

architecture arch of all_pulsed_bits is
    signal pulsed_bits_in : reg_data_t;
    signal pulsed_bits : reg_data_t := (others => '0');

begin
    delay : entity work.dlyreg generic map (
        DLY => BUFFER_LENGTH,
        DW => pulsed_bits_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => pulsed_bits_i,
        data_o => pulsed_bits_in
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            if read_strobe_i = '1' then
                read_data_o <= pulsed_bits;
                pulsed_bits <= pulsed_bits_in;
            else
                pulsed_bits <= pulsed_bits_in or pulsed_bits;
            end if;
            read_ack_o <= read_strobe_i;
        end if;
    end process;
end;
