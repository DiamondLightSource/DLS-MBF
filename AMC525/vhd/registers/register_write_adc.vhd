-- Maps a register write from DSP to ADC clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity register_write_adc is
    port (
        dsp_clk_i : in std_logic;
        adc_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Register interface on DSP clock
        dsp_write_strobe_i : in std_logic_vector;
        dsp_write_data_i : in reg_data_t;
        dsp_write_ack_o : out std_logic_vector;

        -- Translated register interface on ADC clock
        adc_write_strobe_o : out std_logic_vector;
        adc_write_data_o : out reg_data_t;
        adc_write_ack_i : in std_logic_vector
    );
end;

architecture register_write_adc of register_write_adc is
    subtype register_range is natural range dsp_write_strobe_i'RANGE;
    signal write_ack : std_logic_vector(register_range) := (others => '0');

begin
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            for r in register_range loop
                adc_write_strobe_o(r) <= dsp_write_strobe_i(r) and adc_phase_i;
                if adc_write_ack_i(r) = '1' then
                    write_ack(r) <= '1';
                elsif adc_phase_i = '0' then
                    write_ack(r) <= '0';
                end if;
            end loop;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            dsp_write_ack_o <= write_ack;
        end if;
    end process;

    adc_write_data_o <= dsp_write_data_i;
end;
