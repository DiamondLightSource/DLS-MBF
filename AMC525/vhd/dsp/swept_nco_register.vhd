-- Register file for writing NCO parameters.
-- The 48-bit frequency values are set with two 32-bit register words,
-- updated only on write to the second word.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.nco_defs.all;
use work.dsp_defs.all;
use work.sequencer_defs.all;
use work.swept_nco_defs.all;
use work.register_defs.all;

entity swept_nco_register is
    port (
        -- Clocking
        clk_i : in std_ulogic;

        -- Register control interface
        write_strobe_i : in std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
        write_data_i : in reg_data_t;
        write_ack_o : out std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
        read_strobe_i : in std_ulogic_vector(SWEPT_NCO_REGS_RANGE);
        read_data_o : out reg_data_array_t(SWEPT_NCO_REGS_RANGE);
        read_ack_o : out std_ulogic_vector(SWEPT_NCO_REGS_RANGE);

        -- Swept NCO config registers
        start_freq_o : out angle_t := (others => '0');
        delta_freq_o : out angle_t := (others => '0');
        dwell_count_o : out dwell_count_t := (others => '0');
        point_count_o : out capture_count_t := (others => '0');
        nco_gain_o : out nco_gain_t := (others => '0');
        reset_phase_o : out std_ulogic := '0';
        enable_tune_pll_o : out std_ulogic := '0';
        repeat_count_o : out repeat_count_t := (others => '0');
        repeat_continuous_o : out std_ulogic;
        repeat_start_o : out std_ulogic;
        repeat_start_reset_o : out std_ulogic;

        -- actual value of repeat for readout
        repeat_count_i : in repeat_count_t;

        reset_sweep_o : out std_ulogic := '0'
    );
end;

architecture arch of swept_nco_register is
    signal start_freq_low_bits_out : reg_data_t := (others => '0');
    signal delta_freq_low_bits_out : reg_data_t := (others => '0');
    signal freq_low_bits_in : reg_data_t := (others => '0');

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i(SWEPT_NCO_GAIN_TUNE_REG) = '1' then
                nco_gain_o <=
                    unsigned(write_data_i(SWEPT_NCO_GAIN_TUNE_GAIN_BITS));
                enable_tune_pll_o <=
                    write_data_i(SWEPT_NCO_GAIN_TUNE_ENA_TUNE_PLL_BIT);
            end if;

            if write_strobe_i(SWEPT_NCO_DELTA_FREQ_LOW_REG) = '1' then
                delta_freq_low_bits_out <= write_data_i;
            end if;

            if write_strobe_i(SWEPT_NCO_DELTA_FREQ_HIGH_REG) = '1' then
                delta_freq_o <= (
                    31 downto 0 => unsigned(delta_freq_low_bits_out),
                    47 downto 32 =>
                        unsigned(write_data_i(
                            SWEPT_NCO_DELTA_FREQ_HIGH_BITS_BITS))
                );
            end if;

            if write_strobe_i(SWEPT_NCO_TIME_REG) = '1' then
                dwell_count_o <=
                    unsigned(write_data_i(SWEPT_NCO_TIME_DWELL_BITS));
                point_count_o <=
                    unsigned(write_data_i(SWEPT_NCO_TIME_COUNT_BITS));
            end if;

            if write_strobe_i(SWEPT_NCO_REPEAT_REG) = '1' then
                repeat_count_o <=
                    unsigned(write_data_i(SWEPT_NCO_REPEAT_COUNT_BITS));
                repeat_continuous_o <=
                    write_data_i(SWEPT_NCO_REPEAT_CONTINUOUS_BIT);
            end if;

            if write_strobe_i(SWEPT_NCO_COMMAND_REG) = '1' then
                repeat_start_o <= write_data_i(SWEPT_NCO_COMMAND_START_BIT);
                repeat_start_reset_o <=
                    write_data_i(SWEPT_NCO_COMMAND_RESET_PHASE_BIT);
                reset_sweep_o <= write_data_i(SWEPT_NCO_COMMAND_ABORT_BIT);
            else
                repeat_start_o <= '0';
                repeat_start_reset_o <= '0';
                reset_sweep_o <= '0';
            end if;

            if write_strobe_i(SWEPT_NCO_FREQ_LOW_REG) = '1' then
                start_freq_low_bits_out <= write_data_i;
            end if;

            if write_strobe_i(SWEPT_NCO_FREQ_HIGH_REG) = '1' then
                start_freq_o <= (
                    31 downto 0 => unsigned(start_freq_low_bits_out),
                    47 downto 32 =>
                        unsigned(write_data_i(SWEPT_NCO_FREQ_HIGH_BITS_BITS))
                );
                reset_phase_o <=
                    write_data_i(SWEPT_NCO_FREQ_HIGH_RESET_PHASE_BIT);
            else
                reset_phase_o <= '0';
            end if;
        end if;
    end process;

    write_ack_o <= (others => '1');
    read_data_o <= (
        SWEPT_NCO_REPEAT_REG => (
            SWEPT_NCO_REPEAT_COUNT_BITS => std_ulogic_vector(repeat_count_i),
            others => '0'),
        others => (others => '0'));
    read_ack_o <= (others => '1');
    
end;
