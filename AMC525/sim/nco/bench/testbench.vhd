library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity testbench is
end testbench;


architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : STD_LOGIC := '0';


    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;


    signal phase_advance : angle_t;
    signal reset : std_logic;
    signal unscaled : cos_sin_18_channels_t;
    signal gain : unsigned(3 downto 0);
    signal scaled : cos_sin_16_channels_t;

begin

    dsp_clk <= not dsp_clk after 2 ns;


    nco_inst : entity work.nco port map (
        clk_i => dsp_clk,
        phase_advance_i => phase_advance,
        reset_i => reset,
        cos_sin_o => unscaled
    );

    nco_scaling_inst : entity work.nco_scaling port map (
        clk_i => dsp_clk,
        gain_i => gain,
        unscaled_i => unscaled,
        scaled_o => scaled
    );

    process begin
        gain <= "0000";
        tick_wait(10);
        gain <= "0001";
        tick_wait(10);
        gain <= "0010";
        tick_wait(10);
        gain <= "0011";
        tick_wait(10);
        gain <= "0100";
        wait;
    end process;

    process begin
--         phase_advance <= X"F0000000";
--         reset <= '0';
--         tick_wait(50);
--         reset <= '1';
        phase_advance <= X"00001000";
        tick_wait;
        reset <= '0';
        wait;
    end process;


end testbench;
