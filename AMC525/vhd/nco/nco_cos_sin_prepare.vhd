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
        REFINE_DELAY : natural      -- Delay for final octant correction
    );
    port (
        clk_i : in std_logic;
        angle_i : in angle_t;

        -- Table lookup
        lookup_o : out lookup_t := (others => '0');
        residue_o : out residue_t := (others => '0');
        -- Octant for final correction
        octant_o : out octant_t
    );
end;

architecture nco_cos_sin_prepare of nco_cos_sin_prepare is
    -- Delay in this block:
    --  angle_i => lookup_o, residue_o
    constant PREPARE_DELAY : natural := 1;

    signal octant : octant_t;
    signal lookup : lookup_t;
    signal residue : residue_t;

begin
    -- Split the input angle into its three components
    --
    --   31    29 28    19 18      0
    --  +--------+--------+---------+
    --  | octant | lookup | residue |
    --  +--------+--------+---------+
    --
    octant <= angle_i(31 downto 29);        -- 3 bits
    lookup <= angle_i(28 downto 19);        -- 10 bits
    residue <= angle_i(18 downto 0);        -- the rest

    -- The octant determines the direction of the angle and how to treat the
    -- generated sin and cos values.  This will need to be pipelined through to
    -- the generated output according to the timing below:
    --
    --  clk_i       /     /     /     /     /     /     /     /     /
    --  angle_i   --X A   X--------------------------------------------
    --  octant    --X O   X--------------------------------------------
    --  lookup_o  --------X L   X--------------------------------------
    --  residue_o --------X R   X--------------------------------------
    --  raw data  --------------------X D   X--------------------------
    --              |                 |--- ... -->| REFINE_DELAY
    --  cos_sin_i --------------------------------X CS  X--------------
    --              |-------- octant_delay ------>|
    --  octant_d  --------------------------------X O   X--------------
    --  cos_sin_o --------------------------------------X CS' X--------
    --
    octant_delay : entity work.dlyline generic map (
        DLY => PREPARE_DELAY + LOOKUP_DELAY + REFINE_DELAY,
        DW => octant_t'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(octant),
        unsigned(data_o) => octant_o
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Start by selecting the correct address.  Even octants go
            -- forwards, odd ones backwards.
            if octant(0) = '0' then
                lookup_o <= lookup;
                residue_o <= residue;
            else
                lookup_o <= not lookup;
                residue_o <= not residue;
            end if;
        end if;
    end process;
end;
