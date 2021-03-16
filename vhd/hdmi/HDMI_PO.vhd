library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;


entity HDMI_PO is
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

end entity HDMI_PO;

architecture po of HDMI_PO is
	-- Ces types définissent le format de l'infoframe AVI ( Auxiliary Video Information).
    	type avi_byte_vector is array (integer range <>) of avi_byte;
    	type avi_8bytes_vector is array (integer range <>) of avi_byte_vector(7 downto 0);
	--Registres PO
	signal countdown_d, countdown_q : integer;
	signal countdown_max_d, countdown_max_q : integer;
	
	
	-- Signaux relatifs à l'AVI
	signal avi_info_d, avi_info_q : HDMI_AVI;
	
	
	signal AVI_PB : avi_byte_vector(27 downto 0); -- Contient les données concernant l'AVI
	signal AVI_SUB_PACKETS : avi_8bytes_vector(3 downto 0);
	
	signal AVI_PB_sum : avi_byte;

	signal AVI_HB : avi_byte_vector(3 downto  0); -- En-tête de l'AVI.
	signal AVI_Header : std_logic_vector(31 downto 0);
	
	signal AVI_HB_sum : avi_byte := "10001101"; -- checksum de AVI_HB(2 downto 0). On l'encode en dur pour l'instant.

	signal step : integer;
	signal subpacket_0_bch : avi_byte; -- Pour envoyer l'AVI, on voit le répartir dans des sous paquets.
	signal subpacket_1_bch : avi_byte;
	signal subpacket_2_bch : avi_byte;
	
	-- Signaux intermédiaires pour le T.M.D.S
	signal video_d : video_signal_vector(2 downto 0);	
	signal video_q : video_signal_vector(2 downto 0);	
	signal control : control_signal_vector(2 downto 0);
	signal aux : aux_signal_vector(2 downto 0);	
	signal encoded_signal : tmds_signal_vector(2 downto 0);	
	signal output : tmds_signal_vector(2 downto 0);	

	signal encoding_type : ENCODING_TYPE;
	
	-- Contient les données sur l'écran.
	signal screen : SCREEN_SIZE_DATA;


	signal data_type_q : DATA_TYPE;
	signal data_type_d : DATA_TYPE;
	
