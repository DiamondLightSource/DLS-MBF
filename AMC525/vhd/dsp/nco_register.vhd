-- Register file for writing an NCO frequency: two 32-bit register words to
-- update a 48-bit frequency, updated only on write to second word, final output
-- on ADC clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;

entity nco_register is
    port (
        -- Clocking
        clk_i : in std_ulogic;

        -- Register control interface
        write_strobe_i : in std_ulogic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(0 to 1);
        read_strobe_i : in std_ulogic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_ulogic_vector(0 to 1);

        -- Current frequency
        nco_freq_o : out angle_t;
        reset_phase_o : out std_ulogic
    );
end;

architecture arch of nco_register is
    signal freq_low_bits : reg_data_t;

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i(0) = '1' then
                freq_low_bits <= write_data_i;
            end if;

            if write_strobe_i(1) = '1' then
                nco_freq_o <= (
                    31 downto 0 => unsigned(freq_low_bits),
                    47 downto 32 => unsigned(write_data_i(15 downto 0))
                );

                reset_phase_o <= write_data_i(31);
            else
                reset_phase_o <= '0';
            end if;
        end if;
    end process;


    read_data_o(0) <= std_ulogic_vector(nco_freq_o(31 downto 0));
    read_data_o(1) <= (
        15 downto 0 => std_ulogic_vector(nco_freq_o(47 downto 32)),
        others => '0'
    );

    write_ack_o <= (others => '1');
    read_ack_o <= (others => '1');
end;
