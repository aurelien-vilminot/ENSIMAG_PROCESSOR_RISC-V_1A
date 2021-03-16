library ieee;
use ieee.std_logic_1164.all;

use work.HDMI_pkg.all;

entity TERC4Encoder is
	port (

	D : in aux_signal;
	q_out : out tmds_signal
	
	);
end;
-- TMDS Error Reducton Coding

-- Selon la spécification HDMI1.4a
-- TERC4 : significantly reduces the error rate on the link
-- by choosing only 10-bit codes with high inherent error avoidance.

-- La distance de Hamming minimale est de 2 et la distance de Hamming moyenne
-- est de 5. On peut donc en moyenne corriger 2 erreurs.

-- De plus les signaux ici sont DC-balanced (autant de 0 que de 1).

-- Cette table est disponible dans la spécification HDMI1.4a
architecture simple_mapping of TERC4Encoder is
begin

process (D) is
begin
    case D is
    when "0000" =>
        q_out <= "1010011100";
    when "0001" =>
        q_out <= "1001100011";
    when "0010" =>
        q_out <= "1011100100";
    when "0011" =>
        q_out <= "1011100010";
    when "0100" =>
        q_out <= "0101110001";
    when "0101" =>
        q_out <= "0100011110";
    when "0110" =>
        q_out <= "0110001110";
    when "0111" =>
        q_out <= "0100111100";
    when "1000" =>
        q_out <= "1011001100";
    when "1001" =>
        q_out <= "0100111001";
    when "1010" =>
        q_out <= "0110011100";
    when "1011" =>
        q_out <= "1011000110";
    when "1100" =>
        q_out <= "1010001110";
    when "1101" =>
        q_out <= "1001110001";
    when "1110" =>
        q_out <= "0101100011";
    when "1111" =>
        q_out <= "1011000011";
    when others =>
        q_out <= "1010011100";
    end case;
end process;
end architecture;  
