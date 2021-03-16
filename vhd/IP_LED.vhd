library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity IP_LED is
    port (
        -- Clock / Reset
        clk : in std_logic;
        rst : in std_logic;

        -- Memory Slave Interface
        addr  : in  waddr ;
        size  : in  RF_SIZE_select ;
        datai : in  w32 ;
        datao : out w32 ;
        we    : in  std_logic ;
        ce    : in  std_logic ;

        -- IOs
        led    : out unsigned( 3 downto 0 ) ;
        switch : in  unsigned( 2 downto 0 ) ;

        -- Debug Interface
        pout : in  w32
    );
end entity;


architecture RTL of IP_LED  is

    -- Registres memorry-mapped
    signal        led_q, led32       : unsigned( 31 downto 0 ) ;
    -- Le registre data_sel sert à choisir si les données qui vont sur les LEDs
    -- proviennent de pout ou si elles sont memory-mapped
    signal data_sel_q,en_led, en_sel : std_logic ;

begin

    synchrone: process (clk)
    begin
        if clk'event and clk='1' then
            if (rst='1') then
                led_q      <= (others => '0');
                data_sel_q <= '0';
            else
                if en_led = '1' then
                    led_q <= datai;
                end if;
                if en_sel = '1' then
                    data_sel_q <= datai(0);
                end if;
            end if;
        end if;
    end process synchrone;

    registre: process (all)
    begin
        datao  <= (others=>'0');
        en_led <= we and ce and not addr(2); 
        en_sel <= we and ce and addr(2);
        if (data_sel_q = '0') then
            led32 <= pout;
        else
            led32 <= led_q;
        end if;
        led    <= led32( (to_integer(switch)+1)*4-1 downto to_integer(switch)*4);
    end process registre;

end architecture;
