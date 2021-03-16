library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity IP_PIN is
    port (
        -- Clock/Reset
        clk : in std_logic ;
        rst : in std_logic ;

        -- Memory Slave Interface
        addr  : in  waddr ;
        size  : in  RF_SIZE_select ;
        datai : in  w32 ;
        datao : out w32 ;
        we    : in  std_logic ;
        ce    : in  std_logic ;

        -- IOs
        pin : in w32
    );
end entity;


architecture RTL of  IP_PIN is
    signal data_q: w32;
begin

    synchrone : process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                data_q <= (others=>'0');
                datao  <= (others=>'0');
            else
                data_q <= pin;
                datao  <= data_q;
            end if;
        end if;
    end process;

end architecture;
