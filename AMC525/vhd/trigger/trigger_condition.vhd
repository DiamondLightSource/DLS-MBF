-- Trigger conditioning
--
-- Brings asynchronous trigger over to specified clock without metastability
-- and converts rising edge into a single pulse.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity trigger_condition is
    port (
        clk_i : in std_logic;
        trigger_i : in std_logic;
        trigger_o : out std_logic := '0'
    );
end;

architecture trigger_condition of trigger_condition is
    signal trigger : std_logic;
    signal trigger_edge : std_logic;

begin
    -- Stabilise the incoming turn clock relative to the clock
    sync_bit_inst : entity work.sync_bit port map (
        clk_i => clk_i,
        bit_i => trigger_i,
        bit_o => trigger
    );

    -- Detect rising edge of trigger
    edge_detect_inst : entity work.edge_detect port map (
        clk_i => clk_i,
        data_i => trigger,
        edge_o => trigger_edge
    );

    -- Register the detected edge
    process (clk_i) begin
        if rising_edge(clk_i) then
            trigger_o <= trigger_edge;
        end if;
    end process;
end;
