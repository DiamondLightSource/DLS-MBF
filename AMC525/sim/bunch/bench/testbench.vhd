library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.bunch_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;

architecture testbench of testbench is
    signal dsp_clk : std_logic := '1';

    signal sync_trigger : std_logic;

    signal write_strobe : std_logic_vector(0 to 1);
    signal write_data : reg_data_t;
    signal write_ack : std_logic_vector(0 to 1);
    signal read_strobe : std_logic_vector(0 to 1);
    signal read_data : reg_data_array_t(0 to 1);
    signal read_ack : std_logic_vector(0 to 1);

    signal write_start : std_logic;

    signal bank : unsigned(1 downto 0);
    signal bunch_index : bunch_count_t;
    signal bunch_config : bunch_config_lanes_t;
    signal turn_clk : std_logic;

begin
    dsp_clk <= not dsp_clk after 2 ns;

    bunch_select_inst : entity work.bunch_select port map (
        dsp_clk_i => dsp_clk,

        sync_trigger_i => sync_trigger,

        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,

        write_start_i => write_start,

        bank_i => bank,
        bunch_index_o => bunch_index,
        bunch_config_o => bunch_config,
        turn_clk_o => turn_clk
    );

    read_strobe <= "00";

    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg(dsp_clk, read_data, read_strobe, read_ack, reg);
        end;

        procedure clk_wait(ticks : natural) is
        begin
            clk_wait(dsp_clk, ticks);
        end;

        procedure clk_wait is begin clk_wait(1); end;

    begin
        write_strobe <= "00";
        sync_trigger <= '0';
        write_start <= '0';
        bank <= "00";

        write_reg(0, X"00003003");  -- start at bunch 3, max bunch is 3
        clk_wait(2);

        sync_trigger <= '1';
        clk_wait;
        sync_trigger <= '0';

        write_start <= '1';
        clk_wait;
        write_start <= '0';

        write_reg(1, X"00121111");
        write_reg(1, X"00122222");
        write_reg(1, X"00123333");
        write_reg(1, X"00124444");
        write_reg(1, X"00125555");
        write_reg(1, X"00126666");
        write_reg(1, X"00127777");
        write_reg(1, X"00128888");

        clk_wait(2);
        write_reg(0, X"00001003");  -- now start at bunch 1
        clk_wait(2);
        sync_trigger <= '1';
        clk_wait;
        sync_trigger <= '0';

        wait;
    end process;

end testbench;
