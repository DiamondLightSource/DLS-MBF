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
    subtype SELECT_REGS is natural range 0 to 1;
    subtype FIR_REGS is natural range 2 to 3;

    signal dsp_clk : std_logic := '1';

    signal sync_trigger : std_logic;

    signal write_strobe : std_logic_vector(0 to 3);
    signal write_data : reg_data_t;
    signal write_ack : std_logic_vector(0 to 3);
    signal read_strobe : std_logic_vector(0 to 3);
    signal read_data : reg_data_array_t(0 to 3);
    signal read_ack : std_logic_vector(0 to 3);

    signal write_start : std_logic;

    signal bank : unsigned(1 downto 0);
    signal bunch_index : bunch_count_t;
    signal bunch_config : bunch_config_lanes_t;
    signal turn_clock : std_logic;

    signal data_in : signed_array(LANES)(15 downto 0) := (X"0000", X"0001");
    signal data_out : signed_array(LANES)(15 downto 0);

begin
    dsp_clk <= not dsp_clk after 2 ns;

    bunch_select_inst : entity work.bunch_select port map (
        dsp_clk_i => dsp_clk,

        sync_trigger_i => sync_trigger,

        write_strobe_i => write_strobe(SELECT_REGS),
        write_data_i => write_data,
        write_ack_o => write_ack(SELECT_REGS),
        read_strobe_i => read_strobe(SELECT_REGS),
        read_data_o => read_data(SELECT_REGS),
        read_ack_o => read_ack(SELECT_REGS),

        write_start_i => write_start,

        bank_i => bank,
        bunch_index_o => bunch_index,
        bunch_config_o => bunch_config,
        turn_clock_o => turn_clock
    );

    bunch_fir_inst : entity work.bunch_fir_top generic map (
        TAP_COUNT => 3
    ) port map (
        dsp_clk_i => dsp_clk,

        data_i => data_in,
        data_o => data_out,

        turn_clock_i => turn_clock,
        bunch_index_i => bunch_index,
        bunch_config_i => bunch_config,

        write_strobe_i => write_strobe(FIR_REGS),
        write_data_i => write_data,
        write_ack_o => write_ack(FIR_REGS),
        read_strobe_i => read_strobe(FIR_REGS),
        read_data_o => read_data(FIR_REGS),
        read_ack_o => read_ack(FIR_REGS),

        write_start_i => write_start
    );

    process (dsp_clk) begin
        if rising_edge(dsp_clk) then
            for l in LANES loop
                data_in(l) <= data_in(l) + 2;
            end loop;
        end if;
    end process;

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

        procedure start_write is
        begin
            write_start <= '1';
            clk_wait;
            write_start <= '0';
        end;

    begin
        read_strobe <= (others => '0');
        write_strobe <= (others => '0');
        sync_trigger <= '0';
        write_start <= '0';
        bank <= "00";

        write_reg(0, X"00003003");  -- start at bunch 3, max bunch is 3
        clk_wait(2);

        sync_trigger <= '1';
        clk_wait;
        sync_trigger <= '0';

        start_write;

        write_reg(1, X"00121111");
        write_reg(1, X"00122222");
        write_reg(1, X"00123333");
        write_reg(1, X"00124444");
        write_reg(1, X"00125555");
        write_reg(1, X"00126666");
        write_reg(1, X"00127777");
        write_reg(1, X"00128888");

        clk_wait(2);
        write_reg(0, X"00001006");  -- now start at bunch 1
        clk_wait(2);
        sync_trigger <= '1';
        clk_wait;
        sync_trigger <= '0';

        -- Now write some taps
        start_write;
        write_reg(2, X"00000000");  -- Bank 0
        write_reg(3, X"7FF00000");
        write_reg(3, X"7FF10000");
        write_reg(3, X"7FF20000");
        start_write;
        write_reg(2, X"00000001");  -- Bank 1
        write_reg(3, X"7FF01000");
        write_reg(3, X"7FF11000");
        write_reg(3, X"7FF21000");
        start_write;
        write_reg(2, X"00000002");  -- Bank 2
        write_reg(3, X"7FF02000");
        write_reg(3, X"7FF12000");
        write_reg(3, X"7FF22000");
        start_write;
        write_reg(2, X"0000040F");  -- Bank 3, 16 decimation
        write_reg(3, X"7FF03000");
        write_reg(3, X"7FF13000");
        write_reg(3, X"7FF23000");

        wait;
    end process;

end testbench;
