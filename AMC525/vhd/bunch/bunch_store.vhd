-- Access to both lanes of bunch configuration memory and update interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.bunch_defs.all;

entity bunch_store is
    port (
        dsp_clk_i : in std_logic;

        -- Write interface
        write_strobe_i : in std_logic;
        write_data_i : in reg_data_t;
        write_ack_o : out std_logic;
        write_start_i : in std_logic;   -- Reset write address
        write_bank_i : in unsigned;     -- Selects which bank to write

        -- Bunch readout
        bank_i : in unsigned;
        bunch_index_i : in unsigned;
        config_o : out bunch_config_lanes_t
    );
end;

architecture bunch_store of bunch_store is
    -- Assemble address from bank_i and bunch_index_i
    constant ADDR_BITS : natural := bank_i'LENGTH + bunch_index_i'LENGTH;
    signal read_addr : unsigned(ADDR_BITS-1 downto 0) := (others => '0');
    signal write_addr : unsigned(ADDR_BITS-1 downto 0) := (others => '0');

    subtype data_t is std_logic_vector(BUNCH_CONFIG_BITS-1 downto 0);
    type data_lanes_t is array(LANES) of data_t;
    signal read_data : data_lanes_t;
    signal write_data : data_t;

    signal write_bunch : bunch_index_i'SUBTYPE;
    signal write_lane : LANES;
    signal write_strobe : std_logic_vector(LANES);

    signal write_data_in : bunch_config_t;
    signal config : bunch_config_lanes_t;
    signal config_out : bunch_config_lanes_t
        := (others => default_bunch_config_t);

begin
    -- Bunch memory for each line
    gen_lanes : for l in LANES generate
        memory_inst : entity work.block_memory generic map (
            ADDR_BITS => ADDR_BITS,
            DATA_BITS => BUNCH_CONFIG_BITS
        ) port map (
            clk_i => dsp_clk_i,
            read_addr_i => read_addr,
            read_data_o => read_data(l),
            write_strobe_i => write_strobe(l),
            write_addr_i => write_addr,
            write_data_i => write_data,
            write_data_o => open
        );

        config(l) <= bits_to_bunch_config(read_data(l));
    end generate;

    -- We pack and unpack the written data simply so that the external bit
    -- layout can be decoupled from the stored packed representation.
    write_data_in.fir_select   <= unsigned(write_data_i(1 downto 0));
    write_data_in.fir_enable   <= write_data_i(4);
    write_data_in.nco_0_enable <= write_data_i(5);
    write_data_in.nco_1_enable <= write_data_i(6);
    write_data_in.gain         <= signed  (write_data_i(31 downto 19));

    -- Assemble addresses from selected bank and target bunch
    read_addr <= bank_i & bunch_index_i;

    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            if write_start_i = '1' then
                -- Reset write back to start
                write_bunch <= (others => '0');
                write_lane <= 0;
                write_strobe <= (others => '0');
            elsif write_strobe_i = '1' then
                -- Write a single value into the current bunch and lane
                write_addr <= write_bank_i & write_bunch;
                write_data <= bunch_config_to_bits(write_data_in);
                write_strobe <= compute_strobe(write_lane, LANE_COUNT);

                -- Advance to next entry
                write_lane <= (write_lane + 1) mod LANE_COUNT;
                if write_lane = LANE_COUNT-1 then
                    write_bunch <= write_bunch + 1;
                end if;
            else
                write_strobe <= (others => '0');
            end if;

            -- Register the bunch configuration
            config_out <= config;
        end if;
    end process;

    write_ack_o <= '1';
    config_o <= config_out;
end;
