library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;

-- Ce composant permet d'obtenir les données sur l'écran à partir d'un mode VIC.
-- Pour l'instant, comme la fréquence d'horloge n'est pas configurable, seul les
-- modes ayant 74.250 MHz peuvent fonctionner.

entity VIC_Interpreter is
	port (
		VIC : in std_logic_vector(6 downto 0);
		
		screen_out : out SCREEN_SIZE_DATA
	);
end entity VIC_Interpreter;
architecture comb of VIC_Interpreter is
	signal screen : SCREEN_SIZE_DATA;
begin
	screen_out <= screen;

	VIC_sel : process(VIC) is
	begin
		screen.vsync_beg <= 0;
		screen.vsync_end <= 4; 
		case VIC is


			when "0010011" => -- 720p @ 50 fps (format 19)
				screen.width <= 1280;
				screen.height <= 720; 
				screen.h_blank <= 700; 
				screen.v_blank <= 30; 
			
				screen.hsync_beg <= 440;
				screen.hsync_end <= 479;
			when "0100000" => --1080p @ 24 Hz (format 32)
				screen.width <= 1920;
				screen.height <= 1080; 
				screen.h_blank <= 830; 
				screen.v_blank <= 45; 
			
				screen.hsync_beg <= 638;
				screen.hsync_end <= 681; 
			when "0100001" => --1080p @ 25 Hz (format 33)
				screen.width <= 1920;
				screen.height <= 1080; 
				screen.h_blank <= 720; 
				screen.v_blank <= 45; 
			
				screen.hsync_beg <= 528;
				screen.hsync_end <= 571; 
			when "0100010" => --1080p @ 30 Hz (format 34)
				screen.width <= 1920;
				screen.height <= 1080; 
				screen.h_blank <= 280; 
				screen.v_blank <= 45; 
			
				screen.hsync_beg <= 88;
				screen.hsync_end <= 131; 
			when others => -- 720p @ 60Hz (format 4)	
				screen.width <= 1280;
				screen.height <= 720; 
				screen.h_blank <= 370; 
				screen.v_blank <= 30; 
			
				screen.hsync_beg <= 110;
				screen.hsync_end <= 149;
				screen.vsync_beg <= 5;
				screen.vsync_end <= 5+5-1;
		end case;
	end process VIC_sel;
	
	
	screen.h_blank_minus_10 <= screen.h_blank - 10; 
	screen.total_width <= screen.width + screen.h_blank;
	screen.total_height <= screen.height + screen.v_blank; 
	
	screen.max_x <=	to_signed(screen.width - 1, 13);
	screen.min_x <=	to_signed(- screen.h_blank, 13);
	screen.max_y <=	to_signed(screen.height - 1, 13);
	screen.min_y <=	to_signed(-screen.v_blank, 13);

	screen.min_hsync_x <=	screen.min_x + screen.hsync_beg;
	screen.max_hsync_x <=	screen.min_x + screen.hsync_end;
	screen.min_vsync_y <=	screen.min_y + screen.vsync_beg;
	screen.max_vsync_y <=	screen.min_y + screen.vsync_end;

end architecture;
