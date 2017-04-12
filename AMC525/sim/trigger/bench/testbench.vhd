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
    signal event_trigger : std_logic;
    signal postmortem_trigger : std_logic;
    signal blanking_trigger : std_logic;
    signal adc_trigger : std_logic_vector(CHANNELS);
    signal seq_trigger : std_logic_vector(CHANNELS);
    signal blanking_window : std_logic_vector(CHANNELS);
    signal turn_clock_adc : std_logic_vector(CHANNELS);
    signal seq_start : std_logic_vector(CHANNELS);
    signal dram0_trigger : std_logic;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    revolution_clock <= not revolution_clock after 17.3 ns;

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
        turn_clock_adc_o => turn_clock_adc,
        seq_start_o => seq_start,
        dram0_trigger_o => dram0_trigger
    );


    -- Event generation
    process begin
        event_trigger <= '0';

        wait for 111 ns;
        event_trigger <= '1';

        wait;
    end process;


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

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');

        clk_wait(dsp_clk);

        -- max_bunch = 6 (7 ticks per turn)
        write_reg(CTRL_TRG_CONFIG_TURN_SETUP_REG,   X"0000_0806");
        write_reg(CTRL_TRG_CONTROL_REG_W,           X"0000_0001");

        read_reg(CTRL_TRG_PULSED_REG_R);
        read_reg(CTRL_TRG_READBACK_STATUS_REG);
        read_reg(CTRL_TRG_READBACK_SOURCES_REG);

        -- Blanking 3 for channel 0, 5 for channel 1
        write_reg(CTRL_TRG_CONFIG_BLANKING_REG,     X"0005_0003");
        write_reg(CTRL_TRG_CONFIG_DELAY_SEQ_0_REG,  X"0000_0010");
        write_reg(CTRL_TRG_CONFIG_DELAY_SEQ_1_REG,  X"0000_0000");
        write_reg(CTRL_TRG_CONFIG_DELAY_DRAM_REG,   X"0000_0005");
        write_reg(CTRL_TRG_CONFIG_TRIG_SEQ_REG,     X"00FF_FFFF");
        write_reg(CTRL_TRG_CONFIG_TRIG_DRAM_REG,    X"0000_00FF");

        -- Arm SEQ and DRAM0
        write_reg(CTRL_TRG_CONTROL_REG_W,           X"0000_0054");

        -- Sample phase of clock
        write_reg(CTRL_TRG_CONTROL_REG_W,           X"0000_0002");

        wait;
    end process;
end;
