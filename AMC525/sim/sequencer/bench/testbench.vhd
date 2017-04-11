library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.nco_defs.all;
use work.sequencer_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';
    signal turn_clock : std_logic;

    constant TURN_COUNT : natural := 7;

    signal blanking : std_logic;
    signal write_strobe : std_logic_vector(DSP_SEQ_REGS);
    signal write_data : reg_data_t;
    signal write_ack : std_logic_vector(DSP_SEQ_REGS);
    signal read_strobe : std_logic_vector(DSP_SEQ_REGS);
    signal read_data : reg_data_array_t(DSP_SEQ_REGS);
    signal read_ack : std_logic_vector(DSP_SEQ_REGS);
    signal trigger : std_logic;
    signal state_trigger : std_logic;
    signal seq_start : std_logic;
    signal seq_write : std_logic;
    signal hom_freq : angle_t;
    signal hom_gain : unsigned(3 downto 0);
    signal hom_window : hom_win_t;
    signal bunch_bank : unsigned(1 downto 0);

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;


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

    blanking <= '0';

    sequencer : entity work.sequencer_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

        turn_clock_i => turn_clock,
        blanking_i => blanking,

        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,

        trigger_i => trigger,
        state_trigger_o => state_trigger,

        seq_start_o => seq_start,
        seq_write_o => seq_write,

        hom_freq_o => hom_freq,
        hom_gain_o => hom_gain,
        hom_window_o => hom_window,
        bunch_bank_o => bunch_bank
    );


    -- Register control interface
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(
                dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');

        wait;
    end process;
end;
