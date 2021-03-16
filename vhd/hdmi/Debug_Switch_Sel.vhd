library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debug_Switch_Sel is
	port (
		debug_signal0 :	in std_logic_vector (3 downto 0);
		debug_signal1 :	in std_logic_vector (3 downto 0);
		debug_signal2 :	in std_logic_vector (3 downto 0);
		debug_signal3 :	in std_logic_vector (3 downto 0);
		debug_signal4 :	in std_logic_vector (3 downto 0);
		debug_signal5 :	in std_logic_vector (3 downto 0);
		debug_signal6 :	in std_logic_vector (3 downto 0);
		debug_signal7 :	in std_logic_vector (3 downto 0);
		debug_signal8 :	in std_logic_vector (3 downto 0);
		debug_signal9 :	in std_logic_vector (3 downto 0);
		debug_signal10 : in std_logic_vector (3 downto 0);
		debug_signal11 : in std_logic_vector (3 downto 0);
		debug_signal12 : in std_logic_vector (3 downto 0);
		debug_signal13 : in std_logic_vector (3 downto 0);
		debug_signal14 : in std_logic_vector (3 downto 0);
		debug_signal15 : in std_logic_vector (3 downto 0);
		debug_switches : in std_logic_vector(3 downto 0);
		debug_leds : out std_logic_vector (3 downto 0)
	);
end entity;

architecture behavior of Debug_Switch_Sel is
	signal switch_mode : unsigned(3 downto 0);
	signal switch_mode4 : unsigned(5 downto 0);
begin
	switch_mode <= unsigned(debug_switches);

	process (debug_switches,
		debug_signal0,
		debug_signal1,
		debug_signal2,
		debug_signal3,
		debug_signal4,
		debug_signal5,
		debug_signal6,
		debug_signal7,
		debug_signal8,
		debug_signal9,
		debug_signal10,
		debug_signal11,
		debug_signal12,
		debug_signal13,
		debug_signal14,
		debug_signal15) is
	begin
		case debug_switches is
		
		when "0000" =>
			debug_leds <= debug_signal0;
		when "0001" =>
			debug_leds <= debug_signal1;
		when "0010" =>
			debug_leds <= debug_signal2;
		when "0011" =>
			debug_leds <= debug_signal3;
		when "0100" =>
			debug_leds <= debug_signal4;
		when "0101" =>
			debug_leds <= debug_signal5;
		when "0110" =>
			debug_leds <= debug_signal6;
		when "0111" =>
			debug_leds <= debug_signal7;
		when "1000" =>
			debug_leds <= debug_signal8;
		when "1001" =>
			debug_leds <= debug_signal9;
		when "1010" =>
			debug_leds <= debug_signal10;
		when "1011" =>
			debug_leds <= debug_signal11;
		when "1100" =>
			debug_leds <= debug_signal12;
		when "1101" =>
			debug_leds <= debug_signal13;
		when "1110" =>
			debug_leds <= debug_signal14;
		when "1111" =>
			debug_leds <= debug_signal15;
		end case;	
	end process;
end architecture;


