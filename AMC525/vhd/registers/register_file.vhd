-- Simple register file

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity register_file is
    port (
        clk_i : in std_logic;

        -- Write interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;
        read_strobe_i : in std_logic_vector;
        read_data_o : out reg_data_array_t;
        read_ack_o : out std_logic_vector;

        -- Register array
        register_data_o : out reg_data_array_t
    );
end;

architecture register_file of register_file is
    signal register_file : reg_data_array_t(write_strobe_i'RANGE) :=
        (others => (others => '0'));

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            for r in write_strobe_i'RANGE loop
                if write_strobe_i(r) = '1' then
                    register_file(r) <= write_data_i;
                end if;
            end loop;
        end if;
    end process;

    write_ack_o <= (others => '1');
    read_ack_o <= (others => '1');
    read_data_o <= register_file;

    register_data_o <= register_file;
end;
