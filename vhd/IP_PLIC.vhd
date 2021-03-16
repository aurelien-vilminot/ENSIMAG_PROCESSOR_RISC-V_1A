library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity IP_PLIC is
    port (
        -- Clock/Reset
        clk   : in  std_logic ;
        rst   : in  std_logic ;

        -- IRQ Interface
        meip  : out std_logic ;
        uart  : in  std_logic ;
        push  : in  std_logic ;

        -- Memory Slave Interface
        addr  : in  waddr ;
        size  : in  RF_SIZE_select ;
        datai : in  w32 ;
        datao : out w32 ;
        we    : in  std_logic ;
        ce    : in  std_logic
    );
end entity;

architecture RTL of IP_PLIC is
    -- Registre du PLIC
    signal PLIC_pending_d, PLIC_pending_q : w32 ;
    signal PLIC_enable_d , PLIC_enable_q  : w32 ;
    signal PLIC_claim_d  , PLIC_claim_q   : w32 ;

    signal tmp_datao_d, tmp_datao_q : w32 ;

    signal ADDR_word : waddr ;

    -- Fonction renvoyant la bonne valeur à store suivant si sw, sh ou sb est utilisé
    impure function reg_to_store (PLIC_reg_q : w32)
        return w32 is
        variable res : w32;
    begin
        res := PLIC_reg_q;
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

    synchrone: process (clk)
    begin
        if clk'event and clk = '1' then
            if rst = '1' then
                -- Alors on mets les registres à zéro par défaut
                PLIC_pending_q  <= w32_zero;
                PLIC_enable_q   <= w32_zero;
                PLIC_claim_q    <= w32_zero;
                tmp_datao_q     <= w32_zero;
            else 
                PLIC_pending_q <= PLIC_pending_d( 31 downto 1 ) & '0';
                PLIC_enable_q  <= PLIC_enable_d( 31 downto 1 )  & '0';
                PLIC_claim_q   <= PLIC_claim_d;
                tmp_datao_q    <= tmp_datao_d;
            end if;
        end if;
    end process synchrone;

    registre: process (all)
    begin
        -- Les registres reprennent la même valeur par défaut
        PLIC_pending_d <= PLIC_pending_q;
        PLIC_enable_d  <= PLIC_enable_q;
        PLIC_claim_d   <= PLIC_claim_q;
        tmp_datao_d    <= tmp_datao_q;

        if ce = '1' then
            case ADDR_word is
                -- Choix du registre :
                when x"0C00_1000" =>
                    -- Registre de pending
                    if we = '1' then
                        PLIC_pending_d <= reg_to_store(PLIC_pending_q);
                    end if;
                    tmp_datao_d <= PLIC_pending_q;

                when x"0C00_2000" =>
                    -- Registre pour enable les interruptions
                    if we = '1' then
                        PLIC_enable_d <= reg_to_store(PLIC_enable_q);
                    end if;
                    tmp_datao_d <= PLIC_enable_q;

                when x"0C20_0004" =>
                    -- Registre pour claim l'interruption
                    -- On vérifie si une écriture est demandé
                    if we = '1' then
                        PLIC_claim_d <= reg_to_store(PLIC_claim_q);
                    end if;
                    -- Lecture
                    tmp_datao_d <= PLIC_claim_q;
                    -- Une lecture est faite donc on doit claim l'interruption
                    -- Par défaut on remet le registre de claim à 0
                    PLIC_claim_d <= w32_zero;
                    case PLIC_claim_q( 1 downto 0 ) is
                        -- On décode le registre claim pour savoir quelle interruption
                        -- enlevé du pending
                        when "01" =>
                            -- Uart
                            PLIC_pending_d(1) <= '0';
                            if PLIC_pending_q(2) = '1' then
                                -- On reste en interruption tant que pending != 0
                                PLIC_claim_d( 1 downto 0 ) <= "10";
                            end if;
                        when "10" =>
                            -- Bouton poussoir
                            PLIC_pending_d(2) <= '0';
                            if PLIC_pending_q(1) = '1' then
                                -- On reste en interruption tant que pending != 0
                                PLIC_claim_d( 1 downto 0 ) <= "01";
                            end if;
                        when others => null;
                    end case;

                when others => null;
            end case;
        end if;

        -- Les interruptions arrivent de manière synchrone dans les registres
        if push = '1' then
            -- L'ID des bouttons poussoir est 2.
            PLIC_pending_d(2) <= push;
            if PLIC_claim_q = 0 then
                PLIC_claim_d( 1 downto 0 ) <= "10";
            end if;
        end if;
        -- On met l'uart en deuxième pour qu'elle soit prioritaire sur le push
        if uart = '1' then
            -- L'ID de l'UART est 1.
            PLIC_pending_d(1) <= uart;
            if PLIC_claim_q = 0 then
                PLIC_claim_d( 1 downto 0 ) <= "01";
            end if;
        end if;

        if not( (PLIC_pending_q and PLIC_enable_q) = 0 ) then
            meip <= '1';
        else
            meip <= '0';
        end if;

    end process registre;

end architecture;

