-- Constants and common type definitions

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.support.all;

package defines is

    -- The register control interface consists of a set of "modules" each of
    -- can implement a number of registers.
    constant MOD_ADDR_BITS : natural := 4;
    constant REG_ADDR_BITS : natural := 5;

    -- Register data is in blocks of 32-bits
    constant REG_DATA_WIDTH : natural := 32;
    subtype reg_data_t is std_logic_vector(REG_DATA_WIDTH-1 downto 0);
    type reg_data_array_t is array(natural range <>) of reg_data_t;

    -- Modules are selected by appropriate strobes
    constant MOD_ADDR_COUNT : natural := 2**MOD_ADDR_BITS;
    subtype MOD_ADDR_RANGE is natural range 0 to MOD_ADDR_COUNT-1;
    subtype mod_strobe_t is std_logic_vector(MOD_ADDR_RANGE);

    -- Within a single module we have an addressable range
    constant REG_ADDR_COUNT : natural := 2**REG_ADDR_BITS;
    subtype REG_ADDR_RANGE is natural range 0 to REG_ADDR_COUNT-1;
    subtype reg_addr_t is std_logic_vector(REG_ADDR_BITS-1 downto 0);



end package;
