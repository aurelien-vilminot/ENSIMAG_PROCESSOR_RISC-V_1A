library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;

entity GeneRGB is
	port(
		x : in signed(12 downto 0);
		y : in signed(12 downto 0);
		r : out video_signal;
		g : out video_signal;
		b : out video_signal
	);
end entity GeneRGB;

architecture simple_mire of GeneRGB is
begin
		
	r <= std_logic_vector(x(8 downto 1));
	g <= std_logic_vector(y(8 downto 1));
	b <= std_logic_vector(x(8 downto 1));

end architecture simple_mire;
