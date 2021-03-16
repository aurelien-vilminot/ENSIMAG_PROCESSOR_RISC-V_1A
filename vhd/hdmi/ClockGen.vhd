library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity ClockGen is
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
end entity ClockGen;

architecture simple of ClockGen is
	type State_HDMI is (
		S_HDMI_Init,
		S_HDMI_Data_Preamble,
		S_HDMI_AVI_InfoFrame,
		S_HDMI_Head_Control,
		S_HDMI_Line_Control,
		S_HDMI_Line_Data
	);
	signal clk_fb_2 : std_logic;
	signal clk_fb_1 : std_logic;
	signal inter_clk : std_logic;
	signal lock_1, lock_2 : std_logic;

	signal tmds_clk_cmt : std_logic;
	signal pixel_clk_cmt : std_logic;
	signal dephased_pixel_clk_cmt : std_logic;

begin

	dcm_lock <= lock_1 and lock_2;
	
	MMCME2_BASE_inst_1 : MMCME2_BASE -- f_vc0 = 37.125/5*125 = 928 MHz (600Mhz < OK ! <  1200 MHz)
	generic map (
		CLKFBOUT_MULT_F  => 37.125, 
		CLKIN1_PERIOD	=> 8.0, -- horloge entrante à 125MHz
	
		DIVCLK_DIVIDE => 5,	
		CLKOUT0_DIVIDE_F => 2.5,
		REF_JITTER1	  => 0.010
	)
	port map (
		CLKOUT0  => inter_clk,  -- horloge sortante à 125x37.125/(2.5*5) =  371.25MHz
		LOCKED   => lock_1,
		CLKFBOUT => clk_fb_1,
		CLKFBIN  => clk_fb_1,
		CLKIN1   => fpga_clk,

		PWRDWN   => '0',
		RST	  => rst
	);
	MMCME2_BASE_inst_2 : MMCME2_BASE -- f_vc0 = 10 / 5 * 371.25 = 742.5 MHz (600 MHz < OK ! < 1200 MHz)
	generic map (
		CLKFBOUT_MULT_F  => 10.0,
		CLKIN1_PERIOD	=> 2.694, -- horloge entrante à 371.25MHz
	
		DIVCLK_DIVIDE => 5,
		CLKOUT0_DIVIDE_F => 2.0,
		CLKOUT1_DIVIDE => 10,
		CLKOUT2_DIVIDE => 10,
		CLKOUT1_PHASE => 72.0,
		REF_JITTER1	  => 0.010
	)
	port map (
		CLKOUT0  => tmds_clk_cmt,  -- horloge sortante à 371.25 * 10 / (5 * 2)  =  371.25MHz
		CLKOUT1  => pixel_clk_cmt,  -- horloge sortante à 371.25 * 10 / (5 * 10)  =  74,25MHz
		CLKOUT2  => dephased_pixel_clk_cmt,  -- horloge sortante à 371.25 * 10 / (5 * 10)  =  74,25MHz
		LOCKED   => lock_2,
		CLKFBOUT => clk_fb_2,
		CLKFBIN  => clk_fb_2,
		CLKIN1   => inter_clk,

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
