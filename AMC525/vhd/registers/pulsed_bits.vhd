-- Bit array of single clock events.
-- Each single clock event is recorded and can then be read out via a register
-- interface.
--
-- A two stage readout is needed: first write to the register to latch the
-- current state of the accumulated bits and reset selected bits; then the
-- latched state can be read.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

entity pulsed_bits is
    generic (
        PIPELINE_DELAY : natural := 1
    );
    port (
        clk_i : in std_logic;

        -- Control register interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t := (others => '0');
        read_ack_o : out std_logic;

        -- Input pulsed bits
        pulsed_bits_i : in reg_data_t
    );
end;

architecture arch of pulsed_bits is
    signal pulsed_bits_in : reg_data_t;
    signal pulsed_bits : reg_data_t := (others => '0');

begin
    -- Pipeline incoming bits
    delay_gen : if PIPELINE_DELAY > 0 generate
        delay : entity work.dlyreg generic map (
            DLY => PIPELINE_DELAY,
            DW => reg_data_t'LENGTH
        ) port map (
            clk_i => clk_i,
            data_i => pulsed_bits_i,
            data_o => pulsed_bits_in
        );
    else generate
        pulsed_bits_in <= pulsed_bits_i;
    end generate;

    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                read_data_o <= pulsed_bits;
                pulsed_bits <=
                    pulsed_bits_in or (pulsed_bits and not write_data_i);
            else
                pulsed_bits <= pulsed_bits_in or pulsed_bits;
            end if;
        end if;
    end process;

    write_ack_o <= '1';
    read_ack_o <= '1';
end;
