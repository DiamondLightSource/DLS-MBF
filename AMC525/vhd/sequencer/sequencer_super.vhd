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
        dsp_clk_i : in std_ulogic;

        write_strobe_i : in std_ulogic;
        write_addr_i : in unsigned;
        write_data_i : in reg_data_t;

        super_state_i : in super_count_t;
        nco_freq_base_o : out angle_t := (others => '0')
    );
end;

architecture arch of sequencer_super is
begin
    super_memory : entity work.block_memory generic map (
        ADDR_BITS => super_count_t'LENGTH,
        DATA_BITS => 32
    ) port map (
        read_clk_i => dsp_clk_i,
        read_addr_i => super_state_i,
        unsigned(read_data_o) => nco_freq_base_o(47 downto 16),

        write_clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i,
        write_addr_i => write_addr_i,
        write_data_i => write_data_i
    );

    nco_freq_base_o(15 downto 0) <= (others => '0');
end;
