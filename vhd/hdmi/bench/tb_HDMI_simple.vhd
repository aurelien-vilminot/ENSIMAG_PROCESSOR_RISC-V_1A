library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HDMI_pkg.all;

entity tb_HDMI_simple is
end entity;


architecture behavior of tb_HDMI_simple is

	component HDMI_simple is
		port (
            clk : in std_logic; -- FPGA clock 
            rst : in std_logic;
    
            channel_0_p : out std_logic;
            channel_0_n : out std_logic;
            
            channel_1_p : out std_logic;
            channel_1_n : out std_logic;
            
            channel_2_p : out std_logic;
            channel_2_n : out std_logic;
    
            clk_p : out std_logic;
            clk_n : out std_logic;
    
            debug : out std_logic_vector(3 downto 0);
    
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
            initiated_transaction : in std_logic;
    
            out_pixel_clk : out std_logic;
		reset_mem : out std_logic;
		reset_mem_ack : in std_logic
        );
	end component;
	-- Signals
	signal reset : std_logic;
	signal	clk : std_logic := '0'; -- FPGA clock 
	
	signal	c_0_p : std_logic;
	signal	c_0_n : std_logic;
	
	signal	c_1_p : std_logic;
	signal	c_1_n : std_logic;
	
	signal	c_2_p : std_logic;
	signal	c_2_n : std_logic;
	
	signal	clk_p : std_logic;
	signal	clk_n : std_logic;
			

	signal	cec : std_logic;
	signal	hpd : std_logic;
	signal	out_en : std_logic;
	signal	scl : std_logic;
	signal	debug : std_logic_vector(3 downto 0); 
	
	signal valid : std_logic;
	signal ack : std_logic;

	signal reset_mem : std_logic;
	signal reset_mem_ack : std_logic;
begin


	C_HDMI_simple : HDMI_Simple
		port map (
			clk => clk,
			rst => reset,

			channel_0_p => c_0_p,	
			channel_0_n => c_0_n,	
			channel_1_p => c_1_p,	
			channel_1_n => c_1_n,	
			channel_2_p => c_2_p,	
			channel_2_n => c_2_n,	

			clk_p => clk_p,
			clk_n => clk_n,
			cec => cec,
			hpd => hpd,
			out_en => out_en,
			scl => scl,

			debug => debug,
			debug_button_1 => '0',
			debug_button_2 => '0',
			
			r => (others => '0'),
			g => (others => '0'),
			b => (others => '0'),
			valid => valid,
			ack => ack,
			initiated_transaction => '0',
			reset_mem => reset_mem,
			reset_mem_ack => reset_mem_ack
		);
	
	gen_horloge: process
	begin
		clk <= not clk;
		wait for 4 ns;
	end process;
	
	tb : process
	begin
		reset  <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '0';
		valid <= '1';
		reset_mem_ack <= '1';
		for i in 1 to 10000 loop
		  wait until rising_edge(clk);
		end loop;

		wait; -- will wait forever
	end process;
end architecture;
