-- Register interface for Tune PLL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.nco_defs.all;

entity tune_pll_registers is
    port (
        dsp_clk_i : in std_ulogic;

        -- Register interface
        write_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);
        read_data_o : out reg_data_array_t(DSP_TUNE_PLL_CONTROL_REGS);
        read_ack_o : out std_ulogic_vector(DSP_TUNE_PLL_CONTROL_REGS);

        -- NCO control
        nco_gain_o : out unsigned(3 downto 0);
        nco_enable_o : out std_ulogic;
        nco_freq_i : in angle_t;

        -- Detector control and status
        bunch_start_write_o : out std_ulogic;
        bunch_write_strobe_o : out std_ulogic;
        data_select_o : out std_logic_vector(1 downto 0);
        detector_shift_o : out unsigned(1 downto 0);
        detector_overflow_i : in std_ulogic;

        -- Feedback control and status
        target_phase_o : out signed(17 downto 0);
        integral_o : out signed(24 downto 0);
        proportional_o : out signed(24 downto 0);
        magnitude_limit_o : out unsigned(31 downto 0);
        offset_limit_o : out signed(31 downto 0);
        base_frequency_o : out angle_t;
        set_frequency_o : out std_ulogic;
        magnitude_error_i : in std_ulogic;
        offset_error_i : in std_ulogic;

        -- Top level control
        dwell_time_o : out unsigned(11 downto 0);
        enable_feedback_i : in std_ulogic;
        stop_stop_i : in std_ulogic;
        stop_detector_overflow_i : in std_ulogic;
        stop_magnitude_error_i : in std_ulogic;
        stop_offset_error_i : in std_ulogic
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
        clk_i => dsp_clk_i,
        write_strobe_i => write_strobe_i(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        read_strobe_i => read_strobe_i(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        read_data_o => read_data_o(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        read_ack_o => read_ack_o(DSP_TUNE_PLL_CONTROL_NCO_FREQ_REGS),
        nco_freq_i => nco_freq_i,
        nco_freq_o => base_frequency_o,
        reset_phase_o => open,
        write_freq_o => set_frequency_o
    );


    -- Fixed register settings
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
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
            write_strobe_i(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_TUNE_PLL_CONTROL_CONFIG_REG_W),
        write_ack_o(1) => write_ack_o(DSP_TUNE_PLL_CONTROL_TARGET_PHASE_REG),
        write_ack_o(2) => write_ack_o(DSP_TUNE_PLL_CONTROL_INTEGRAL_REG),
        write_ack_o(3) => write_ack_o(DSP_TUNE_PLL_CONTROL_PROPORTIONAL_REG),
        write_ack_o(4) => write_ack_o(DSP_TUNE_PLL_CONTROL_MIN_MAGNITUDE_REG),
        write_ack_o(5) =>
            write_ack_o(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG),
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
    read_data_o(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG) <= (others => '0');
    read_ack_o(DSP_TUNE_PLL_CONTROL_MAX_OFFSET_ERROR_REG) <= '1';

    data_select_o <= config_register(DSP_TUNE_PLL_CONTROL_CONFIG_SELECT_BITS);
    detector_shift_o <= unsigned(
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_DET_SHIFT_BITS));
    nco_gain_o <= unsigned(
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_NCO_GAIN_BITS));
    nco_enable_o <=
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_NCO_ENABLE_BIT);
    dwell_time_o <= unsigned(
        config_register(DSP_TUNE_PLL_CONTROL_CONFIG_DWELL_TIME_BITS));

    status_register <= (
        DSP_TUNE_PLL_CONTROL_STATUS_RUNNING_BIT => enable_feedback_i,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_STOP_BIT => stop_stop_i,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_OVERFLOW_BIT =>
            stop_detector_overflow_i,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_MAGNITUDE_BIT =>
            stop_magnitude_error_i,
        DSP_TUNE_PLL_CONTROL_STATUS_STOP_OFFSET_BIT => stop_offset_error_i,
        others => '0'
    );

    target_phase_o <= signed(target_phase_register(31 downto 14));
    integral_o <= signed(integral_register(31 downto 7));
    proportional_o <= signed(proportional_register(31 downto 7));
    magnitude_limit_o <= unsigned(mag_limit_register);
    offset_limit_o <= signed(offset_limit_register);


    -- Event sensing bits
    events : entity work.all_pulsed_bits port map (
        clk_i => dsp_clk_i,
        read_strobe_i => read_strobe_i(DSP_TUNE_PLL_CONTROL_EVENTS_REG_R),
        read_data_o => read_data_o(DSP_TUNE_PLL_CONTROL_EVENTS_REG_R),
        read_ack_o => read_ack_o(DSP_TUNE_PLL_CONTROL_EVENTS_REG_R),
        pulsed_bits_i => event_bits
    );

    event_bits <= (
        DSP_TUNE_PLL_CONTROL_EVENTS_DET_OVFL_BIT => detector_overflow_i,
        DSP_TUNE_PLL_CONTROL_EVENTS_MAG_ERROR_BIT => magnitude_error_i,
        DSP_TUNE_PLL_CONTROL_EVENTS_OFFSET_ERROR_BIT => offset_error_i,
        others => '0'
    );


    -- Pulsed command bits
    command : entity work.strobed_bits port map (
        clk_i => dsp_clk_i,
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
