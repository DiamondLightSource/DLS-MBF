library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal clk : STD_LOGIC := '0';



    procedure tick_wait(count : natural) is
    begin
        clk_wait(clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(clk, 1);
    end procedure;

    signal delay : unsigned(2 downto 0);
    signal data_in : unsigned(7 downto 0) := (others => '0');
    signal data_out : unsigned(7 downto 0);

    signal computed_delay : unsigned(7 downto 0);

begin

    clk <= not clk after 1 ns;

    delay_inst : entity work.long_delay generic map (
        WIDTH => data_in'LENGTH
    ) port map (
        clk_i => clk,
        delay_i => delay,
        data_i => std_ulogic_vector(data_in),
        unsigned(data_o) => data_out
    );

    computed_delay <= data_in - data_out;

    process begin
        data_in <= (others => '0');
        loop
            tick_wait;
            data_in <= data_in + 1;
        end loop;
    end process;

    process begin
        for d in 0 to 7 loop
            delay <= to_unsigned(d, delay'LENGTH);
            tick_wait(10);
        end loop;
        for d in 6 downto 0 loop
            delay <= to_unsigned(d, delay'LENGTH);
            tick_wait(10);
        end loop;

        wait;
    end process;

end;
