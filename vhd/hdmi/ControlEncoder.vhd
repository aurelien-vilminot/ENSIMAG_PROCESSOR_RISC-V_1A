library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;

entity ControlEncoder is
	
	port (
	D : in control_signal;
	q_out : out tmds_signal
    );
end entity;

architecture simple_mapping of ControlEncoder is
begin

-- On encode le signal de contrôle en utilisant des codes qui
-- sont inaccessibles par l'Encodeur vidéo. En effet :
-- 1101010100 -- décodeur vidéo --> 11111101
-- 0010101011 -- décodeur vidéo --> 00000011
-- 0101010100 -- décodeur vidéo --> 11111100
-- 1010101011 -- décodeur vidéo --> 00000010

-- Les résultats de ce contrôleur sont inaccessibles par le contrôleur vidéo
-- car ils représentent un encodage de mots ou le nombre de
-- transitions n'est pas minimisé alors que l'encodeur vidéo minimise les transitions. (concrètement, on devrait
-- utiliser xor au lieu de xnor ou l'inverse, voir VideoEncoder.vhd).

-- Cette table est disponible dans la spécification HDMI1.4a.

update : process (D) is
begin
    case D is
    
    when "01" =>
        q_out <= "0010101011";
    when "10" =>
        q_out <= "0101010100";
    when "11" =>
        q_out <= "1010101011";
    when others =>
        q_out <= "1101010100";
    end case;
end process;
end architecture;
