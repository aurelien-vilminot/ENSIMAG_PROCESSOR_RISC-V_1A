library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.HDMI_pkg.all;

entity HDMI_Controller is
	port (
		pixel_clk : in std_logic;
		tmds_clk : in std_logic;
		rst : in std_logic;
		hpd : in std_logic;

		channel : out std_logic_vector(2 downto 0);
		
		debug_button_1 : in std_logic;
		debug_button_2 : in std_logic;

		r : in std_logic_vector(7 downto 0);
		g : in std_logic_vector(7 downto 0);
		b : in std_logic_vector(7 downto 0);

		valid : in std_logic;
		ack : out std_logic;
		
		reset_mem : out std_logic;
		reset_mem_ack : in std_logic

	);
end entity;
architecture simple of HDMI_Controller is
	signal cmd : HDMI_PO_cmd;
	signal status : HDMI_PO_status;
	signal data_pos : integer;

	signal ack_s : std_logic;
begin
	pc : HDMI_PC
	port map(
		pixel_clk => pixel_clk,
		rst => rst,
		cmd => cmd,
		status => status,
		debug_button_1 => debug_button_1,
		debug_button_2 => debug_button_2,
		reset_mem => reset_mem,
		reset_mem_ack => reset_mem_ack
	);
	
	po : HDMI_PO
	port map (
		pixel_clk => pixel_clk,
		tmds_clk => tmds_clk,
		rst => rst,

		cmd => cmd,
		status => status,

		channel => channel,
		
		r => r,
		g => g,
		b => b,

		valid => valid,
		ack => ack_s
	);
	ack <= ack_s;

end architecture;
