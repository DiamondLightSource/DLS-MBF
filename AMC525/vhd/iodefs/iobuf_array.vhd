-- Array of IOBUF
--
-- Tristate I/O buffers with 1.8V CMOS input standard and tristate control

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity iobuf_array is
    generic (
        COUNT : natural := 1
    );
    port (
        i_i : in std_logic_vector(COUNT-1 downto 0);
        t_i : in std_logic_vector(COUNT-1 downto 0);
        o_o : out std_logic_vector(COUNT-1 downto 0);
        io : inout std_logic_vector(COUNT-1 downto 0)
    );
end;

architecture arch of iobuf_array is
begin
    iobuf_array:
    for i in 0 to COUNT-1 generate
        iobuf_inst : IOBUF generic map (
            IOSTANDARD => "LVCMOS18"
        ) port map (
            I => i_i(i),
            T => t_i(i),
            O => o_o(i),
            IO => io(i)
        );
    end generate;
end;
