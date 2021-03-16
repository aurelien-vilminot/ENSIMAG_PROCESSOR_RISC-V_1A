library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity PROC_bus is
    generic (
        N_SLAVE : integer ;
        base : waddr_vec ;
        high : waddr_vec
    );
    port (
        -- Clock/Reset
        clk : in std_logic ;
        rst : in std_logic ;

        -- Memory Slave Interface
        CPU_addr  : in  waddr ;
        CPU_size  : in  RF_SIZE_select ;
        CPU_datao : in  w32 ;
        CPU_datai : out w32 ;
        CPU_ce    : in  std_logic ;
        CPU_we    : in  std_logic ;

        -- Memory Master Interface
        ce    : out unsigned ( 0 to N_SLAVE-1 ) ;
        we    : out unsigned ( 0 to N_SLAVE-1 ) ;
        datai : in  w32_vec  ( 0 to N_SLAVE-1 )
    );
end entity;


architecture RTL of PROC_bus is
    signal ce_d, ce_q : unsigned(0 to N_SLAVE-1);
begin
---------------------------------------------------
    C_enable: process (CPU_ce, CPU_addr, CPU_we)
    begin
        for i in 0 to N_SLAVE-1 loop
            if CPU_ce='1' and (CPU_addr>=base(i) and CPU_addr<=high(i)) then
                ce_d(i) <= '1';
                we(i)   <= CPU_we;
            else
                ce_d(i) <= '0';
                we(i)   <= '0';
            end if;
        end loop; -- i
    end process;

    ce <= ce_d;

---------------------------------------------------
    synchrone : process (clk)
    begin
        if clk'event and clk='1' then 
            ce_q <= ce_d;
        end if;
    end process;

---------------------------------------------------
    Acces_lecture: process (ce_d, ce_q, datai)
        variable v,r : w32;
    begin
        r := (others=>'0');
        for i in 0 to N_SLAVE-1 loop
            v := (others=>'0');
            if ce_q(i)='1' then
                v := datai(i);
            end if;
            r:= r or v;
        end loop; -- i
        CPU_datai <= r;
    end process;
  
end architecture;
