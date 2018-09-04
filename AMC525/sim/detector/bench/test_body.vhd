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
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural := 1) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';
    signal turn_clock : std_ulogic;

    constant TURN_COUNT : natural := 7;

    signal nco_frequency : angle_t := X"31234567";

    -- detector_core parameters
    signal start_write : std_ulogic;
    signal bunch_write : std_ulogic;
    signal write_data : reg_data_t;
    signal data : signed(24 downto 0);
    signal iq_in : cos_sin_18_t;
    signal start : std_ulogic;
    signal write_in : std_ulogic;
    signal data_overflow_in : std_ulogic;
    signal data_overflow : std_ulogic;
    signal detector_overflow : std_ulogic;
    signal output_underrun : std_ulogic;
    signal output_scaling : unsigned(2 downto 0);
    signal valid : std_ulogic;
    signal ready : std_ulogic;
    signal data_out : std_ulogic_vector(63 downto 0);

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
    detector_body : entity work.detector_body generic map (
        BUFFER_LENGTH => 2
    ) port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        turn_clock_i => turn_clock,
        start_write_i => start_write,
        bunch_write_i => bunch_write,
        write_data_i => write_data,
        data_i => data,
        iq_i => iq_in,
        start_i => start,
        write_i => write_in,
        data_overflow_i => data_overflow_in,
        data_overflow_o => data_overflow,
        detector_overflow_o => detector_overflow,
        output_underrun_o => output_underrun,
        output_scaling_i => output_scaling,
        valid_o => valid,
        ready_i => ready,
        data_o => data_out
    );

    data_overflow_in <= '0';

    -- Initialise the bunch memory
    process begin
        start_write <= '0';
        bunch_write <= '0';
        clk_wait(dsp_clk, 2);

        start_write <= '1';
        clk_wait(dsp_clk);
        start_write <= '0';

        write_data <= X"00000055";
        bunch_write <= '1';
        clk_wait(dsp_clk);
        bunch_write <= '0';

        wait;
    end process;


    -- Generate cycles of capture
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


    -- Test sequence with gain changes and data flow
    process begin
        ready <= '1';
        output_scaling <= "000";

        clk_wait(dsp_clk, 22);
        output_scaling <= "001";

        clk_wait(dsp_clk, 10);
        ready <= '0';

        wait;
    end process;
end;
