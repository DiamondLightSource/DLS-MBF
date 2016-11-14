-- Readout of min/max/sum data

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.min_max_sum_defs.all;

entity min_max_sum_readout is
    port (
        dsp_clk_i : in std_logic;

        -- Interface to stored data.  First reset_readout_i is pulsed to
        -- indicate that the readout address has been reset to zero.  Then the
        -- data can be read from data_i.  Finally readout_strobe_o can be used
        -- to advance the readout address.
        reset_readout_i : in std_logic;
        data_i : in mms_row_lanes_t;
        readout_strobe_o : out std_logic := '0';
        readout_ack_i : in std_logic;

        -- Register readout interface
        read_strobe_i : in std_logic;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic := '0'
    );
end;

architecture min_max_sum_readout of min_max_sum_readout is
    -- Number of words read per sample (per lane)
    constant WORD_COUNT : natural := 4;

    -- The readout state advances through the lanes and the two words -- we
    -- have to deliver min/max and sum separately.
    signal lane : LANES;
    signal phase : natural range 0 to WORD_COUNT-1;
    signal mms : mms_row_t;
    signal last_word : boolean;
    signal last_phase : boolean;

    -- While we're waiting for memory to advance we're busy
    signal busy : boolean := false;
    signal read_request : boolean := false;

begin
    -- quick and dirty
    mms <= data_i(lane);
    last_phase <= phase = WORD_COUNT-1;
    last_word <= lane = LANE_COUNT-1 and last_phase;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Advance phase and lane as appropriate
            if reset_readout_i = '1' then
                lane <= 0;
                phase <= 0;
            elsif read_strobe_i = '1' then
                phase <= (phase + 1) mod WORD_COUNT;
                if last_phase then
                    lane <= (lane + 1) mod LANE_COUNT;
                end if;
            end if;

            -- Generate request for new word when we've consumed the old word
            if last_word and read_strobe_i = '1' then
                readout_strobe_o <= '1';
                busy <= true;
            else
                readout_strobe_o <= '0';
                if readout_ack_i = '1' then
                    busy <= false;
                end if;
            end if;

            -- Ensure we don't generate an ack while we're busy.
            read_ack_o <= to_std_logic(
                not busy and (read_strobe_i = '1' or read_request));
            if busy and read_strobe_i = '1' then
                read_request <= true;
            elsif not busy then
                read_request <= false;
            end if;

            -- Register the appropriate output word
            case phase is
                when 0 => read_data_o <=
                    std_logic_vector(mms.max) & std_logic_vector(mms.min);
                when 1 => read_data_o <=
                    std_logic_vector(mms.sum);
                when 2 => read_data_o <=
                    std_logic_vector(mms.sum2(31 downto 0));
                when 3 => read_data_o <=
                    X"0000" & std_logic_vector(mms.sum2(47 downto 32));
            end case;
        end if;
    end process;
end;
