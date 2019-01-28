library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal clk : std_ulogic := '1';

    procedure clk_wait(count : in natural := 1) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;


    constant TURN_COUNT : natural := 5;
    signal turn_num : natural;
    signal turn_clock : std_ulogic;

    signal shift : unsigned(3 downto 0);
    signal data_in : signed(15 downto 0);
    signal data_out : signed(15 downto 0);

    constant MAX_SHIFT : natural := 12;

begin
    clk <= not clk after 1 ns;

    fill_reject : entity work.adc_fill_reject generic map (
        MAX_SHIFT => MAX_SHIFT
    ) port map (
        clk_i => clk,

        turn_clock_i => turn_clock,
        shift_i => shift,

        data_i => data_in,
        data_o => data_out
    );


    -- Generate turn clock
    process begin
        turn_num <= 0;
        loop
            clk_wait;
            if turn_num = TURN_COUNT-1 then
                turn_num <= 0;
            else
                turn_num <= turn_num + 1;
            end if;
        end loop;
        wait;
    end process;
    turn_clock <= to_std_ulogic(turn_num = 0);


    -- Advance the shift counter in suitable steps
    process
        variable delay : natural;
    begin
        for i in 0 to MAX_SHIFT loop
            shift <= to_unsigned(i, 4);
            delay := 20 + 4 * TURN_COUNT * 2**i;
            report "clk_wait(" & natural'image(i) & "): " &
                natural'image(delay);
            clk_wait(delay);
        end loop;
    end process;

    -- Start with pretty dumb dummy data
    process begin
        data_in <= (others => '0');
        while true loop
            clk_wait;
            data_in <= to_signed(turn_num, 16);
--             data_in <= data_in + 1;
        end loop;
    end process;

end;
