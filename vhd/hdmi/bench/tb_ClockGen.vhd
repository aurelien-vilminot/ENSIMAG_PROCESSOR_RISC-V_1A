library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HDMI_pkg.all;

-- Ce test_bench est là pour tester plusieurs choses.
-- * Le TMDSEncoder fait appel au bon encoder selon le DATA_TYPE 
-- * Le compteur du VideoEncoder est bien mis à jour.
-- * Le VideoEncoder choisit toujours un encodage qui rapproche
-- le compteur de 0.
entity tb_ClockGen is
end entity;


architecture behavior of tb_ClockGen is

	component ClockGen
		port (
			fpga_clk : in std_logic;
			rst : in std_logic;
			pixel_clk : out std_logic;
			tmds_clk : out std_logic;

			dcm_lock : out std_logic
		);
	end component;
	
	-- Signals
	signal fpga_clk	: std_logic := '0' ; -- 125MHz
	signal pixel_clk: std_logic := '0' ; -- 75MHz
	signal tmds_clk	: std_logic := '0' ; -- 375MHz
	signal dcm_lock : std_logic;
	signal reset : std_logic;
begin


	C_ClockGen : ClockGen
		port map (
			fpga_clk => fpga_clk,
			rst => reset,
			pixel_clk => pixel_clk,
			tmds_clk => tmds_clk,
			dcm_lock => dcm_lock
		);
	
	gen_horloge: process
	begin
		fpga_clk <= not fpga_clk;
		wait for 4 ns;
	end process;
	
	tb : process
	begin
		reset  <= '1';
		wait until rising_edge(fpga_clk);
		wait until rising_edge(fpga_clk);
		reset <= '0';
		for i in 1 to 10000 loop
		  wait until rising_edge(fpga_clk);
		end loop;

		wait; -- will wait forever
	end process;
end architecture;
