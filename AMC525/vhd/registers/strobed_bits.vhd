-- Converts write to a register into an array of strobed bits

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity strobed_bits is
    generic (
        BUFFER_LENGTH : natural := 2
    );
    port (
        clk_i : in std_ulogic;

        -- Control register interface
        write_strobe_i : in std_ulogic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic;

        -- Output strobed bits
        strobed_bits_o : out reg_data_t
    );
end;

architecture arch of strobed_bits is
    signal strobed_bits : reg_data_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                strobed_bits <= write_data_i;
            else
                strobed_bits <= (others => '0');
            end if;
        end if;
    end process;

    delay_strobe : entity work.dlyreg generic map (
        DLY => BUFFER_LENGTH,
        DW => strobed_bits_o'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => strobed_bits,
        data_o => strobed_bits_o
    );

    -- Delay the ack so that it's synchronous with our delayed strobe.  This
    -- will avoid problems if the next register write depends on side effects of
    -- the strobe.
    delay_ack : entity work.dlyline generic map (
        DLY => BUFFER_LENGTH + 1
    ) port map (
        clk_i => clk_i,
        data_i(0) => write_strobe_i,
        data_o(0) => write_ack_o
    );
end;
