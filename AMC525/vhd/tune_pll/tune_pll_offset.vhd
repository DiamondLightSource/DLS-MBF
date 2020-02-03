-- Optionally add tune PLL offset to input frequency


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

use work.nco_defs.all;

entity tune_pll_offset is
    port (
        clk_i : in std_ulogic;
        freq_offset_i : in signed(31 downto 0);
        enable_i : in std_ulogic;
        freq_i : in angle_t;
        freq_o : out angle_t
    );
end;

architecture arch of tune_pll_offset is
    -- Do all the arithmetic as signed numbers for better match to DSP.  In fact
    -- angle_t is unsigned, but the offset is signed.
    signal freq_offset_in : signed(angle_t'RANGE);
    signal freq_in : signed(angle_t'RANGE);
    signal freq_out : signed(angle_t'RANGE);

    -- Use DSP unit for our 48 bit arithmetic here
    attribute USE_DSP : string;
    attribute USE_DSP of freq_out : signal is "yes";

    -- Stop input registers being absorbed into DSP
    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of freq_i : signal is "yes";
    attribute DONT_TOUCH of freq_offset_i : signal is "yes";

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- The frequency offset covers bits [39:8] of the 48 bit angle.
            freq_offset_in <= resize(freq_offset_i & X"00", angle_t'LENGTH);
            freq_in <= signed(freq_i);
            if enable_i = '1' then
                freq_out <= freq_in + freq_offset_in;
            else
                freq_out <= freq_in;
            end if;
        end if;
    end process;
    freq_o <= unsigned(freq_out);
end;
