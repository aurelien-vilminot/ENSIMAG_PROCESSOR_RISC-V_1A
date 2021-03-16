library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity ClockGenApprox is
	port (
		fpga_clk : in std_logic;
		rst : in std_logic;
		pixel_clk : out std_logic;
		tmds_clk : out std_logic;
		dephased_pixel_clk : out std_logic;
		
		dcm_lock : out std_logic -- Digital Clock Management Lock.
					 -- The user must wait for this
					 -- signal to be equal to 1.
	);
end entity ClockGenApprox;

architecture simple of ClockGenApprox is
	type State_HDMI is (
		S_HDMI_Init,
		S_HDMI_Data_Preamble,
		S_HDMI_AVI_InfoFrame,
		S_HDMI_Head_Control,
		S_HDMI_Line_Control,
		S_HDMI_Line_Data
	);
	signal clk_fb_1 : std_logic;
	signal inter_clk : std_logic;
	signal lock_1 : std_logic;

	signal tmds_clk_cmt : std_logic;
	signal pixel_clk_cmt : std_logic;
	signal dephased_pixel_clk_cmt : std_logic;

begin

	dcm_lock <= lock_1;
	
	MMCME2_BASE_inst_1 : MMCME2_BASE -- f_vc0 = 62.375/7*125 = 1113.84 MHz (600Mhz < OK ! <  1200 MHz)
	generic map (
		CLKFBOUT_MULT_F  => 62.375, 
		CLKIN1_PERIOD	=> 8.0, -- horloge entrante à 125MHz
	
		DIVCLK_DIVIDE => 7,	
		CLKOUT0_DIVIDE_F => 3.0,
		CLKOUT1_DIVIDE => 15,
		CLKOUT2_DIVIDE => 15,
		CLKOUT2_PHASE => 72.0,
		REF_JITTER1	  => 0.010
	)
	port map (
		LOCKED   => lock_1,
		CLKFBOUT => clk_fb_1,
		CLKFBIN  => clk_fb_1,
		CLKIN1   => fpga_clk,
		
		

		CLKOUT0  => tmds_clk_cmt,  -- horloge sortante à 1113.84 / 3 = 371.280 MHz (objectif 371.25 MHz) 
		CLKOUT1 => pixel_clk_cmt,  -- horloge sortante à 1113.84 / 15 = 74.256 MHz (objectif 74.25 MHz)
		CLKOUT2 => dephased_pixel_clk_cmt, -- idem
		PWRDWN   => '0',
		RST	  => rst
	);
	buf_g_0 : BUFG
	port map (
		I => tmds_clk_cmt,
		O => tmds_clk
	);
	
	buf_g_1 : BUFG
	port map (
		I => pixel_clk_cmt,
		O => pixel_clk
	);
	
	buf_g_2 : BUFG
	port map (
		I => dephased_pixel_clk_cmt,
		O => dephased_pixel_clk
	);

	
end architecture simple;
