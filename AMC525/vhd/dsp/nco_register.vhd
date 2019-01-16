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
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_ulogic_vector(0 to 1);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(0 to 1);
        read_strobe_i : in std_ulogic_vector(0 to 1);
        read_data_o : out reg_data_array_t(0 to 1);
        read_ack_o : out std_ulogic_vector(0 to 1);

        -- Current frequency
        nco_freq_o : out angle_t
    );
end;

architecture arch of nco_register is
    signal nco_registers : reg_data_array_t(0 to 1);
    signal nco_freq_dsp : angle_t;

    signal freq_low_bits : reg_data_t;
    signal freq_high_bits : reg_data_t;

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_strobe_i(0) = '1' then
                freq_low_bits <= write_data_i;
            end if;

            if write_strobe_i(1) = '1' then
                nco_freq_dsp <= (
                    31 downto 0 => unsigned(freq_low_bits),
                    47 downto 32 => unsigned(write_data_i(15 downto 0))
                );
            end if;
        end if;
    end process;

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            nco_freq_o <= nco_freq_dsp;
        end if;
    end process;


    read_data_o(0) <= std_logic_vector(nco_freq_dsp(31 downto 0));
    read_data_o(1) <= (
        15 downto 0 => std_logic_vector(nco_freq_dsp(47 downto 32)),
        others => '0'
    );

    write_ack_o <= (others => '1');
    read_ack_o <= (others => '1');
end;
