library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
    signal ext : std_logic;
    signal z : std_logic;
    signal s : std_logic;
    signal res : signed(32 downto 0);


begin

ext <= ((not IR(12)) and (not IR(6))) OR (IR(6) and (not IR(13)));
res <= signed(('0' & rs1)) - signed(('0' & alu_y)) when ext='0' else signed((rs1(31) & rs1)) - signed((alu_y(31) & alu_y));
s <= res(32);
z <= '1' when res=0 else '0';
jcond <= ((IR(12) XOR z) AND (NOT IR(14))) OR ((IR(12) XOR s) AND IR(14));
slt <= s;

end architecture;
