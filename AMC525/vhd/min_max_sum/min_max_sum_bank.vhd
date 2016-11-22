-- Bank addressing and switching.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.min_max_sum_defs.all;

entity min_max_sum_bank is
    generic (
        READ_DELAY : natural;
        UPDATE_DELAY : natural
    );
    port (
        clk_i : in std_logic;
        turn_clock_i : in std_logic;       -- Revolution clock

        -- Register readout bank count and switch
        count_read_strobe_i : in std_logic;         -- Request to switch bank
        count_read_data_o : out reg_data_t;         -- Frames since last switch
        count_read_ack_o : out std_logic := '0';    -- On completion of switch

        -- Update control and current bank
        bank_select_o : out std_logic;
        update_addr_o : out unsigned;

        -- Readout control and address: readout_strobe_i advances address
        readout_strobe_i : in std_logic;
        readout_addr_o : out unsigned;

        -- Incoming overflow detect signals
        sum_overflow_i : in std_logic;
        sum2_overflow_i : in std_logic
    );
end;

architecture min_max_sum_bank of min_max_sum_bank is
    signal switch_request : boolean;
    signal switch_event : boolean;
    signal switch_done : std_logic;

    signal sum_overflow : std_logic;
    signal sum2_overflow : std_logic;
    signal overflow_readout : std_logic;

    signal frame_count : unsigned(29 downto 0) := (others => '0');
    signal frame_count_overflow : std_logic;

    signal bank_select : std_logic := '0';
    signal update_addr  : unsigned(update_addr_o'RANGE)  := (others => '0');
    signal readout_addr : unsigned(readout_addr_o'RANGE) := (others => '0');

begin
    -- The switch event is posponed to next bunch reset event
    switch_event <= switch_request and turn_clock_i = '1';
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Advance the update address
            if turn_clock_i = '1' then
                update_addr <= (others => '0');
            else
                update_addr <= update_addr + 1;
            end if;

            -- Count each frame, readout and reset on request
            if turn_clock_i = '1' then
                if switch_request then
                    count_read_data_o(28 downto 0) <=
                        std_logic_vector(frame_count(28 downto 0));
                    count_read_data_o(29) <= frame_count_overflow;
                    frame_count <= (others => '0');
                    frame_count_overflow <= '0';
                else
                    frame_count <= frame_count + 1;
                end if;
            elsif frame_count(29) = '1' then
                frame_count_overflow <= '1';
            end if;

            -- Bank switching.  On receipt of a bank switch request we wait for
            -- a bunch reset event.  This ensures that the first update will
            -- always be to cell zero.
            if count_read_strobe_i = '1' then
                switch_request <= true;
            elsif switch_event then
                switch_request <= false;
                bank_select <= not bank_select;
            end if;

            -- Manage the readout address.  Advance on request, or reset on
            -- switch event
            if switch_event then
                readout_addr <= (others => '0');
            elsif readout_strobe_i = '1' then
                readout_addr <= readout_addr + 1;
            end if;

            -- Latch the overflow bits when they're ready
            if overflow_readout = '1' then
                count_read_data_o(30) <= sum_overflow;
                count_read_data_o(31) <= sum2_overflow;
                sum_overflow <= sum_overflow_i;
                sum2_overflow <= sum2_overflow_i;
            else
                sum_overflow <= sum_overflow or sum_overflow_i;
                sum2_overflow <= sum2_overflow or sum2_overflow_i;
            end if;
            count_read_ack_o <= overflow_readout;
        end if;
    end process;

    bank_select_o <= bank_select;
    update_addr_o <= update_addr;
    readout_addr_o <= readout_addr;

    -- The delay to overflow readout is delicate, as this integrates delays from
    -- the entirety of the min/max/sum component.
    --
    --  clk_i         /     / ... /     / ... /     /     /     /     /
    --            __________
    --  sw_r           _____\_____________________________________________
    --  tc_i      ____/_____\_____________________________________________
    --  sw_e      ____/     \_____________________________________________
    --  bs          B       X B'
    --  ua        ----X LA  X---------------------------------------------
    --                |---- ... ->| READ_DELAY
    --  udo       ----------------X DA  X---------------------------------
    --                            |---- ... ->| UPDATE_DELAY
    --  udi       ----------------------------X DA' X---------------------
    --  ovf_i     ----------------------------------X DO  X---------------
    --                                                     _____
    --  or        ________________________________________/     \_________
    --  ovf       ----------------------------------------X +DO X O   X---
    --                                                           _____
    --  ack       ______________________________________________/     \___
    --
    -- sw_r = switch_request, tc_i = turn_clock_i, sw_e = switch_event
    -- bs = bank_select, ua = update_addr, LA = last update address before
    -- bank switch, udo = update data from store, DA = data from LA,
    -- udi = update data to store, DA' = updated data,
    -- ovf_i = sum_overflow_i & sum2_overflow_i, DO = overflow status,
    -- ovf = sum overflow & sum2_overflow, +DO = accumulated status,
    -- or = overflow_readout, O = reset status, ack = count_read_ack_o
    --
    --  READ_DELAY = delay from bank select to store data out = 4 ticks
    --  UPDATE_DELAY = update computation, 2 ticks
    switch_done <= to_std_logic(switch_event);
    overflow_readout_dly : entity work.dlyline generic map (
        DLY => READ_DELAY + UPDATE_DELAY + 2
    ) port map (
        clk_i => clk_i,
        data_i(0) => switch_done,
        data_o(0) => overflow_readout
    );
end;
