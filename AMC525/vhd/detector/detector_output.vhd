-- Scaling and output of a single detector value with output handshaking
-- underrun detection.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.detector_defs.all;

entity detector_output is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        scaling_i : in unsigned(2 downto 0);
        overflow_o : out std_logic := '0';
        write_i : in std_logic;
        data_i : in cos_sin_96_t;

        output_valid_o : out std_logic := '0';
        output_ready_i : in std_logic;
        output_data_o : out std_logic_vector(63 downto 0);
        output_underrun_o : out std_logic := '0'
    );
end;

architecture arch of detector_output is
    signal write_in : std_logic;
    signal write_dly : std_logic;

    signal cos_overflow : std_logic;
    signal sin_overflow : std_logic;

    signal cos_out : signed(31 downto 0);
    signal sin_out : signed(31 downto 0);

    signal output_valid : std_logic := '0';

begin
    -- Bring the write pulse over to the DSP clock and delay it enough for the
    -- gain corrected data to be valid.
    write_pulse : entity work.pulse_adc_to_dsp port map (
        adc_clk_i => adc_clk_i,
        dsp_clk_i => dsp_clk_i,
        pulse_i => write_i,
        pulse_o => write_in
    );
    write_delay : entity work.dlyline generic map (
        DLY => 3
    ) port map (
        clk_i => dsp_clk_i,
        data_i(0) => write_in,
        data_o(0) => write_dly
    );


    -- Gain control on input data
    cos_gain : entity work.gain_control generic map (
        INTERVAL => 8
    ) port map (
        clk_i => dsp_clk_i,
        gain_sel_i => scaling_i,
        data_i => data_i.cos,
        data_o => cos_out,
        overflow_o => cos_overflow
    );

    sin_gain : entity work.gain_control generic map (
        INTERVAL => 8
    ) port map (
        clk_i => dsp_clk_i,
        gain_sel_i => scaling_i,
        data_i => data_i.sin,
        data_o => sin_out,
        overflow_o => sin_overflow
    );

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- There's something a bit tricky about overflow detection -- it's
            -- done asynchronously to data handshaking.
            overflow_o <= output_valid and (cos_overflow or sin_overflow);

            case output_valid is
                when '0' =>
                    if write_dly = '1' then
                        output_valid <= '1';
                    end if;
                when '1' =>
                    if output_ready_i = '1' then
                        output_valid <= '0';
                    end if;
                when others =>
            end case;

            -- Report an error if a new write arrives while the old write is
            -- still not dealt with.
            output_underrun_o <= output_valid and write_dly;
        end if;
    end process;

    output_valid_o <= output_valid;
    output_data_o(31 downto  0) <= std_logic_vector(cos_out);
    output_data_o(63 downto 32) <= std_logic_vector(sin_out);
end;
