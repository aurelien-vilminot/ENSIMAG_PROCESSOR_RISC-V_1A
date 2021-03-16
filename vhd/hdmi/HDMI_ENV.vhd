library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

use work.HDMI_pkg.all;

entity HDMI_ENV is
	port (
		channel_n : out std_logic_vector(2 downto 0);
		channel_p : out std_logic_vector(2 downto 0);

		clk : in std_logic;

		clk_p : out std_logic;
		clk_n : out std_logic;

		cec : in std_logic;
		hpd : in std_logic;
		out_en : out std_logic;
		scl : out std_logic;
		sda : out std_logic;

		debug_button_1 : in std_logic;
		debug_button_2 : in std_logic;
    
		DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_cas_n : inout STD_LOGIC;
		DDR_ck_n : inout STD_LOGIC;
		DDR_ck_p : inout STD_LOGIC;
		DDR_cke : inout STD_LOGIC;
		DDR_cs_n : inout STD_LOGIC;
		DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_odt : inout STD_LOGIC;
		DDR_ras_n : inout STD_LOGIC;
		DDR_reset_n : inout STD_LOGIC;
		DDR_we_n : inout STD_LOGIC;
		FIXED_IO_ddr_vrn : inout STD_LOGIC;
		FIXED_IO_ddr_vrp : inout STD_LOGIC;
		FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ps_clk : inout STD_LOGIC;
		FIXED_IO_ps_porb : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC
	);
end entity;

architecture structural of HDMI_ENV is
	component PS_Link is
	port (	
		DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
		DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
		DDR_cas_n : inout STD_LOGIC;
		DDR_ck_n : inout STD_LOGIC;
		DDR_ck_p : inout STD_LOGIC;
		DDR_cke : inout STD_LOGIC;
		DDR_cs_n : inout STD_LOGIC;
		DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
		DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
		DDR_odt : inout STD_LOGIC;
		DDR_ras_n : inout STD_LOGIC;
		DDR_reset_n : inout STD_LOGIC;
		DDR_we_n : inout STD_LOGIC;
		FIXED_IO_ddr_vrn : inout STD_LOGIC;
		FIXED_IO_ddr_vrp : inout STD_LOGIC;
		FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
		FIXED_IO_ps_clk : inout STD_LOGIC;
		FIXED_IO_ps_porb : inout STD_LOGIC;
		FIXED_IO_ps_srstb : inout STD_LOGIC;

		hdmi_r : out std_logic_vector(7 downto 0);
		hdmi_g : out std_logic_vector(7 downto 0);
		hdmi_b : out std_logic_vector(7 downto 0);

		axi_clk : in std_logic;
		axi_rst : in std_logic;
		hdmi_ddr_valid : out std_logic;
		hdmi_ddr_ack : in std_logic;
		hdmi_pixel_clk : in std_logic;
		hdmi_reset_mem : in std_logic;
		hdmi_reset_mem_ack : out std_logic		

	);
	end component PS_Link; 	
	component HDMI_simple is
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
	end component;
	signal hdmi_r : std_logic_vector(7 downto 0);
	signal hdmi_g : std_logic_vector(7 downto 0);
	signal hdmi_b : std_logic_vector(7 downto 0);

	signal hdmi_ddr_valid : std_logic;
	signal hdmi_ddr_ack : std_logic;
	signal hdmi_pixel_clk : std_logic;
	signal hdmi_reset_mem : std_logic;
	signal hdmi_reset_mem_ack : std_logic;		

	signal clk_2 : std_logic;
begin
	PS_Link_inst : component PS_Link
	port map (	
		DDR_addr => DDR_addr,
		DDR_ba => DDR_ba,
		DDR_cas_n => DDR_cas_n ,
		DDR_ck_n => DDR_ck_n ,
		DDR_ck_p => DDR_ck_p ,
		DDR_cke => DDR_cke ,
		DDR_cs_n => DDR_cs_n ,
		DDR_dm => DDR_dm,
		DDR_dq => DDR_dq,
		DDR_dqs_n => DDR_dqs_n,
		DDR_dqs_p => DDR_dqs_p,
		DDR_odt => DDR_odt ,
		DDR_ras_n => DDR_ras_n ,
		DDR_reset_n => DDR_reset_n ,
		DDR_we_n => DDR_we_n ,
		FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn ,
		FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp ,
		FIXED_IO_mio => FIXED_IO_mio,
		FIXED_IO_ps_clk => FIXED_IO_ps_clk ,
		FIXED_IO_ps_porb => FIXED_IO_ps_porb ,
		FIXED_IO_ps_srstb => FIXED_IO_ps_srstb ,
		
		axi_clk => clk_2,
		axi_rst => '0',

		hdmi_r => hdmi_r,
		hdmi_g => hdmi_g,
		hdmi_b => hdmi_b,

		hdmi_ddr_valid => hdmi_ddr_valid,
		hdmi_ddr_ack => hdmi_ddr_ack,
		hdmi_pixel_clk => hdmi_pixel_clk,
		hdmi_reset_mem => hdmi_reset_mem,
		hdmi_reset_mem_ack => hdmi_reset_mem_ack

	);
	HDMI_simple_inst : component HDMI_simple
		port map(
			clk => clk_2, -- FPGA clock 
			rst => '0',
	
			channel_n => channel_n,
			channel_p => channel_p,
	
			clk_p => clk_p,
			clk_n => clk_n,
	
			debug_button_1 => debug_button_1,
			debug_button_2 => debug_button_2,
	
			cec => cec,
			hpd => hpd,
			out_en => out_en,
			scl => scl,
			sda => sda,
	
			r => hdmi_r,
			g => hdmi_g,
			b => hdmi_b,
	
			valid => hdmi_ddr_valid,
			ack => hdmi_ddr_ack,
	
			out_pixel_clk => hdmi_pixel_clk,
			reset_mem => hdmi_reset_mem,
			reset_mem_ack => hdmi_reset_mem_ack
		);
	ibufg : BUFG
	port map (
		I => clk,
		O => clk_2
	);
end architecture structural;
