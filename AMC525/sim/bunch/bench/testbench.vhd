library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;
use work.bunch_defs.all;

use work.register_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal adc_clk : std_logic := '1';
    signal dsp_clk : std_logic := '0';

    constant TURN_COUNT : natural := 7;
    signal turn_clock : std_logic := '0';

    signal write_strobe : std_logic_vector(DSP_REGS_RANGE) := (others => '0');
    signal write_data : reg_data_t;
    signal write_ack : std_logic_vector(DSP_REGS_RANGE) := (others => '0');
    signal read_strobe : std_logic_vector(DSP_REGS_RANGE) := (others => '0');
    signal read_data : reg_data_array_t(DSP_REGS_RANGE);
    signal read_ack : std_logic_vector(DSP_REGS_RANGE) := (others => '0');

    signal bank_select : unsigned(1 downto 0) := "00";
    signal bunch_config : bunch_config_t;

    signal data_in : signed(15 downto 0) := X"0000";
    signal data_out : signed(23 downto 0);

    constant TAP_COUNT : natural := 16;
    constant HEADROOM_OFFSET : natural := 2;

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    process begin
        loop
            clk_wait(adc_clk, TURN_COUNT - 1);
            turn_clock <= '1';
            clk_wait(adc_clk);
            turn_clock <= '0';
        end loop;
        wait;
    end process;


    bunch_select : entity work.bunch_select port map (
        dsp_clk_i => dsp_clk,
        adc_clk_i => adc_clk,
        turn_clock_i => turn_clock,

        write_strobe_i => write_strobe(DSP_BUNCH_REGS),
        write_data_i => write_data,
        write_ack_o => write_ack(DSP_BUNCH_REGS),
        read_strobe_i => read_strobe(DSP_BUNCH_REGS),
        read_data_o => read_data(DSP_BUNCH_REGS),
        read_ack_o => read_ack(DSP_BUNCH_REGS),

        bank_select_i => bank_select,
        bunch_config_o => bunch_config
    );

    bunch_fir_top : entity work.bunch_fir_top generic map (
        TAP_COUNT => TAP_COUNT,
        HEADROOM_OFFSET => HEADROOM_OFFSET
    ) port map (
        dsp_clk_i => dsp_clk,
        adc_clk_i => adc_clk,

        data_i => data_in,
        data_o => data_out,

        turn_clock_i => turn_clock,
        bunch_config_i => bunch_config,

        write_strobe_i => write_strobe(DSP_FIR_REGS),
        write_data_i => write_data,
        write_ack_o => write_ack(DSP_FIR_REGS),
        read_strobe_i => read_strobe(DSP_FIR_REGS),
        read_data_o => read_data(DSP_FIR_REGS),
        read_ack_o => read_ack(DSP_FIR_REGS)
    );

    process (dsp_clk) begin
        if rising_edge(dsp_clk) then
            data_in <= data_in + 2;
        end if;
    end process;

    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure read_reg(reg : natural) is
        begin
            read_reg(dsp_clk, read_data, read_strobe, read_ack, reg);
        end;

        procedure clk_wait(ticks : natural := 1) is
        begin
            clk_wait(dsp_clk, ticks);
        end;

    begin
        clk_wait(10);

        -- Now write some taps
        write_reg(DSP_FIR_CONFIG_REG_W, X"00000000");  -- Bank 0
        write_reg(DSP_FIR_TAPS_REG, X"7FF00000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF10000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF20000");

        write_reg(DSP_FIR_CONFIG_REG_W, X"00000001");  -- Bank 1
        write_reg(DSP_FIR_TAPS_REG, X"7FF01000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF11000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF21000");

        write_reg(DSP_FIR_CONFIG_REG_W, X"00000002");  -- Bank 2
        write_reg(DSP_FIR_TAPS_REG, X"7FF02000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF12000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF22000");

        write_reg(DSP_FIR_CONFIG_REG_W, X"0000040F");  -- Bank 3, 16 decimation
        write_reg(DSP_FIR_TAPS_REG, X"7FF03000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF13000");
        write_reg(DSP_FIR_TAPS_REG, X"7FF23000");

        clk_wait(100);

        -- Configure banks with differing FIR selections
        write_reg(DSP_BUNCH_CONFIG_REG, X"00000000");
        write_reg(DSP_BUNCH_BANK_REG, X"00000000");
        write_reg(DSP_BUNCH_BANK_REG, X"00000000");
        write_reg(DSP_BUNCH_BANK_REG, X"00000001");
        write_reg(DSP_BUNCH_BANK_REG, X"00000001");
        write_reg(DSP_BUNCH_BANK_REG, X"00000002");
        write_reg(DSP_BUNCH_BANK_REG, X"00000002");
        write_reg(DSP_BUNCH_BANK_REG, X"00000003");

        wait;
    end process;

end;
