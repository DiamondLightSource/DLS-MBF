library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

entity dsp_main is
    port (
        -- Clocking
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- External data in and out (on ADC clock)
        adc_data_i : in signed_array;
        dac_data_o : out signed_array;

        -- Register control interface (on DSP clock)
        write_strobe_i : in std_logic;
        write_address_i : in unsigned;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        read_strobe_i : in std_logic;
        read_address_i : in unsigned;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic;

        -- DRAM0 data and control (on DSP clock)
        dram0_capture_enable_o : out std_logic;
        dram0_data_ready_i : in std_logic;
        dram0_capture_address_i : in std_logic_vector;
        dram0_data_o : out std_logic_vector;
        dram0_data_valid_o : out std_logic;
        dram0_data_error_i : in std_logic;
        dram0_addr_error_i : in std_logic;
        dram0_brsp_error_i : in std_logic;

        -- DRAM1 data and control (on DSP clock)
        dram1_address_o : out unsigned;
        dram1_data_o : out std_logic_vector;
        dram1_data_valid_o : out std_logic;
        dram1_data_ready_i : in std_logic;
        dram1_brsp_error_i : in std_logic;

        -- External hardware events
        revolution_clock_i : in std_logic;
        event_trigger_i : in std_logic;
        postmortem_trigger_i : in std_logic;
        blanking_trigger_i : in std_logic;
        dsp_events_o : out std_logic_vector;

        interrupts_o : out std_logic_vector
    );
end;

architecture arch of dsp_main is
begin
end;
