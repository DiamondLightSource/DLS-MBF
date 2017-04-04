library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.detector_defs.all;

entity testbench is
end testbench;

architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural := 1) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';
    signal turn_clock : std_logic;

    constant TURN_COUNT : natural := 7;

    signal nco_frequency : angle_t := X"31234567";

    signal data : signed(24 downto 0) := (others => '0');
    signal iq_in : cos_sin_18_t;
    signal bunch_enable : std_logic;
    signal overflow_in : std_logic;
    signal overflow_out : std_logic;
    signal start : std_logic;
    signal write_in : std_logic;
    signal write_out : std_logic;
    signal iq_out : cos_sin_96_t;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    -- Turn clock
    process begin
        turn_clock <= '0';
        loop
            clk_wait(adc_clk, TURN_COUNT-1);
            turn_clock <= '1';
            clk_wait(adc_clk);
            turn_clock <= '0';
        end loop;
        wait;
    end process;

    -- Data ramp
--     process begin
--         clk_wait(adc_clk);
--         data <= data + 1234;
--     end process;
    data <= 25X"0000FFF";

    -- Oscillator for detector
--     nco : entity work.nco_core port map (
--         clk_i => adc_clk,
--         phase_advance_i => nco_frequency,
--         cos_sin_o => iq_in
--     );
    iq_in.cos <= 18X"1FFFF";
    iq_in.sin <= 18X"1FFFF";

    -- Detector under test
    detector_core : entity work.detector_core port map (
        clk_i => adc_clk,
        data_i => data,
        iq_i => iq_in,
        bunch_enable_i => bunch_enable,
        overflow_i => overflow_in,
        overflow_o => overflow_out,
        start_i => start,
        write_i => write_in,
        write_o => write_out,
        iq_o => iq_out
    );


    bunch_enable <= '1';
    overflow_in <= '0';

    process begin
        start <= '0';
        write_in <= '0';

        clk_wait(adc_clk, 2);
        start <= '1';
        clk_wait(adc_clk);
        start <= '0';

        loop
            clk_wait(adc_clk, 10);
            start <= '1';
            write_in <= '1';
            clk_wait(adc_clk);
            start <= '0';
            write_in <= '0';
        end loop;

        wait;
    end process;

end;
