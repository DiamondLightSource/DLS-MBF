-- Support for dynamic readout of live data via low pass filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.defines.all;
use work.support.all;

use work.register_defs.all;
use work.detector_defs.all;

entity tune_pll_filtered is
    generic (
        READOUT_IIR_SHIFT : unsigned;
        READOUT_IIR_CLOCK_BITS : natural
    );
    port (
        clk_i : in std_ulogic;

        -- Detector output
        iq_i : in cos_sin_32_t;
        filtered_iq_o : out cos_sin_32_t;

        -- CORDIC output
        phase_i : in signed;
        magnitude_i : in unsigned;
        filter_cordic_i : in std_ulogic;

        -- Feedback output
        frequency_offset_i : in signed;
        filtered_frequency_offset_o : out signed
    );
end;

architecture arch of tune_pll_filtered is
    signal iir_clock_counter :
        unsigned(READOUT_IIR_CLOCK_BITS-1 downto 0) := (others => '0');
    signal iir_clock : std_ulogic := '0';

    signal cos_data_in : signed(31 downto 0);
    signal sin_data_in : signed(31 downto 0);

begin
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Use a fixed frequency clock to run the IIRs
            iir_clock_counter <= iir_clock_counter + 1;
            iir_clock <= to_std_ulogic(iir_clock_counter = 0);

            -- Debug multiplexing of cos/sin IIR inputs for sanity checking of
            -- CORDIC outputs.
            if filter_cordic_i = '1' then
                cos_data_in <= (31 downto 14 => phase_i, others => '0');
                sin_data_in <= signed(magnitude_i);
            else
                cos_data_in <= iq_i.cos;
                sin_data_in <= iq_i.sin;
            end if;
        end if;
    end process;


    cos_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => cos_data_in,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_iq_o.cos,
        done_o => open
    );

    sin_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => sin_data_in,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_iq_o.sin,
        done_o => open
    );

    offset_filter : entity work.one_pole_iir port map (
        clk_i => clk_i,
        data_i => frequency_offset_i,
        iir_shift_i => READOUT_IIR_SHIFT,
        start_i => iir_clock,
        data_o => filtered_frequency_offset_o,
        done_o => open
    );
end;
