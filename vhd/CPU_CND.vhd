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
    -- signal rs1_ext : signed(32 downto 0);
    -- signal ALU_Y_ext : signed(32 downto 0);
    signal res : unsigned(32 downto 0);


begin

ext <= (not(IR(12) and not(IR(6)))) OR (IR(6) and not(IR(13)));
res <= ('0' & rs1) - ('0' & alu_y) when ext='0' else (rs1(31) & rs1) - (alu_y(31) & alu_y);
s <= res(32);
z <= '1' when res=0 else '0';
jcond <= ((IR(12) XOR z) AND NOT(IR(14))) OR ((IR(12) XOR s) AND IR(14));
slt <= s;


    -- -- Notre partie
    -- ext <= (NOT(IR(12)) AND NOT(IR(6))) OR (NOT(IR(13)) AND IR(6));
    -- rs1_ext <= signed('1'&rs1) when ext='1' AND rs1(31)='1' else signed('0'&rs1);
    -- ALU_Y_ext <= signed('1'&alu_y) when ext ='1' AND rs1(31)='1' else signed('0'&alu_y);
	-- -- A relire ce qui est au dessus, s'assurer que c'est bon !!!!!!
    -- res <= rs1_ext - ALU_Y_ext;
    -- z <= '1' when res=0 else '0';
    -- s <= res(32);
    -- jcond <= ((IR(12) XOR z) AND NOT(IR(14))) OR ((IR(12) XOR s) AND IR(14));
    -- slt <= s;

end architecture;