begin
	-- COMPOSANTS
	
	GEN_TMDS_SERDES : for i in 0 to 2 generate
		encoder : TMDSEncoder
		port map (
			D_video => video_q(i),
			D_control => control(i),
			D_auxiliary => aux(i),
			encoding_type => encoding_type,
			clk => pixel_clk,
			rst => rst,
			q_out => encoded_signal(i)
		);
		serializer_0 : OutputSERDES
		port map (
			D => output(i),
			rst => rst,
			clk => tmds_clk,
			clk_div => pixel_clk,
			
			q => channel(i)
		);
	end generate GEN_TMDS_SERDES;
	
	C_vic_interpreter : VIC_Interpreter
	port map (
		VIC => avi_info_q.VIC,
		screen_out => screen
	);

	-- MISE À JOUR DES REGISTRES

	synchrone : process (pixel_clk)
	begin
		if pixel_clk'event and pixel_clk='1' then
			if rst = '1' or cmd.rst = '1' then
				countdown_q <= 0;
				countdown_max_q <= 0;
				avi_info_q <= HDMI_AVI_zero;
				video_q(0) <= "00000000";
				video_q(1) <= "10000000";
				video_q(2) <= "00000000";
				data_type_q <= DATA_BLANK;
			else
				countdown_q <= countdown_d;
				countdown_max_q <= countdown_max_d;
				avi_info_q <= avi_info_d;
				video_q <= video_d;
				data_type_q <= data_type_d;
			end if;
		end if;
	end process synchrone;
	
	-- AFFECTATION DES SIGNAUX

	status.countdown <= countdown_q;
	status.screen <= screen;
	step <= countdown_max_q - countdown_q;
		
	video_d(0) <= b when valid = '1' else (others => '1');
	video_d(1) <= g when valid = '1' else (others => '0');
	video_d(2) <= r when valid = '1' else (others => '0');
	
	-- Mire de debug

	-- video_d(0) <= (others => '1');
	-- video_d(1) <= std_logic_vector(cmd.x(9 downto 5)) & "000";
	-- video_d(2) <= std_logic_vector(cmd.y(9 downto 5)) & "000";

	data_type_d <= cmd.data_type_sel;
	
	AVI_PB(1) <= '0' & avi_info_q.Y & avi_info_q.A & avi_info_q.B & avi_info_q.S; -- La manière de remplir l'AVI est décrite dans la documentation HDMI.
	AVI_PB(2) <= avi_info_q.C & avi_info_q.M & avi_info_q.R;
	AVI_PB(3) <= "000000" & avi_info_q.SC;
	AVI_PB(4) <= '0' & avi_info_q.VIC;
	AVI_PB(5) <= "0000" & avi_info_q.PR;
	AVI_PB(6) <= std_logic_vector(avi_info_q.end_top_bar(7 downto 0));
	AVI_PB(7) <= std_logic_vector(avi_info_q.end_top_bar(15 downto 8));
	AVI_PB(8) <= std_logic_vector(avi_info_q.start_bottom_bar(7 downto 0));
	AVI_PB(9) <= std_logic_vector(avi_info_q.start_bottom_bar(15 downto 8));
	AVI_PB(10) <= std_logic_vector(avi_info_q.end_left_bar(7 downto 0));
	AVI_PB(11) <= std_logic_vector(avi_info_q.end_left_bar(15 downto 8));
	AVI_PB(12) <= std_logic_vector(avi_info_q.start_right_bar(7 downto 0));	
	AVI_PB(13) <= std_logic_vector(avi_info_q.start_right_bar(15 downto 8));
	AVI_PB(27 downto 14) <= (others => avi_byte_zero);
	
	AVI_PB_sum <= "00000000";
	
	AVI_HB(0) <= avi_packet_id;
	AVI_HB(1) <= std_logic_vector(avi_info_q.version); 
	AVI_HB(2) <= "000" & std_logic_vector(avi_info_q.length); 
	AVI_HB(3) <= "00010111";	
	AVI_HB_sum <= "00000000";
	
	AVI_PB (0) <= "01000010";

	AVI_SUB_PACKETS(0)(6 downto 0) <= AVI_PB(6 downto 0); 
	AVI_SUB_PACKETS(0)(7) <= "00110101"; 
	AVI_SUB_PACKETS(1)(6 downto 0) <= AVI_PB(13 downto 7); 
	AVI_SUB_PACKETS(1)(7) <= "11100011"; 
	AVI_SUB_PACKETS(2)(6 downto 0) <= AVI_PB(20 downto 14); 
	AVI_SUB_PACKETS(2)(7) <= avi_byte_zero; 
	AVI_SUB_PACKETS(3)(6 downto 0) <= AVI_PB(27 downto 21); 
	AVI_SUB_PACKETS(3)(7) <= avi_byte_zero;
 
	AVI_HEADER <= AVI_HB(0) & AVI_HB(1) & AVI_HB(2) & AVI_HB(3);
	
	comb_MUX : process(countdown_max_q,
				countdown_q,
				avi_info_q,
				encoded_signal,
				cmd,
				AVI_HEADER,
				AVI_SUB_PACKETS,
				screen,
				step,
				valid,
				cmd.countdown_max_we,
				cmd.countdown_max_sel,
				cmd.x,
				cmd.data_type_sel)
	begin	
		-- Affectation par défaut des signaux.
		countdown_max_d <= countdown_max_q;
		countdown_d <= countdown_q - 1;
		avi_info_d <= avi_info_q;

		control <= (others => "00");		
		aux <= (others => "0000");
		
		ack <= '0';
		
		output <= encoded_signal;
		
		encoding_type <= ENCODING_VIDEO;

		-- Sélection du signal de sortie en fonction du type de données demandé.
		case data_type_q is
			when DATA_BLANK =>
				control(0) <= cmd.vsync & cmd.hsync;
				encoding_type <= ENCODING_CONTROL;
			when DATA_CONTROL =>
				control(0) <= cmd.vsync & cmd.hsync;
				control(1) <= cmd.ctl(1 downto 0);
				control(2) <= cmd.ctl(3 downto 2);
				encoding_type <= ENCODING_CONTROL;
			when DATA_VIDEO =>
				if valid = '1' then
					ack <= '1';
				end if;
				encoding_type <= ENCODING_VIDEO;
			when DATA_GUARD_VIDEO =>
				output(0) <= "1011001100";
				output(1) <= "0100110011";
				output(2) <= "1011001100";
			when DATA_AVI =>
				if step = 0 then
					aux(0) <= '0' & AVI_HEADER(0) & cmd.vsync & cmd.hsync;
					aux(1) <= AVI_SUB_PACKETS(3)(0)(0) & AVI_SUB_PACKETS(2)(0)(0) & AVI_SUB_PACKETS(1)(0)(0) & AVI_SUB_PACKETS(0)(0)(0);
					aux(2) <= AVI_SUB_PACKETS(3)(0)(1) & AVI_SUB_PACKETS(2)(0)(1) & AVI_SUB_PACKETS(1)(0)(1) & AVI_SUB_PACKETS(0)(0)(1);
				else
					for i in 0 to 7 loop
						for j in 0 to 3 loop
							if step = i*4+j then
								aux(0) <= '1' & AVI_HEADER(i*4 + j) & cmd.vsync & cmd.hsync;
								aux(1) <= AVI_SUB_PACKETS(3)(i)(2 * j) & AVI_SUB_PACKETS(2)(i)(2 * j) & AVI_SUB_PACKETS(1)(i)(2 * j) & AVI_SUB_PACKETS(0)(i)(2 * j);
								aux(2) <= AVI_SUB_PACKETS(3)(i)(2 * j + 1) & AVI_SUB_PACKETS(2)(i)(2 * j + 1) & AVI_SUB_PACKETS(1)(i)(2 * j + 1) & AVI_SUB_PACKETS(0)(i)(2 * j + 1);
							end if;
						end loop;
					end loop;
				end if;
				encoding_type <= ENCODING_AUXILIARY;	
			when DATA_GUARD_AUX =>
				aux(0) <= "11" & cmd.vsync & cmd.hsync;	
				output(1) <= "0100110011";
				output(2) <= "0100110011";
				encoding_type <= ENCODING_AUXILIARY;
		end case;

		-- Mise à jour du compteur
		if cmd.countdown_max_we then
			case cmd.countdown_max_sel is
				when CNTD_CUSTOM =>
					countdown_max_d <= cmd.countdown_max;
					countdown_d <= cmd.countdown_max;
				when CNTD_SCREEN_WIDTH =>
					countdown_max_d <= screen.width;
					countdown_d <= screen.width;
				when CNTD_H_BLANK =>
					countdown_max_d <= screen.h_blank;
					countdown_d <= screen.h_blank;
				when CNTD_UNTIL_FIRST_LINE =>
					countdown_max_d <= screen.width - to_integer(cmd.x) +  (- to_integer(cmd.y) - 1) * screen.total_width - 1;
					countdown_d <= screen.width - to_integer(cmd.x) +  (- to_integer(cmd.y) - 1) * screen.total_width - 1;
				when CNTD_32 =>
					countdown_max_d <= 32;
					countdown_d <= 32;
				when CNTD_8 =>
					countdown_max_d <= 8;
					countdown_d <= 8;
				when CNTD_2 =>
					countdown_max_d <= 2;
					countdown_d <= 2;
				when CNTD_H_BLANK_MINUS_10 =>
					countdown_max_d <= screen.h_blank_minus_10;
					countdown_d <= screen.h_blank_minus_10;
			end case;
		end if;

		if cmd.avi_we then
			avi_info_d <= cmd.avi_info;
		end if;
	
	end process comb_MUX;
	
			
end architecture po;
