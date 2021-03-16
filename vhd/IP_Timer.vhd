library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity IP_Timer is
    port (
        -- Clock/Reset
        clk : in  std_logic ;
        rst : in  std_logic ;

        -- Memory Slave Interface
        ad    : in  waddr ;
        datai : in  w32 ;
        datao : out w32 ;
        we    : in  std_logic ;
        ce    : in  std_logic
    );
end entity;


architecture RTL of IP_Timer  is
    constant period_timer_simu : integer := 20000;
    constant period_timer_synth : integer := 75000000;
    constant period_timer : integer := period_timer_simu * val_simu +
                                       period_timer_synth * (1-val_simu);
    signal counter_d, counter_q: integer range 0 to period_timer-1;
    signal period_q: integer range 0 to period_timer-1;
    signal start_q: integer range 0 to period_timer-1;

    signal etat_q : w32;
begin

    synchrone: process (clk)
    begin
        if clk'event and clk='1' then
            if (rst='1') then
                etat_q <= (others => '0');
                counter_q <= 0;
                period_q <= period_timer-1;
                start_q <= 13;
            else
                if counter_q =  period_q then
                    counter_q <= 0;
                else
                    counter_q <= counter_q+1;
                end if;
                if counter_q < start_q then  	-- premiers cycles à zéro
                    etat_q <= (others => '0');
                else
                    etat_q <= (others => '1');
                end if;
                if we='1' then
                    if ad(2)='0' then
                        period_q <= to_integer(datai);
                        counter_q <= 0;
                    end if;
                    if ad(2)='1' then
                        start_q <= to_integer(datai);
                    end if;
                end if;
            end if;
        end if;
    end process;

    datao <= etat_q;

end architecture;
