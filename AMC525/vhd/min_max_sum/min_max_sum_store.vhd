-- Entity to min_max_sum storage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;
use work.defines.all;

use work.min_max_sum_defs.all;

entity min_max_sum_store is
    generic (
        ADDR_BITS : natural;
        UPDATE_DELAY : natural
    );
    port (
        clk_i : in std_logic;

        -- Bank switching and address control
        bunch_reset_i : in std_logic;
        switch_request_i : in std_logic;
        switch_done_o : out std_logic;

        -- Continuous bunch by bunch update interface
        update_data_o : out mms_row_channels_t;
        update_data_i : in mms_row_channels_t;

        -- Readout and reset interface.  Pulsing readout_strobe_i will advance
        -- the read pointer and reset the previously read value.  The current
        -- readout is valid until after this strobe is seen.
        readout_strobe_i : in std_logic;
        readout_data_o : out mms_row_channels_t;
        readout_ack_o : out std_logic;
        readout_reset_data_i : in mms_row_channels_t
    );
end;

architecture min_max_sum_store of min_max_sum_store is
    -- This is [0..1][channels][rows]row, ie a four dimenstional array of bits
    type mms_row_array_t is array(natural range 0 to 1) of mms_row_channels_t;

    -- Interface to two banks of memory
    signal read_addr : unsigned_array(0 to 1)(ADDR_BITS-1 downto 0);
    signal read_data : mms_row_array_t;
    signal write_strobe : std_logic_vector(0 to 1);
    signal write_addr : unsigned_array(0 to 1)(ADDR_BITS-1 downto 0);
    signal write_data : mms_row_array_t;

    -- Bunch by bunch update and readout addresses
    signal update_read_addr : unsigned(ADDR_BITS-1 downto 0) := (others => '0');
    signal update_write_addr : unsigned(ADDR_BITS-1 downto 0);
    signal readout_addr : unsigned(ADDR_BITS-1 downto 0) := (others => '0');

    -- Bank selection
    signal read_addr_bank : natural range 0 to 1 := 0;
    signal read_data_bank : natural range 0 to 1;
    signal write_bank : natural range 0 to 1;

    -- Skew from update read to write address
    constant WRITE_DELAY : natural := 3 + UPDATE_DELAY;

    -- Bank switching control
    signal switch_request : boolean := false;
    signal switch_done : std_logic := '0';

