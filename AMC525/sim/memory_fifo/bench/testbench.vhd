library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal clk : std_logic := '0';

    procedure clk_wait(count : in natural := 1) is
    begin
        for i in 0 to count-1 loop
            wait until falling_edge(clk);
        end loop;
    end procedure;

    signal write_valid : std_ulogic := '0';
    signal write_ready : std_ulogic;
    signal write_data : std_ulogic_vector(7 downto 0) := X"00";
    signal read_valid : std_ulogic;
    signal read_ready : std_ulogic := '0';
    signal read_data : std_ulogic_vector(7 downto 0) := X"00";
    signal reset_fifo : std_ulogic := '0';
    signal fifo_depth : unsigned(2 downto 0);

begin
    clk <= not clk after 1 ns;

    fifo : entity work.memory_fifo generic map (
        FIFO_BITS => 2
    ) port map (
        clk_i => clk,
        write_valid_i => write_valid,
        write_ready_o => write_ready,
        write_data_i => write_data,
        read_valid_o => read_valid,
        read_ready_i => read_ready,
        read_data_o => read_data,
        reset_fifo_i => reset_fifo,
        fifo_depth_o => fifo_depth
    );


    -- Writing process
    process begin
        -- First just fill the fifo as fast as possible
        clk_wait;
        for i in 1 to 8 loop
            write_data <= std_ulogic_vector(to_unsigned(i, 8));
            write_valid <= '1';
            clk_wait;
        end loop;
        write_valid <= '0';

        -- Wait for readout
        clk_wait(10);

        -- Now write the fifo more slowly with write strobes.  This breaks the
        -- interface rules...
        clk_wait;
        for i in 1 to 8 loop
            write_data <= std_ulogic_vector(to_unsigned(i + 16, 8));
            write_valid <= '1';
            clk_wait;
            write_valid <= '0';
            clk_wait(5);
        end loop;

        -- Now write with proper handshaking.  This will wait for reader.
        clk_wait;
        for i in 1 to 8 loop
            write_data <= std_ulogic_vector(to_unsigned(i + 32, 8));
            write_valid <= '1';
            while write_ready = '0' loop
                clk_wait;
            end loop;
            clk_wait;
            write_valid <= '0';
        end loop;

        -- Fill the fifo again
        clk_wait(10);
        for i in 1 to 4 loop
            write_data <= std_ulogic_vector(to_unsigned(i + 48, 8));
            write_valid <= '1';
            clk_wait;
        end loop;
        write_valid <= '0';

        clk_wait;
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';

        -- Now try combinations of resets and writes

        -- Write -(2)- reset
        clk_wait(5);
        write_data <= X"A0";
        write_valid <= '1';
        clk_wait;
        write_valid <= '0';
        clk_wait;
        clk_wait;
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';

        -- Write -(1)- reset
        clk_wait(5);
        write_data <= X"A1";
        write_valid <= '1';
        clk_wait;
        write_valid <= '0';
        clk_wait;
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';

        -- Write -(0)- reset
        clk_wait(5);
        write_data <= X"A2";
        write_valid <= '1';
        clk_wait;
        write_valid <= '0';
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';

        -- Write reset
        clk_wait(5);
        write_data <= X"A3";
        write_valid <= '1';
        reset_fifo <= '1';
        clk_wait;
        write_valid <= '0';
        reset_fifo <= '0';

        -- Reset -(0)- write
        clk_wait(5);
        write_data <= X"A4";
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';
        write_valid <= '1';
        clk_wait;
        -- Need second clock wait for proper write handshake, write not ready
        clk_wait;
        write_valid <= '0';

        -- Reset -(1)- write
        clk_wait(5);
        write_data <= X"A5";
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';
        clk_wait;
        write_valid <= '1';
        clk_wait;
        write_valid <= '0';

        -- Reset -(1)- write
        clk_wait(5);
        write_data <= X"A6";
        reset_fifo <= '1';
        clk_wait;
        reset_fifo <= '0';
        clk_wait;
        clk_wait;
        write_valid <= '1';
        clk_wait;
        write_valid <= '0';

        wait;
    end process;


    -- Reading process
    process begin
        -- Wait for first burst to complete
        clk_wait(10);

        -- Read out what we just wrote
        clk_wait;
        read_ready <= '1';
        while read_valid = '1' loop
            clk_wait;
        end loop;
        read_ready <= '0';

        clk_wait(50);

        -- Again, read out everything stored
        clk_wait;
        read_ready <= '1';
        while read_valid = '1' loop
            clk_wait;
        end loop;
        read_ready <= '0';

        -- Wait for stalled process
        clk_wait(10);

        -- Again, read out everything stored
        clk_wait;
        read_ready <= '1';
        while read_valid = '1' loop
            clk_wait;
        end loop;
        read_ready <= '0';

        clk_wait(5);

        -- Again, read out everything stored
        clk_wait;
        read_ready <= '1';
        while read_valid = '1' loop
            clk_wait;
        end loop;
        read_ready <= '0';

        wait;
    end process;
end;
