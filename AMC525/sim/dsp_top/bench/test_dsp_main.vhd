library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.dsp_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;


architecture arch of testbench is
    -- DSP Main signals
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';

    signal adc_data : signed_array(CHANNELS)(13 downto 0)
        := (others => (others => '0'));
    signal dac_data : signed_array(CHANNELS)(15 downto 0);

    signal write_strobe : std_logic;
    signal write_address : unsigned(12 downto 0);
    signal write_data : reg_data_t;
    signal write_ack : std_logic;
    signal read_strobe : std_logic;
    signal read_address : unsigned(12 downto 0);
    signal read_data : reg_data_t;
    signal read_ack : std_logic;

    signal dram0_capture_enable : std_logic;
    signal dram0_data_ready : std_logic;
    signal dram0_capture_address : std_logic_vector(30 downto 0);
    signal dram0_data : std_logic_vector(63 downto 0);
    signal dram0_data_valid : std_logic;
    signal dram0_data_error : std_logic;
    signal dram0_addr_error : std_logic;
    signal dram0_brsp_error : std_logic;

    signal dram1_address : unsigned(23 downto 0);
    signal dram1_data : std_logic_vector(63 downto 0);
    signal dram1_data_valid : std_logic;
    signal dram1_data_ready : std_logic;
    signal dram1_brsp_error : std_logic;

    signal revolution_clock : std_logic := '0';
    signal event_trigger : std_logic := '0';
    signal postmortem_trigger : std_logic := '0';
    signal blanking_trigger : std_logic := '0';
    signal dsp_events : std_logic_vector(CHANNELS);

    signal dram1_ready_delay : natural := 5;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    -- Simple ADC data simulation: we just generate a ramp.
    process (adc_clk) begin
        if rising_edge(adc_clk) then
            for c in CHANNELS loop
                adc_data(c) <= adc_data(c) + 1;
            end loop;
        end if;
    end process;

    -- Revolution clock
    process begin
        revolution_clock <= '0';
        loop
            clk_wait(adc_clk, 6);
            revolution_clock <= '1';
            clk_wait(adc_clk, 6);
            revolution_clock <= '0';
        end loop;
        wait;
    end process;

    event_trigger <= not event_trigger after 233 ns;
    blanking_trigger <= not blanking_trigger after 200 ns;
    postmortem_trigger <= not postmortem_trigger after 255 ns;


    -- The dsp_main instance.
    dsp_main_inst : entity work.dsp_main port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,

        adc_data_i => adc_data,
        dac_data_o => dac_data,

        write_strobe_i => write_strobe,
        write_address_i => write_address,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_address_i => read_address,
        read_data_o => read_data,
        read_ack_o => read_ack,

        dram0_capture_enable_o => dram0_capture_enable,
        dram0_data_ready_i => dram0_data_ready,
        dram0_capture_address_i => dram0_capture_address,
        dram0_data_o => dram0_data,
        dram0_data_valid_o => dram0_data_valid,
        dram0_data_error_i => dram0_data_error,
        dram0_addr_error_i => dram0_addr_error,
        dram0_brsp_error_i => dram0_brsp_error,

        dram1_address_o => dram1_address,
        dram1_data_o => dram1_data,
        dram1_data_valid_o => dram1_data_valid,
        dram1_data_ready_i => dram1_data_ready,
        dram1_brsp_error_i => dram1_brsp_error,

        revolution_clock_i => revolution_clock,
        event_trigger_i => event_trigger,
        postmortem_trigger_i => postmortem_trigger,
        blanking_trigger_i => blanking_trigger,
        dsp_events_o => dsp_events
    );


    dram0_data_ready <= '1';
    dram0_data_error <= '0';
    dram0_addr_error <= '0';
    dram0_brsp_error <= '0';

    dram1_brsp_error <= '0';


    -- DRAM0 simulation
    process begin
        wait until dram0_capture_enable = '1';
        dram0_capture_address <= (others => '0');
        while dram0_capture_enable = '1' loop
            clk_wait(dsp_clk);
            if dram0_data_valid = '1' then
                dram0_capture_address <= std_logic_vector(
                    signed(dram0_capture_address) + 1);
            end if;
        end loop;
    end process;


    -- DRAM1 ready handshaking
    process
        variable is_valid : boolean;
    begin
        dram1_data_ready <= '0';
        loop
            clk_wait(dsp_clk, dram1_ready_delay);
            dram1_data_ready <= '1';
            loop
                is_valid := dram1_data_valid = '1';
                clk_wait(dsp_clk);
                exit when is_valid;
            end loop;
            dram1_data_ready <= '0';
        end loop;
        wait;
    end process;


    -- Register control testbench
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg_a(
                dsp_clk, write_strobe, write_address, write_data, write_ack,
                reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg_a(
                dsp_clk, read_strobe, read_address, read_data, read_ack, reg);
        end;

        -- Writes to both DSP units simultaneously
        procedure write_dsp(reg : natural; value : reg_data_t) is
        begin
            write_reg(16#1000# + reg, value);
            write_reg(16#1800# + reg, value);
        end;
    begin
        write_strobe <= '0';
        read_strobe <= '0';
        write_address <= (others => '0');
        read_address <= (others => '0');
        clk_wait(dsp_clk, 5);

        read_reg(16#0006#);             -- Dummy read

        -- Set up number of bunches
        write_reg(16#0009#, X"0000000B");   -- 12 bunches in our ring!
        -- Trigger synchronisation and sample
        write_reg(16#0006#, X"00000003");
        -- Configure blanking intervals
        write_reg(16#000A#, X"00010004");
        -- Enable DRAM0 triggers
        write_reg(16#000F#, X"0000007F");
        -- Arm DRAM0 trigger
        write_reg(16#0006#, X"00000140");
        -- Read the trigger events
        read_reg(16#0006#);
        -- Rearm DRAM0 without soft trigger
        write_reg(16#0006#, X"00000040");

        -- Configure decimation factor
        write_dsp(7, X"0000000C");

        -- Start DRAM1 memory transfer
        write_reg(16#1006#, X"20000008");   -- Start DSP0 DRAM1
        write_reg(16#1806#, X"20000008");   -- Start DSP1 DRAM1

        -- Initiate DRAM0 memory transfer
        write_reg(3, X"00000010");
        write_reg(4, X"00000003");

        read_reg(5);
        read_reg(4);

        -- Write to DSP 1 sequencer
        write_reg(16#180B#, X"00000002");   -- Start memory write sequence
        write_reg(16#180C#, X"00000000");   -- Select sequencer memory
        write_reg(16#180D#, X"00000000");   -- Write one word to seq memory
        write_reg(16#180C#, X"10000000");   -- Select window memory
        write_reg(16#180D#, X"00000000");   -- Write one word to window memory
        write_reg(16#180C#, X"20000000");   -- Select super memory
        write_reg(16#180D#, X"00000000");   -- Write one word to super memory

        -- Sample the turn clock
        write_reg(16#0006#, X"00000002");

-- 
--         -- Initialise ADC FIR with passthrough.
--         write_dsp(0, X"00000001");
--         write_dsp(3, X"7FFFFFFF");
-- 
--         -- Configure bunch control
--         write_dsp(4, X"00000004");      -- 10 bunches (2*5) in our ring!
--         write_dsp(0, X"00000001");      -- Start write
--         write_dsp(5, X"7FFF0070");      -- Enable all outpus with maximum gain
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
--         write_dsp(5, X"7FFF0070");
-- 
--         -- Write 1 into first tap of bank 0
--         write_dsp(8, X"7FFFFFFF");
-- 
--         -- Global DAC output config
--         write_dsp(9, X"02000000");      -- Enable FIR, zero delay
-- 
--         -- Initialise DAC FIR
--         write_dsp(0, X"00000001");
--         write_dsp(10, X"7FFFFFFF");
-- 
--         -- Enable DAC output
--         write_dsp(11, X"00000008");
-- 
--         -- Set both oscillator frequencies
--         write_dsp(12, X"01000000");
--         write_dsp(13, X"10000000");
        wait;
    end process;

-- 
--         -- Initialise ADC FIR with passthrough.
--         clk_wait(dsp_clk, 10);
--         write_reg(0, X"00000001");
--         write_reg(3, X"7FFFFFFF");
-- 
--         -- Configure bunch control
--         write_reg(4, X"00000004");      -- 10 bunches (2*5) in our ring!
--         write_reg(0, X"00000001");      -- Start write
--         write_reg(5, X"7FFF0070");      -- Enable all outpus with maximum gain
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
--         write_reg(5, X"7FFF0070");
-- 
--         -- Write 1 into first tap of bank 0
--         write_reg(8, X"7FFFFFFF");
-- 
--         -- Global DAC output config
--         write_reg(9, X"02000000");      -- Enable FIR, zero delay
-- 
--         -- Initialise DAC FIR
--         write_reg(0, X"00000001");
--         write_reg(10, X"7FFFFFFF");
-- 
--         -- Enable DAC output
--         write_reg(11, X"00000008");
-- 
--         -- Set both oscillator frequencies
--         write_reg(12, X"01000000");
--         write_reg(13, X"10000000");
-- 
--         clk_wait(dsp_clk, 10);
-- 
--         write_reg(9, X"06000011");     -- 17 tick delay, enable NCO0
-- 
--         wait;
-- 
--     end process;

end;
