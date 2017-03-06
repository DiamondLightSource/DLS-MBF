-- Maps a register read from DSP to ADC clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity register_read_adc is
    port (
        dsp_clk_i : in std_logic;
        adc_clk_i : in std_logic;

        -- Register interface on DSP clock
        dsp_read_strobe_i : in std_logic_vector;
        dsp_read_data_o : out reg_data_array_t;
        dsp_read_ack_o : out std_logic_vector;

        -- Translated register interface on ADC clock
        adc_read_strobe_o : out std_logic_vector;
        adc_read_data_i : in reg_data_array_t;
        adc_read_ack_i : in std_logic_vector
    );
end;

architecture register_read_adc of register_read_adc is
    signal adc_phase : std_logic;

    subtype register_range is natural range dsp_read_strobe_i'RANGE;
    signal read_strobe : dsp_read_strobe_i'SUBTYPE;
    signal read_ack : std_logic_vector(register_range) := (others => '0');
    signal read_data : dsp_read_data_o'SUBTYPE;
    signal read_ack_pl : std_logic_vector(register_range) := (others => '0');
    signal read_data_pl : dsp_read_data_o'SUBTYPE;

begin
    phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            for r in register_range loop
                adc_read_strobe_o(r) <= read_strobe(r) and adc_phase;
                if adc_read_ack_i(r) = '1' then
                    read_data(r) <= adc_read_data_i(r);
                    read_ack(r) <= '1';
                elsif adc_phase = '0' then
                    read_ack(r) <= '0';
                end if;
            end loop;
        end if;
    end process;

    -- Ensure that our outputs are properly registered on the DSP clock domain
    -- and add a pipeline stage to assist with timing.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            read_strobe <= dsp_read_strobe_i;
            read_data_pl <= read_data;
            read_ack_pl <= read_ack;
            dsp_read_data_o <= read_data_pl;
            dsp_read_ack_o <= read_ack_pl;
        end if;
    end process;
end;
