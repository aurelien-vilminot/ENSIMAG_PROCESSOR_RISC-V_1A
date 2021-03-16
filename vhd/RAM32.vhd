library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

use work.PKG.all;


-- RAM 32 bits
entity RAM32 is
    generic (
        -- Memory configuration
        MEMORY_SIZE : integer ;

        -- Memory initialization
        FILE_NAME   : string  := "none"
    );
    port (
        -- Clock/Reset
        clk  : in  std_logic ;
        rst  : in  std_logic ;

        -- Memory slave interface
        addr : in  waddr ;
        size : in  RF_SIZE_select;
        do   : out w32 ;
        di   : in  w32 ;
        ce   : in  std_logic ;
        we   : in  std_logic
    );
end entity;


architecture behavioral of RAM32 is
    -- Utils
    function log2ceil (x:positive) return natural is
        variable i : natural := x-1 ;
        variable n : natural := 0 ;
    begin
        while i > 0 loop
            n := n + 1; i := i / 2;
        end loop;
        return n;
    end function;

    -- Constants
    constant N_BIT : natural := log2ceil( MEMORY_SIZE ) ;

    -- Signals
    signal s_we : std_logic_vector ( 3 downto 0 ) ;
    signal s_do : std_logic_vector ( 31 downto 0 ) ;
    signal s_di : std_logic_vector ( 31 downto 0 ) ;

    -- Signaux pour sh et sb
    signal DATA_tmp               : w32       := w32_zero;
    signal we_0, we_1, we_2, we_3 : std_logic := '0';
begin

    store : process(we,di,addr,size)
    begin
        -- Les we valent par défaut 0
        we_0 <= '0';
        we_1 <= '0';
        we_2 <= '0';
        we_3 <= '0';

        DATA_tmp <= di;
        -- Le we ce fait sur 4 bit afin de pouvoir choisir
        -- le we sur chaque sous octet du mot
        if addr(1) = '0' then
            if addr(0) = '0' then
                case size is
                    when RF_SIZE_word =>
                        we_0 <= we;
                        we_1 <= we;
                        we_2 <= we;
                        we_3 <= we;
                    when RF_SIZE_half =>
                        we_0 <= we;
                        we_1 <= we;
                    when RF_SIZE_byte =>
                        we_0 <= we;
                    when others => null;
                end case;
            else
                if size = RF_SIZE_byte then
                    we_1 <= we;
                    DATA_tmp( 15 downto 8 ) <= di( 7 downto 0 );
                end if;
            end if;
        else
            if addr(0) = '0' then
                case size is
                    when RF_SIZE_half =>
                        we_2 <= we;
                        we_3 <= we;
                        DATA_tmp( 31 downto 16 ) <= di( 15 downto 0 );
                    when RF_SIZE_byte =>
                        we_2 <= we;
                        DATA_tmp( 23 downto 16 ) <= di( 7 downto 0 );
                    when others => null;
                end case;
            else
                if size = RF_SIZE_byte then
                    we_3 <= we;
                    DATA_tmp( 31 downto 24 ) <= di( 7 downto 0 );
                end if;
            end if;
        end if;
    end process store;

    s_we <= we_3 & we_2 & we_1 & we_0;

    -- Internal signals -> ports
    do <= unsigned(s_do(w32'range));
    s_di <= std_logic_vector(DATA_tmp);

    -- Memory block (XPM memory)
    --
    -- Documentation:
    -- https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug974-vivado-ultrascale-libraries.pdf
    -- pages 89 to 99
    XPM_RAM : XPM_MEMORY_SPRAM
        generic map (
            -- Memory configuration
            MEMORY_SIZE         => MEMORY_SIZE * 8, -- byte size -> bit size
            MEMORY_PRIMITIVE    => "block", -- Must be set to "block" for updatemem
            MEMORY_OPTIMIZATION => "true",
            MEMORY_INIT_FILE    => FILE_NAME,
            USE_MEM_INIT        => 1,
            ECC_MODE            => "no_ecc",

            -- Ports configuration
            ADDR_WIDTH_A        => N_BIT-2,
            BYTE_WRITE_WIDTH_A  => 8, -- /!\ Do not set to 32 ! updatemem is unable to fill memory with 32bit bytes
            WRITE_DATA_WIDTH_A  => 32,
            READ_DATA_WIDTH_A   => 32,
            WRITE_MODE_A        => "read_first",
            READ_LATENCY_A      => 1  -- Number of buffer on the read path. (Might be used to reduce critical path)
        )
        port map (
            -- Clock/Reset
            clkA   => clk,
            rstA   => rst,
            sleep  => '0',

            -- Memory slave interface
            addrA  => std_logic_vector( addr(N_BIT -1 downto 2) ),
            enA    => ce,
            weA    => s_we,
            dinA   => s_di, 
            doutA  => s_do,
            regceA => '0',

            -- Error injection : off
            sbiterrA       => open,
            dbiterrA       => open,
            injectsbiterrA => '0',
            injectdbiterrA => '0'
        );


end architecture;
