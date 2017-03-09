-- Slow memory multiplexer.
--
-- Provides two separate buffered channels to slow memory.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;

entity slow_memory_top is
    generic (
        FIFO_BITS : natural := 5            -- log2 FIFO depth
    );
    port (
        dsp_clk_i : in std_logic;

        -- Inputs from two DSP channels
        dsp_strobe_i : in std_logic_vector;
        dsp_address_i : in unsigned_array;
        dsp_data_i : in vector_array;
        dsp_error_o : out std_logic_vector; -- Set if buffer overflow

        -- Output to AXI control
        dram1_address_o : out unsigned;
        dram1_data_o : out std_logic_vector;
        dram1_data_valid_o : out std_logic;
        dram1_data_ready_i : in std_logic
    );
end;

architecture arch of slow_memory_top is
    subtype CHANNELS is natural range dsp_strobe_i'RANGE;
    constant CHANNEL_BITS : natural := bits(CHANNELS'HIGH);

    constant DATA_WIDTH : natural := dram1_data_o'LENGTH;
    constant ADDR_WIDTH : natural := dram1_address_o'LENGTH;
    constant FIFO_WIDTH : natural := DATA_WIDTH + ADDR_WIDTH;

    signal fifo_write_ready : std_logic_vector(CHANNELS);
    signal fifo_read_valid : std_logic_vector(CHANNELS);
    signal fifo_read_ready : std_logic_vector(CHANNELS);
    signal fifo_read_data : vector_array(CHANNELS)(FIFO_WIDTH-1 downto 0);

    signal input_data : vector_array(CHANNELS)(FIFO_WIDTH-1 downto 0);
    signal output_data : std_logic_vector(FIFO_WIDTH-1 downto 0);

begin
    fifo_gen : for c in CHANNELS generate
        -- Assemble incoming data into FIFO channels
        input_data(c)(DATA_WIDTH-1 downto 0) <= dsp_data_i(c);
        input_data(c)(FIFO_WIDTH-CHANNEL_BITS-1 downto DATA_WIDTH)
            <= std_logic_vector(dsp_address_i(c));
        input_data(c)(FIFO_WIDTH-1 downto FIFO_WIDTH-CHANNEL_BITS)
            <= std_logic_vector(to_unsigned(c, CHANNEL_BITS));


        -- One FIFO for each incoming channel
        fifo_inst : entity work.slow_memory_fifo generic map (
            FIFO_BITS => FIFO_BITS
        ) port map (
            clk_i => dsp_clk_i,

            write_valid_i => dsp_strobe_i(c),
            write_ready_o => fifo_write_ready(c),
            write_data_i => input_data(c),

            read_valid_o => fifo_read_valid(c),
            read_ready_i => fifo_read_ready(c),
            read_data_o => fifo_read_data(c)
        );
    end generate;


    -- Report error if FIFO not ready for input data (data lost)
    process (dsp_clk_i) begin
        if rising_edge(dsp_clk_i) then
            for c in CHANNELS loop
                dsp_error_o(c) <= dsp_strobe_i(c) and not fifo_write_ready(c);
            end loop;
        end if;
    end process;


    -- Priority multiplexer for output
    priority_inst : entity work.slow_memory_priority port map (
        clk_i => dsp_clk_i,

        input_valid_i => fifo_read_valid,
        input_ready_o => fifo_read_ready,
        data_i => fifo_read_data,

        output_ready_i => dram1_data_ready_i,
        output_valid_o => dram1_data_valid_o,
        data_o => output_data
    );


    -- Disassemble outgoing data
    dram1_data_o <= output_data(DATA_WIDTH-1 downto 0);
    dram1_address_o <= unsigned(output_data(FIFO_WIDTH-1 downto DATA_WIDTH));
end;
