library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;

library unisim;
use unisim.vcomponents.all;


architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : std_logic := '0';
    signal dsp_clk_en : std_logic := '0';
    signal dsp_clk_bufgen : std_logic := '0';
    signal dsp_clk_bufgctrl : std_logic := '0';



    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;

begin

    dsp_clk <= not dsp_clk after 2 ns;

    bufgen_inst : BUFGCE port map (
        CE => dsp_clk_en,
        I => dsp_clk,
        O => dsp_clk_bufgen
    );

    bufgctrl_inst : BUFGCTRL port map (
        I0 => dsp_clk,
        S0 => dsp_clk_en,
        CE0 => '1',
        IGNORE0 => '0',
        I1 => '0',
        S1 => '0',
        CE1 => '0',
        IGNORE1 => '1',
        O => dsp_clk_bufgctrl
    );

    process begin
        dsp_clk_en <= '0';
        wait for 16 ns;
        dsp_clk_en <= '1';
        wait for 5.9 ns;
        dsp_clk_en <= '0';
--         wait until rising_edge(dsp_clk);
        wait for 7 ns;
        dsp_clk_en <= '1';
        wait;
    end process;



end testbench;
