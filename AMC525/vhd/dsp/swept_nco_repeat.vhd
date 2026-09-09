-- Control the NCO to repeat a frequency sweep a certain number of times.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.dsp_defs.all;
use work.swept_nco_defs.all;

entity swept_nco_repeat is
    port (
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;
        reset_i : in std_ulogic;

        repeat_count_i : in repeat_count_t;  -- number of repeat
        repeat_continuous_i : in std_ulogic;
        repeat_start_i : in std_ulogic;      -- repeat start command
        repeat_count_o : out repeat_count_t; -- for readout

        nco_gain_i : in nco_gain_t;          -- NCO gain selected by user

        state_end_i : in std_ulogic;         -- Next turn is start of state

        nco_gain_o : out nco_gain_t := (others => '0')
    );
end;

architecture arch of swept_nco_repeat is
    signal update_nco_gain : std_ulogic;
    signal repeat_cnt_s : repeat_count_t;
    signal repeat_cnt_readout : unsigned(15 downto 0);
    signal repeat_start_arm : std_ulogic := '0';

begin
-- We have a few clock cycles between the moment nco_gain_o is updated and
-- when it is taken into account.
-- This is due to the delay line with NCO_GAIN_DELAY clock cycles delay
-- used in sequencer_nco.

-- note: reset_i and repeat_start_i need to stay high during a full turn cycle

    process (dsp_clk_i)
        variable repeat_cnt_v : repeat_count_t;
    begin
        if rising_edge(dsp_clk_i) then
            if turn_clock_i = '1' then
                -- Setting repeat_count_o with repeat_cnt_readout is delayed
                -- by one turn clock to wait that the NCO is actually updated.
                repeat_count_o <= repeat_cnt_readout;

                if repeat_start_i = '1' then
                    repeat_start_arm <= '1';
                end if;

                if repeat_continuous_i = '1' then
                    nco_gain_o <= nco_gain_i;
                    repeat_cnt_s <= (others => '0');
                    repeat_cnt_readout <= (others => '0');
                    repeat_start_arm <= '0';

                elsif reset_i = '1' then
                    nco_gain_o <= (others => '0');
                    repeat_cnt_s <= (others => '0');
                    repeat_cnt_readout <= (others => '0');
                    repeat_start_arm <= repeat_start_i;

                elsif state_end_i = '1' then
                    if repeat_start_arm = '1' then
                        repeat_start_arm <= '0';
                        repeat_cnt_v := repeat_count_i;
                    else
                        repeat_cnt_v := repeat_cnt_s;
                    end if;

                    repeat_cnt_readout <= repeat_cnt_v;

                    if repeat_cnt_v /= 0 then
                        repeat_cnt_s <= repeat_cnt_v - 1;
                        nco_gain_o <= nco_gain_i;
                    else
                        repeat_cnt_s <= repeat_cnt_v;
                        nco_gain_o <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process;

end;
