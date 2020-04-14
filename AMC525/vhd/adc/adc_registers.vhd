-- Register control for ADC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;

entity adc_registers is
    port (
        clk_i : in std_ulogic;

        write_strobe_i : in std_ulogic_vector(DSP_ADC_REGISTERS_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_ADC_REGISTERS_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_ADC_REGISTERS_REGS);
        read_data_o : out reg_data_array_t(DSP_ADC_REGISTERS_REGS);
        read_ack_o : out std_ulogic_vector(DSP_ADC_REGISTERS_REGS);

        mms_source_o : out std_ulogic_vector;
        dram_source_o : out std_ulogic_vector;
        reject_shift_o : out unsigned;

        input_limit_o : out unsigned;
        delta_limit_o : out unsigned;

        write_start_o : out std_ulogic;
        delta_reset_o : out std_ulogic;

        input_overflow_i : in std_ulogic;
        fir_overflow_i : in std_ulogic;
        delta_event_i : in std_ulogic
    );
end;

architecture arch of adc_registers is
    signal config_register : reg_data_t;
    signal limits_register : reg_data_t;
    signal command_bits : reg_data_t;
    signal event_bits : reg_data_t;

begin
    -- Configuration register.
    register_file : entity work.register_file port map (
        clk_i => clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_ADC_CONFIG_REG),
        write_strobe_i(1) => write_strobe_i(DSP_ADC_LIMITS_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_ADC_CONFIG_REG),
        write_ack_o(1) => write_ack_o(DSP_ADC_LIMITS_REG),
        register_data_o(0) => config_register,
        register_data_o(1) => limits_register
    );
    read_data_o(DSP_ADC_CONFIG_REG) <= (others => '0');
    read_ack_o(DSP_ADC_CONFIG_REG) <= '1';
    read_data_o(DSP_ADC_LIMITS_REG) <= (others => '0');
    read_ack_o(DSP_ADC_LIMITS_REG) <= '1';

    -- Command register: start write and reset limit
    command : entity work.strobed_bits port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(DSP_ADC_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_ADC_COMMAND_REG_W),
        strobed_bits_o => command_bits
    );

    -- Event detection register
    events : entity work.all_pulsed_bits port map (
        clk_i => clk_i,
        read_strobe_i => read_strobe_i(DSP_ADC_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_ADC_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_ADC_EVENTS_REG_R),
        pulsed_bits_i => event_bits
    );


    mms_source_o  <= config_register(DSP_ADC_CONFIG_MMS_SOURCE_BITS);
    dram_source_o <= config_register(DSP_ADC_CONFIG_DRAM_SOURCE_BITS);
    reject_shift_o <=
        unsigned(config_register(DSP_ADC_CONFIG_REJECT_SHIFT_BITS));

    input_limit_o <=
        unsigned(limits_register(DSP_ADC_LIMITS_THRESHOLD_BITS));
    delta_limit_o <=
        unsigned(limits_register(DSP_ADC_LIMITS_DELTA_BITS));

    write_start_o <= command_bits(DSP_ADC_COMMAND_WRITE_BIT);
    delta_reset_o <= command_bits(DSP_ADC_COMMAND_RESET_DELTA_BIT);

    event_bits <= (
        DSP_ADC_EVENTS_INP_OVF_BIT => input_overflow_i,
        DSP_ADC_EVENTS_FIR_OVF_BIT => fir_overflow_i,
        DSP_ADC_EVENTS_DELTA_BIT   => delta_event_i,
        others => '0'
    );
end;
