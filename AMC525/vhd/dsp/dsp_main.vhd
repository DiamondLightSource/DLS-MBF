-- Top level DSP coordinator: combines shared DSP control with two separate
-- channels of DSP processing.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.dsp_defs.all;

entity dsp_main is
    port (
        -- Clocking
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- External data in and out (on ADC clock)
        adc_data_i : in signed_array;
        dac_data_o : out signed_array;

        -- Register control interface (on DSP clock)
        write_strobe_i : in std_ulogic;
        write_address_i : in unsigned;
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic;
        read_strobe_i : in std_ulogic;
        read_address_i : in unsigned;
        read_data_o : out reg_data_t;
        read_ack_o : out std_ulogic;

        -- DRAM0 data and control (on DSP clock)
        dram0_capture_enable_o : out std_ulogic;
        dram0_data_ready_i : in std_ulogic;
        dram0_capture_address_i : in std_ulogic_vector;
        dram0_data_o : out std_ulogic_vector;
        dram0_data_valid_o : out std_ulogic;
        dram0_data_error_i : in std_ulogic;
        dram0_addr_error_i : in std_ulogic;
        dram0_brsp_error_i : in std_ulogic;

        -- DRAM1 data and control (on DSP clock)
        dram1_address_o : out unsigned;
        dram1_data_o : out std_ulogic_vector;
        dram1_data_valid_o : out std_ulogic;
        dram1_data_ready_i : in std_ulogic;
        dram1_brsp_error_i : in std_ulogic;

        -- External hardware events
        revolution_clock_i : in std_ulogic;
        event_trigger_i : in std_ulogic;
        postmortem_trigger_i : in std_ulogic;
        blanking_trigger_i : in std_ulogic;
        dsp_events_o : out std_ulogic_vector;

        interrupts_o : out std_ulogic_vector
    );
end;

architecture arch of dsp_main is
    constant ADDRESS_BITS : natural := write_address_i'LENGTH;
    subtype DECODE_RANGE is natural range ADDRESS_BITS-1 downto ADDRESS_BITS-2;
    subtype MAIN_ADDR_RANGE is natural range ADDRESS_BITS-3 downto 0;

    constant CTRL_REG : natural := 0;
    constant UNUSED_REG : natural := 1;
    constant DSP0_REG : natural := 2;

    -- Register ranges
    subtype MAIN_REG_RANGE is natural range 0 to 3;

    -- Incoming registers decoded into our four main blocks
    signal main_write_strobe : std_ulogic_vector(MAIN_REG_RANGE);
    signal main_write_address : unsigned(MAIN_ADDR_RANGE);
    signal main_write_data : reg_data_t;
    signal main_write_ack : std_ulogic_vector(MAIN_REG_RANGE);
    signal main_read_strobe : std_ulogic_vector(MAIN_REG_RANGE);
    signal main_read_address : unsigned(MAIN_ADDR_RANGE);
    signal main_read_data : reg_data_array_t(MAIN_REG_RANGE);
    signal main_read_ack : std_ulogic_vector(MAIN_REG_RANGE);

    -- Control block registers
    signal ctrl_write_strobe : std_ulogic_vector(CTRL_REGS_RANGE);
    signal ctrl_write_data : reg_data_t;
    signal ctrl_write_ack : std_ulogic_vector(CTRL_REGS_RANGE);
    signal ctrl_read_strobe : std_ulogic_vector(CTRL_REGS_RANGE);
    signal ctrl_read_data : reg_data_array_t(CTRL_REGS_RANGE);
    signal ctrl_read_ack : std_ulogic_vector(CTRL_REGS_RANGE);

    -- DSP control interface
    signal dsp_to_control : dsp_to_control_array_t;
    signal control_to_dsp : control_to_dsp_array_t;
    signal loopback : std_ulogic_vector(CHANNELS);
    signal output_enable : std_ulogic_vector(CHANNELS);

    signal dsp_events : dsp_events_o'SUBTYPE;

