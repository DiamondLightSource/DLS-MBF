-- Entity to min_max_sum storage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.support.all;
use work.defines.all;

use work.min_max_sum_defs.all;

entity min_max_sum_store is
    generic (
        UPDATE_DELAY : natural
    );
    port (
        clk_i : in std_logic;

        -- Selects bank used for updates and for readout
        bank_select_i : in std_logic;

        -- Continuous bunch by bunch update interface
        update_addr_i : in unsigned;
        update_data_o : out mms_row_t := mms_reset_value;
        update_data_i : in mms_row_t;

        -- Readout and reset interface.  Pulsing readout_strobe_i will advance
        -- the read pointer and reset the previously read value.  The current
        -- readout is valid until after this strobe is seen.
        readout_strobe_i : in std_logic;
        readout_addr_i : in unsigned;
        readout_data_o : out mms_row_t;
        readout_ack_o : out std_logic
    );
end;

architecture arch of min_max_sum_store is
    -- This is [0..1][rows]row, ie a three dimenstional array of bits
    type mms_row_array_t is array(natural range 0 to 1) of mms_row_t;

    -- Interface to two banks of memory
    signal read_addr : unsigned_array(0 to 1)(update_addr_i'RANGE)
        := (others => (others => '0'));
    signal read_data : mms_row_array_t;
    signal write_strobe : std_logic_vector(0 to 1) := "00";
    signal write_addr : unsigned_array(0 to 1)(update_addr_i'RANGE)
        := (others => (others => '0'));
    signal write_data : mms_row_array_t := (others => mms_reset_value);

    signal update_write_addr : update_addr_i'SUBTYPE;

    -- Bank selection
    signal read_addr_bank : natural range 0 to 1;
    signal read_data_bank_std : std_logic;
    signal read_data_bank : natural range 0 to 1;
    signal write_bank : natural range 0 to 1;
    signal write_bank_std : std_logic;

    -- Delay read_addr => read_data
    constant READ_DELAY : natural := 4;

    -- Skew from update read to write address:
    --  update_addr_i => update_write_addr and update_data_i must match:
    --  update_addr_i
    --      => read_addr(read_addr_bank)
    --      =(READ_DELAY)=> read_data(read_addr_bank)
    --      => update_data_o
    --      =(UPDATE_DELAY)=> update_data_i
    constant WRITE_DELAY : natural := READ_DELAY + UPDATE_DELAY + 2;

    -- Delay from readout_{strobe,addr}_i => readout_{data,ack}_o
    --  readout_strobe_i, readout_addr_i
    --      => read_addr(1-read_addr_bank)
    --      =(READ_DELAY)=> read_data(1-read_data_bank)
    --      => readout_data_o
    constant READOUT_DELAY : natural := READ_DELAY + 2;

begin
    -- Memory interface
    mem_gen : for i in 0 to 1 generate
        memory_inst : entity work.min_max_sum_memory generic map (
            READ_DELAY => READ_DELAY
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
    read_addr_bank <= to_integer(bank_select_i);
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Update read
            read_addr(read_addr_bank) <= update_addr_i;
            update_data_o <= read_data(read_data_bank);
            -- Update write
            write_strobe(write_bank) <= '1';
            write_addr(write_bank) <= update_write_addr;
            write_data(write_bank) <= update_data_i;

            -- Readout read
            read_addr(1 - read_addr_bank) <= readout_addr_i;
            readout_data_o <= read_data(1 - read_data_bank);
            -- Readout reset
            write_strobe(1 - write_bank) <= readout_strobe_i;
            write_addr(1 - write_bank) <= readout_addr_i;
            write_data(1 - write_bank) <= mms_reset_value;
        end if;
    end process;


    -- There are two sets of delays which need to be aligned.  First, the data
    -- bank must be aligned with the read address, which is a two tick delay,
    -- and secondly the write address must be delayed to align with the external
    -- update delay so that values are updated in place.
    --
    -- The following timing diagram illustrates this:
    --
    --  clk_i       /     /     /     /     /     /     /     /     /
    --  ra      ----X A   X----------------------------------------------------
    --  rab     ----X B   X----------------------------------------------------
    --  ra[B]   ----------X MA  X----------------------------------------------
    --                    |-- READ_DELAY -->|
    --  rd[B]   ----------------------------X MA  X----------------------------
    --  rdb     ----------------------------X B   X----------------------------
    --  ud_o    ----------------------------------------X MA  X----------------
    --                                      |---------->| UPDATE_DELAY
    --  ud_i    ----------------------------------------------X UMA X----------
    --  wa      ----------------------------------------------X A   X----------
    --  wb      ----------------------------------------------X B   X----------
    --              |--------- WRITE_DELAY ------------------>|
    --  wa[B]   ----------------------------------------------------X A   X----
    --  wd[B]   ----------------------------------------------------X UMA X----
    --
    -- ra = update_addr_i, rab = read_addr_bank, ra[B] = read_addr(B),
    -- rd[B] = read_data(B), rdb = read_data_bank, ud_o = update_data_o,
    -- ud_i = update_data_i, wa = update_write_addr, bw = write_bank,
    -- wa[B] = write_addr(B), wd[N] = write_data(B).

    dly_read_inst : entity work.dlyreg generic map (
        DLY => READ_DELAY + 1
    ) port map (
        clk_i => clk_i,
        data_i(0) => to_std_logic(read_addr_bank),
        data_o(0) => read_data_bank_std
    );
    read_data_bank <= to_integer(read_data_bank_std);

    dly_write_bank_inst : entity work.dlyreg generic map (
        DLY => WRITE_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => to_std_logic(read_addr_bank),
        data_o(0) => write_bank_std
    );
    write_bank <= to_integer(write_bank_std);

    dly_write_addr_inst : entity work.dlyline generic map (
        DLY => WRITE_DELAY,
        DW => update_addr_i'LENGTH
    ) port map (
        clk_i => clk_i,
        data_i => std_logic_vector(update_addr_i),
        unsigned(data_o) => update_write_addr
    );

    -- Also delay the readout_ack_o long enough for the next data word to be
    -- valid.
    --
    --  clk_i       /     /     /     /     /     /     /     /
    --               _____
    --  rs_i    ____/     \_____________________________________
    --
    --  ra        A       | A+1
    --  ra[B]     A             | A+1
    --  rd[B]     M[A]                      | M[A+1]
    --  rd_o      M[A]                            | M[A+1]
    --                                             _____
    --  ra_o    __________________________________/     \_______
    --
    -- rs_i = readout_strobe_i, ra = readout_addr_i, B = currently selected
    -- readout bank, ra[B] = read_addr(B), rd[B] = read_data(B),
    -- rd_o = readout_data_o, ra_o = readout_ack_o
    dly_readout_ack_inst : entity work.dlyline generic map (
        DLY => READOUT_DELAY
    ) port map (
        clk_i => clk_i,
        data_i(0) => readout_strobe_i,
        data_o(0) => readout_ack_o
    );
end;
