library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.min_max_sum_defs.all;

entity testbench is
end testbench;

architecture arch of testbench is
    procedure clk_wait(signal clk_i : in std_logic; count : in natural := 1) is
        variable i : natural;
    begin
        for i in 0 to count-1 loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;


    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';


    procedure tick_wait(count : natural) is
    begin
        clk_wait(dsp_clk, count);
    end procedure;

    procedure tick_wait is
    begin
        clk_wait(dsp_clk, 1);
    end procedure;

    signal turn_clock : std_logic;

    signal adc_data_raw : signed(15 downto 0) := (others => '0');
    signal adc_data : signed(15 downto 0) := (others => '0');

    signal limit : unsigned(15 downto 0);
    signal limit_event : std_logic;
    signal reset_event : std_logic;
    signal read_strobe : std_logic_vector(0 to 1);
    signal read_data : reg_data_array_t(0 to 1);
    signal read_ack : std_logic_vector(0 to 1);
    signal delta : unsigned(15 downto 0);
    signal overflow : std_logic;

    constant BUNCH_COUNT : natural := 12;   -- A very small ring!

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;


    -- Device under test
    min_max_sum_inst : entity work.min_max_sum generic map (
        ADDR_BITS => 4
    ) port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        turn_clock_i => turn_clock,
        data_i => adc_data,
        delta_o => delta,
        overflow_o => overflow,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack
    );

    min_max_limit_inst : entity work.min_max_limit port map (
        adc_clk_i => adc_clk,
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
            if adc_data_raw = 0 then
                adc_data_raw <= to_signed(BUNCH_COUNT-1, 16);
            else
                adc_data_raw <= adc_data_raw - 1;
            end if;

            case adc_data_raw is
                when X"0000" => adc_data <= (others => '0');
                when X"0001" => adc_data <= X"7FFF";
                when X"0002" => adc_data <= X"8000";
                when others  => adc_data <= adc_data_raw - 5;
            end case;
        end if;
    end process;

    -- Turn clock
    process begin
        turn_clock <= '0';
        loop
            clk_wait(adc_clk, BUNCH_COUNT-1);
            turn_clock <= '1';
            clk_wait(adc_clk);
            turn_clock <= '0';
        end loop;
    end process;


    -- Register control and bank readout
    process
        variable read_result : reg_data_t;

        procedure read_register(reg : natural) is
        begin
            read_strobe(reg) <= '1';
            tick_wait;
            read_strobe(reg) <= '0';
            wait until rising_edge(dsp_clk) and read_ack(reg) = '1';
            read_result := read_data(reg);
        end;

        -- Readout bank
        procedure readout_bank is
            variable min : std_logic_vector(15 downto 0);
            variable max : std_logic_vector(15 downto 0);
            variable sum : std_logic_vector(31 downto 0);
            variable sum2 : std_logic_vector(47 downto 0);
        begin
            -- 4 words for each bunch
            for i in 0 to BUNCH_COUNT-1 loop
                read_register(1);
                min := read_result(15 downto 0);
                max := read_result(31 downto 16);
                read_register(1);
                sum := read_result;
                read_register(1);
                sum2(31 downto 0) := read_result;
                read_register(1);
                sum2(47 downto 32) := read_result(15 downto 0);

                report "bunch[" & integer'image(i) & "] = { " &
                    to_hstring(min) & ", " & to_hstring(max) & "; " &
                    to_hstring(sum) & ", " & to_hstring(sum2) & " }";
            end loop;
        end;

        -- Switch bank
        procedure switch_bank is
        begin
            read_register(0);
            report "switch: frame count = " &
                to_hstring(read_result(28 downto 0)) &
                ", count_ovfl = " &
                std_logic'image(read_result(29)) &
                ", sum_ovfl = " &
                std_logic'image(read_result(30)) &
                ", sum2_ovfl = " &
                std_logic'image(read_result(31));
        end;
    begin
        read_strobe <= "00";
        tick_wait(10);      -- Wait for clocking to settle

        -- Loop alternately reading out banks.
        loop
            report "---------------------------------------------------------";
            switch_bank;
            readout_bank;
        end loop;
        wait;
    end process;


    -- Limit detection
    process begin
        reset_event <= '0';
        tick_wait(200);
        reset_event <= '1';
        tick_wait;
        reset_event <= '0';
        wait;
    end process;

end;
