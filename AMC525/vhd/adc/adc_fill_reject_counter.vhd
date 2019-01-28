-- Turn counter for fill reject processing
--
-- Generates reset event pulse every 2^S turns where S is set by shift_i.  The
-- reset pulse lasts for an entire turn.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity adc_fill_reject_counter is
    generic (
        MAX_SHIFT : natural;
        WRITE_DELAY : natural
    );
    port (
        clk_i : in std_ulogic;

        turn_clock_i : in std_ulogic;
        shift_i : in unsigned(3 downto 0);

        reset_accum_o : out std_ulogic := '0';
        write_offset_o : out std_ulogic := '0'
    );
end;

architecture arch of adc_fill_reject_counter is
    subtype counter_t is unsigned(MAX_SHIFT-1 downto 0);
    constant base_mask : counter_t := (others => '1');
    signal turn_counter : counter_t := (others => '0');
    signal count_event : std_ulogic := '0';

begin
    -- Delay the write offset event by the requested delay
    delay_write : entity work.dlyline generic map (
        DLY => WRITE_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => count_event,
        data_o(0) => write_offset_o
    );


    process (clk_i) begin
        if rising_edge(clk_i) then
            if turn_clock_i = '1' then
                if turn_counter = 0 then
                    turn_counter <= not shift_left(
                        base_mask, to_integer(shift_i), MAX_SHIFT);
                else
                    turn_counter <= turn_counter - 1;
                end if;

                count_event <= to_std_ulogic(turn_counter = 0);
                reset_accum_o <= count_event;
            end if;
        end if;
    end process;
end;
