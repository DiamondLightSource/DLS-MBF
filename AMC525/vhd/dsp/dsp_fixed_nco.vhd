-- Interfacing to fixed frequency NCOs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.dsp_defs.all;
use work.bunch_defs.all;
use work.nco_defs.all;

entity dsp_fixed_nco is
    port (
        -- Clocking
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;

        -- Register control interface (clocked by dsp_clk_i)
        write_strobe_i : in std_ulogic_vector(DSP_FIXED_NCO_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_FIXED_NCO_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_FIXED_NCO_REGS);
        read_data_o : out reg_data_array_t(DSP_FIXED_NCO_REGS);
        read_ack_o : out std_ulogic_vector(DSP_FIXED_NCO_REGS);

        tune_pll_offset_i : in signed;
        nco1_data_o : out dsp_nco_to_mux_t;
        nco2_data_o : out dsp_nco_to_mux_t
    );
end;

architecture arch of dsp_fixed_nco is
    signal nco1_register : reg_data_t;
    signal nco2_register : reg_data_t;

    signal enable_pll : std_ulogic_vector(1 to 2);
    signal set_frequency : unsigned_array(1 to 2)(angle_t'RANGE);
    signal reset_phase : std_ulogic_vector(1 to 2);
    type cos_sin_array_t is array(1 to 2) of cos_sin_18_t;
    signal nco_out : cos_sin_array_t;

begin
    -- Register interface to control settings
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_FIXED_NCO_NCO1_REG),
        write_strobe_i(1) => write_strobe_i(DSP_FIXED_NCO_NCO2_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_FIXED_NCO_NCO1_REG),
        write_ack_o(1) => write_ack_o(DSP_FIXED_NCO_NCO2_REG),
        register_data_o(0) => nco1_register,
        register_data_o(1) => nco2_register
    );
    read_data_o(DSP_FIXED_NCO_NCO1_REG) <= (others => '0');
    read_ack_o(DSP_FIXED_NCO_NCO1_REG) <= '1';
    read_data_o(DSP_FIXED_NCO_NCO2_REG) <= (others => '0');
    read_ack_o(DSP_FIXED_NCO_NCO2_REG) <= '1';

    nco1_data_o.gain <= unsigned(nco1_register(DSP_FIXED_NCO_NCO1_GAIN_BITS));
    nco1_data_o.enable <= nco1_register(DSP_FIXED_NCO_NCO1_ENABLE_BIT);
    enable_pll(1) <= nco1_register(DSP_FIXED_NCO_NCO1_ENA_TUNE_PLL_BIT);

    nco2_data_o.gain <= unsigned(nco1_register(DSP_FIXED_NCO_NCO2_GAIN_BITS));
    nco2_data_o.enable <= nco2_register(DSP_FIXED_NCO_NCO2_ENABLE_BIT);
    enable_pll(2) <= nco2_register(DSP_FIXED_NCO_NCO2_ENA_TUNE_PLL_BIT);


    -- NCO base frequency setting
    set_nco1_freq : entity work.nco_register port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_FIXED_NCO_NCO1_FREQ_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_FIXED_NCO_NCO1_FREQ_REGS),
        read_strobe_i => read_strobe_i(DSP_FIXED_NCO_NCO1_FREQ_REGS),
        read_data_o => read_data_o(DSP_FIXED_NCO_NCO1_FREQ_REGS),
        read_ack_o => read_ack_o(DSP_FIXED_NCO_NCO1_FREQ_REGS),

        nco_freq_i => set_frequency(1),
        nco_freq_o => set_frequency(1),
        reset_phase_o => reset_phase(1),
        write_freq_o => open
    );

    set_nco2_freq : entity work.nco_register port map (
        clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_FIXED_NCO_NCO2_FREQ_REGS),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_FIXED_NCO_NCO2_FREQ_REGS),
        read_strobe_i => read_strobe_i(DSP_FIXED_NCO_NCO2_FREQ_REGS),
        read_data_o => read_data_o(DSP_FIXED_NCO_NCO2_FREQ_REGS),
        read_ack_o => read_ack_o(DSP_FIXED_NCO_NCO2_FREQ_REGS),

        nco_freq_i => set_frequency(2),
        nco_freq_o => set_frequency(2),
        reset_phase_o => reset_phase(2),
        write_freq_o => open
    );


    -- NCOs and frequency offset management
    gen_nco : for i in 1 to 2 generate
        signal nco_frequency : angle_t;
        signal reset_phase_out : std_ulogic;

    begin
        -- Add offset to computed frequency if required
        add_offset : entity work.tune_pll_offset port map (
            clk_i => dsp_clk_i,
            freq_offset_i => tune_pll_offset_i,
            enable_i => enable_pll(i),
            freq_i => set_frequency(i),
            freq_o => nco_frequency
        );

        -- Align phase reset with frequency setting
        phase_delay : entity work.dlyline generic map (
            DLY => 2
        ) port map (
            clk_i => dsp_clk_i,
            data_i(0) => reset_phase(i),
            data_o(0) => reset_phase_out
        );

        nco : entity work.nco port map (
            adc_clk_i => adc_clk_i,
            dsp_clk_i => dsp_clk_i,
            phase_advance_i => nco_frequency,
            reset_phase_i => reset_phase_out,
            cos_sin_o => nco_out(i)
        );
    end generate;

    nco1_data_o.nco <= nco_out(1);
    nco2_data_o.nco <= nco_out(2);
end;
