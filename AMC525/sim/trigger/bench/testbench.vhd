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
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';

    constant TURN_COUNT : natural := 31;

    signal write_strobe : std_logic_vector(CTRL_TRG_REGS);
    signal write_data : reg_data_t;
    signal write_ack : std_logic_vector(CTRL_TRG_REGS);
    signal read_strobe : std_logic_vector(CTRL_TRG_REGS);
    signal read_data : reg_data_array_t(CTRL_TRG_REGS);
    signal read_ack : std_logic_vector(CTRL_TRG_REGS);
    signal revolution_clock : std_logic := '0';
    signal event_trigger : std_logic := '0';
    signal postmortem_trigger : std_logic;
    signal blanking_trigger : std_logic;
    signal adc_trigger : std_logic_vector(CHANNELS);
    signal seq_trigger : std_logic_vector(CHANNELS);
    signal blanking_window : std_logic_vector(CHANNELS);
    signal turn_clock : std_logic_vector(CHANNELS);
    signal seq_start : std_logic_vector(CHANNELS);
    signal dram0_trigger : std_logic;
    signal dram0_phase : std_logic;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

--     revolution_clock <= not revolution_clock after 17.3 ns;
    revolution_clock <= not revolution_clock after 17 ns;
    event_trigger <= not event_trigger after 40 ns;

    postmortem_trigger <= '0';
    blanking_trigger <= '0';
    adc_trigger <= "00";
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
        seq_trigger_i => seq_trigger,

        blanking_window_o => blanking_window,
        turn_clock_o => turn_clock,
        seq_start_o => seq_start,
        dram0_trigger_o => dram0_trigger,
        dram0_phase_o => dram0_phase
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

        procedure arm(seq0 : std_logic; seq1 : std_logic; dram : std_logic) is
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
        write_reg(CTRL_TRG_CONFIG_TURN_REG,         X"0000_0810");
        write_reg(CTRL_TRG_CONTROL_REG_W,           X"0000_0001");

        read_reg(CTRL_TRG_PULSED_REG_R);
        read_reg(CTRL_TRG_STATUS_REG);
        read_reg(CTRL_TRG_SOURCES_REG);

        -- Enable all trigger sources for SEQ and DRAM and arm
        write_reg(CTRL_TRG_CONFIG_TRIG_SEQ_REG,     X"00FF_00FF");
        write_reg(CTRL_TRG_CONFIG_TRIG_DRAM_REG,    X"0000_00FF");
        arm('1', '1', '1');

        -- Blanking 3 for channel 0, 5 for channel 1
        write_reg(CTRL_TRG_CONFIG_BLANKING_REG,     X"0005_0003");
        write_reg(CTRL_TRG_CONFIG_SEQ0_REG,         X"0000_0010");
        write_reg(CTRL_TRG_CONFIG_SEQ1_REG,         X"0000_0000");
        write_reg(CTRL_TRG_CONFIG_DRAM0_REG,        X"0000_0000");
        write_reg(CTRL_TRG_CONFIG_TRIG_SEQ_REG,     X"00FF_FFFF");

        -- Sample phase of clock
        write_reg(CTRL_TRG_CONTROL_REG_W,           X"0000_0002");

        read_reg(CTRL_TRG_PULSED_REG_R);

        loop
            arm('1', '1', '1');
        end loop;

        wait;
    end process;
end;
