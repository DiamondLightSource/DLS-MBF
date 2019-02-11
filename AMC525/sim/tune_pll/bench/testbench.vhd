library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.nco_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';

    constant TURN_COUNT : natural := 64;
    signal turn_clock : std_ulogic;

    signal write_strobe : std_ulogic_vector(DUMMY_TUNE_PLL_REGS)
        := (others => '0');
    signal write_data : reg_data_t;
    signal write_ack : std_ulogic_vector(DUMMY_TUNE_PLL_REGS);
    signal read_strobe : std_ulogic_vector(DUMMY_TUNE_PLL_REGS)
        := (others => '0');
    signal read_data : reg_data_array_t(DUMMY_TUNE_PLL_REGS);
    signal read_ack : std_ulogic_vector(DUMMY_TUNE_PLL_REGS);
    signal adc_data : signed(15 downto 0);
    signal adc_fill_reject : signed(15 downto 0);
    signal fir_data : signed(24 downto 0);
    signal nco_iq : cos_sin_18_t;
    signal start : std_ulogic := '0';
    signal blanking : std_ulogic := '0';
    signal nco_gain : unsigned(3 downto 0);
    signal nco_enable : std_ulogic;
    signal nco_freq : angle_t;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    tune_pll : entity work.tune_pll_top port map (
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
        adc_fill_reject_i => adc_fill_reject,
        fir_data_i => fir_data,
        nco_iq_i => nco_iq,
        start_i => start,
        blanking_i => blanking,
        nco_gain_o => nco_gain,
        nco_enable_o => nco_enable,
        nco_freq_o => nco_freq
    );

    -- Generate turn clock
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

end;
