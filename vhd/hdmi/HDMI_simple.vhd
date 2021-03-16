library unisim;
use unisim.vcomponents.all;


library ieee;
use ieee.std_logic_1164.all;

use work.HDMI_pkg.all;

entity HDMI_simple is
	port (
		clk : in std_logic; -- FPGA clock 
		rst : in std_logic;

		channel_n : out std_logic_vector(2 downto 0);
		channel_p : out std_logic_vector(2 downto 0);

		clk_p : out std_logic;
		clk_n : out std_logic;

		debug_button_1 : in std_logic;
		debug_button_2 : in std_logic;

		cec : in std_logic;
		hpd : in std_logic;
		out_en : out std_logic;
		scl : out std_logic;
		sda : out std_logic;

		r : in std_logic_vector(7 downto 0);
		g : in std_logic_vector(7 downto 0);
		b : in std_logic_vector(7 downto 0);

		valid : in std_logic;
		ack : out std_logic;

		out_pixel_clk : out std_logic;
		reset_mem : out std_logic;
		reset_mem_ack : in std_logic
	);
end entity;

architecture structural of HDMI_simple is
	signal dephased_pixel_clk : std_logic;
	signal pixel_clk : std_logic;
	signal tmds_clk : std_logic;
	signal dcm_lock : std_logic;

	signal channel : std_logic_vector(2 downto 0);
	signal rst_controller : std_logic;
	signal inter_ack : std_logic;
	signal debug_controller : std_logic_vector(3 downto 0);

begin
	out_pixel_clk <= pixel_clk;

	rst_controller <= rst or (not dcm_lock);
	out_en <= '1';
	scl <= '0';
	sda <= '0';
	ack <= inter_ack;
	
	C_ClockGen : ClockGenApprox
	port map (
		fpga_clk => clk,
		rst => rst,

		pixel_clk => pixel_clk,
		dephased_pixel_clk => dephased_pixel_clk,
		tmds_clk => tmds_clk,
		dcm_lock => dcm_lock
	);

	C_HDMI_Controller : HDMI_Controller
	port map (
		pixel_clk => pixel_clk,
		tmds_clk => tmds_clk,
		rst => rst_controller,
		hpd => hpd,
		channel => channel,	

		debug_button_1 => debug_button_1,
		debug_button_2 => debug_button_2,

		r => r,
		g => g,
		b => b,

		valid => valid,
		ack => inter_ack,
		reset_mem => reset_mem,
		reset_mem_ack => reset_mem_ack
	);

	buf_gen : for i in 0 to 2 generate

		buf : OBUFDS
		generic map (
			IOSTANDARD => "TMDS_33"
		)
		port map (
			I => channel(i),
			O => channel_p(i),
			OB => channel_n(i)
		);
	end generate buf_gen;
	
	buf_clk : OBUFDS
	generic map (
		IOSTANDARD => "TMDS_33"
	)
	port map (
		I => dephased_pixel_clk,
		O => clk_p,
		OB => clk_n
	);
end architecture;
