library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HDMI_pkg.all;

-- Ce test_bench est là pour tester plusieurs choses.
-- * Le TMDSEncoder fait appel au bon encoder selon le ENCODING_TYPE 
-- * Le compteur du VideoEncoder est bien mis à jour.
-- * Le VideoEncoder choisit toujours un encodage qui rapproche
-- le compteur de 0.
entity tb_TMDSEncoder is
end entity;


architecture behavior of tb_TMDSEncoder is

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

	-- Signals
	signal clk	: std_logic := '0' ;
	signal fast_clk	: std_logic := '0' ;
	signal reset  : std_logic;
	signal q  : std_logic;
	signal q_out : tmds_signal;
	
	signal D_video : video_signal;
	
	signal D_control : control_signal;
	signal D_auxiliary : aux_signal;
	signal encoding_type : ENCODING_TYPE := ENCODING_CONTROL;
begin


	C_TMDSEncoder : TMDSEncoder
		port map (
			D_video => D_video,
			D_control => D_control,
			D_auxiliary => D_auxiliary,
			encoding_type => encoding_type,
			clk	=> clk,
			rst  => reset,
			q_out => q_out
			
		);
	C_OutputSERDES : OutputSERDES
		port map (
		D => q_out,
		rst => reset,
		clk => fast_clk,
		clk_div => clk,
		q => q
		); 

	gen_horloge: process
	begin
		clk <= not clk;
		wait for 10 ns;
	end process;
	
	gen_horloge_des : process
	begin
		fast_clk <= not fast_clk;
		wait for 2 ns;
	end process;

	tb : process
	begin
		reset  <= '1';
		D_video <= "00001111";
		D_control <= "00";
		D_auxiliary <= "0000";
		encoding_type <= ENCODING_CONTROL;

		for i in 1 to 6 loop
		  wait until rising_edge(clk);
		end loop;

		reset <= '0';
		wait until rising_edge(clk);

		encoding_type <= ENCODING_AUXILIARY;
		wait until rising_edge(clk);

		encoding_type <= ENCODING_VIDEO;
		wait until rising_edge(clk);

		D_video <= "11110000";

		wait until rising_edge(clk);
		D_video <= "11111111";

		wait until rising_edge(clk);
		D_video <= "11111111";
 
		wait until rising_edge(clk);
		D_video <= "00000000";
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		D_video <= "11111111";
			
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		
		D_video <= "11101010";
		
		encoding_type <= ENCODING_CONTROL;
		wait until rising_edge(clk);
		
		wait; -- will wait forever
	end process;


end architecture;
