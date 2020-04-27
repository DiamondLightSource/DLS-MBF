library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


use work.support.all;
use work.defines.all;

architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    signal reg_clk : std_ulogic := '0';

    procedure tick_wait(count : natural) is
    begin
        clk_wait(reg_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(reg_clk, 1);
    end procedure;


    signal read_strobe_in : std_ulogic;
    signal read_address : unsigned(4 downto 0);
    signal read_data_out : reg_data_t;
    signal read_ack_out : std_ulogic;
    signal read_data_in : reg_data_array_t(0 to 15);
    signal read_strobe_out : std_ulogic_vector(0 to 15);
    signal read_ack_in : std_ulogic_vector(0 to 15);
    signal write_strobe_in : std_ulogic;
    signal write_address : unsigned(4 downto 0);
    signal write_data_in : reg_data_t;
    signal write_ack_out : std_ulogic;
    signal write_strobe_out : std_ulogic_vector(0 to 15);
    signal write_data_out : reg_data_t;
    signal write_ack_in : std_ulogic_vector(0 to 15);

begin
    -- Basic register clock
    reg_clk <= not reg_clk after 1 ns;

    register_mux_inst : entity work.register_mux port map (
        clk_i => reg_clk,

        read_strobe_i => read_strobe_in,
        read_address_i => read_address,
        read_data_o => read_data_out,
        read_ack_o => read_ack_out,

        read_data_i => read_data_in,
        read_strobe_o => read_strobe_out,
        read_ack_i => read_ack_in,

        write_strobe_i => write_strobe_in,
        write_address_i => write_address,
        write_data_i => write_data_in,
        write_ack_o => write_ack_out,

        write_strobe_o => write_strobe_out,
        write_data_o => write_data_out,
        write_ack_i => write_ack_in
    );


    -- Make the read data count its age so we can check we're reading the right
    -- value.
    process begin
        for i in 0 to 15 loop
            read_data_in(i) <= std_ulogic_vector(to_unsigned(i, 16)) & X"0000";
        end loop;
        write_data_in <= (others => '0');
        while true loop
            tick_wait;
            for i in 0 to 15 loop
                read_data_in(i) <= reg_data_t(unsigned(read_data_in(i)) + 1);
            end loop;
            write_data_in <= reg_data_t(unsigned(write_data_in) + 1);
        end loop;
    end process;


    process begin
        write_address <= "00000";
        write_ack_in <= (0 => '1', others => '0');
        write_strobe_in <= '0';

        read_address <= "00000";
        read_ack_in <= (0 => '1', others => '0');
        read_strobe_in <= '0';

        -- Test write with acknowledge
        write_address <= "00001";
        tick_wait;
        write_strobe_in <= '1';
        tick_wait;
        write_strobe_in <= '0';
        tick_wait(4);
        write_ack_in(1) <= '1';
        tick_wait;
        write_ack_in(1) <= '0';

        -- Test write with fixed acknowledge
        write_address <= "00000";
        tick_wait;
        write_strobe_in <= '1';
        tick_wait;
        write_strobe_in <= '0';


        -- Test read with acknowledge
        read_address <= "00011";
        tick_wait;
        read_strobe_in <= '1';
        tick_wait;
        read_strobe_in <= '0';
        tick_wait(4);
        read_ack_in(3) <= '1';
        tick_wait;
        read_ack_in(3) <= '0';
        tick_wait(2);

        -- Test read with fixed acknowledge
        read_address <= "00000";
        tick_wait;
        read_strobe_in <= '1';
        tick_wait;
        read_strobe_in <= '0';



        wait;
    end process;

end;
