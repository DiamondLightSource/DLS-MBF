-- Definitions for bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

package bunch_defs is
    -- Bunch configuration
    -- This needs to match the register definition for DSP.BUNCH.BANK
    type bunch_config_t is record
        -- Selects FIR filter
        fir_select : unsigned(FIR_BANK_BITS-1 downto 0);
        -- Output enables
        fir_enable : std_ulogic;
        nco_0_enable : std_ulogic;
        nco_1_enable : std_ulogic;
        -- Final output gain
        gain : signed(12 downto 0);
    end record;

    constant BUNCH_CONFIG_BITS : natural := FIR_BANK_BITS + 3 + 13;
end;
