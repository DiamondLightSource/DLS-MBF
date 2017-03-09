-- Frequency offset management for super sequencer

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.sequencer_defs.all;

entity sequencer_super is
    port (
        dsp_clk_i : in std_logic;

        write_strobe_i : in std_logic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;

        super_state_i : in super_count_t;
        nco_freq_base_o : out angle_t
    );
end;

architecture arch of sequencer_super is
    type freq_memory_t is array(0 to 2**super_count_t'LENGTH-1) of angle_t;
    signal freq_memory : freq_memory_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of freq_memory : signal is "BLOCK";

begin
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_strobe_i = '1' then
                freq_memory(to_integer(write_addr_i)) <= angle_t(write_data_i);
            end if;
            nco_freq_base_o <= freq_memory(to_integer(super_state_i));
        end if;
    end process;
end;
