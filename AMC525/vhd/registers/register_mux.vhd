-- I/O register mux

-- Decodes register plus address read and write into appropriate strobes and
-- read data multiplexing.  Also routes read_ack signal properly.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;

entity register_mux is
    port (
        clk_i : in std_logic;
        clk_ok_i : in std_logic;

        -- Register read.
        read_strobe_i : in std_logic;
        read_address_i : in reg_addr_t;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- Multiplexed registers
        read_data_i : in reg_data_array_t;      -- Individual read registers
        read_strobe_o : out reg_strobe_t;       -- Individual read selects
        read_ack_i : in reg_strobe_t;           -- Individual read acknowlege

        -- Register write.
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_ack_o : out std_logic;

        write_strobe_o : out reg_strobe_t;
        write_ack_i : in reg_strobe_t
    );
end;

architecture register_mux of register_mux is
    signal read_address : natural;
    signal read_data : reg_data_t;
    signal read_ack : std_logic;

begin
    write_strobe_inst : entity work.register_mux_strobe port map (
        clk_i => clk_i,
        clk_ok_i => clk_ok_i,
        strobe_i => write_strobe_i,
        address_i => write_address_i,
        ack_o => write_ack_o,
        strobe_o => write_strobe_o,
        ack_i => write_ack_i
    );

    read_strobe_inst : entity work.register_mux_strobe port map (
        clk_i => clk_i,
        clk_ok_i => clk_ok_i,
        strobe_i => read_strobe_i,
        address_i => read_address_i,
        ack_o => read_ack,
        strobe_o => read_strobe_o,
        ack_i => read_ack_i
    );

    -- Read data needs to be demultiplexed and latched at the right point, and
    -- need to delay the read acknowledge out at the same time.
    read_address <= to_integer(read_address_i);

    process (clk_i) begin
        if rising_edge(clk_i) then
            read_data <= read_data_i(read_address);
            if read_ack = '1' then
                read_data_o <= read_data;
            end if;
            read_ack_o <= read_ack;
        end if;
    end process;

end;
