-- Interface to CERN FMC 5-channel Digital I/O board:
--  http://www.ohwr.org/projects/fmc-dio-5chttla
-- Sourced as CTI-FMC-DIO from www.creotech.pl

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity fmc_digital_io is
    port (
        clk_i : in std_logic;

        -- All FMC low pin count connections.
        FMC_LA_P : inout std_logic_vector(0 to 33);
        FMC_LA_N : inout std_logic_vector(0 to 33);

        -- Control interface
        write_strobe_i : in std_logic;
        write_address_i : in reg_addr_t;
        write_data_i : in reg_data_t;

        -- Direct connection to I/O pins, buffered only.
        output_i : in std_logic_vector(4 downto 0);
        input_o : out std_logic_vector(4 downto 0)
    );
end;

architecture fmc_digital_io of fmc_digital_io is
    signal buf_input_p : std_logic_vector(4 downto 0);
    signal buf_input_n : std_logic_vector(4 downto 0);
    signal buf_input : std_logic_vector(4 downto 0);

    signal buf_output_p : std_logic_vector(4 downto 0);
    signal buf_output_n : std_logic_vector(4 downto 0);
    signal buf_output : std_logic_vector(4 downto 0);

    signal n_out_enable : std_logic_vector(4 downto 0);
    signal out_enable : std_logic_vector(4 downto 0);

    signal term_enable : std_logic_vector(4 downto 0);

    signal leds : std_logic_vector(1 downto 0);

begin
    -- Pin by pin buffer assignments

    -- Unused pins
    FMC_LA_P(2) <= 'Z';
    FMC_LA_N(2) <= 'Z';
    FMC_LA_P(6) <= 'Z';
    FMC_LA_P(10) <= 'Z';
    FMC_LA_N(10) <= 'Z';
    FMC_LA_N(11) <= 'Z';
    FMC_LA_P(12) <= 'Z';
    FMC_LA_N(12) <= 'Z';
    FMC_LA_P(13) <= 'Z';
    FMC_LA_N(13) <= 'Z';
    FMC_LA_P(14) <= 'Z';
    FMC_LA_N(14) <= 'Z';
    FMC_LA_P(15) <= 'Z';
    FMC_LA_P(17) <= 'Z';
    FMC_LA_N(17) <= 'Z';
    FMC_LA_P(18) <= 'Z';
    FMC_LA_N(18) <= 'Z';
    FMC_LA_P(19) <= 'Z';
    FMC_LA_N(19) <= 'Z';
    FMC_LA_P(21) <= 'Z';
    FMC_LA_N(21) <= 'Z';
    FMC_LA_P(22) <= 'Z';
    FMC_LA_N(22) <= 'Z';
    FMC_LA_P(23) <= 'Z';
    FMC_LA_N(23) <= 'Z';       -- Unused one wire connection to temp sensor
    FMC_LA_P(24) <= 'Z';
    FMC_LA_P(25) <= 'Z';
    FMC_LA_N(25) <= 'Z';
    FMC_LA_P(26) <= 'Z';
    FMC_LA_N(26) <= 'Z';
    FMC_LA_P(27) <= 'Z';
    FMC_LA_N(27) <= 'Z';
    FMC_LA_P(31) <= 'Z';
    FMC_LA_N(31) <= 'Z';
    FMC_LA_P(32) <= 'Z';
    FMC_LA_N(32) <= 'Z';

    -- Input buffer
    buf_input_p(0) <= FMC_LA_P(33);     buf_input_n(0) <= FMC_LA_N(33);
    buf_input_p(1) <= FMC_LA_P(20);     buf_input_n(1) <= FMC_LA_N(20);
    buf_input_p(2) <= FMC_LA_P(16);     buf_input_n(2) <= FMC_LA_N(16);
    buf_input_p(3) <= FMC_LA_P( 3);     buf_input_n(3) <= FMC_LA_N( 3);
    buf_input_p(4) <= FMC_LA_P( 0);     buf_input_n(4) <= FMC_LA_N( 0);
    input_inst : entity work.ibufds_array generic map (
        COUNT => 5
    ) port map (
        p_i => buf_input_p,
        n_i => buf_input_n,
        o_o => buf_input
    );

    -- Output buffer
    FMC_LA_P(29) <= buf_output_p(0);    FMC_LA_N(29) <= buf_output_n(0);
    FMC_LA_P(28) <= buf_output_p(1);    FMC_LA_N(28) <= buf_output_n(1);
    FMC_LA_P( 8) <= buf_output_p(2);    FMC_LA_N( 8) <= buf_output_n(2);
    FMC_LA_P( 7) <= buf_output_p(3);    FMC_LA_N( 7) <= buf_output_n(3);
    FMC_LA_P( 4) <= buf_output_p(4);    FMC_LA_N( 4) <= buf_output_n(4);
    output_inst : entity work.obufds_array generic map (
        COUNT => 5
    ) port map (
        i_i => buf_output,
        p_o => buf_output_p,
        n_o => buf_output_n
    );

    -- Output enables
    n_out_enable <= not out_enable;
    out_enable_inst : entity work.obuf_array generic map (
        COUNT => 5
    ) port map (
        i_i => n_out_enable,
        o_o(0) => FMC_LA_P(30),
        o_o(1) => FMC_LA_N(24),
        o_o(2) => FMC_LA_N(15),
        o_o(3) => FMC_LA_P(11),
        o_o(4) => FMC_LA_P(5)
    );

    -- Input terminations
    term_enable_inst : entity work.obuf_array generic map (
        COUNT => 5
    ) port map (
        i_i => term_enable,
        o_o(0) => FMC_LA_N(30),
        o_o(1) => FMC_LA_N(6),
        o_o(2) => FMC_LA_N(5),
        o_o(3) => FMC_LA_P(9),
        o_o(4) => FMC_LA_N(9)
    );

    -- LEDs
    leds_inst : entity work.obuf_array generic map (
        COUNT => 2
    ) port map (
        i_i => leds,
        o_o(0) => FMC_LA_P(1),
        o_o(1) => FMC_LA_N(1)
    );


    -- Register control interface
    process (clk_i) begin
        if rising_edge(clk_i) then
            if write_strobe_i = '1' then
                case to_integer(write_address_i) is
                    when 0 =>
                        leds <= write_data_i(1 downto 0);
                    when 1 =>
                        out_enable <= write_data_i(4 downto 0);
                    when 2 =>
                        term_enable <= write_data_i(4 downto 0);
                    when 3 =>
                        buf_output <= write_data_i(4 downto 0);
                    when others =>
                end case;
            end if;
        end if;
    end process;

--     buf_output <= output_i;
    input_o <= buf_input;
end;