begin
    -- Memory interface
    mem_gen : for i in 0 to 1 generate
        memory_inst : entity work.min_max_sum_memory generic map (
            ADDR_BITS => ADDR_BITS
        ) port map (
            clk_i => clk_i,
            read_addr_i => read_addr(i),
            read_data_o => read_data(i),
            write_strobe_i => write_strobe(i),
            write_addr_i => write_addr(i),
            write_data_i => write_data(i)
        );
    end generate;

    -- Multiplexing memory interface: update bank and readout bank
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Update read
            read_addr(read_addr_bank) <= update_read_addr;
            update_data_o <= read_data(read_data_bank);
            -- Update write
            write_strobe(write_bank) <= '1';
            write_addr(write_bank) <= update_write_addr;
            write_data(write_bank) <= update_data_i;

            -- Readout read
            read_addr(1 - read_addr_bank) <= readout_addr;
            readout_data_o <= read_data(1 - read_data_bank);
            -- Readout reset
            write_strobe(1 - write_bank) <= readout_strobe_i;
            write_addr(1 - write_bank) <= readout_addr;
            write_data(1 - write_bank) <= readout_reset_data_i;
        end if;
    end process;


    -- There are two sets of delays which need to be aligned.  First, the data
    -- bank must be aligned with the read address, which is a two tick delay,
    -- and secondly the write address must be delayed to align with the external
    -- update delay so that values are updated in place.
    --
    -- The following timing diagram illustrates this:
    --
    --  clk_i       /     /     /     / ... /     /    /     /
    --  ra      ----X A   X-------------------------------------
    --  rab     ----X B   X-------------------------------------
    --  ra[B]   ----------X MA  X-------------------------------
    --  rd[B]   ----------------X MA  X-------------------------
    --  rdb     ----------------X B   X-------------------------
    --  ud_o    ----------------------X MA  X-------------------
    --                                |---->| UPDATE_DELAY
    --  ud_i    ----------------------------X UMA X-------------
    --  wa      ----------------------------X A   X-------------
    --  wb      ----------------------------X B   X-------------
    --  wa[B]   ----------------------------------X A   X-------
    --  wd[B]   ----------------------------------X UMA X-------
    --
    -- ra = update_read_addr, rab = read_addr_bank, ra[B] = read_addr(B),
    -- rd[B] = read_data(B), rdb = read_data_bank, ud_o = update_data_o,
    -- ud_i = update_data_i, wa = update_write_addr, bw = write_bank,
    -- wa[B] = write_addr(B), wd[N] = write_data(B).
    dly_read_inst : entity work.dlyline generic map (
        DLY => 2
    ) port map (
        clk_i => clk_i,
        data_i(0) => to_std_logic(read_addr_bank),
        to_integer(data_o(0)) => read_data_bank
    );
    dly_write_bank_inst : entity work.dlyline generic map (
        DLY => WRITE_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => to_std_logic(read_addr_bank),
        to_integer(data_o(0)) => write_bank
    );
    dly_write_addr_inst : entity work.dlyline generic map (
        DLY => WRITE_DELAY,
        DW => ADDR_BITS
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(update_read_addr),
        unsigned(data_o) => update_write_addr
    );

    -- Also delay the readout_ack_o long enough for the next data word to be
    -- valid.
    --
    --  clk_i       /     /     /     /     /     /    /     /
    --               _____
    --  rs_i    ____/     \_____________________________________
    --
    --  ra        A       | A+1
    --  ra[B]     A             | A+1
    --  rd[B]     M[A]                | M[A+1]
    --  rd_o      M[A]                      | M[A+1]
    --                                       _____
    --  ra_o    ____________________________/     \_____________
    --
    -- rs_i = readout_strobe_i, ra = readout_addr, B = currently selected
    -- readout bank, ra[B] = read_addr(B), rd[B] = read_data(B),
    -- rd_o = readout_data_o, ra_o = readout_ack_o
    dly_readout_ack_inst : entity work.dlyline generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => readout_strobe_i,
        data_o(0) => readout_ack_o
    );


    -- Addresses computation and advance.  The update address always advances,
    -- except when it loops back on the bunch reset.  The readout address
    -- advances on each read strobe, and is reset when a bank switch request
    -- is received.
    process (clk_i) begin
        if rising_edge(clk_i) then
            if bunch_reset_i = '1' then
                update_read_addr <= (others => '0');
            else
                update_read_addr <= update_read_addr + 1;
            end if;

            if switch_request_i = '1' then
                readout_addr <= (others => '0');
            elsif readout_strobe_i = '1' then
                readout_addr <= readout_addr + 1;
            end if;
        end if;
    end process;


    -- Bank switching.  On receipt of a bank switch request we wait for a bunch
    -- reset event.  This ensures that the first update will always be to cell
    -- zero.
    process (clk_i) begin
        if rising_edge(clk_i) then
            if switch_request_i then
                switch_request <= true;
                switch_done <= '0';
            elsif switch_request and bunch_reset_i = '1' then
                read_addr_bank <= 1 - read_addr_bank;
                switch_request <= false;
                switch_done <= '1';
            else
                switch_done <= '0';
            end if;
        end if;
    end process;
    -- Need to delay the switch done a little.
    switch_done_dly : entity work.dlyline generic map (
        DLY => 4
    ) port map (
        clk_i => clk_i,
        data_i(0) => switch_done,
        data_o(0) => switch_done_o
    );
end;
