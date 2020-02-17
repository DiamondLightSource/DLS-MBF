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
    signal write_data : std_logic_vector(angle_t'RANGE);
    signal write_strobe : std_ulogic;

begin
    super_memory : entity work.block_memory generic map (
        ADDR_BITS => super_count_t'LENGTH,
        DATA_BITS => 48
    ) port map (
        read_clk_i => dsp_clk_i,
        read_addr_i => super_state_i,
        unsigned(read_data_o) => nco_freq_base_o,

        write_clk_i => dsp_clk_i,
        write_strobe_i => write_strobe,
        write_addr_i => write_addr_i(super_count_t'LENGTH downto 1),
        write_data_i => write_data
    );

    -- We gather successive pairs of 32-bit writes into a 48-bit angle_t, and
    -- trigger a write each time we have a complete word.
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Only trigger write on writing to second word in group of two
            write_strobe <= write_strobe_i and write_addr_i(0);
            if write_strobe_i = '1' then
                case write_addr_i(0) is
                    when '0' =>
                        write_data(31 downto 0) <= write_data_i;
                    when '1' =>
                        write_data(47 downto 32) <= write_data_i(15 downto 0);
                    when others =>
                end case;
            end if;
        end if;
    end process;
end;
