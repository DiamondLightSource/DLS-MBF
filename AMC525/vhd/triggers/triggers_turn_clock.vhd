-- Management of turn clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity triggers_turn_clock is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        adc_phase_i : in std_logic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_logic_vector(0 to 3);
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic_vector(0 to 3);
        read_strobe_i : in std_logic_vector(0 to 3);
        read_data_o : out reg_data_array_t(0 to 3);
        read_ack_o : out std_logic_vector(0 to 3);

        -- Input
        revolution_clock_i : in std_logic;
        -- Generated outputs
        turn_clock_o : out std_logic_vector(CHANNELS)
    );
end;

architecture triggers_turn_clock of triggers_turn_clock is
    -- Register interface
    constant CONTROL_REG : natural := 0;
    subtype CONFIG_REGS is natural range 1 to 3;
    signal readback_register : reg_data_t;
    signal strobed_bits : reg_data_t;
    signal register_data : reg_data_array_t(CONFIG_REGS);

    -- Control parameters
    signal max_bunch : bunch_count_t;
    signal clock_offset : unsigned_array(CHANNELS)(bunch_count_t'RANGE);
    signal start_sync : std_logic;
    signal start_sample : std_logic;

    -- Incoming revolution clock
    signal revolution_clock : std_logic;
    signal rev_clock_adc : std_logic;
    signal rev_clock_adc_dsp : std_logic;
    signal rev_clock_dsp : std_logic;
    signal clock_phase_adc : std_logic;
    signal clock_phase_dsp : std_logic;

    signal bunch_counter : bunch_count_t := (others => '0');

    -- Synchronisation and sample state
    signal sync_request : boolean := false;
    signal sync_holdoff : boolean := false;
    signal sync_phase : std_logic;
    signal sample_request : boolean := false;
    signal sample_counter : bunch_count_t;
    signal sample_phase : std_logic;

begin
    -- -------------------------------------------------------------------------
    -- Register control interface

    strobed_bits_inst : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(CONTROL_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONTROL_REG),
        strobed_bits_o => strobed_bits
    );

    read_data_o(CONTROL_REG) <= readback_register;
    read_ack_o(CONTROL_REG) <= '1';

    register_file_inst : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(CONFIG_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(CONFIG_REGS),
        register_data_o => register_data
    );
    read_data_o(CONFIG_REGS) <= register_data;
    read_ack_o(CONFIG_REGS) <= (others => '1');


    start_sync <= strobed_bits(0);
    start_sample <= strobed_bits(1);

    readback_register <= (
        bunch_count_t'RANGE => std_logic_vector(sample_counter),
        16 => to_std_logic(sync_request),
        17 => to_std_logic(sample_request),
        18 => sync_phase,
        19 => sample_phase,
        others => '0'
    );

    max_bunch <= bunch_count_t(register_data(1)(bunch_count_t'RANGE));
    gen_chan : for c in CHANNELS generate
        clock_offset(c) <=
            bunch_count_t(register_data(c+2)(bunch_count_t'RANGE));
    end generate;


    -- -------------------------------------------------------------------------
    -- Revolution clock at ADC clock rate

    -- Stabilise the incoming turn clock relative to the ADC clock
    sync_bit_inst : entity work.sync_bit port map (
        clk_i => adc_clk_i,
        bit_i => revolution_clock_i,
        bit_o => revolution_clock
    );

    -- Detect rising edge of revolution clock
    edge_detect_inst : entity work.edge_detect port map (
        clk_i => adc_clk_i,
        data_i => revolution_clock,
        edge_o => rev_clock_adc
    );

    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            -- Pick up the turn clock phase
            if rev_clock_adc = '1' then
                clock_phase_adc <= adc_phase_i;
            end if;

            -- Convert event into event on dsp clock
            if rev_clock_adc = '1' then
                rev_clock_adc_dsp <= '1';
            elsif adc_phase_i = '0' then
                rev_clock_adc_dsp <= '0';
            end if;
        end if;
    end process;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Bring trigger and phase over to DSP clock
            clock_phase_dsp <= clock_phase_adc;
            rev_clock_dsp <= rev_clock_adc_dsp;
        end if;
    end process;


    -- -------------------------------------------------------------------------
    -- Normal processing at DSP clock rate

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Synchronise or else advance base bunch counter
            if rev_clock_dsp = '1' and sync_request then
                bunch_counter <= (others => '0');
                sync_phase <= clock_phase_dsp;
                sync_holdoff <= true;
            elsif bunch_counter = max_bunch then
                bunch_counter <= (others => '0');
                sync_holdoff <= false;
            else
                bunch_counter <= bunch_counter + 1;
            end if;

            -- Sample bunch counter
            if rev_clock_dsp = '1' and sample_request then
                sample_counter <= bunch_counter;
                sample_phase <= clock_phase_dsp;
            end if;

            -- Synchronisation request.
            if start_sync = '1' then
                sync_request <= true;
            elsif rev_clock_dsp = '1' then
                sync_request <= false;
            end if;

            -- Sample request.
            if start_sample = '1' then
                sample_request <= true;
            elsif rev_clock_dsp = '1' then
                sample_request <= false;
            end if;

            -- Output of channel specific turn clocks
            for c in CHANNELS loop
                if sync_request or sync_holdoff then
                    turn_clock_o(c) <= '0';
                else
                    turn_clock_o(c) <=
                        to_std_logic(bunch_counter = clock_offset(c));
                end if;
            end loop;
        end if;
    end process;
end;
