-- Bank addressing and switching.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.min_max_sum_defs.all;

entity min_max_sum_bank is
    port (
        clk_i : in std_logic;
        bunch_reset_i : in std_logic;       -- Revolution clock

        -- External bank control.
        switch_request_i : in std_logic;    -- Request to switch bank
        frame_count_o : out unsigned;       -- Frames since last switch
        switch_done_o : out std_logic;      -- Strobed on completion of switch

        -- Update control and current bank
        bank_select_o : out std_logic;
        update_addr_o : out unsigned;

        -- Readout control and address
        readout_strobe_i : in std_logic;
        readout_addr_o : out unsigned
    );
end;

architecture min_max_sum_bank of min_max_sum_bank is
    signal switch_request : boolean;
    signal switch_event : boolean;
    signal switch_done : std_logic := '0';

    signal frame_count : unsigned(frame_count_o'RANGE);

    signal bank_select : std_logic := '0';
    signal update_addr : unsigned(update_addr_o'RANGE);
    signal readout_addr : unsigned(readout_addr_o'RANGE) := (others => '0');

begin
    -- The switch event is posponed to next bunch reset event
    switch_event <= switch_request and bunch_reset_i = '1';
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Advance the update address
            if bunch_reset_i = '1' then
                update_addr <= (others => '0');
            else
                update_addr <= update_addr + 1;
            end if;

            -- Count each frame, readout and reset on request
            if bunch_reset_i = '1' then
                if switch_request then
                    frame_count_o <= frame_count;
                    frame_count <= (others => '0');
                else
                    frame_count <= frame_count + 1;
                end if;
            end if;

            -- Bank switching.  On receipt of a bank switch request we wait for
            -- a bunch reset event.  This ensures that the first update will
            -- always be to cell zero.
            if switch_request_i = '1' then
                switch_request <= true;
            elsif switch_event then
                switch_request <= false;
                bank_select <= not bank_select;
            end if;
            switch_done <= to_std_logic(switch_event);

            -- Manage the readout address.  Advance on request, or reset on
            -- switch event
            if switch_event then
                readout_addr <= (others => '0');
            elsif readout_strobe_i = '1' then
                readout_addr <= readout_addr + 1;
            end if;
        end if;
    end process;

    bank_select_o <= bank_select;
    update_addr_o <= update_addr;
    readout_addr_o <= readout_addr;

    -- Need to delay the switch done a little so that nobody attempts to read
    -- data before the switch has actually completed.
    switch_done_dly : entity work.dlyline generic map (
        DLY => 5
    ) port map (
        clk_i => clk_i,
        data_i(0) => switch_done,
        data_o(0) => switch_done_o
    );
end;
