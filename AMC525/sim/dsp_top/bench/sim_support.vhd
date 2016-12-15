-- Shared simulation functions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

package sim_support is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural);
    procedure clk_wait(signal clk_i : in std_logic);

    procedure write_reg(
        signal clk_i : in std_logic;
        signal data_o : out reg_data_t;
        signal strobe_o : out std_logic_vector;
        signal ack_i : in std_logic_vector;
        reg : natural; value : reg_data_t);
    procedure read_reg(
        signal clk_i : in std_logic;
        signal data_i : in reg_data_array_t;
        signal strobe_o : out std_logic_vector;
        signal ack_i : in std_logic_vector;
        reg : natural);

    procedure write_reg_a(
        signal clk_i : in std_logic;
        signal strobe_o : out std_logic;
        signal address_o : out unsigned;
        signal data_o : out reg_data_t;
        signal ack_i : in std_logic;
        reg : natural; value : reg_data_t);
    procedure read_reg_a(
        signal clk_i : in std_logic;
        signal strobe_o : out std_logic;
        signal address_o : out unsigned;
        signal data_i : in reg_data_t;
        signal ack_i : in std_logic;
        reg : natural);

end package;

package body sim_support is

    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    procedure clk_wait(signal clk_i : in std_logic) is
    begin
        clk_wait(clk_i, 1);
    end procedure;

    procedure write_reg(
        signal clk_i : in std_logic;
        signal data_o : out reg_data_t;
        signal strobe_o : out std_logic_vector;
        signal ack_i : in std_logic_vector;
        reg : natural; value : reg_data_t) is
    begin
        data_o <= value;
        clk_wait(clk_i);
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
        signal clk_i : in std_logic;
        signal data_i : in reg_data_array_t;
        signal strobe_o : out std_logic_vector;
        signal ack_i : in std_logic_vector;
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


    procedure write_reg_a(
        signal clk_i : in std_logic;
        signal strobe_o : out std_logic;
        signal address_o : out unsigned;
        signal data_o : out reg_data_t;
        signal ack_i : in std_logic;
        reg : natural; value : reg_data_t) is
    begin
        address_o <= to_unsigned(reg, address_o'LENGTH);
        data_o <= value;
        strobe_o <= '1';
        while ack_i = '0' loop
            clk_wait(clk_i);
            strobe_o <= '0';
        end loop;
        clk_wait(clk_i);
        strobe_o <= '0';

        report "write_reg [" & to_hstring(address_o) &
            "] <= " & to_hstring(value);
    end procedure;

    procedure read_reg_a(
        signal clk_i : in std_logic;
        signal strobe_o : out std_logic;
        signal address_o : out unsigned;
        signal data_i : in reg_data_t;
        signal ack_i : in std_logic;
        reg : natural)
    is
        variable value : reg_data_t;
    begin
        address_o <= to_unsigned(reg, address_o'LENGTH);
        strobe_o <= '1';
        while ack_i = '0' loop
            clk_wait(clk_i);
            strobe_o <= '0';
        end loop;
        value := data_i;
        clk_wait(clk_i);
        strobe_o <= '0';

        report "read_reg [" & to_hstring(address_o) &
            "] => " & to_hstring(value);
    end procedure;


end package body;
