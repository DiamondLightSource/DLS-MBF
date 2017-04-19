-- Simple register file

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity register_file is
    generic (
        UNTIMED : boolean := true
    );
    port (
        clk_i : in std_logic;

        -- Register interface
        write_strobe_i : in std_logic_vector;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector;

        -- Register array
        register_data_o : out reg_data_array_t
    );
end;

architecture arch of register_file is
begin
    if_untimed : if UNTIMED generate
        -- By default we generate untimed registers for register files.  This is
        -- reasonable because register files are used for static slowly or
        -- rarely changing configurations.
        gen_untimed : for r in write_strobe_i'RANGE generate
            untimed : entity work.untimed_reg generic map (
                WIDTH => reg_data_t'LENGTH
            ) port map (
                clk_i => clk_i,
                write_i => write_strobe_i(r),
                data_i => write_data_i,
                data_o => register_data_o(r)
            );
        end generate;

    else generate
        signal register_file : reg_data_array_t(write_strobe_i'RANGE) :=
            (others => (others => '0'));

    begin
        -- If the potential glitching of register values during a write is
        -- liable to cause problems, then we must make the register file
        -- properly synchronous with the writing clock.
        process (clk_i) begin
            if rising_edge(clk_i) then
                for r in write_strobe_i'RANGE loop
                    if write_strobe_i(r) = '1' then
                        register_file(r) <= write_data_i;
                    end if;
                end loop;
            end if;
        end process;

        register_data_o <= register_file;
    end generate;

    write_ack_o <= (write_ack_o'RANGE => '1');
end;
