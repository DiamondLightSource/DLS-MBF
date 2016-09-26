library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


use work.support.all;
use work.defines.all;

architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal out_clk : std_logic := '0';
    signal reg_clk : std_logic := '0';


    procedure tick_wait(count : natural) is
    begin
        clk_wait(reg_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(reg_clk, 1);
    end procedure;


    signal out_rst_n : std_logic := '0';

    signal reg_read_strobe : std_logic := '0';
    signal reg_read_data : reg_data_t;
    signal reg_read_ack : std_logic;
    signal out_read_strobe : std_logic;
    signal out_read_data : reg_data_t := (others => '0');
    signal out_read_ack : std_logic := '0';
    signal reg_write_strobe : std_logic := '0';
    signal reg_write_ack : std_logic;
    signal out_write_strobe : std_logic;
    signal out_write_ack : std_logic := '0';

    signal force_read_ack : std_logic := '0';

begin

    process begin
        if out_rst_n = '1' then
            out_clk <= not out_clk;
            wait for 2 ns;
        else
            wait on out_rst_n;
        end if;
    end process;

    process (out_clk) begin
        if rising_edge(out_clk) then
            out_read_data <=
                std_logic_vector(unsigned(out_read_data) + 1);
        end if;
    end process;


    reg_clk <= not reg_clk after 2.1 ns;

    register_cc_inst : entity work.register_cc port map (
        reg_clk_i => reg_clk,
        out_clk_i => out_clk,
        out_rst_n_i => out_rst_n,
        reg_read_strobe_i => reg_read_strobe,
        reg_read_data_o => reg_read_data,
        reg_read_ack_o => reg_read_ack,
        out_read_strobe_o => out_read_strobe,
        out_read_data_i => out_read_data,
        out_read_ack_i => out_read_ack,
        reg_write_strobe_i => reg_write_strobe,
        reg_write_ack_o => reg_write_ack,
        out_write_strobe_o => out_write_strobe,
        out_write_ack_i => out_write_ack
    );

    -- Simplest test first
--     out_read_ack <= '1';
    out_write_ack <= '1';

    process (out_clk) begin
        if rising_edge(out_clk) then
            out_read_ack <= out_read_strobe or force_read_ack;
        end if;
    end process;

    process begin
        force_read_ack <= '0';
        reg_write_strobe <= '0';
        reg_read_strobe <= '0';

        out_rst_n <= '0';
        tick_wait(10);
        out_rst_n <= '1';
        tick_wait(10);

        reg_write_strobe <= '1';
        tick_wait;
        reg_write_strobe <= '0';

        tick_wait(15);
        reg_read_strobe <= '1';
        tick_wait;
        reg_read_strobe <= '0';

        tick_wait(15);
        force_read_ack <= '1';
        reg_read_strobe <= '1';
        tick_wait;
        reg_read_strobe <= '0';

--         out_rst_n <= '0';
--         tick_wait;
-- 
--         reg_strobe <= '1';
--         tick_wait;
--         reg_strobe <= '0';
-- 
--         tick_wait(10);
--         out_rst_n <= '0';
-- 
--         reg_strobe <= '1';
--         tick_wait;
--         reg_strobe <= '0';
-- 
--         tick_wait;
--         tick_wait;
--         out_rst_n <= '1';


        wait;
    end process;

end testbench;
