-- Global reset synchroniser.  Takes in an asynchronous active low reset,
-- generates a synchronous reset: enters reset asynchronously, comes out of
-- reset synchronously.

library ieee;
use ieee.std_logic_1164.all;

use work.support.all;

entity sync_reset is
    port (
        clk_i : in std_logic;
        clk_ok_i : in std_logic;
        sync_clk_ok_o : out std_logic
    );
end entity;

architecture sync_reset of sync_reset is
    signal clk_ok_meta : std_logic;
    signal clk_ok_delay : std_logic;    -- Delay to help with reset distribution

    -- Not sure if this requires metastability management: we can come out of
    -- reset at an entirely unpredictable time relative to the clock, so I'm
    -- guessing that clk_ok_meta can be forced into an uncomfortable state.
    attribute async_reg : string;
    attribute async_reg of clk_ok_meta : signal is "TRUE";
    attribute async_reg of sync_clk_ok_o : signal is "TRUE";

begin
    process (clk_ok_i, clk_i) begin
        if clk_ok_i = '0' then
            clk_ok_meta <= '0';
            clk_ok_delay <= '0';
            sync_clk_ok_o <= '0';
        elsif rising_edge(clk_i) then
            clk_ok_meta <= '1';
            clk_ok_delay <= clk_ok_meta;
            sync_clk_ok_o <= clk_ok_delay;
        end if;
    end process;
end;
