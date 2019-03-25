library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal clk : std_logic := '0';
    signal data_in : signed(15 downto 0);
    signal iir_shift : unsigned(2 downto 0);
    signal start : std_logic := '0';
    signal data_out : data_in'SUBTYPE;
    signal done : std_logic;

    procedure clk_wait(count : in natural := 1) is
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

begin
    clk <= not clk after 1 ns;

    iir : entity work.one_pole_iir generic map (
        SHIFT_STEP => 2
    ) port map (
        clk_i => clk,
        data_i => data_in,
        iir_shift_i => iir_shift,
        start_i => start,
        data_o => data_out,
        done_o => done
    );

    process begin
        start <= '0';
        clk_wait;
        start <= '1';
        clk_wait;
        start <= '0';
        while done = '0' loop
            clk_wait;
        end loop;
    end process;


    process
        procedure test_step(shift : unsigned; delay : natural) is
        begin
            iir_shift <= shift;
            data_in <= X"7FFF";
            clk_wait(delay);
            data_in <= X"8000";
            clk_wait(delay);
            data_in <= X"0000";
            clk_wait(delay);
        end;
    begin
        test_step("000", 20);
        test_step("010", 200);
        test_step("100", 2000);

        wait;
    end process;
end;
