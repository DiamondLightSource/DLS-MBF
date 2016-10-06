-- DAC signal integrity test pattern generator.
--
-- If test_mode_i is set then test_pattern_i is used to generate the DAC data
-- signal.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity dac_test_pattern is
    port (
        adc_clk_i : in std_logic;

        test_mode_i : in std_logic;
        test_pattern_i : in reg_data_array_t(0 to 1);

        dac_data_a_i : in dac_out_t;
        dac_data_b_i : in dac_out_t;
        dac_data_a_o : out dac_out_t;
        dac_data_b_o : out dac_out_t;
        dac_frame_o : out std_logic
    );
end;

architecture dac_test_pattern of dac_test_pattern is
    signal test_mode : std_logic;
    signal test_pattern : reg_data_t;
    signal frame : std_logic := '0';
    signal frame_index : natural;
begin
    frame_index <= to_integer(unsigned'("" & frame));
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            frame <= not frame;
            test_pattern <= test_pattern_i(frame_index);
            test_mode <= test_mode_i;
            case test_mode is
                when '0' =>
                    dac_data_a_o <= dac_data_a_i;
                    dac_data_b_o <= dac_data_b_i;
                when '1' =>
                    dac_data_a_o <= signed(test_pattern(15 downto 0));
                    dac_data_b_o <= signed(test_pattern(31 downto 16));
            end case;
        end if;
    end process;
    dac_frame_o <= frame;
end;
