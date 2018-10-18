-- Shared simulation functions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package sim_support is
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural := 1);

    procedure write_reg(
        signal clk_i : in std_ulogic;
        signal data_o : out reg_data_t;
        signal strobe_o : out std_ulogic_vector;
        signal ack_i : in std_ulogic_vector;
        reg : natural; value : reg_data_t);

    procedure read_reg(
        signal clk_i : in std_ulogic;
        signal data_i : in reg_data_array_t;
        signal strobe_o : out std_ulogic_vector;
        signal ack_i : in std_ulogic_vector;
        reg : natural);

    procedure receive_mem(
        signal clk_i : in std_ulogic;
        signal valid_i : in std_ulogic;
        signal ready_o : out std_ulogic;
        signal data_i : in std_ulogic_vector;
        signal addr_i : in unsigned);
end package;

package body sim_support is
    procedure clk_wait(signal clk_i : in std_ulogic; count : in natural := 1) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    procedure write_reg(
        signal clk_i : in std_ulogic;
        signal data_o : out reg_data_t;
        signal strobe_o : out std_ulogic_vector;
        signal ack_i : in std_ulogic_vector;
        reg : natural; value : reg_data_t) is
    begin
        data_o <= value;
        strobe_o <= (strobe_o'RANGE => '0');
        strobe_o(reg) <= '1';
        while ack_i(reg) = '0' loop
            clk_wait(clk_i);
            strobe_o <= (strobe_o'RANGE => '0');
        end loop;
        clk_wait(clk_i);
        strobe_o <= (strobe_o'RANGE => '0');
        report "write_reg [" & natural'image(reg) & "] <= " & to_hstring(value);
    end procedure;

    procedure read_reg(
        signal clk_i : in std_ulogic;
        signal data_i : in reg_data_array_t;
        signal strobe_o : out std_ulogic_vector;
        signal ack_i : in std_ulogic_vector;
        reg : natural)
    is
        variable value : reg_data_t;
    begin
        strobe_o <= (strobe_o'RANGE => '0');
        strobe_o(reg) <= '1';
        while ack_i(reg) = '0' loop
            clk_wait(clk_i);
            strobe_o <= (strobe_o'RANGE => '0');
        end loop;
        value := data_i(reg);
        clk_wait(clk_i);
        strobe_o <= (strobe_o'RANGE => '0');

        report "read_reg [" & natural'image(reg) & "] => " & to_hstring(value);
    end procedure;

    procedure receive_mem(
        signal clk_i : in std_ulogic;
        signal valid_i : in std_ulogic;
        signal ready_o : out std_ulogic;
        signal data_i : in std_ulogic_vector;
        signal addr_i : in unsigned)
    is
        variable data : data_i'SUBTYPE;
        variable addr : addr_i'SUBTYPE;
    begin
        ready_o <= '1';
        loop
            clk_wait(clk_i);
            if valid_i = '1' then
                exit;
            end if;
        end loop;
        ready_o <= '0';
        data := data_i;
        addr := addr_i;

        report "mem [" & to_hstring(addr) & "] = " & to_hstring(data);
    end procedure;
end package body;
