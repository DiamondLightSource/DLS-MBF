-- Controller for fast memory

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity fast_memory_control is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        start_i : in std_logic;
        stop_i : in std_logic;
        count_i : in unsigned;

        trigger_i : in std_logic;   -- On ADC clock, we need the phase

        capture_enable_o : out std_logic := '0';
        capture_address_i : in std_logic_vector;
        capture_address_o : out std_logic_vector
    );
end;

architecture arch of fast_memory_control is
    signal adc_phase : std_logic;
    signal trigger_in : std_logic := '0';
    signal trigger : std_logic := '0';
    signal capture_phase_in : std_logic := '0';
    signal capture_phase : std_logic := '0';

    signal counter : count_i'SUBTYPE;
    type state_t is (IDLE, RUNNING, RUNOUT);
    signal state : state_t := IDLE;


    -- The phase bit is inserted into the capture address at the right point.
    -- We are capturing 4 bytes per ADC tick, so we need to insert the ADC
    -- phase as bit 2.
    function insert_phase_bit(
        word : std_logic_vector;
        phase : std_logic) return std_logic_vector
    is
        variable result : word'SUBTYPE := word;
    begin
        result(2) := phase;
        return result;
    end;

begin
    adc_dsp_phase : entity work.adc_dsp_phase port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        adc_phase_o => adc_phase
    );

    -- Bring trigger_i over to DSP clock and capture clock phase
    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if trigger_i then
                trigger_in <= '1';
                capture_phase_in <= adc_phase;
            elsif trigger then
                trigger_in <= '0';
            end if;
        end if;
    end process;


    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            trigger <= trigger_in;
            capture_phase <= capture_phase_in;

            case state is
                when IDLE =>
                    if start_i = '1' then
                        counter <= count_i;
                        state <= RUNNING;
                    end if;
                when RUNNING =>
                    if trigger = '1' then
                        if counter = 0 then
                            state <= IDLE;
                        else
                            capture_address_o <= insert_phase_bit(
                                capture_address_i, capture_phase);
                            state <= RUNOUT;
                        end if;
                    elsif stop_i = '1' then
                        state <= IDLE;
                    end if;
                when RUNOUT =>
                    if counter = 0 then
                        state <= IDLE;
                    elsif stop_i = '1' then
                        state <= IDLE;
                    else
                        counter <= counter - 1;
                    end if;
            end case;

            capture_enable_o <= to_std_logic(state /= IDLE);
        end if;
    end process;
end;
