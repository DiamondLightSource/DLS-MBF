-- Applies gain selection to FIR, produces two outputs: one wide output for
-- input to further accumulation of NCO values, one narrow output for optional
-- output to the MMS.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity dac_fir_gain is
    port (
        clk_i : in std_ulogic;

        fir_data_i : in signed(24 downto 0);    -- 4.21
        fixed_gain_i : in unsigned(3 downto 0); -- Treat as x2^7 to x2^-8
        bb_gain_i : in signed(17 downto 0);     -- 4.14
        fir_enable_i : in std_ulogic;

        fir_data_o : out signed(47 downto 0) := (others => '0');   -- 13.35
        fir_mms_o : out signed(15 downto 0);    -- 1.15
        fir_overflow_o : out std_ulogic;
        mms_overflow_o : out std_ulogic
    );
end;

architecture arch of dac_fir_gain is
    signal fir_off : boolean := false;
    signal fixed_gain_in : unsigned(3 downto 0);

    signal data_in : signed(39 downto 0) := (others => '0');
    signal shifted_data : signed(39 downto 0) := (others => '0');
    -- This signal should be interpreted as the 4.21 input signal scaled by a
    -- shift between +7 and -8, so is a 11.29 signal.  From this range of 40
    -- bits we will extract a 25 bit value to scale.
    signal shifted_data_out : signed(39 downto 0) := (others => '0');
    signal fir_overflow : std_ulogic := '0';

    signal shifted_fir : signed(24 downto 0);
    signal fir_data_out : signed(47 downto 0);

    signal mms_overflow : std_ulogic;

    -- Our output is a 12.35 value packed into a PCOUT wire.  We generate this
    -- by multiplying a 4.14 bunch by bunch scaling factor into a 4.21 input,
    -- which was in turn extracted from the 11.29 scaled value.
    --
    -- This readout shift determines the position of the binary point in the
    -- final output.  We extract 6.19.
    constant BASE_READOUT_SHIFT : natural := 10;
    subtype BASE_READOUT_RANGE is natural range
        BASE_READOUT_SHIFT + 24 downto BASE_READOUT_SHIFT;
    subtype OVERFLOW_RANGE is natural range
        shifted_data'LEFT downto BASE_READOUT_RANGE'LEFT;

    -- shifted_data (6.19) is multiplied by bb_gain_i (4.14) to yield
    -- fir_data_out (10.33), from which we extract 1.15 for MMS readout and we
    -- shift up by 2 to match the .35 required for fir_data_o.
    subtype MMS_READOUT_RANGE is natural range 33 downto 18;
    constant OUTPUT_SHIFT : natural := 2;

    constant ROUNDING_MASK : signed(47 downto 0) := (
        MMS_READOUT_RANGE'RIGHT-1 => '1',
        others => '0');

    signal bb_gain_in : signed(17 downto 0);
    signal fir_enable_in : std_ulogic;

begin
    -- Shift the data to apply the fixed gain
    process (clk_i) begin
        if rising_edge(clk_i) then
            fixed_gain_in <= fixed_gain_i;
            fir_off <= fixed_gain_i = "1111";
            data_in <= (39 downto 15 => fir_data_i, others => '0');

            if fir_off then
                shifted_data <= (others => '0');
            else
                shifted_data <= shift_right(data_in, to_integer(fixed_gain_in));
            end if;

            -- Compute output data and overflow detection together, we'll need
            -- this for the saturation stage.
            shifted_data_out <= shifted_data;
            fir_overflow <= overflow_detect(shifted_data(OVERFLOW_RANGE));

            bb_gain_in <= bb_gain_i;
        end if;
    end process;

    -- Slice 25 bits from the shifted FIR so we can scale it; at this point we
    -- may suffer an overflow.
    saturate_fir : entity work.saturate generic map (
        OFFSET => BASE_READOUT_SHIFT
    ) port map (
        clk_i => clk_i,
        data_i => shifted_data_out,
        ovf_i => fir_overflow,
        data_o => shifted_fir,
        ovf_o => fir_overflow_o
    );

    -- Next scale the shifted and saturated data by the bunch by bunch factor
    bb_scale_nco : entity work.dsp48e_mac generic map (
        TOP_RESULT_BIT => MMS_READOUT_RANGE'LEFT
    ) port map (
        clk_i => clk_i,
        a_i => shifted_fir,
        b_i => bb_gain_in,
        en_ab_i => '1',
        c_i => ROUNDING_MASK,
        en_c_i => '1',
        p_o => fir_data_out,
        ovf_o => mms_overflow
    );

    -- Finally saturate the displayed MMS output.
    saturate_mms : entity work.saturate generic map (
        OFFSET => MMS_READOUT_RANGE'RIGHT
    ) port map (
        clk_i => clk_i,
        data_i => fir_data_out,
        ovf_i => mms_overflow,
        data_o => fir_mms_o,
        ovf_o => mms_overflow_o
    );


    delay_enable : entity work.dlyline generic map (
        DLY => 4        -- Matches gain delay through MAC
    ) port map (
        clk_i => clk_i,
        data_i(0) => fir_enable_i,
        data_o(0) => fir_enable_in
    );

    process (clk_i) begin
        if rising_edge(clk_i) then
            if fir_enable_in then
                -- Shift output up to fit .35 NCO scaling calculations
                fir_data_o <= shift_left(fir_data_out, OUTPUT_SHIFT);
            else
                fir_data_o <= shift_left(ROUNDING_MASK, OUTPUT_SHIFT);
            end if;
        end if;
    end process;
end;
