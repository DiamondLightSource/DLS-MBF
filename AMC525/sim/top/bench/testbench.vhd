library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity testbench is
end testbench;


architecture arch of testbench is
    signal ULED : std_logic_vector(3 downto 0);
    signal nCOLDRST : std_logic;
    signal AMC_RX_P : std_logic_vector(11 downto 4);
    signal AMC_RX_N : std_logic_vector(11 downto 4);
    signal AMC_TX_P : std_logic_vector(11 downto 4);
    signal AMC_TX_N : std_logic_vector(11 downto 4);
    signal FCLKA_P : std_logic;
    signal FCLKA_N : std_logic;
    signal C0_DDR3_DQ : std_logic_vector(63 downto 0);
    signal C0_DDR3_DQS_P : std_logic_vector(7 downto 0);
    signal C0_DDR3_DQS_N : std_logic_vector(7 downto 0);
    signal C0_DDR3_ADDR : std_logic_vector(14 downto 0);
    signal C0_DDR3_BA : std_logic_vector(2 downto 0);
    signal C0_DDR3_RAS_N : std_logic;
    signal C0_DDR3_CAS_N : std_logic;
    signal C0_DDR3_WE_N : std_logic;
    signal C0_DDR3_RESET_N : std_logic;
    signal C0_DDR3_CK_P : std_logic_vector(0 to 0);
    signal C0_DDR3_CK_N : std_logic_vector(0 to 0);
    signal C0_DDR3_CKE : std_logic_vector(0 to 0);
    signal C0_DDR3_DM : std_logic_vector(7 downto 0);
    signal C0_DDR3_ODT : std_logic_vector(0 to 0);
    signal CLK533MHZ1_P : std_logic;
    signal CLK533MHZ1_N : std_logic;
    signal C1_DDR3_DQ : std_logic_vector(15 downto 0);
    signal C1_DDR3_DQS_P : std_logic_vector(1 downto 0);
    signal C1_DDR3_DQS_N : std_logic_vector(1 downto 0);
    signal C1_DDR3_ADDR : std_logic_vector(12 downto 0);
    signal C1_DDR3_BA : std_logic_vector(2 downto 0);
    signal C1_DDR3_RAS_N : std_logic;
    signal C1_DDR3_CAS_N : std_logic;
    signal C1_DDR3_WE_N : std_logic;
    signal C1_DDR3_RESET_N : std_logic;
    signal C1_DDR3_CK_P : std_logic_vector(0 to 0);
    signal C1_DDR3_CK_N : std_logic_vector(0 to 0);
    signal C1_DDR3_CKE : std_logic_vector(0 to 0);
    signal C1_DDR3_DM : std_logic_vector(1 downto 0);
    signal C1_DDR3_ODT : std_logic_vector(0 to 0);
    signal CLK533MHZ0_P : std_logic;
    signal CLK533MHZ0_N : std_logic;
    signal CLK125MHZ0_P : std_logic := '0';
    signal CLK125MHZ0_N : std_logic := '1';
    signal FMC0_LA_P : std_logic_vector(0 to 33);
    signal FMC0_LA_N : std_logic_vector(0 to 33);
    signal FMC1_LA_P : std_logic_vector(0 to 33);
    signal FMC1_LA_N : std_logic_vector(0 to 33);
    signal FMC1_HB_P : std_logic_vector(0 to 21);
    signal FMC1_HB_N : std_logic_vector(0 to 21);

begin
    CLK125MHZ0_P <= not CLK125MHZ0_P after 4 ns;
    CLK125MHZ0_N <= not CLK125MHZ0_N after 4 ns;

    top: entity work.top port map (
        ULED => ULED,
        nCOLDRST => nCOLDRST,
        AMC_RX_P => AMC_RX_P,
        AMC_RX_N => AMC_RX_N,
        AMC_TX_P => AMC_TX_P,
        AMC_TX_N => AMC_TX_N,
        FCLKA_P => FCLKA_P,
        FCLKA_N => FCLKA_N,
        C0_DDR3_DQ => C0_DDR3_DQ,
        C0_DDR3_DQS_P => C0_DDR3_DQS_P,
        C0_DDR3_DQS_N => C0_DDR3_DQS_N,
        C0_DDR3_ADDR => C0_DDR3_ADDR,
        C0_DDR3_BA => C0_DDR3_BA,
        C0_DDR3_RAS_N => C0_DDR3_RAS_N,
        C0_DDR3_CAS_N => C0_DDR3_CAS_N,
        C0_DDR3_WE_N => C0_DDR3_WE_N,
        C0_DDR3_RESET_N => C0_DDR3_RESET_N,
        C0_DDR3_CK_P => C0_DDR3_CK_P,
        C0_DDR3_CK_N => C0_DDR3_CK_N,
        C0_DDR3_CKE => C0_DDR3_CKE,
        C0_DDR3_DM => C0_DDR3_DM,
        C0_DDR3_ODT => C0_DDR3_ODT,
        CLK533MHZ1_P => CLK533MHZ1_P,
        CLK533MHZ1_N => CLK533MHZ1_N,
        C1_DDR3_DQ => C1_DDR3_DQ,
        C1_DDR3_DQS_P => C1_DDR3_DQS_P,
        C1_DDR3_DQS_N => C1_DDR3_DQS_N,
        C1_DDR3_ADDR => C1_DDR3_ADDR,
        C1_DDR3_BA => C1_DDR3_BA,
        C1_DDR3_RAS_N => C1_DDR3_RAS_N,
        C1_DDR3_CAS_N => C1_DDR3_CAS_N,
        C1_DDR3_WE_N => C1_DDR3_WE_N,
        C1_DDR3_RESET_N => C1_DDR3_RESET_N,
        C1_DDR3_CK_P => C1_DDR3_CK_P,
        C1_DDR3_CK_N => C1_DDR3_CK_N,
        C1_DDR3_CKE => C1_DDR3_CKE,
        C1_DDR3_DM => C1_DDR3_DM,
        C1_DDR3_ODT => C1_DDR3_ODT,
        CLK533MHZ0_P => CLK533MHZ0_P,
        CLK533MHZ0_N => CLK533MHZ0_N,
        CLK125MHZ0_P => CLK125MHZ0_P,
        CLK125MHZ0_N => CLK125MHZ0_N,
        FMC0_LA_P => FMC0_LA_P,
        FMC0_LA_N => FMC0_LA_N,
        FMC1_LA_P => FMC1_LA_P,
        FMC1_LA_N => FMC1_LA_N,
        FMC1_HB_P => FMC1_HB_P,
        FMC1_HB_N => FMC1_HB_N
    );
end;
