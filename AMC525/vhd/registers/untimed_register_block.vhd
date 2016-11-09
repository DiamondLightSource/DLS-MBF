-- Support for an array of register data written through a streamed interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity untimed_register_block is
    port (
        clk_in_i : in std_logic;
        clk_out_i : in std_logic;

        -- Register interface (write only)
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic := '0';
        -- Write start
        write_start_i : in std_logic;

        -- The register array
        registers_o : out reg_data_array_t
    );
end;

architecture untimed_register_block of untimed_register_block is
    constant COUNT : natural := registers_o'LENGTH;
    constant COUNT_BITS : natural := bits(COUNT-1);

    signal write_ptr : unsigned(COUNT_BITS-1 downto 0);
    signal write_strobe : std_logic_vector(0 to COUNT-1);

begin
    assert registers_o'LEFT = 0;

    generate_registers : for r in 0 to COUNT-1 generate
        untimed_register_inst : entity work.untimed_register port map (
            clk_in_i => clk_in_i,
            clk_out_i => clk_out_i,
            write_i => write_strobe(r),
            data_i => write_data_i,
            data_o => registers_o(r)
        );
    end generate;

    process (clk_in_i) begin
        if rising_edge(clk_in_i) then
            if write_strobe_i = '1' then
                write_ptr <= write_ptr + 1;
                write_strobe(to_integer(write_ptr)) <= '1';
                write_ack_o <= '1';
            else
                if write_start_i = '1' then
                    write_ptr <= (others => '0');
                end if;
                write_strobe <= (others => '0');
                write_ack_o <= '0';
            end if;
        end if;
    end process;
end;
