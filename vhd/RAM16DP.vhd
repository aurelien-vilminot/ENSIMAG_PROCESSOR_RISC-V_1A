library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

use work.PKG.all;


-- RAM 16 bits Dual Port
entity RAM16DP is
    generic (
        -- Memory configuration
        MEMORY_SIZE : integer ;

        -- Memory initialization
        FILE_NAME   : string  := "none"
    );
    port (
        -- Clock/Reset
        clkA  : in  std_logic ;
        clkB  : in  std_logic ;
        rstA  : in  std_logic ;
        rstB  : in  std_logic ;

        -- Port A: Memory slave interface
        addrA : in  waddr ;
        doA   : out w16 ;
        diA   : in  w16 ;
        ceA   : in  std_logic ;
        weA   : in  std_logic ;

        -- Port B: Memory slave interface
        addrB : in  waddr ;
        doB   : out w16 ;
        diB   : in  w16 ;
        ceB   : in  std_logic ;
        weB   : in  std_logic
    );
end entity;


architecture structural of RAM16DP is
    -- Utils
    function log2ceil ( x : positive ) return natural is
        variable i : natural := x-1 ;
        variable n : natural := 0 ;
    begin
        while i > 0 loop
            n := n + 1; i := i / 2;
        end loop;
        return n;
    end function;

    -- Constants
    constant N_BIT : natural := log2ceil( MEMORY_SIZE ) + 1 ;

    -- Signals
    signal s_diA : std_logic_vector ( w16'range ) ;
    signal s_diB : std_logic_vector ( w16'range ) ;
    signal s_doA : std_logic_vector ( w16'range ) ;
    signal s_doB : std_logic_vector ( w16'range ) ;
    signal s_weA : std_logic_vector ( 1 downto 0 ) ;
    signal s_weB : std_logic_vector ( 1 downto 0 ) ;
begin

    -- No byte strobes
    s_weA <= weA & weA ;
    s_weB <= weB & weB ;

    -- Unsigned to std_logic_sector
      doA <= unsigned(s_doA);
    s_diA <= std_logic_vector(diA);
      doB <= unsigned(s_doB);
    s_diB <= std_logic_vector(diB);


    -- Memory XPM True Dual Port RAM
    XPM_RAM : XPM_MEMORY_TDPRAM
        generic map (
            -- Memory configuration
            MEMORY_SIZE         => MEMORY_SIZE * 8, -- byte size -> bit size
            MEMORY_PRIMITIVE    => "block",
            MEMORY_OPTIMIZATION => "true",
            MEMORY_INIT_FILE    => FILE_NAME,
            USE_MEM_INIT        => 1,
            ECC_MODE            => "no_ecc",

            -- Port A: Port configuration
            ADDR_WIDTH_A        => N_BIT - 2,
            BYTE_WRITE_WIDTH_A  =>  8,
            WRITE_DATA_WIDTH_A  => 16,
            READ_DATA_WIDTH_A   => 16,
            WRITE_MODE_A        => "read_first",
            READ_LATENCY_A      => 1,

            --Port B: Port configuration
            ADDR_WIDTH_B        => N_BIT - 2,
            BYTE_WRITE_WIDTH_B  =>  8,
            WRITE_DATA_WIDTH_B  => 16,
            READ_DATA_WIDTH_B   => 16,
            WRITE_MODE_B        => "read_first",
            READ_LATENCY_B      => 1
        )
        port map (
            -- Clock/Reset
            clkA   => clkA,
            rstA   => rstA,
            clkB   => clkB,
            rstB   => rstB,
            sleep  => '0',

            -- Port A: Memory slave interface
            addrA  => std_logic_vector( addrA(N_BIT -1 downto 2) ),
            enA    => ceA,
            weA    => s_weA,
            dinA   => s_diA, 
            doutA  => s_doA,
            regceA => '0',

            -- Error injection : off
            sbiterrA       => open,
            dbiterrA       => open,
            injectsbiterrA => '0',
            injectdbiterrA => '0',

            -- Port B: Memory slave interface
            addrB  => std_logic_vector( addrB(N_BIT -1 downto 2) ),
            enB    => ceB,
            weB    => s_weB,
            dinB   => s_diB, 
            doutB  => s_doB,
            regceB => '0',

            -- Error injection : off
            sbiterrB       => open,
            dbiterrB       => open,
            injectsbiterrB => '0',
            injectdbiterrB => '0'
        );


end architecture;
