-- Scaling and output of a single detector value with output handshaking
-- underrun detection.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;

entity detector_output is
    port (
        dsp_clk_i : in std_ulogic;

        write_i : in std_ulogic;
        data_i : in cos_sin_32_t;

        output_valid_o : out std_ulogic := '0';
        output_ready_i : in std_ulogic;
        output_data_o : out std_ulogic_vector(63 downto 0);
        output_underrun_o : out std_ulogic := '0'
    );
end;

architecture arch of detector_output is
    signal output_valid : std_ulogic := '0';

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            case output_valid is
                when '0' =>
                    if write_i = '1' then
                        output_valid <= '1';
                    end if;
                when '1' =>
                    if output_ready_i = '1' then
                        output_valid <= '0';
                    end if;
                when others =>
            end case;

            -- Report an error if a new write arrives while the old write is
            -- still not dealt with.
            output_underrun_o <= output_valid and write_i;
        end if;
    end process;

    output_valid_o <= output_valid;
    output_data_o(31 downto  0) <= std_ulogic_vector(data_i.cos);
    output_data_o(63 downto 32) <= std_ulogic_vector(data_i.sin);
end;
