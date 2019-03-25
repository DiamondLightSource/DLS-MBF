library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.nco_defs.all;
use work.detector_defs.all;
use work.register_defs.all;

use work.sim_support.all;

entity testbench is
end testbench;

architecture arch of testbench is
    signal adc_clk : std_ulogic := '1';
    signal dsp_clk : std_ulogic := '0';
    signal turn_clock : std_ulogic;

    constant TURN_COUNT : natural := 33;

    -- detector_top parameters
    signal write_strobe : std_ulogic_vector(DSP_DET_REGS);
    signal write_data : reg_data_t;
    signal write_ack : std_ulogic_vector(DSP_DET_REGS);
    signal read_strobe : std_ulogic_vector(DSP_DET_REGS);
    signal read_data : reg_data_array_t(DSP_DET_REGS);
    signal read_ack : std_ulogic_vector(DSP_DET_REGS);
    signal adc_data : signed(15 downto 0);
    signal adc_fill_reject : signed(15 downto 0);
    signal fir_data : signed(35 downto 0);
    signal nco_iq : cos_sin_18_t;
    signal window : signed(17 downto 0);
    signal start : std_ulogic;
    signal write : std_ulogic;
    signal mem_valid : std_ulogic;
    signal mem_ready : std_ulogic;
    signal mem_addr : unsigned(19 downto 0);
    signal mem_data : std_ulogic_vector(63 downto 0);

begin
    adc_clk <= not adc_clk after 1 ns;
    dsp_clk <= not dsp_clk after 2 ns;

    -- Turn clock
    process begin
        turn_clock <= '0';
        loop
            clk_wait(adc_clk, TURN_COUNT-1);
            turn_clock <= '1';
            clk_wait(adc_clk);
            turn_clock <= '0';
        end loop;
        wait;
    end process;

    nco_iq.cos <= 18X"1FFFF";
    nco_iq.sin <= 18X"1FFFF";

    adc_data <= 16X"1234";
    fir_data <= 36X"123456789";
    window <= 18X"1FFFF";


    detector : entity work.detector_top generic map (
        DATA_IN_BUFFER_LENGTH => 2,
        DATA_BUFFER_LENGTH => 2,
        NCO_BUFFER_LENGTH => 2,
        MEMORY_BUFFER_LENGTH => 2,
        CONTROL_BUFFER_LENGTH => 2
    ) port map (
        adc_clk_i => adc_clk,
        dsp_clk_i => dsp_clk,
        turn_clock_i => turn_clock,
        write_strobe_i => write_strobe,
        write_data_i => write_data,
        write_ack_o => write_ack,
        read_strobe_i => read_strobe,
        read_data_o => read_data,
        read_ack_o => read_ack,
        adc_data_i => adc_data,
        adc_fill_reject_i => adc_fill_reject,
        fir_data_i => fir_data,
        nco_iq_i => nco_iq,
        window_i => window,
        start_i => start,
        write_i => write,
        mem_valid_o => mem_valid,
        mem_ready_i => mem_ready,
        mem_addr_o => mem_addr,
        mem_data_o => mem_data
    );


    -- Generate cycles of capture
    process begin
        start <= '0';
        write <= '0';

        clk_wait(adc_clk, 2);
        start <= '1';
        clk_wait(adc_clk);
        start <= '0';

        loop
            clk_wait(adc_clk, 10);
            start <= '1';
            write <= '1';
            clk_wait(adc_clk);
            start <= '0';
            write <= '0';
        end loop;

        wait;
    end process;


    -- Memory consumer
    process
        procedure receive is
        begin
            receive_mem(dsp_clk, mem_valid, mem_ready, mem_data, mem_addr);
        end;

    begin
        mem_ready <= '0';
        clk_wait(dsp_clk, 2);
        receive;
    end process;


    -- Register control interface
    process
        procedure write_reg(reg : natural; value : reg_data_t) is
        begin
            write_reg(
                dsp_clk, write_data, write_strobe, write_ack, reg, value);
        end;

        procedure write_config(value : reg_data_t) is
        begin
            write_reg(DSP_DET_CONFIG_REG, value);
        end;

        procedure write_command(value : reg_data_t) is
        begin
            write_reg(DSP_DET_COMMAND_REG_W, value);
        end;

        procedure write_bunch(value : reg_data_t) is
        begin
            write_reg(DSP_DET_BUNCH_REG, value);
        end;

        procedure read_events is
        begin
            read_reg(
                dsp_clk, read_data, read_strobe, read_ack,
                DSP_DET_EVENTS_REG_R);
        end;

    begin
        write_strobe <= (others => '0');
        read_strobe <= (others => '0');

        -- Write the bunch memories
        write_command(X"0000_0003");
        write_config(X"0000_0000");
        write_bunch(X"0000_0055");
        write_bunch(X"FFFF_FFFF");
        write_config(X"4000_0000");
        write_bunch(X"0000_0055");
        write_config(X"8000_0000");
        write_bunch(X"0000_0055");
        write_config(X"C000_0000");
        write_bunch(X"0000_0055");

        -- Enable all four outputs with different scaling, select FIR input with
        -- attenuation.
        write_config(X"00_092B_03");

        read_events;

        wait;
    end process;
end;
