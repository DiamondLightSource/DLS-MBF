library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

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


    signal clk : STD_LOGIC := '0';


    procedure tick_wait(count : natural := 1) is
    begin
        clk_wait(clk, count);
    end procedure;


    signal data : signed(24 downto 0);
    signal mul : signed(17 downto 0);
    signal enable : std_logic;
    signal start : std_logic;

    signal sim_sum : signed(95 downto 0);
    signal true_sum : signed(95 downto 0);
    signal diff : signed(95 downto 0);
    signal ok : boolean;

begin

    clk <= not clk after 1 ns;

    dsp48e1 : entity work.detector_dsp48e1 port map (
        clk_i => clk,

        data_i => data,
        mul_i => mul,
        enable_i => enable,
        start_i => start,
        sum_o => true_sum
    );

    sim_dsp96 : entity work.sim_dsp96 port map (
        clk_i => clk,

        data_i => data,
        mul_i => mul,
        enable_i => enable,
        start_i => start,
        sum_o => sim_sum
    );


    process (clk) begin
        if rising_edge(clk) then
            diff <= true_sum - sim_sum;
        end if;
    end process;
    ok <= diff = 0;


    process begin
        -- Load with large positive number and accumulate a little
        data <= 25X"0FFFFFF";
        mul <= 18X"1FFFF";
        start <= '0';
        enable <= '1';

        tick_wait;
        start <= '1';
        tick_wait;
        start <= '0';
        tick_wait(5);
        enable <= '0';
        tick_wait(2);
        enable <= '1';
        tick_wait(3);

        -- Now load large negative number
        data <= 25X"1000000";
        start <= '1';
        tick_wait;
        start <= '0';

        wait;
    end process;


end testbench;
