library ieee;
use ieee.std_logic_1164.all;

library unisim; -- Pour la simulation, on a besoin de simuler les primitives de la carte Zybo.
use unisim.VComponents.all;

use work.HDMI_pkg.all;

entity OutputSERDES is
	port(
	D : in tmds_signal;
	rst: in std_logic;

	clk : in std_logic;	-- Contient l'horloge à la fréquence TMDS / 2.
				-- C'est à dire la fréquence de transmission
				-- des bits / 2.
				-- Attention : Cette fréquence est en fait divisée
				-- par deux car on utilise un DDR (double data rate)
				-- Et le composant change la sortie sur TOUT les
				-- fronts de cette horloge.
	clk_div : in std_logic; -- Contient l'horloge à la fréquence de la pixel clock.	

	q : out std_logic
	);
end entity OutputSERDES;

-- Dans ce composant, on utilise uniquement des primitives de la carte Zybo,
-- Car on a besoin de pouvoir émettre un stream de bit à une fréquence trop
-- élevée pour les circuits simulés sur la Zybo.

architecture primitive of OutputSERDES is
	signal shift1 : std_logic;
	signal shift2 : std_logic;
	signal delay_in : std_logic;
begin
	-- On utilise deux primitives de type OSERDESE2.
	-- Un OSERDESE2 (Output Serializer-Deserializer) permet de transformer des
	-- données en parallèle (ici notre entrée) en donnée en série (la sortie).
	-- On en a besoin de deux, reliés, car un seul peut seulement traiter une
	-- sérialization de jusqu'à 8 bits.
	master : OSERDESE2
	generic map (
		DATA_RATE_OQ => "DDR",
		DATA_RATE_TQ => "SDR",
		DATA_WIDTH => 10,
		SERDES_MODE => "MASTER",
		TRISTATE_WIDTH => 1
	)
	port map (
		-- entrées
		CLK => clk,
		CLKDIV => clk_div,
		D1 => D(0), -- On envoie en premier le bit de poids fort.
		D2 => D(1),
		D3 => D(2),
		D4 => D(3),
		D5 => D(4),
		D6 => D(5),
		D7 => D(6),
		D8 => D(7),
		
		T1 => '0',
		T2 => '0',
		T3 => '0',
		T4 => '0',

		TCE => '0',
		OCE => '1',
		TBYTEIN => '0',
		RST => rst,
		SHIFTIN1 => shift1,
		SHIFTIN2 => shift2,	
		-- sorties
		OQ => q, -- la donnée de sortie.
		OFB => open,
		TQ => open, -- signal de contrôle d'un IOBUF (que l'on utilise pas)
		TFB => open,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open
	);
	slave : OSERDESE2
	generic map (
		DATA_RATE_OQ => "DDR",
		DATA_RATE_TQ => "SDR",
		DATA_WIDTH => 10,
		SERDES_MODE => "SLAVE",
		TRISTATE_WIDTH => 1
	)
	port map (
		-- entrées
		CLK => clk,
		CLKDIV => clk_div,
		D1 => '0',
		D2 => '0',
		D3 => D(8),
		D4 => D(9),
		D5 => '0',
		D6 => '0',
		D7 => '0',
		D8 => '0',
		
		T1 => '0',
		T2 => '0',
		T3 => '0',
		T4 => '0',

		TCE => '0',
		OCE => '1',
		TBYTEIN => '0',
		RST => rst,
		SHIFTIN1 => '0',
		SHIFTIN2 => '0',
		-- sorties
		SHIFTOUT1 => shift1,
		SHIFTOUT2 => shift2,	
		OQ => open, -- la donnée de sortie.
		OFB => open,
		TQ => open, -- signal de contrôle d'un IOBUF (que l'on utilise pas)
		TFB => open
	);
end architecture primitive;
