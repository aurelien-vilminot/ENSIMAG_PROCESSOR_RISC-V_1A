library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG.all;


entity IP_ITpush is
    port (
        -- Clock/Reset
        clk  : in  std_logic ;
        rst  : in  std_logic ;

        -- IOs
        push : in  std_logic ;
        irq  : out std_logic
    );
end entity;


architecture RTL of IP_ITpush is
    signal delai1 : std_logic;
    signal delai2 : std_logic;
    signal compteur : unsigned(3 downto 0);
begin

    process (clk)
    begin
        if rst = '1' then
            delai1 <= '0';
            delai2 <= '0';
        elsif rising_edge(clk) then
            delai1 <= push;
            delai2 <= delai1;
        end if;
    end process;

    process (clk)
    begin
        if rst = '1' then
            compteur <= B"0000";
        elsif rising_edge(clk) then
            if ((not(push) and not(delai1) and delai2) = '1') then
                compteur <= X"F";
            elsif compteur /= 0 then
                compteur <= compteur - 1;
            end if;
        end if;
    end process;

    irq <= '1' when (compteur /= 0) else '0';

end architecture;
