library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';

    constant TURN_COUNT : natural := 31;

    signal write_strobe : std_ulogic_vector(CTRL_TRG_REGS);
    signal write_data : reg_data_t;
    signal write_ack : std_ulogic_vector(CTRL_TRG_REGS);
    signal read_strobe : std_ulogic_vector(CTRL_TRG_REGS);
    signal read_data : reg_data_array_t(CTRL_TRG_REGS);
    signal read_ack : std_ulogic_vector(CTRL_TRG_REGS);
    signal revolution_clock : std_ulogic := '0';
    signal event_trigger : std_ulogic := '0';
    signal postmortem_trigger : std_ulogic;
    signal blanking_trigger : std_ulogic;
    signal adc_trigger : std_ulogic_vector(CHANNELS);
    signal dac_trigger : std_ulogic_vector(CHANNELS);
    signal seq_trigger : std_ulogic_vector(CHANNELS);
    signal blanking_window : std_ulogic;
    signal turn_clock : std_ulogic;
    signal seq_start : std_ulogic_vector(CHANNELS);
    signal dram0_trigger : std_ulogic;
    signal dram0_phase : std_ulogic;
    signal start_tune_pll0 : std_ulogic;
    signal start_tune_pll1 : std_ulogic;
    signal stop_tune_pll0 : std_ulogic;
    signal stop_tune_pll1 : std_ulogic;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

--     revolution_clock <= not revolution_clock after 17.3 ns;
    revolution_clock <= not revolution_clock after 17 ns;
    event_trigger <= not event_trigger after 40 ns;

    postmortem_trigger <= '0';
    blanking_trigger <= '0';
    adc_trigger <= "00";
    dac_trigger <= "00";
    seq_trigger <= "00";

    triggers : entity work.trigger_top port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,

        revolution_clock_i => revolution_clock,
        event_trigger_i => event_trigger,
        postmortem_trigger_i => postmortem_trigger,
        blanking_trigger_i => blanking_trigger,

        adc_trigger_i => adc_trigger,
        dac_trigger_i => dac_trigger,
        seq_trigger_i => seq_trigger,

        blanking_window_o => blanking_window,
        turn_clock_o => turn_clock,
        seq_start_o => seq_start,
        dram0_trigger_o => dram0_trigger,
        dram0_phase_o => dram0_phase,

        start_tune_pll0_o => start_tune_pll0,
        start_tune_pll1_o => start_tune_pll1,
        stop_tune_pll0_o => stop_tune_pll0,
        stop_tune_pll1_o => stop_tune_pll1
    );


    -- Register control interface
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(
                dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg(dsp_clk, read_data, read_strobe, read_ack, reg);
        end;

        procedure arm(seq0 : std_ulogic; seq1 : std_ulogic; dram : std_ulogic)
        is
            variable command : reg_data_t;
        begin
            command := (
                CTRL_TRG_CONTROL_SEQ0_ARM_BIT => seq0,
                CTRL_TRG_CONTROL_SEQ1_ARM_BIT => seq1,
                CTRL_TRG_CONTROL_DRAM0_ARM_BIT => dram,
                others => '0');
            write_reg(CTRL_TRG_CONTROL_REG_W, command);
        end;

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');

        clk_wait(dsp_clk);

        -- max_bunch = 6 (7 ticks per turn)
        write_reg(CTRL_TRG_CONFIG_TURN_REG, (
            CTRL_TRG_CONFIG_TURN_MAX_BUNCH_BITS => 10X"006",
            CTRL_TRG_CONFIG_TURN_TURN_OFFSET_BITS => 10X"003",
            others => '0'));
        write_reg(CTRL_TRG_CONTROL_REG_W, (
            CTRL_TRG_CONTROL_SYNC_TURN_BIT => '1',
            others => '0'));

        read_reg(CTRL_TRG_PULSED_REG_R);
        read_reg(CTRL_TRG_STATUS_REG);
        read_reg(CTRL_TRG_SOURCES_REG);

        -- Enable all trigger sources for SEQ and DRAM and arm
        write_reg(CTRL_TRG_CONFIG_TRIG_SEQ0_REG, (
            CTRL_TRG_CONFIG_TRIG_SEQ0_ENABLE_BITS => 9X"1FF",
            others => '0'));
        write_reg(CTRL_TRG_CONFIG_TRIG_SEQ1_REG, (
            CTRL_TRG_CONFIG_TRIG_SEQ1_ENABLE_BITS => 9X"1FF",
            others => '0'));
        write_reg(CTRL_TRG_CONFIG_TRIG_DRAM_REG, (
            CTRL_TRG_CONFIG_TRIG_DRAM_ENABLE_BITS => 9X"1FF",
            others => '0'));
        arm('1', '1', '1');

        -- Blanking 3 for channel 0, 5 for channel 1
        write_reg(CTRL_TRG_CONFIG_BLANKING_REG,     X"0005_0003");
        write_reg(CTRL_TRG_CONFIG_SEQ0_REG,         X"0000_0010");
        write_reg(CTRL_TRG_CONFIG_SEQ1_REG,         X"0000_0000");
        write_reg(CTRL_TRG_CONFIG_DRAM0_REG,        X"0000_0000");

        -- Sample phase of clock
        write_reg(CTRL_TRG_CONTROL_REG_W, (
            CTRL_TRG_CONTROL_READ_SYNC_BIT => '1',
            others => '0'));

        read_reg(CTRL_TRG_PULSED_REG_R);

        loop
            arm('1', '1', '1');
        end loop;

        wait;
    end process;
end;
