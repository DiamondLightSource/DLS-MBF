-- A single lane of DAC output multiplexer generation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.dsp_defs.all;
use work.bunch_defs.all;

entity dac_output_mux is
    generic (
        PIPELINE_OUT : natural := 4
    );
    port (
        clk_i : in std_ulogic;

        -- output selection and bunch by bunch gains
        bunch_config_i : in bunch_config_t;

        -- Input signals with individual "fixed" gains
        fir_data_i : in signed;
        fir_gain_i : in unsigned;

        nco_0_data_i : in dsp_nco_from_mux_t;
        nco_1_data_i : in dsp_nco_from_mux_t;
        nco_2_data_i : in dsp_nco_from_mux_t;
        nco_3_data_i : in dsp_nco_from_mux_t;

        -- Generated outputs.  Note that the FIR overflow is pipelined through
        -- so that we know whether to ignore it, if the output was unused.
        data_o : out signed;
        -- This FIR data out is just for the MMS view
        fir_mms_o : out signed;

        fir_overflow_o : out std_ulogic := '0';
        mux_overflow_o : out std_ulogic
    );
end;

architecture arch of dac_output_mux is
    -- The processing here involves careful balancing of the available bit
    -- budget.  First we apply gain adjustment on the 25 bits of FIR data from
    -- the bunch by bunch FIR: this is done by a shift of between 0 and 15 bits,
    -- giving a total range of possible values covering 40 bits (25+15).
    constant MAX_FIR_SHIFT : natural := 2**fir_gain_i'LENGTH - 1;
    constant SHIFTED_FIR_BITS : natural := fir_data_i'LENGTH + MAX_FIR_SHIFT;
    signal scaled_fir : signed(SHIFTED_FIR_BITS-1 downto 0);
    -- At the end of processing, we will extract 16 bits of output corresponding
    -- to the range of gains of interest.  In our application it turns out that
    -- we want to be able to output quite high gain.
    --    Here we choose to be able to shift the bottom 15 bits of the FIR into
    -- the top bits of the DAC output.
    constant FIR_MAX_GAIN_BITS : natural := 15;
    constant FIR_SHIFT_OFFSET : natural :=
        MAX_FIR_SHIFT + FIR_MAX_GAIN_BITS - data_o'LENGTH;
    -- At the same time, we are computing products of the NCO inputs and their
    -- corresponding gains.  Everything is accumulated into the 48-bit DSP
    -- accumlator, as illustrated in the figure below:
    --
    --    +--------------------------------------------+
    --    |         :                  :               |        Scaled FIR
    --    +--------------------------------------------+
    --          NCO (as 1.17)       Gain (as 6.19)
    --  +-----+-------------------+--------------------------+
    --  |     | .                 | .                        |  Scaled NCO
    --  +-----+-------------------+--------------------------+
    --               +-----------------+
    --               | .               |                        DAC Output
    --               +-----------------+
    -- To allow for overscaling at the bunch-by-bunch level (not yet
    -- implemented) we treat the gain multiplier as a 6.19 constant.  At present
    -- we just inject our 18 bit gain into the 0.18 part of this value.
    subtype NCO_GAIN_RANGE is natural range 18 downto 1;
    -- Treating the NCO as 1.17 and assuming we want a 1.15 DAC output, we now
    -- have a 7.36 output and so we want to drop 21 bits from the final output.
    constant DAC_OUTPUT_OFFSET : natural := 21;
    -- To align the DAC output offset above with the scaled FIR data, we need an
    -- extra FIR offset which is applied to the FIR data.
    constant FIR_INPUT_OFFSET : natural := DAC_OUTPUT_OFFSET - FIR_SHIFT_OFFSET;

    -- The final output stage adds an extra complication.  We extract 25 bits
    -- from the output above (keeping two bits for rounding) which we treat as a
    -- 8.17 value, which means we need to extract the following range:
    constant RAW_DAC_OUT_TOP : natural := DAC_OUTPUT_OFFSET + 23;
    subtype RAW_DAC_OUT_RANGE is natural range
        RAW_DAC_OUT_TOP-1 downto DAC_OUTPUT_OFFSET-2;
    signal unscaled_dac_out : signed(24 downto 0);
    -- This is then multiplied by a 6.12 bunch-by-bunch scalar, giving us a
    -- 14.29 value, from which we want the 1.15 part.
    constant DAC_RESULT_OFFSET : natural := 29 - 15;
    subtype DAC_RESULT_RANGE is natural range
        DAC_RESULT_OFFSET + 15 downto DAC_RESULT_OFFSET;

    constant DAC_RESULT_ROUNDING : signed(47 downto 0)
        := (DAC_RESULT_OFFSET-1 => '1', others => '0');

    subtype NCOS is natural range 0 to 3;
    type dsp_nco_array is array(NCOS) of dsp_nco_from_mux_t;
    signal nco_data : dsp_nco_array;
    signal nco_enables_in : std_ulogic_vector(NCOS);
    signal nco_enables : vector_array(NCOS)(NCOS);
    signal nco_overflows : std_ulogic_vector(NCOS);
    signal unscaled_overflow_out : std_ulogic;
    signal scaling_overflow : std_ulogic;
    signal scaling_overflow_out : std_ulogic;

    signal accum_signal : signed_array(0 to NCOS'HIGH + 1)(47 downto 0);
    signal full_dac_out : signed(47 downto 0);

    -- This is truly strange.  Without this intermediate definition, Vivado
    -- chokes when trying to elaborate the assignments that use this below!
    constant ONE : std_ulogic := '1';

begin
    -- Map individual NCOs to arrays for generation
    nco_data <= (
        0 => nco_0_data_i,
        1 => nco_1_data_i,
        2 => nco_2_data_i,
        3 => nco_3_data_i);
    nco_enables_in <= (
        0 => bunch_config_i.nco_0_enable,
        1 => bunch_config_i.nco_1_enable,
        2 => bunch_config_i.nco_2_enable,
        3 => bunch_config_i.nco_3_enable);

    -- Delay each enable so data out and enables align
    process (clk_i) begin
        if rising_edge(clk_i) then
            nco_enables(0) <= nco_enables_in;
            for i in 0 to NCOS'HIGH-1 loop
                nco_enables(i+1) <= nco_enables(i);
            end loop;
        end if;
    end process;


    -- FIR gain
    fir : entity work.dac_fir_gain generic map (
        MMS_OFFSET => FIR_SHIFT_OFFSET
    ) port map (
        clk_i => clk_i,

        data_i => fir_data_i,
        gain_i => fir_gain_i,
        enable_i => bunch_config_i.fir_enable,

        data_o => scaled_fir,
        mms_o => fir_mms_o,
        overflow_o => fir_overflow_o
    );
    accum_signal(0) <= (
        47 downto FIR_INPUT_OFFSET => resize(scaled_fir, 48 - FIR_INPUT_OFFSET),
        others => '0');

    -- Accumulate all the NCOs
    scale_ncos : for i in NCOS generate
        signal a_in : signed(17 downto 0);
        signal b_in : signed(24 downto 0);
        signal ab : signed(42 downto 0);
        signal abc : signed(47 downto 0);

        subtype OVF_RANGE is natural range 47 downto RAW_DAC_OUT_RANGE'LEFT;
        constant ONES_MASK : signed(OVF_RANGE) := (others => '1');
        signal all_ones : boolean;
        signal all_zeros : boolean;

    begin
        process (clk_i) begin
            if rising_edge(clk_i) then
                a_in <= nco_data(i).nco;
                b_in <= (
                    NCO_GAIN_RANGE => signed(nco_data(i).gain),
                    others => '0');
                if nco_enables(i)(i) = '1' then
                    ab <= a_in * b_in;
                else
                    ab <= (others => '0');
                end if;
                accum_signal(i + 1) <= abc;
                all_ones <= abc(OVF_RANGE) = ONES_MASK;
                all_zeros <= abc(OVF_RANGE) = 0;
            end if;
        end process;
        abc <= resize(ab, 48) + accum_signal(i);
        nco_overflows(i) <= to_std_ulogic(not all_ones and not all_zeros);
    end generate;

    -- Saturate final output from NCO accumulator chain.  We can't put this off
    -- until after the next stage, as we've run out of bits to play with.
    saturate_accum : entity work.saturate generic map (
        OFFSET => RAW_DAC_OUT_RANGE'RIGHT
    ) port map (
        clk_i => clk_i,
        data_i => accum_signal(NCOS'HIGH + 1),
        ovf_i => nco_overflows(NCOS'HIGH),
        data_o => unscaled_dac_out,
        ovf_o => unscaled_overflow_out
    );

    -- Final output scaling
    dac_mac : entity work.dsp_mac generic map (
        TOP_RESULT_BIT => DAC_RESULT_RANGE'LEFT
    ) port map (
        clk_i => clk_i,
        a_i => bunch_config_i.gain,
        b_i => unscaled_dac_out,
        en_ab_i => ONE,
        c_i => DAC_RESULT_ROUNDING,
        en_c_i => ONE,
        p_o => full_dac_out,
        ovf_o => scaling_overflow
    );

    saturate_dac : entity work.saturate generic map (
        OFFSET => DAC_RESULT_RANGE'RIGHT
    ) port map (
        clk_i => clk_i,
        data_i => full_dac_out,
        ovf_i => scaling_overflow,
        data_o => data_o,
        ovf_o => scaling_overflow_out
    );

    mux_overflow_o <= unscaled_overflow_out or scaling_overflow_out;
end;
