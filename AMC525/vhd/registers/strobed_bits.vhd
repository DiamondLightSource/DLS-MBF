-- Converts write to a register into an array of strobed bits

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity strobed_bits is
    generic (
        BUFFER_LENGTH : natural := 4
    );
    port (
        clk_i : in std_logic;

        -- Control register interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;

        -- Output strobed bits
        strobed_bits_o : out reg_data_t
    );
end;

architecture arch of strobed_bits is
    signal strobed_bits_out : reg_data_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                strobed_bits_out <= write_data_i;
            else
                strobed_bits_out <= (others => '0');
            end if;
        end if;
    end process;

    delay : entity work.dlyreg generic map (
        DLY => BUFFER_LENGTH,
        DW => strobed_bits_o'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => strobed_bits_out,
        data_o => strobed_bits_o
    );

    write_ack_o <= '1';
end;
