-- Preparation of lookup

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.nco_defs.all;

entity nco_cos_sin_prepare is
    generic (
        LOOKUP_DELAY : natural;     -- Time to look up addr in memory
        RESIDUE_DELAY : natural;    -- Lead time required on residue
        REFINE_DELAY : natural      -- Delay for final octant correction
    );
    port (
        clk_i : in std_ulogic;
        angle_i : in angle_t;

        -- Table lookup
        lookup_o : out lookup_t := (others => '0');
        residue_o : out residue_t := (others => '0');
        -- Octant for final correction
        octant_o : out octant_t
    );
end;

architecture arch of nco_cos_sin_prepare is
    -- Delay in this block:
    --  angle_i => lookup_out, residue_o
    constant PREPARE_DELAY : natural := 1;

    -- In order to meet the timing relationships documented in nco_core the
    -- octant_o and lookup_o delays need to be delayed by the times computed
    -- below.

    -- The lookup table output needs to arrive RESIDUE_DELAY ticks after
    -- residue_o, and we know that this delay is longer than the lookup time.
    constant LOOKUP_DELAY_OUT : natural := RESIDUE_DELAY - LOOKUP_DELAY;

    -- The octant_o fixup output needs to come after all other processing is
    -- complete.  In this case we also need to take account of our internal
    -- delay (residue_o is one tick laster than octant), and so we have the
    -- following critical path:
    --  angle_i = residue
    --      =(PREPARE_DELAY)=> residue_o = refine.residue_i
    --      =(RESIDUE_DELAY+REFINE_DELAY) => refine.cos_sin_o
    constant OCTANT_DELAY_OUT : natural :=
        PREPARE_DELAY + RESIDUE_DELAY + REFINE_DELAY;


    signal octant : octant_t;
    signal lookup : lookup_t;
    signal lookup_out : lookup_t;
    signal residue : residue_t;

begin
    -- Split the input angle into its three components
    --
    --   31    29 28    19 18      0
    --  +--------+--------+---------+
    --  | octant | lookup | residue |
    --  +--------+--------+---------+
    --
    octant <= angle_i(47 downto 45);        -- 3 bits
    lookup <= angle_i(44 downto 35);        -- 10 bits
    residue <= angle_i(34 downto 0);        -- the rest

    -- Compute appropriate lookup and residue fields
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Start by selecting the correct address.  Even octants go
            -- forwards, odd ones backwards.
            if octant(0) = '0' then
                lookup_out <= lookup;
                residue_o <= residue;
            else
                lookup_out <= not lookup;
                residue_o <= not residue;
            end if;
        end if;
    end process;

    -- Delay lookup so refine.cos_sin_i is early enough
    i_lookup_delay : entity work.dlyline generic map (
        DLY => LOOKUP_DELAY_OUT,
        DW => lookup_t'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(lookup_out),
        unsigned(data_o) => lookup_o
    );

    -- Delay octant so refine.cos_sin_o in step with octant_o
    i_octant_delay : entity work.dlyline generic map (
        DLY => OCTANT_DELAY_OUT,
        DW => octant_t'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_ulogic_vector(octant),
        unsigned(data_o) => octant_o
    );
end;
