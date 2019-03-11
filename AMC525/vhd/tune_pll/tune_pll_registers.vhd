-- Register interface for Tune PLL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;

use work.tune_pll_defs.all;

entity tune_pll_registers is
    port (
        clk_i : in std_ulogic;

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        read_data_o : out reg_data_array_t(DSP_TUNE_PLL_CONTROL_REGS);
        read_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);

        -- Structured config and status
        config_o : out tune_pll_config_t;
        status_i : in tune_pll_status_t;

        -- Readback of full NCO frequency
        nco_freq_i : in angle_t;
        -- Set when NCO frequency changed
        set_frequency_o : out std_ulogic;

        -- Detector bunch memory interface
        bunch_start_write_o : out std_ulogic;
        bunch_write_strobe_o : out std_ulogic
    );
end;

architecture arch of tune_pll_registers is
    signal config_register : reg_data_t;
    signal status_register : reg_data_t;
    signal target_phase_register : reg_data_t;
    signal integral_register : reg_data_t;
    signal proportional_register : reg_data_t;
    signal mag_limit_register : reg_data_t;
    signal offset_limit_register : reg_data_t;
    signal event_bits : reg_data_t;
    signal command_bits : reg_data_t;

begin
    -- Setting base NCO frequency
    nco_register : entity work.nco_register port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        read_strobe_i => read_strobe_i(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        read_data_o => read_data_o(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        read_ack_o => read_ack_o(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        nco_freq_i => nco_freq_i,
        nco_freq_o => config_o.base_frequency,
        reset_phase_o => config_o.nco_reset,
        write_freq_o => set_frequency_o
    );


    -- Fixed register settings
    register_file : entity work.register_file port map (
        clk_i => clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_TUNE_PLL_CONTROL_CONFIG_REG_W),
        write_strobe_i(1) =>
            write_strobe_i(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG),
        write_strobe_i(2) =>
            write_strobe_i(DSP_TUNE_PLL_CONTROL_INTEGRAL_REG),
        write_strobe_i(3) =>
            write_strobe_i(DSP_TUNE_PLL_CONTROL_PROPORTIONAL_REG),
        write_strobe_i(4) =>
            write_strobe_i(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG),
        write_strobe_i(5) =>
            write_strobe_i(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG_W),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_TUNE_PLL_CONTROL_CONFIG_REG_W),
        write_ack_o(1) => write_ack_o(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG),
        write_ack_o(2) => write_ack_o(DSP_TUNE_PLL_CONTROL_INTEGRAL_REG),
        write_ack_o(3) => write_ack_o(DSP_TUNE_PLL_CONTROL_PROPORTIONAL_REG),
        write_ack_o(4) => write_ack_o(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG),
        write_ack_o(5) =>
            write_ack_o(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG_W),
        register_data_o(0) => config_register,
        register_data_o(1) => target_phase_register,
        register_data_o(2) => integral_register,
        register_data_o(3) => proportional_register,
        register_data_o(4) => mag_limit_register,
        register_data_o(5) => offset_limit_register
    );

    read_data_o(DSP_TUNE_PLL_CONTROL_STATUS_REG_R) <= status_register;
    read_ack_o(DSP_TUNE_PLL_CONTROL_STATUS_REG_R) <= '1';

    read_data_o(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG) <= (others => '0');
    read_ack_o(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG) <= '1';

    read_data_o(DSP_TUNE_PLL_CONTROL_INTEGRAL_REG) <= (others => '0');
    read_ack_o(DSP_TUNE_PLL_CONTROL_INTEGRAL_REG) <= '1';
    read_data_o(DSP_TUNE_PLL_CONTROL_PROPORTIONAL_REG) <= (others => '0');
    read_ack_o(DSP_TUNE_PLL_CONTROL_PROPORTIONAL_REG) <= '1';

    read_data_o(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG) <= (others => '0');
    read_ack_o(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG) <= '1';

    read_data_o(DSP_TUNE_PLL_CONTROL_FILTERED_OFFSET_REG_R) <=
        std_ulogic_vector(status_i.filtered_frequency_offset);
    read_ack_o(DSP_TUNE_PLL_CONTROL_FILTERED_OFFSET_REG_R) <= '1';

    config_o.data_select <=
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_SELECT_BITS);
    config_o.detector_shift <= unsigned(
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_DET_SHIFT_BITS));
    config_o.nco_gain <= unsigned(
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_NCO_GAIN_BITS));
    config_o.nco_enable <=
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_NCO_ENABLE_BIT);
    config_o.filter_cordic <=
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_FILTER_CORDIC_BIT);
    config_o.capture_cordic <=
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_CAPTURE_CORDIC_BIT);
    config_o.dwell_time <= unsigned(
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_DWELL_TIME_BITS));
    config_o.offset_override <=
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_OFFSET_OVERRIDE_BIT);

    status_register <= (
        DSP_TUNE_PLL_CONTROL_STATUS_RUNNING_BIT =>
            status_i.enable_feedback,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_STOP_BIT =>
            status_i.stop_stop,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_OVERFLOW_BIT =>
            status_i.stop_detector_overflow,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_MAGNITUDE_BIT =>
            status_i.stop_magnitude_error,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_OFFSET_BIT =>
            status_i.stop_offset_error,
        others => '0'
    );

    config_o.target_phase <= signed(target_phase_register(31 downto 14));
    config_o.integral <= signed(integral_register(31 downto 7));
    config_o.proportional <= signed(proportional_register(31 downto 7));
    config_o.magnitude_limit <= unsigned(mag_limit_register);
    config_o.offset_limit <= signed(offset_limit_register);
    config_o.debug_offset <= signed(proportional_register);

    read_data_o(DSP_TUNE_PLL_CONTROL_FILTERED_I_REG) <=
        std_ulogic_vector(status_i.filtered_iq.cos);
    read_ack_o(DSP_TUNE_PLL_CONTROL_FILTERED_I_REG) <= '1';
    write_ack_o(DSP_TUNE_PLL_CONTROL_FILTERED_I_REG) <= '1';

    read_data_o(DSP_TUNE_PLL_CONTROL_FILTERED_Q_REG) <=
        std_ulogic_vector(status_i.filtered_iq.sin);
    read_ack_o(DSP_TUNE_PLL_CONTROL_FILTERED_Q_REG) <= '1';
    write_ack_o(DSP_TUNE_PLL_CONTROL_FILTERED_Q_REG) <= '1';

    -- Event sensing bits
    events : entity work.all_pulsed_bits port map (
        clk_i => clk_i,
        read_strobe_i => read_strobe_i(DSP_TUNE_PLL_CONTROL_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_TUNE_PLL_CONTROL_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_TUNE_PLL_CONTROL_EVENTS_REG_R),
        pulsed_bits_i => event_bits
    );

    event_bits <= (
        DSP_TUNE_PLL_CONTROL_EVENTS_DET_OVFL_BIT => status_i.detector_overflow,
        DSP_TUNE_PLL_CONTROL_EVENTS_MAG_ERROR_BIT => status_i.magnitude_error,
        DSP_TUNE_PLL_CONTROL_EVENTS_OFFSET_ERROR_BIT => status_i.offset_error,
        others => '0'
    );


    -- Pulsed command bits
    command : entity work.strobed_bits port map (
        clk_i => clk_i,
        write_strobe_i => write_strobe_i(DSP_TUNE_PLL_CONTROL_COMMAND_REG_W),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_TUNE_PLL_CONTROL_COMMAND_REG_W),
        strobed_bits_o => command_bits
    );

    bunch_start_write_o <=
        command_bits(DSP_TUNE_PLL_CONTROL_COMMAND_WRITE_BUNCH_BIT);


    -- Pass the bunch memory write strobe straight through
    bunch_write_strobe_o <= write_strobe_i(DSP_TUNE_PLL_CONTROL_BUNCH_REG);
    write_ack_o(DSP_TUNE_PLL_CONTROL_BUNCH_REG) <= '1';
    read_data_o(DSP_TUNE_PLL_CONTROL_BUNCH_REG) <= (others => '0');
    read_ack_o(DSP_TUNE_PLL_CONTROL_BUNCH_REG) <= '1';
end;
