-- Implements NCO gains and final saturation of output

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.dsp_defs.all;
use work.bunch_defs.all;

entity dac_nco_gains is
    port (
        clk_i : in std_ulogic;

        bunch_config_i : in bunch_config_t;
        nco_data_i : in nco_data_array_t;

        fir_data_i : in signed(47 downto 0);
        dac_data_o : out signed(DAC_DATA_RANGE);
        mux_overflow_o : out std_ulogic
    );
end;

architecture arch of dac_nco_gains is
    signal accum_array : signed_array(0 to NCO_SET'HIGH + 1)(47 downto 0);
    signal full_dac_out : signed(47 downto 0);

    signal bb_gains : signed_array_array(NCO_SET)(NCO_SET)(17 downto 0)
        := (NCO_SET => (NCO_SET => (others => '0')));
    type nco_array_array_t is array(NCO_SET) of nco_data_array_t;
    signal nco_data : nco_array_array_t
        := (NCO_SET => (NCO_SET => dsp_nco_from_mux_reset));

    signal mux_overflow : std_ulogic;

    -- The FIR data in will be treated as a 13.35 signal.  If we then treat the
    -- NCO scaling as multiplying a 1.17 NCO value by a a scalar we need the
    -- scalar to be a .18 value, which we extract from multiplying 4.14 by 1.18;
    -- in other words, we will discard the bottom 14 bits.
    constant SCALAR_SHIFT : natural := 14;
    constant ROUND_SCALAR : signed(47 downto 0) :=
        (SCALAR_SHIFT-1 => '1', others => '0');
    subtype SCALAR_RANGE is natural range SCALAR_SHIFT+24 downto SCALAR_SHIFT;

    -- We pluck out the 1.15 part of the finaly 13.35 signal
    subtype DAC_RESULT_RANGE is natural range 35 downto 20;

begin
    -- Bunch by bunch gains and NCO data will be aligned.  Start with the
    -- incoming data.
    bb_gains(0) <= (
        0 => bunch_config_i.nco0_gain,
        1 => bunch_config_i.nco1_gain,
        2 => bunch_config_i.nco2_gain,
        3 => bunch_config_i.nco3_gain);
    nco_data(0) <= nco_data_i;


    -- Generated the aligned gains and signals.  All the bunch by bunch gains
    -- must be aligned, and the SEQ NCO fixed gain and NCO signal must be also
    -- be aligned; the other signals can be just passed through.
    align : for i in 1 to NCO_SET'HIGH generate
        process (clk_i) begin
            if rising_edge(clk_i) then
                bb_gains(i) <= bb_gains(i - 1);
                -- Delay SEQ NCO data to align
                nco_data(i)(NCO_SEQ) <= nco_data(i - 1)(NCO_SEQ);
            end if;
        end process;

        -- All the other NCO data is passed through without delay
        passthrough : for j in NCO_SET generate
            not_seq : if j /= NCO_SEQ generate
                nco_data(i)(j) <= nco_data_i(j);
            end generate;
        end generate;
    end generate;


    -- Work through each NCO in turn, scaling and accumulating.
    accum_array(0) <= fir_data_i;
    nco_array : for i in NCO_SET generate
        signal full_scalar : signed(47 downto 0);
        signal scalar : signed(24 downto 0) := (others => '0');
        signal nco_in : signed(17 downto 0);

        constant use_pcin : boolean := i > NCO_SET'LOW;
        signal p_out : signed(47 downto 0);
        signal ovf_out : std_ulogic;

    begin
        -- Compute scalar as product of fixed and bunch by bunch gains
        scale : entity work.dsp48e_mac port map (
            clk_i => clk_i,
            a_i => resize('0' & signed(nco_data(i)(i).gain), 25),
            b_i => bb_gains(i)(i),
            en_ab_i => '1',
            c_i => ROUND_SCALAR,
            en_c_i => '1',
            p_o => full_scalar
        );

        process (clk_i) begin
            if rising_edge(clk_i) then
                scalar <= full_scalar(SCALAR_RANGE);
            end if;
        end process;

        -- We need to delay the SEQ NCO data a further 4 clock ticks so that the
        -- scalar computed above and the NCO value align.  This correction is
        -- not applied to the other NCOs.
        delay_nco : if i = NCO_SEQ generate
            delay : entity work.dlyline generic map (
                DLY => 4,
                DW => 18
            ) port map (
                clk_i => clk_i,
                data_i => std_logic_vector(nco_data(i)(i).nco),
                signed(data_o) => nco_in
            );
        else generate
            nco_in <= nco_data(i)(i).nco;
        end generate;

        mac : entity work.dsp48e_mac generic map (
            TOP_RESULT_BIT => DAC_RESULT_RANGE'LEFT,
            USE_PCIN => use_pcin
        ) port map (
            clk_i => clk_i,
            a_i => scalar,
            b_i => nco_in,
            en_ab_i => '1',
            c_i => accum_array(i),
            en_c_i => '1',
            p_o => p_out,
            pc_o => accum_array(i + 1),
            ovf_o => ovf_out
        );

        last_mac : if i = NCO_SET'RIGHT generate
            full_dac_out <= p_out;
            mux_overflow <= ovf_out;
        end generate;
    end generate;


    -- Generate the final saturated output
    saturate_dac : entity work.saturate generic map (
        OFFSET => DAC_RESULT_RANGE'RIGHT
    ) port map (
        clk_i => clk_i,
        data_i => full_dac_out,
        ovf_i => mux_overflow,
        data_o => dac_data_o,
        ovf_o => mux_overflow_o
    );
end;
