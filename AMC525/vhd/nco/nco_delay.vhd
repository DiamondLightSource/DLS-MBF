-- Delay line for cos/sin data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.nco_defs.all;

entity nco_delay is
    generic (
        DELAY : natural
    );
    port (
        clk_i : in std_ulogic;
        cos_sin_i : in cos_sin_t;
        cos_sin_o : out cos_sin_t
    );
end;

architecture arch of nco_delay is
    -- QuestaSim seems to be rather confused about sizes and subtypes of
    -- unconstrained inputs.  Trying to directly connect data_i=>cos_sin_o.cos
    -- results in the rhs as being treated as of length zero, and there's a
    -- similar result when using 'SUBTYPE on either input to declare
    -- cos_sin_out below.
    constant WIDTH : natural := cos_sin_i.cos'LENGTH;
    signal cos_sin_out :
        cos_sin_t(cos(WIDTH-1 downto 0), sin(WIDTH-1 downto 0));

begin
    cos_dly : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => WIDTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(cos_sin_i.cos),
        signed(data_o) => cos_sin_out.cos
    );

    sin_dly : entity work.dlyreg generic map (
        DLY => DELAY,
        DW => WIDTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(cos_sin_i.sin),
        signed(data_o) => cos_sin_out.sin
    );

    cos_sin_o <= cos_sin_out;
end;