begin
    -- Demultiplex top two bits to our main components
    register_mux : entity work.register_mux port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i,
        write_address_i => write_address_i(DECODE_RANGE),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o,

        write_strobe_o => main_write_strobe,
        write_data_o => main_write_data,
        write_ack_i => main_write_ack,

        read_strobe_i => read_strobe_i,
        read_address_i => read_address_i(DECODE_RANGE),
        read_data_o => read_data_o,
        read_ack_o => read_ack_o,

        read_data_i => main_read_data,
        read_strobe_o => main_read_strobe,
        read_ack_i => main_read_ack
    );
    main_write_address <= write_address_i(MAIN_ADDR_RANGE);
    main_read_address <= read_address_i(MAIN_ADDR_RANGE);

    -- Unused register space
    main_write_ack(UNUSED_REG) <= '1';
    main_read_data(UNUSED_REG) <= (others => '0');
    main_read_ack(UNUSED_REG) <= '1';


    -- Register mapping for dsp control top
    ctrl_register_mux : entity work.register_mux port map (
        clk_i => dsp_clk_i,

        write_strobe_i => main_write_strobe(CTRL_REG),
        write_address_i => main_write_address,
        write_data_i => main_write_data,
        write_ack_o => main_write_ack(CTRL_REG),

        write_strobe_o => ctrl_write_strobe,
        write_data_o => ctrl_write_data,
        write_ack_i => ctrl_write_ack,

        read_strobe_i => main_read_strobe(CTRL_REG),
        read_address_i => main_read_address,
        read_data_o => main_read_data(CTRL_REG),
        read_ack_o => main_read_ack(CTRL_REG),

        read_data_i => ctrl_read_data,
        read_strobe_o => ctrl_read_strobe,
        read_ack_i => ctrl_read_ack
    );

    -- Top level control
    dsp_control_top : entity work.dsp_control_top port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => ctrl_write_strobe,
        write_data_i => ctrl_write_data,
        write_ack_o => ctrl_write_ack,
        read_strobe_i => ctrl_read_strobe,
        read_data_o => ctrl_read_data,
        read_ack_o => ctrl_read_ack,

        control_to_dsp_o => control_to_dsp,
        dsp_to_control_i => dsp_to_control,
        loopback_o => loopback,
        output_enable_o => output_enable,

        dram0_capture_enable_o => dram0_capture_enable_o,
        dram0_data_ready_i => dram0_data_ready_i,
        dram0_capture_address_i => dram0_capture_address_i,
        dram0_data_valid_o => dram0_data_valid_o,
        dram0_data_o => dram0_data_o,
        dram0_data_error_i => dram0_data_error_i,
        dram0_addr_error_i => dram0_addr_error_i,
        dram0_brsp_error_i => dram0_brsp_error_i,

        dram1_address_o => dram1_address_o,
        dram1_data_o => dram1_data_o,
        dram1_data_valid_o => dram1_data_valid_o,
        dram1_data_ready_i => dram1_data_ready_i,
        dram1_brsp_error_i => dram1_brsp_error_i,

        revolution_clock_i => revolution_clock_i,
        event_trigger_i => event_trigger_i,
        postmortem_trigger_i => postmortem_trigger_i,
        blanking_trigger_i => blanking_trigger_i,

        interrupts_o => interrupts_o
    );


    -- DSP control blocks
    dsp_gen : for c in CHANNELS generate
        signal dsp_write_strobe : std_ulogic_vector(DSP_REGS_RANGE);
        signal dsp_write_data : reg_data_t;
        signal dsp_write_ack : std_ulogic_vector(DSP_REGS_RANGE);
        signal dsp_read_strobe : std_ulogic_vector(DSP_REGS_RANGE);
        signal dsp_read_data : reg_data_array_t(DSP_REGS_RANGE);
        signal dsp_read_ack : std_ulogic_vector(DSP_REGS_RANGE);

        signal adc_data_in : adc_data_i(c)'SUBTYPE;
        signal dac_data_out : dac_data_o(c)'SUBTYPE;

    begin
        dsp_register_mux : entity work.register_mux port map (
            clk_i => dsp_clk_i,

            write_strobe_i => main_write_strobe(DSP0_REG + c),
            write_address_i => main_write_address,
            write_data_i => main_write_data,
            write_ack_o => main_write_ack(DSP0_REG + c),

            write_strobe_o => dsp_write_strobe,
            write_data_o => dsp_write_data,
            write_ack_i => dsp_write_ack,

            read_strobe_i => main_read_strobe(DSP0_REG + c),
            read_address_i => main_read_address,
            read_data_o => main_read_data(DSP0_REG + c),
            read_ack_o => main_read_ack(DSP0_REG + c),

            read_data_i => dsp_read_data,
            read_strobe_o => dsp_read_strobe,
            read_ack_i => dsp_read_ack
        );

        dsp_top : entity work.dsp_top port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,

            adc_data_i => adc_data_in,
            dac_data_o => dac_data_out,

            write_strobe_i => dsp_write_strobe,
            write_data_i => dsp_write_data,
            write_ack_o => dsp_write_ack,
            read_strobe_i => dsp_read_strobe,
            read_data_o => dsp_read_data,
            read_ack_o => dsp_read_ack,

            control_to_dsp_i => control_to_dsp(c),
            dsp_to_control_o => dsp_to_control(c),

            dsp_event_o => dsp_events(c)
        );

        -- Loopback enable for internal testing and output control
        dsp_loopback : entity work.dsp_loopback port map (
            adc_clk_i => adc_clk_i,

            loopback_i => loopback(c),
            output_enable_i => output_enable(c),

            adc_data_i => adc_data_i(c),
            dac_data_i => dac_data_out,

            adc_data_o => adc_data_in,
            dac_data_o => dac_data_o(c)
        );
    end generate;

    -- Stretch the DSP output event
    stretch_pulse : entity work.stretch_pulse generic map (
        WIDTH => dsp_events'LENGTH
    ) port map (
        clk_i => dsp_clk_i,
        pulse_i => dsp_events,
        pulse_o => dsp_events_o
    );
end;
