-- A single lane of DAC output multiplexer generation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity dac_output_mux is
    port (
        dsp_clk_i : in std_logic;

        -- output selection and gain
        bunch_config_i : in bunch_config_t;

        -- Input signals with individual enable controls
        fir_enable_i : in std_logic;
        fir_data_i : in signed;
        fir_overflow_i : in std_logic;
        nco_0_enable_i : in std_logic;
        nco_0_i : in signed;
        nco_1_enable_i : in std_logic;
        nco_1_i : in signed;

        -- Generated outputs.  Note that the FIR overflow is pipelined through
        -- so that we know whether to ignore it, if the output was unused.
        data_o : out signed;
        fir_overflow_o : out std_logic;
        mux_overflow_o : out std_logic
    );
end;

architecture dac_output_mux of dac_output_mux is
    constant GAIN_WIDTH : natural := bunch_config_i.gain'LENGTH;
    -- So that we can reliably catch the overflow from adding three quantities,
    -- we need two extra bits in the accumulator.
    constant ACCUM_WIDTH : natural := data_o'LENGTH + 2;

    -- Computed input enables
    signal fir_enable : std_logic;
    signal nco_0_enable : std_logic;
    signal nco_1_enable : std_logic;

    -- Selected data, widened for accumulator
    signal fir_data   : signed(ACCUM_WIDTH-1 downto 0);
    signal nco_0_data : signed(ACCUM_WIDTH-1 downto 0);
    signal nco_1_data : signed(ACCUM_WIDTH-1 downto 0);
    -- Sum of the three values above
    signal accum : signed(ACCUM_WIDTH-1 downto 0);

    -- Pipeline the gain so that the gain and selection change together
    signal bunch_gain_in : signed(GAIN_WIDTH-1 downto 0);
    signal bunch_gain : signed(GAIN_WIDTH-1 downto 0);

    -- Scaled result
    constant FULL_PROD_WIDTH : natural := ACCUM_WIDTH + GAIN_WIDTH;
    signal full_dac_out : signed(FULL_PROD_WIDTH-1 downto 0);
    signal full_dac_out_pl : signed(FULL_PROD_WIDTH-1 downto 0);

    -- To compute the output offset, regard the gain as a signed number in the
    -- range -1..1, ie there are GAIN_WIDTH-1 extra fraction bits after
    -- multiplication which we now want to discard.
    constant OUTPUT_OFFSET : natural := GAIN_WIDTH - 1;


    -- If enable, widens data to required width, otherwise returns 0.
    function prepare(data : signed; enable : std_logic) return signed
    is
        variable result : signed(ACCUM_WIDTH-1 downto 0) := (others => '0');
    begin
        if enable = '1' then
            result := resize(data, ACCUM_WIDTH);
        end if;
        return result;
    end;

begin
    fir_enable   <= fir_enable_i   and bunch_config_i.fir_enable;
    nco_0_enable <= nco_0_enable_i and bunch_config_i.nco_0_enable;
    nco_1_enable <= nco_1_enable_i and bunch_config_i.nco_1_enable;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            -- Widen and select the three inputs.
            fir_data   <= prepare(fir_data_i, fir_enable);
            nco_0_data <= prepare(nco_0_i,    nco_0_enable);
            nco_1_data <= prepare(nco_1_i,    nco_1_enable);
            fir_overflow_o <= fir_overflow_i and fir_enable;
            -- Also pipeline the gain so that the selection and gain match
            bunch_gain_in <= bunch_config_i.gain;

            -- Add all three inputs together, continue with gain pipeline
            accum <= fir_data + nco_0_data + nco_1_data;
            bunch_gain <= bunch_gain_in;

            -- Apply selected gain
            full_dac_out <= bunch_gain * accum;
            full_dac_out_pl <= full_dac_out;
        end if;
    end process;

    -- Round and reduce scaled result to final output
    extract_signed : entity work.extract_signed generic map (
        OFFSET => OUTPUT_OFFSET
    ) port map (
        clk_i => dsp_clk_i,
        data_i => full_dac_out_pl,
        data_o => data_o,
        overflow_o => mux_overflow_o
    );
end;
