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


    signal dsp_clk : std_logic := '0';
    signal axi_clk : std_logic := '0';


    procedure tick_wait(count : natural) is
    begin
        clk_wait(axi_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(axi_clk, 1);
    end procedure;


    signal dsp_rst_n : std_logic := '0';
    signal axi_strobe : std_logic;
    signal dsp_strobe : std_logic;
    signal dsp_ack : std_logic;
    signal axi_ack : std_logic;


begin

    process begin
        if dsp_rst_n = '1' then
            dsp_clk <= not dsp_clk;
            wait for 2 ns;
        else
            wait on dsp_rst_n;
        end if;
    end process;

    axi_clk <= not axi_clk after 2.1 ns;

    register_strobe_cc_inst : entity work.register_strobe_cc port map (
        axi_clk_i => axi_clk,
        dsp_clk_i => dsp_clk,
        dsp_rst_n_i => dsp_rst_n,
        axi_strobe_i => axi_strobe,
        dsp_strobe_o => dsp_strobe,
        dsp_ack_i => dsp_ack,
        axi_ack_o => axi_ack
    );

    -- Simplest test first
    dsp_ack <= '1';
    process begin
        dsp_rst_n <= '0';
        axi_strobe <= '0';
        tick_wait(10);
        dsp_rst_n <= '1';
        tick_wait(10);

        axi_strobe <= '1';
        tick_wait;
        axi_strobe <= '0';

        tick_wait(20);
        dsp_rst_n <= '0';
        tick_wait;

        axi_strobe <= '1';
        tick_wait;
        axi_strobe <= '0';

        tick_wait(10);
        dsp_rst_n <= '0';

        axi_strobe <= '1';
        tick_wait;
        axi_strobe <= '0';

        tick_wait;
        tick_wait;
        dsp_rst_n <= '1';


        wait;
    end process;

end testbench;
