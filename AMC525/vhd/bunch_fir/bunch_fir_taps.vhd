-- Taps for bunch by bunch filter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_fir_taps is
    generic (
        SELECT_BUFFER_LENGTH : natural := 4
    );
    port (
        adc_clk_i : in std_logic;
        dsp_clk_i : in std_logic;

        -- Register write interface for writing taps
        -- Taps write interface
        write_start_i : in std_logic;
        write_fir_i : in unsigned;      -- Selects which FIR group to write

        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;

        -- Taps output
        fir_select_i : in unsigned;
        taps_o : out signed_array
    );
end;

architecture arch of bunch_fir_taps is
    constant BANK_COUNT : natural := 2**FIR_BANK_BITS-1;
    constant TAP_COUNT : natural := taps_o'LENGTH;
    constant TAP_WIDTH : natural := taps_o(0)'LENGTH;

    subtype BANKS_RANGE is natural range 0 to BANK_COUNT;
    subtype TAPS_RANGE is natural range 0 to TAP_COUNT-1;
    subtype TAP_RANGE  is natural range TAP_WIDTH-1 downto 0;

    signal taps_table : signed_array_array(BANKS_RANGE)(TAPS_RANGE)(TAP_RANGE)
        := (others => (others => (others => '0')));
    signal tap_index : unsigned(bits(TAP_COUNT-1)-1 downto 0);

begin
    -- Readout of individual taps
    readout : for tap in TAPS_RANGE generate
        signal fir_select : fir_select_i'SUBTYPE;

    begin
        -- Distribute FIR bank selection to each tap
        delay : entity work.dlyreg generic map (
            DLY => SELECT_BUFFER_LENGTH,
            DW => fir_select_i'LENGTH
        ) port map (
            clk_i => adc_clk_i,
            data_i => std_logic_vector(fir_select_i),
            unsigned(data_o) => fir_select
        );

        process (adc_clk_i) begin
            if rising_edge(adc_clk_i) then
                taps_o(tap) <= taps_table(to_integer(fir_select))(tap);
            end if;
        end process;
    end generate;


    -- Writing of individual taps
    write_taps : for tap in TAPS_RANGE generate
        write_banks : for bank in BANKS_RANGE generate
            signal write_strobe : std_logic := '0';

        begin
            process (dsp_clk_i) begin
                if rising_edge(dsp_clk_i) then
                    write_strobe <= to_std_logic(
                        write_strobe_i = '1' and
                        to_integer(tap_index) = tap and
                        to_integer(write_fir_i) = bank);

                    write_ack_o <= write_strobe_i;
                end if;
            end process;

            untimed_taps : entity work.untimed_reg generic map (
                WIDTH => TAP_WIDTH
            ) port map (
                clk_i => dsp_clk_i,
                write_i => write_strobe,
                data_i =>
                    std_logic_vector(write_data_i(31 downto 32-TAP_WIDTH)),
                signed(data_o) => taps_table(bank)(tap)
            );
        end generate;
    end generate;


    -- Manage taps write counter
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_start_i = '1' then
                tap_index <= (others => '0');
            elsif write_strobe_i = '1' then
                tap_index <= tap_index + 1;
            end if;
        end if;
    end process;
end;
