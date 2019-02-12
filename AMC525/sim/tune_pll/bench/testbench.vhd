library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use ieee.math_real.all;

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

    -- Device under test signals
    signal write_strobe : std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS)
        := (others => '0');
    signal write_data : reg_data_t;
    signal write_ack : std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
    signal read_strobe : std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS)
        := (others => '0');
    signal read_data : reg_data_array_t(DSP_TUNE_PLL_CONTROL_REGS);
    signal read_ack : std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
    signal adc_data : signed(15 downto 0);
    -- We're just using 'Z' as a placeholder for unused signals because it shows
    -- as a different colour from 'X' and 'U'.
    signal adc_fill_reject : signed(15 downto 0) := (others => 'Z');
    signal fir_data : signed(24 downto 0) := (others => 'Z');
    signal nco_iq : cos_sin_18_t;
    signal start : std_ulogic := '0';
    signal blanking : std_ulogic := '0';
    signal nco_gain : unsigned(3 downto 0);
    signal nco_enable : std_ulogic;
    signal nco_freq : angle_t;

    -- Simulated test data
    constant TEST_GAIN : natural := 16#1000#;
    constant NOISE_GAIN : real := real(16#1000#);
    signal test_freq : angle_t := 48X"1000_0000_0000";
    signal data_cos_sin : cos_sin_16_t;
    signal adc_noise : adc_data'SUBTYPE;

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


    -- NCO
    nco : entity work.sim_nco port map (
        clk_i => adc_clk,
        nco_freq_i => nco_freq,
        gain_i => 16#1fffc#,
        cos_sin_o => nco_iq
    );


    -- Test data: sin wave with added noise
    data_nco : entity work.sim_nco port map (
        clk_i => adc_clk,
        nco_freq_i => test_freq,
        gain_i => TEST_GAIN,
        cos_sin_o => data_cos_sin
    );
    process (all)
        variable seed1 : positive := 1;
        variable seed2 : positive := 1;
        variable noise : real;
    begin
        uniform(seed1, seed2, noise);
        adc_noise <= to_signed(integer(noise * NOISE_GAIN), 16);
        adc_data <= data_cos_sin.cos + adc_noise;
    end process;


    -- Register control
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg(dsp_clk, read_data, read_strobe, read_ack, reg);
        end;

        procedure clk_wait(count : in natural := 1) is
        begin
            clk_wait(dsp_clk, count);
        end;

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');

        clk_wait;

        write_reg(23, X"76543210");
        write_reg(24, X"0000BA98");

        wait;
    end process;

end;
