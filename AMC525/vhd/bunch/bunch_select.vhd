-- Bunch counter, turn clock, and detector bunch selection strobes

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.register_defs.all;
use work.bunch_defs.all;

entity bunch_select is
    port (
        adc_clk_i : in std_ulogic;
        dsp_clk_i : in std_ulogic;
        turn_clock_i : in std_ulogic;       -- Revolution clock

        -- Bunch configuration SBC interface for writing configuration
        write_strobe_i : in std_ulogic_vector(DSP_BUNCH_REGS);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(DSP_BUNCH_REGS);
        read_strobe_i : in std_ulogic_vector(DSP_BUNCH_REGS);
        read_data_o : out reg_data_array_t(DSP_BUNCH_REGS);
        read_ack_o : out std_ulogic_vector(DSP_BUNCH_REGS);

        -- Bunch configuration readout
        bank_select_i : in unsigned(1 downto 0);       -- Current bunch bank
        bunch_config_o : out bunch_config_t
    );
end;

architecture arch of bunch_select is
    signal config_register : reg_data_t;

    signal write_start : std_ulogic;
    signal write_bank : unsigned(BUNCH_BANK_BITS-1 downto 0);

    signal bunch_index : bunch_count_t := (others => '0');
    signal bunch_config : std_ulogic_vector(BUNCH_CONFIG_BITS-1 downto 0);
    signal config_out : std_ulogic_vector(BUNCH_CONFIG_BITS-1 downto 0);

begin
    -- Register management
    register_file : entity work.register_file port map (
        clk_i => dsp_clk_i,
        write_strobe_i(0) => write_strobe_i(DSP_BUNCH_CONFIG_REG),
        write_data_i => write_data_i,
        write_ack_o(0) => write_ack_o(DSP_BUNCH_CONFIG_REG),
        register_data_o(0) => config_register
    );

    read_data_o <= (read_data_o'RANGE => (others => '0'));
    read_ack_o <= (read_ack_o'RANGE => '1');

    write_start <= write_strobe_i(DSP_BUNCH_CONFIG_REG);
    write_bank <= unsigned(config_register(1 downto 0));


    -- Bunch counter
    bunch_counter : entity work.bunch_counter port map (
        clk_i => adc_clk_i,
        turn_clock_i => turn_clock_i,
        bunch_index_o => bunch_index
    );

    -- Bunch bank memory
    bunch_store : entity work.bunch_store port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,

        write_strobe_i => write_strobe_i(DSP_BUNCH_BANK_REG),
        write_data_i => write_data_i,
        write_ack_o => write_ack_o(DSP_BUNCH_BANK_REG),
        write_start_i => write_start,
        write_bank_i => write_bank,

        bank_select_i => bank_select_i,
        bunch_index_i => bunch_index,
        config_o => bunch_config
    );

    -- Pipeline the bunch configuration
    bunch_delay : entity work.dlyreg generic map (
        DLY => 4,
        DW  => BUNCH_CONFIG_BITS
    ) port map (
       clk_i => adc_clk_i,
       data_i => bunch_config,
       data_o => config_out
    );

    bunch_config_o.fir_select <=
        unsigned(config_out(DSP_BUNCH_BANK_FIR_SELECT_BITS));
    bunch_config_o.gain <=
        signed(config_out(DSP_BUNCH_BANK_GAIN_BITS));
    bunch_config_o.fir_enable <=
        config_out(DSP_BUNCH_BANK_FIR_ENABLE_BIT);
    bunch_config_o.nco_0_enable <=
        config_out(DSP_BUNCH_BANK_NCO0_ENABLE_BIT);
    bunch_config_o.nco_1_enable <=
        config_out(DSP_BUNCH_BANK_NCO1_ENABLE_BIT);
end;
