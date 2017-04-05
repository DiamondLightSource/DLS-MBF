library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.detector_defs.all;
use work.register_defs.all;

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

    -- detector_top parameters
    signal write_strobe : std_logic_vector(DSP_DET_REGS);
    signal write_data : reg_data_t;
    signal write_ack : std_logic_vector(DSP_DET_REGS);
    signal read_strobe : std_logic_vector(DSP_DET_REGS);
    signal read_data : reg_data_array_t(DSP_DET_REGS);
    signal read_ack : std_logic_vector(DSP_DET_REGS);
    signal adc_data : signed(15 downto 0);
    signal fir_data : signed(35 downto 0);
    signal nco_iq : cos_sin_18_t;
    signal window : signed(17 downto 0);
    signal start : std_logic;
    signal write : std_logic;
    signal mem_valid : std_logic;
    signal mem_ready : std_logic;
    signal mem_addr : unsigned(19 downto 0);
    signal mem_data : std_logic_vector(63 downto 0);

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

    nco_iq.cos <= 18X"1FFFF";
    nco_iq.sin <= 18X"1FFFF";

    adc_data <= 16X"1234";
    fir_data <= 36X"123456789";
    window <= 18X"1FFFF";

    detector : entity work.detector_top generic map (
        MEMORY_BUFFER_LENGTH => 2
    ) port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        turn_clock_i => turn_clock,
        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,
        adc_data_i => adc_data,
        fir_data_i => fir_data,
        nco_iq_i => nco_iq,
        window_i => window,
        start_i => start,
        write_i => write,
        mem_valid_o => mem_valid,
        mem_ready_i => mem_ready,
        mem_addr_o => mem_addr,
        mem_data_o => mem_data
    );

    write_strobe <= (others => '0');
    read_strobe <= (others => '0');
    start <= '0';
    write <= '0';
    mem_ready <= '1';



--     -- Initialise the bunch memory
--     process begin
--         start_write <= '0';
--         bunch_write <= '0';
--         clk_wait(dsp_clk, 2);
-- 
--         start_write <= '1';
--         clk_wait(dsp_clk);
--         start_write <= '0';
-- 
--         write_data <= X"00000055";
--         bunch_write <= '1';
--         clk_wait(dsp_clk);
--         bunch_write <= '0';
-- 
--         wait;
--     end process;
-- 
-- 
--     -- Generate cycles of capture
--     process begin
--         start <= '0';
--         write_in <= '0';
-- 
--         clk_wait(adc_clk, 2);
--         start <= '1';
--         clk_wait(adc_clk);
--         start <= '0';
-- 
--         loop
--             clk_wait(adc_clk, 10);
--             start <= '1';
--             write_in <= '1';
--             clk_wait(adc_clk);
--             start <= '0';
--             write_in <= '0';
--         end loop;
-- 
--         wait;
--     end process;
-- 
-- 
--     -- Test sequence with gain changes and data flow
--     process begin
--         ready <= '1';
--         output_scaling <= "000";
-- 
--         clk_wait(dsp_clk, 22);
--         output_scaling <= "001";
-- 
--         clk_wait(dsp_clk, 10);
--         ready <= '0';
-- 
--         wait;
--     end process;
end;
