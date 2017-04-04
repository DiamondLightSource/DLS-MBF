-- Interface to detector bunch selection

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity detector_bunch_select is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;
        turn_clock_i : in std_logic;

        -- Register write interface
        start_write_i : in std_logic;
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;

        -- Bunch enable output
        bunch_enable_o : out std_logic
    );
end;

architecture arch of detector_bunch_select is
    -- We read a bit at a time, but write 32 bits at a time, so there are 5
    -- fewer write than read addresses
    signal read_address : bunch_count_t := (others => '0');
    signal write_address : unsigned(read_address'LEFT-5 downto 0);

begin
    bunch_mem : entity work.detector_bunch_mem port map (
        write_clk_i => dsp_clk_i,
        write_addr_i => write_address,
        write_data_i => write_data_i,
        write_strobe_i => write_strobe_i,

        read_clk_i => adc_clk_i,
        read_addr_i => read_address,
        read_data_o => bunch_enable_o
    );


    process (adc_clk_i) begin
        if rising_edge(adc_clk_i) then
            if turn_clock_i = '1' then
                read_address <= (others => '0');
            else
                read_address <= read_address + 1;
            end if;
        end if;
    end process;


    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if start_write_i = '1' then
                write_address <= (others => '0');
            elsif write_strobe_i = '1' then
                write_address <= write_address + 1;
            end if;
        end if;
    end process;
end;
