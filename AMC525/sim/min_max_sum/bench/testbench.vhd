library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

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
    signal bunch_reset : std_logic;

    signal adc_data_raw : signed(15 downto 0) := (others => '0');
    signal adc_data : signed(15 downto 0);

    signal limit : unsigned(15 downto 0);
    signal limit_event : std_logic;
    signal reset_event : std_logic;
    signal count_read_strobe : std_logic;
    signal count_read_data : reg_data_t;
    signal count_read_ack : std_logic;
    signal mms_read_strobe : std_logic;
    signal mms_read_data : reg_data_t;
    signal mms_read_ack : std_logic;
    signal dsp_data : signed_array(CHANNELS)(15 downto 0);
    signal delta : unsigned_array(CHANNELS)(15 downto 0);

    constant BUNCH_COUNT : natural := 12;   -- A very small ring!

begin

    -- ADC and DSP clocks with phase generator
    clocks_inst : entity work.clocks port map (
        adc_clk_o => adc_clk,
        dsp_clk_o => dsp_clk,
        adc_phase_o => adc_phase
    );

    -- Split the data into the two working channels ("DSP data")
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
        bunch_reset_i => bunch_reset,
        data_i => dsp_data,
        delta_o => delta,
        count_read_strobe_i => count_read_strobe,
        count_read_data_o => count_read_data,
        count_read_ack_o => count_read_ack,
        mms_read_strobe_i => mms_read_strobe,
        mms_read_data_o => mms_read_data,
        mms_read_ack_o => mms_read_ack
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

            if bunch_reset = '1' and adc_phase = '1' then
                adc_data <= (others => 'X');
            else
                adc_data <= adc_data_raw;
            end if;
        end if;
    end process;

    -- Bunch counter.
    process begin
        bunch_reset <= '0';
        tick_wait(2);
        loop
            bunch_reset <= '1';
            tick_wait;
            bunch_reset <= '0';
            tick_wait(BUNCH_COUNT-1);
        end loop;
    end process;

    -- Register control
    process
        -- Readout bank
        procedure readout_bank is
        begin
            for i in 0 to 4*BUNCH_COUNT-1 loop
                mms_read_strobe <= '1';
                tick_wait;
                mms_read_strobe <= '0';
                wait until rising_edge(dsp_clk) and mms_read_ack = '1';
            end loop;
        end;

        -- Switch bank
        procedure switch_bank is
        begin
            count_read_strobe <= '1';
            tick_wait;
            count_read_strobe <= '0';
            wait until rising_edge(dsp_clk) and count_read_ack = '1';
        end;
    begin
        count_read_strobe <= '0';
        mms_read_strobe <= '0';
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
