-- Bunch by bunch filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity bunch_fir is
    port (
        clk_i : in std_logic;
        turn_clock_i : in std_logic;
        taps_i : in signed_array;

        data_valid_i : in std_logic;
        data_i : in signed;
        data_valid_o : out std_logic := '0';
        data_o : out signed
    );
end;

architecture arch of bunch_fir is
    -- The delay line between taps is limited to 36 bits to fit into BRAM, and
    -- for simplicity we assume that we'll have to clip to fit into the delay.
    constant DELAY_WIDTH : natural := data_o'LENGTH;

    constant TAP_COUNT : natural := taps_i'LENGTH;
    subtype TAPS_RANGE is natural range 0 to TAP_COUNT-1;
    signal accum_out : signed_array(TAPS_RANGE)(DELAY_WIDTH-1 downto 0)
        := (others => (others => '0'));
    signal delay_out : signed_array(TAPS_RANGE)(DELAY_WIDTH-1 downto 0)
        := (others => (others => '0'));

    -- Delay on input to allow data to get to each tap
    constant DISTRIBUTION_DELAY : natural := 4;
    -- Delays from tap computations (should be outputs from DSP entity, but
    -- that's not how VHDL works!)
    constant DSP_DATA_DELAY : natural := 3;
    constant DSP_ACCUM_DELAY : natural := 2;
    -- Registers from DSP to memory
    constant DSP_RAMB_DELAY : natural := 1;
    -- Registers from memory to DSP
    constant RAMB_DSP_DELAY : natural := 1;

    -- Delay from data_i valid to accum_out valid.  This is derived from the
    -- following data path:
    --  data_i, data_valid_i
    --      =(DISTRIBUTION_DELAY)=> data_in
    --      =(DSP_DATA_DELAY)=> accum_out, data_o, data_valid_o
    constant DATA_VALID_DELAY : natural := DISTRIBUTION_DELAY + DSP_DATA_DELAY;

    -- Delay used for delay line, derived from this data path:
    --  delay_out_reg
    --      =(RAMB_DSP_DELAY)=> delay_out
    --      =(DSP_ACCUM_DELAY)=> accum_out
    --      =(DSP_RAMB_DELAY)=> delay_in_reg
    constant PROCESS_DELAY : natural :=
        RAMB_DSP_DELAY + DSP_ACCUM_DELAY + DSP_RAMB_DELAY;

begin
    -- Core processing DSP chain
    taps_gen : for t in TAPS_RANGE generate
        signal data_in : signed(data_i'RANGE);
    begin
        -- Data distribution delays.
        delay_data : entity work.dlyreg generic map (
            DLY => DISTRIBUTION_DELAY,
            DW => data_i'LENGTH
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(data_i),
            signed(data_o) => data_in
        );

        dsp : entity work.bunch_fir_dsp generic map (
            TAP_COUNT => TAP_COUNT,
            DATA_DELAY => DSP_DATA_DELAY,
            ACCUM_DELAY => DSP_ACCUM_DELAY
        ) port map (
            clk_i => clk_i,
            data_i => data_in,
            tap_i => taps_i(TAP_COUNT-1 - t),     -- Taps in reverse order
            accum_i => delay_out(t),
            accum_o => accum_out(t)
        );
    end generate;

    -- The initial empty accumulator needs to be clocked to work around a
    -- QuestaSim misfeature
    process (clk_i) begin
        if rising_edge(clk_i) then
            delay_out(0) <= (others => '0');
        end if;
    end process;
    data_o <= accum_out(TAP_COUNT-1);


    -- Line up data valid with data
    valid_delay_inst : entity work.dlyline generic map (
        DLY => DATA_VALID_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => data_valid_i,
        data_o(0) => data_valid_o
    );

    -- Delay lines between each bunch
    delay_gen : for t in 1 to TAP_COUNT-1 generate
        signal delay_in_reg : signed(DELAY_WIDTH-1 downto 0);
        signal delay_in_valid : std_logic;
        signal delay_out_reg : signed(DELAY_WIDTH-1 downto 0);

    begin
        pipeline_in : entity work.dlyreg generic map (
            DLY => DSP_RAMB_DELAY,
            DW => DELAY_WIDTH
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(accum_out(t-1)),
            signed(data_o) => delay_in_reg
        );

        data_valid_delay : entity work.dlyreg generic map (
            DLY => DSP_RAMB_DELAY
        ) port map (
            clk_i => clk_i,
            data_i(0) => data_valid_o,
            data_o(0) => delay_in_valid
        );

        data_delay_inst : entity work.bunch_fir_delay generic map (
            PROCESS_DELAY => PROCESS_DELAY
        ) port map (
            clk_i => clk_i,
            turn_clock_i => turn_clock_i,
            write_strobe_i => delay_in_valid,
            data_i => delay_in_reg,
            data_o => delay_out_reg
        );

        pipeline_out : entity work.dlyreg generic map (
            DLY => RAMB_DSP_DELAY,
            DW => DELAY_WIDTH
        ) port map (
            clk_i => clk_i,
            data_i => std_logic_vector(delay_out_reg),
            signed(data_o) => delay_out(t)
        );
    end generate;
end;
