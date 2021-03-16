library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package HDMI_pkg is
	subtype w31 is unsigned(30 downto 0);	
	subtype signed_w4 is signed(3 downto 0);	
	
	constant w31_zero : w31 := (others => '0');
	
	subtype video_signal is std_logic_vector(7 downto 0);
	subtype control_signal is std_logic_vector(1 downto 0);
	subtype aux_signal is std_logic_vector(3 downto 0);
	
	subtype tmds_signal is std_logic_vector(9 downto 0);	
    	
	type video_signal_vector is array (integer range <>) of video_signal;
	type control_signal_vector is array (integer range <>) of control_signal;
	type aux_signal_vector is array (integer range <>) of aux_signal;
	
	type tmds_signal_vector is array (integer range <>) of tmds_signal;

	type SCREEN_SIZE_DATA is record

		width : integer;
		height : integer; 
		h_blank : integer; 
		h_blank_minus_10 : integer; 
		v_blank : integer; 

		total_width : integer;
		total_height : integer; 
		
		hsync_beg : integer;
		hsync_end : integer; 
		
		vsync_beg : integer;
		vsync_end : integer; 
		
		max_x : signed(12 downto 0);
		min_x : signed(12 downto 0);
		max_y : signed(12 downto 0);
		min_y : signed(12 downto 0);

		min_hsync_x : signed(12 downto 0);
		max_hsync_x : signed(12 downto 0);
		min_vsync_y : signed(12 downto 0);
		max_vsync_y : signed(12 downto 0);
	
	end record;

	type ENCODING_TYPE is (
		ENCODING_CONTROL, -- la valeur par défaut est ENCODING_CONTROL
		ENCODING_VIDEO,
		ENCODING_AUXILIARY
	);

	type DATA_TYPE is (
		DATA_BLANK,
		DATA_CONTROL,
		DATA_VIDEO,
		DATA_GUARD_VIDEO,
		DATA_GUARD_AUX,
		DATA_AVI
	);
	
	type COUNTDOWN_TYPE is (
		CNTD_CUSTOM,	
		CNTD_SCREEN_WIDTH,
		CNTD_H_BLANK,
		CNTD_UNTIL_FIRST_LINE,
		CNTD_32,
		CNTD_8,
		CNTD_2,
		CNTD_H_BLANK_MINUS_10
	);
	
	subtype avi_byte is std_logic_vector(7 downto 0);
	
	constant avi_byte_zero : avi_byte := "00000000";
	constant avi_packet_id : avi_byte := "10000010";

	type HDMI_AVI is record
		Y : std_logic_vector(1 downto 0);
		A : std_logic;
		B : std_logic_vector(1 downto 0);
		S : std_logic_vector(1 downto 0);
		C : std_logic_vector(1 downto 0);
		M : std_logic_vector(1 downto 0);
		R : std_logic_vector(3 downto 0);
		SC : std_logic_vector(1 downto 0);
		PR : std_logic_vector(3 downto 0);
		VIC : std_logic_vector(6 downto 0);	
		
		end_top_bar : unsigned(15 downto 0);
		start_bottom_bar : unsigned(15 downto 0);
		end_left_bar : unsigned(15 downto 0);
		start_right_bar : unsigned(15 downto 0);

		version : unsigned(7 downto 0);
		length : unsigned(4 downto 0);
	end record; 
	
	constant HDMI_AVI_zero : HDMI_avi := (
		Y	=> "00",
		A	=> '1',
		B	=> "11", -- bar info data valid
		S	=> "00",
		C	=> "00",
		M	=> "10", -- 16/9 eme
		R	=> "1000",
		SC	=> "00",
		PR	=> "0000",
		VIC	=> "0000100",

		end_top_bar => to_unsigned(30, 16),
		start_bottom_bar => to_unsigned(751, 16),
		end_left_bar => to_unsigned(370, 16),
		start_right_bar => to_unsigned(1651, 16),

		version => to_unsigned(2, 8),
		length => to_unsigned(13, 5)
	);
	
	type HDMI_PO_cmd is record
		rst		: std_logic;
		
		hsync : std_logic;
		vsync : std_logic;

		ctl : std_logic_vector(3 downto 0);
		
		avi_info : HDMI_AVI;	
		avi_we	: boolean;
		
		data_type_sel : DATA_TYPE;
		x : signed(12 downto 0);
		y : signed(12 downto 0);

		countdown_max_we : boolean;
		countdown_max_sel : COUNTDOWN_TYPE; 
		countdown_max : integer;
	end record;
	
	constant HDMI_PO_cmd_zero : HDMI_PO_cmd := (
		rst		=> '0',

		hsync 		=> '0',
		vsync		=> '0',

		ctl		=> "0000",

		avi_info	=> HDMI_AVI_zero,
		avi_we		=> false,

		data_type_sel	=> DATA_BLANK,
		x		=>  (others => '0'),
		y		=>  (others => '0'),
		
		countdown_max_we 	=> false,
		countdown_max_sel	=> CNTD_H_BLANK_MINUS_10,
		countdown_max => 0
	);	

	-- Status
	type HDMI_PO_status is record
		countdown : integer;
		screen : SCREEN_SIZE_DATA;
	end record;
	
	component VideoEncoder is
	port (
		D : in video_signal;
		q_out : out tmds_signal;
		ce : in boolean;
		rst : in std_logic;
		clk : in std_logic
		);
	end component;
	component TERC4Encoder is
		port (
	
		D : in aux_signal;
		q_out : out tmds_signal
		
		);
	end component;
	component ControlEncoder is
		
		port (
		D : in control_signal;
		q_out : out tmds_signal
		);
	end component;
	
	component TMDSEncoder
		port (
		D_video : in video_signal ;
		D_control : in control_signal;
		D_auxiliary : in aux_signal;
		encoding_type : in ENCODING_TYPE;
		clk : in std_logic ;
		rst : in std_logic;
		q_out : out tmds_signal
		);
	end component;
	
	component OutputSERDES
		port (
		D : in tmds_signal;
		rst: in std_logic;
		clk: in std_logic;
		clk_div: in std_logic;
		q : out std_logic
		);
	end component;

	component HDMI_PO
		port (
			pixel_clk : in std_logic;
			tmds_clk : in std_logic;
			rst : in std_logic;
			
			-- PO to PC interface
			cmd : in HDMI_PO_cmd;
			status : out HDMI_PO_STATUS;
		
			channel : out std_logic_vector(2 downto 0);
			
			r : in std_logic_vector(7 downto 0);
			g : in std_logic_vector(7 downto 0);
			b : in std_logic_vector(7 downto 0);

			valid : in std_logic;
			ack : out std_logic
		);
	end component;
	component HDMI_PC is
		port (
			pixel_clk : in std_logic;
			rst : in std_logic;
			debug_button_1 : in std_logic;
			debug_button_2 : in std_logic;
	
			cmd	: out	HDMI_PO_cmd;
			status : in HDMI_PO_status;

			reset_mem : out std_logic;	
			reset_mem_ack : in std_logic
			
		);
	end component;
	
	component HDMI_Controller is
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
	end component;
	component ClockGenApprox is
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
	end component ClockGenApprox;

	component GeneRGB is
		port(
			x : in signed(12 downto 0);
			y : in signed(12 downto 0);
			r : out video_signal;
			g : out video_signal;
			b : out video_signal
		);
	end component GeneRGB;
	component VIC_Interpreter is
		port (
			VIC : in std_logic_vector(6 downto 0);
			
			screen_out : out SCREEN_SIZE_DATA
		);
	end component VIC_Interpreter;
end package;
