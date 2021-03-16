library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity IP_CLINT is
    port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- IRQ Interface
        irq    : out std_logic ;
        mtip   : out std_logic ;
        mie    : in  w32 ;
        mip    : in  w32 ;
        mcause : out w32 ;

        -- Memory Slave Interface
        addr   : in  waddr ;
        size   : in  RF_SIZE_select ;
        datai  : in  w32 ;
        datao  : out w32 ;
        we     : in  std_logic ;
        ce     : in  std_logic
    );
end entity;

architecture RTL of IP_CLINT is
    signal mtime_d,    mtime_q    : unsigned( 63 downto 0 ) ;
    signal mtimecmp_d, mtimecmp_q : unsigned( 63 downto 0 ) ;
    signal mtip_d,     mtip_q     : std_logic ;

    signal tmp_datao_d, tmp_datao_q : w32 ;

    signal ADDR_word : waddr ;

    -- Fonction renvoyant la bonne valeur à store suivant si sw, sh ou sb est utilisé
    impure function reg_to_store (CLINT_reg_q : w32)
        return w32 is
        variable res : w32;
    begin
        res := CLINT_reg_q;
        if addr(1) = '0' then
            if addr(0) = '0' then
                case size is
                    when RF_SIZE_word =>
                        res := datai;
                    when RF_SIZE_half =>
                        res( 15 downto 0 ) := datai( 15 downto 0 );
                    when RF_SIZE_byte =>
                        res( 7 downto 0 )  := datai( 7 downto 0 );
                    when others => null;
                end case;
            else
                if size = RF_SIZE_byte then
                    res( 15 downto 8 ) := datai( 7 downto 0 );
                end if;
            end if;
        else
            if addr(0) = '0' then
                case size is
                    when RF_SIZE_half =>
                        res( 31 downto 16 ) := datai( 15 downto 0 );
                    when RF_SIZE_byte =>
                        res( 23 downto 16 ) := datai( 7 downto 0 );
                    when others => null;
                end case;
            else
                if size = RF_SIZE_byte then
                    res( 31 downto 24 ) := datai( 7 downto 0 );
                end if;
            end if;
        end if;
        return res;
    end function reg_to_store;
begin

    ADDR_word <= addr( 31 downto 2 ) & "00"; 
    datao <= tmp_datao_q;

    mtip <= mtip_q;

    synchrone: process (clk)
    begin
        if clk'event and clk = '1' then
            if rst = '1' then
                mtime_q     <= ( others => '0' );
                mtip_q      <= '0';
                tmp_datao_q <= w32_zero;
            else
                mtime_q     <= mtime_d;
                mtimecmp_q  <= mtimecmp_d;
                mtip_q      <= mtip_d;
                tmp_datao_q <= tmp_datao_d;
            end if;
        end if;
    end process synchrone;
        
    registre: process (all)
    begin
        -- Les registres reprennent la même valeur par défaut
        mtimecmp_d  <= mtimecmp_q;
        mtip_d      <= mtip_q;
        tmp_datao_d <= tmp_datao_q;
        -- Sauf mtime qui est incrémenté de 1
        mtime_d <= mtime_q + 1;

        if mtime_q < mtimecmp_q then
            mtip_d <= '0';
        else
            mtip_d <= '1';
        end if;
        
        if ce = '1' then
            case ADDR_word is
                -- Choix du registre :
                when x"0200_4000" =>
                    -- Registre timercmp low
                    -- On vérifie si une écriture est demandé
                    if we = '1' then
                        mtimecmp_d( 31 downto 0 ) <= reg_to_store(mtimecmp_q( 31 downto 0 ));
                        -- Une écriture est faite donc on doit claim l'interruption
                        mtip_d <= '0';
                    end if;
                    -- Lecture
                    tmp_datao_d <= mtimecmp_q( 31 downto 0 );

                when x"0200_4004" =>
                    -- Registre timercmp high
                    -- On vérifie si une écriture est demandé
                    if we = '1' then
                        mtimecmp_d( 63 downto 32 ) <= reg_to_store(mtimecmp_q( 63 downto 32 ));
                        -- Une écriture est faite donc on doit claim l'interruption
                        mtip_d <= '0';
                    end if;
                    -- Lecture
                    tmp_datao_d <= mtimecmp_q( 63 downto 32 );

                when x"0200_BFF8" =>
                    -- Registre timer low
                    -- On vérifie si une écriture est demandé
                    if we ='1' then
                        mtime_d( 31 downto 0 ) <= reg_to_store(mtime_q( 31 downto 0 ));
                    end if;
                    -- Lecture
                    tmp_datao_d <= mtime_q( 31 downto 0 );

                when x"0200_BFFC" =>
                    -- Registre timer high
                    -- On vérifie si une écriture est demandé
                    if we = '1' then
                        mtime_d( 63 downto 32 ) <= reg_to_store(mtime_q( 63 downto 32 ));
                    end if;
                    -- Lecture
                    tmp_datao_d <= mtime_q( 63 downto 32 );

                when others => null;
            end case;
        end if;

        mcause <= w32_zero;
        if not( (mie and mip) = 0) then
            irq <= '1';
            if ( mie(11) and mip(11) ) = '1' then
                mcause(11) <= '1';
                mcause(31) <= '1';
            else
                if ( mie(7) and mip(7) ) = '1' then
                    mcause(7) <= '1';
                    mcause(31) <= '1';
                end if;
            end if;
        else
            irq <= '0';
        end if;

    end process registre;

end architecture;
