-- DAC signal integrity test pattern generator.
--
-- If test_mode_i is set then test_pattern_i is used to generate the DAC data
-- signal.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity dac_test_pattern is
    port (
        adc_clk_i : in std_logic;

        test_mode_i : in std_logic;
        test_pattern_i : in reg_data_array_t(0 to 1);

        dac_data_i : in signed_array;
        dac_data_o : out signed_array;
        dac_frame_o : out std_logic
    );
end;

architecture arch of dac_test_pattern is
    signal test_mode : std_logic;
    signal test_pattern : reg_data_t;
    signal frame : std_logic := '0';
    signal frame_index : natural;

    signal dac_data : signed_array(CHANNELS)(15 downto 0);
    signal data_out : std_logic_vector(31 downto 0);

begin
    frame_index <= to_integer(frame);
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            frame <= not frame;
            test_pattern <= test_pattern_i(frame_index);
            test_mode <= test_mode_i;
            case test_mode is
                when '0' =>
                    dac_data <= dac_data_i;
                when '1' =>
                    dac_data(0) <= signed(test_pattern(15 downto 0));
                    dac_data(1) <= signed(test_pattern(31 downto 16));
                when others =>
            end case;
        end if;
    end process;

    -- Delay all outputs to allow signal to propagate across device
    dac_delay_inst : entity work.dlyreg generic map (
        DLY => 4,
        DW => 33
    ) port map (
        clk_i => adc_clk_i,
        data_i(15 downto  0) => std_logic_vector(dac_data(0)),
        data_i(31 downto 16) => std_logic_vector(dac_data(1)),
        data_i(32) => frame,
        data_o(31 downto 0) => data_out,
        data_o(32) => dac_frame_o
    );

    dac_data_o(0) <= signed(data_out(15 downto 0));
    dac_data_o(1) <= signed(data_out(31 downto 16));
end;
