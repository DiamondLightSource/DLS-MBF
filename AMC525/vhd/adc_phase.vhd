-- Compute ADC phase from ADC clock, DSP clock, and DSP OK signal.  Essentially
-- this mirrors the DSP clock as a signal.  We can't take the DSP clock as a
-- signal because that causes awful timing problems.
--
-- Note from the timing below that this phase computation relies on dsp_clk_ok_i
-- being set synchronous with DSP clk.
--             _     ___     ___     ___     ___     ___     ___     ___
--  adc_clk_i   \___/   \___/   \___/   \___/   \___/   \___/   \___/
--                   _______         _______         _______         ___
--  dsp_clk    _____/       \_______/       \_______/       \_______/
--                   ___________________________________________________
--  dsp_clk_ok_i ___/
--             _____________
--  adc_phase_reset         \___________________________________________
--                                   _______         _______         ___
--  adc_phase_o ____________________/       \_______/       \_______/
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_phase is
    port (
        adc_clk_i : in std_logic;
        dsp_clk_ok_i : in std_logic;

        adc_phase_o : out std_logic
    );
end;

architecture adc_phase of adc_phase is
    signal adc_phase_reset : boolean := false;
    signal adc_phase : std_logic := '0';

begin
    -- Phase reset detection.
    process (adc_clk_i, dsp_clk_ok_i) begin
        if dsp_clk_ok_i = '0' then
            adc_phase_reset <= true;
        elsif rising_edge(adc_clk_i) then
            adc_phase_reset <= false;
            if adc_phase_reset then
                adc_phase <= '0';
            else
                adc_phase <= not adc_phase;
            end if;
        end if;
    end process;

    -- Simple delay line to help with distribution.
    dlyreg_inst : entity work.dlyreg generic map (
        DLY => 2
    ) port map (
        clk_i => adc_clk_i,
        data_i(0) => adc_phase,
        data_o(0) => adc_phase_o
    );

end;
