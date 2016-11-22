library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.min_max_sum_defs.all;

entity testbench is
end testbench;

architecture testbench of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal dsp_clk : std_logic;


    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;

    signal adc_clk : std_logic;
    signal adc_phase : std_logic;
    signal turn_clock : std_logic;

    signal adc_data_raw : signed(15 downto 0) := (others => '0');
    signal adc_data : signed(15 downto 0) := (others => '0');

    signal limit : unsigned(15 downto 0);
    signal limit_event : std_logic;
    signal reset_event : std_logic;
    signal read_strobe : std_logic_vector(0 to 1);
    signal read_data : reg_data_array_t(0 to 1);
    signal read_ack : std_logic_vector(0 to 1);
    signal dsp_data : signed_array(LANES)(15 downto 0);
    signal delta : unsigned_array(LANES)(15 downto 0);
    signal overflow : std_logic;

    constant BUNCH_COUNT : natural := 6;   -- A very small ring!

begin

    -- ADC and DSP clocks with phase generator
    clocks_inst : entity work.clocks port map (
        adc_clk_o => adc_clk,
        dsp_clk_o => dsp_clk,
        adc_phase_o => adc_phase
    );

    -- Split the data into the two working lanes ("DSP data")
    adc_to_dsp_inst : entity work.adc_to_dsp port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        adc_phase_i => adc_phase,
        adc_data_i => adc_data,
        dsp_data_o => dsp_data
    );

    -- Device under test
    min_max_sum_inst : entity work.min_max_sum generic map (
        ADDR_BITS => 4
    ) port map (
        dsp_clk_i => dsp_clk,
        turn_clock_i => turn_clock,
        data_i => dsp_data,
        delta_o => delta,
        overflow_o => overflow,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack
    );

    min_max_limit_inst : entity work.min_max_limit port map (
        dsp_clk_i => dsp_clk,
        delta_i => delta,
        limit_i => limit,
        reset_event_i => reset_event,
        limit_event_o => limit_event
    );

    limit <= to_unsigned(7, 16);

    -- A little sawtooth for the ADC data should be enough
    process (adc_clk) begin
        if rising_edge(adc_clk) then
            if adc_data_raw < 7 then
                adc_data_raw <= adc_data_raw + 1;
            else
                adc_data_raw <= to_signed(-3, 16);
            end if;

            if turn_clock = '1' and adc_phase = '1' then
--                 adc_data <= (others => 'X');
                adc_data <= (others => '0');
            else
                adc_data <= adc_data_raw;
            end if;
        end if;
    end process;

    -- Bunch counter.
    process begin
        turn_clock <= '0';
        tick_wait(2);
        loop
            turn_clock <= '1';
            tick_wait;
            turn_clock <= '0';
            tick_wait(BUNCH_COUNT-1);
        end loop;
    end process;

    -- Register control
    process
        procedure read_register(reg : natural) is
        begin
            read_strobe(reg) <= '1';
            tick_wait;
            read_strobe(reg) <= '0';
            wait until rising_edge(dsp_clk) and read_ack(reg) = '1';
        end;

        -- Readout bank
        procedure readout_bank is
        begin
            -- 8 words for each bunch pair
            for i in 0 to 8*BUNCH_COUNT-1 loop
                read_register(1);
            end loop;
        end;

        -- Switch bank
        procedure switch_bank is
        begin
            read_register(0);
        end;
    begin
        read_strobe <= "00";
        reset_event <= '0';

        -- To get things working we need to start by resetting both banks
        tick_wait(3);
        readout_bank;
        switch_bank;
        readout_bank;
        switch_bank;
        readout_bank;

        reset_event <= '1';
        tick_wait;
        reset_event <= '0';

        wait;
    end process;

end testbench;
