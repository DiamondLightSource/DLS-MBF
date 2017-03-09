-- Simple debug capture mechanism

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defines.all;
use work.support.all;

entity debug is
    generic (
        WIDTH : natural := 64;
        DEPTH : natural := 1024
    );
    port (
        clk_i : in std_logic;

        -- Capture interface: after triggering, capture_i is recorded for each
        -- clock tick on which enable_i is set.
        capture_i : in std_logic_vector(WIDTH-1 downto 0);
        enable_i : in std_logic;
        trigger_i : in std_logic;

        -- Readout and control interface.
        write_strobe_i : in std_logic;
        write_address_i : in unsigned;
        write_data_i : in reg_data_t;

        read_strobe_i : in std_logic;
        read_address_i : in unsigned;
        read_data_o : out reg_data_t;
        read_ack_o : out std_logic
    );
end;

architecture arch of debug is
    -- Capture memory.
    subtype capture_t is std_logic_vector(WIDTH-1 downto 0);
    type memory_t is array(0 to DEPTH-1) of capture_t;
    signal memory : memory_t;

    -- Pipelined input
    signal capture, capture_1 : capture_t;
    signal enable, enable_1 : std_logic;

    -- Capture state machine
    type state_t is (IDLE, ARMED, ACTIVE);
    signal state : state_t := IDLE;
    function to_vector(state : state_t) return std_logic_vector is
    begin
        case state is
            when IDLE   => return "00";
            when ARMED  => return "01";
            when ACTIVE => return "10";
        end case;
    end;

    subtype row_address_t is unsigned(bits(DEPTH-1)-1 downto 0);
    signal write_address : row_address_t;

    -- Memory readout
    constant COLUMNS : natural := WIDTH / 32;
    subtype col_address_t is unsigned(bits(COLUMNS-1)-1 downto 0);
    signal read_row_address : row_address_t;
    signal read_col_address : col_address_t;
    signal read_row : capture_t;
    signal read_word : reg_data_t;

    -- Decoded input events
    signal arm_event : boolean;     -- Arm capture
    signal reset_event : boolean;   -- Reset readout
    signal step_address : boolean;  -- Advance read address

begin
    -- Decode specific write events
    arm_event    <= write_strobe_i = '1' and write_address_i = 0;
    reset_event  <= write_strobe_i = '1' and write_address_i = 1;
    step_address <= write_strobe_i = '1' and write_address_i = 2;

    -- Capture
    process (clk_i) begin
        if rising_edge(clk_i) then
            -- Pipeline input to help memory
            capture_1 <= capture_i;
            enable_1 <= enable_i;
            capture <= capture_1;
            enable <= enable_1;

            case state is
                when IDLE =>
                    -- In the idle state a write to register 0 arms us
                    if arm_event then
                        state <= ARMED;
                        write_address <= (others => '0');
                    end if;
                when ARMED =>
                    -- When armed we go active on trigger
                    if trigger_i = '1' then
                        state <= ACTIVE;
                    end if;
                when ACTIVE =>
                    -- Capture valid data
                    if enable = '1' then
                        memory(to_integer(write_address)) <= capture;
                        write_address <= write_address + 1;
                        if write_address = DEPTH-1 then
                            state <= IDLE;
                        end if;
                    end if;
            end case;
        end if;
    end process;

    -- Memory readout
    process (clk_i) begin
        if rising_edge(clk_i) then
            read_row <= memory(to_integer(read_row_address));
            read_word <=
                read_field(read_row, 32, 32 * to_integer(read_col_address));

            if step_address then
                if read_col_address = COLUMNS-1 then
                    read_col_address <= (others => '0');
                    read_row_address <= read_row_address + 1;
                else
                    read_col_address <= read_col_address + 1;
                end if;
            elsif state = ARMED or reset_event then
                read_col_address <= (others => '0');
                read_row_address <= (others => '0');
            end if;
        end if;
    end process;

    -- Register reads
    process (clk_i) begin
        if rising_edge(clk_i) then
            case to_integer(read_address_i) is
                when 0 =>
                    -- Return status register
                    read_data_o(1 downto 0) <= to_vector(state);
                    read_data_o(31 downto 2) <= (others => '0');
                when 1 =>
                    -- Return memory width
                    read_data_o <= std_logic_vector(to_unsigned(WIDTH, 32));
                when 2 =>
                    -- Return memory depth
                    read_data_o <= std_logic_vector(to_unsigned(DEPTH, 32));
                when 4 =>
                    read_data_o <=
                        std_logic_vector(resize(read_row_address, 32));
                when 5 =>
                    read_data_o <=
                        std_logic_vector(resize(read_col_address, 32));
                when 8 =>
                    read_data_o <= read_word;
                when others =>
                    read_data_o <= (others => '0');
            end case;
        end if;
    end process;

    read_ack_o <= '1';
end;
