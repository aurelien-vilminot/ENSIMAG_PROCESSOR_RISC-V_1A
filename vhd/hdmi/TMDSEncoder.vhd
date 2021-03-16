library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;

-- TMDS stands for Transition Minimized Differential Signaling.

-- On minimise le nombre de transitions dans les signaux pour
-- améliorer la qualité du signal, sauf dans le signal de contrôle
-- où on utilise beaucoup de transitions pour synchroniser la source
-- et le puit. 
-- De plus, on envoie des signaux qui sont DC-balanced (autant de 0 que de 1) en moyenne.

-- Ce composant prend en entrée différents signaux et en sortie renvoie un signal
-- encodé sur 10 bits, ainsi que l'opposé de ce signal.
-- Le décodeur va ensuite faire la différence des deux signaux pour récupérer le signal
-- initial. Cela permet de supprimer le bruit qui a été appliqué aux deux signaux dans le canal.
 
entity TMDSEncoder is
	port (
	D_video : in video_signal;
	D_control : in control_signal;
    	D_auxiliary : in aux_signal;
   	encoding_type : in ENCODING_TYPE := ENCODING_CONTROL;
    	clk : in std_logic ;
    	rst : in std_logic ;
	q_out : out tmds_signal

	);
end TMDSEncoder;
architecture behavior of TMDSEncoder is
	
	signal q_out_video, q_out_control, q_out_auxiliary : tmds_signal;
	signal video_enable : boolean;
begin
	video : VideoEncoder
	port map (
		D => D_video,
		q_out => q_out_video,
		ce => video_enable,
		rst=> rst,
		clk => clk
	);
	control : ControlEncoder
	port map (
		D => D_control,
		q_out => q_out_control
	);
	auxiliary : TERC4Encoder
	port map (
		D => D_auxiliary,
		q_out => q_out_auxiliary
	);
	process_comb : process (q_out_video, q_out_control, q_out_auxiliary, encoding_type) is
	begin
   		case encoding_type is
		when ENCODING_VIDEO =>
    			q_out <= q_out_video;
			video_enable <= true;
		when ENCODING_CONTROL =>
    			q_out <= q_out_control;
			video_enable <= false;
		when ENCODING_AUXILIARY =>
    			q_out <= q_out_auxiliary;
			video_enable <= false;
		end case;
	end process;
end architecture;
