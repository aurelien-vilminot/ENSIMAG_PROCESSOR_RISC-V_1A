library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.HDMI_pkg.all;

-- Cet encodeur 8b/10b encode un signal de 8 bits
-- en signal de 10b. Les 2 bits supplémentaires
-- donnent des informations sur l'encodage utilisé.
-- Cet encodeur minimise le nombre de transitions et
-- envoie en moyenne autant de 1 que de 0.
-- Ces caractéristiques permettent un meilleur
-- transport physique du signal dans le câble.

entity VideoEncoder is
	port (
	D : in video_signal;
	q_out : out tmds_signal ;
	ce : in boolean := false;
	rst : in std_logic;
	clk : in std_logic
	);
end;

architecture behavior of VideoEncoder is
	-- Déclaration des signaux

	signal cnt_q : signed_w4 := (others => '0'); 	-- le compteur est compris entre 5 et -5 :
	signal cnt_d : signed_w4 := (others => '0'); 	-- le compteur est compris entre 5 et -5 :
	signal cnt_diff : signed_w4;			-- on l'écrit sur 4 bits.
	
	signal n1_q_m : integer := 0; 
	
	signal q_m : std_logic_vector(8 downto 0) := (others => '0');
	
	-- Calcule le nombre de 1 dans l'octet x.
	function N_1(x : std_logic_vector(7 downto 0) := (others => '0'))
		return integer is
		variable count : integer := 0;
	begin
        	for i in x'range loop   -- On compte les 1.
            		count := count + to_integer(unsigned(w31_zero & x(i)));
        	end loop;
        	return count;
	end N_1;
	
begin

-- Le circuit suivant est décrit dans la spécification HDMI 1.4a


update_synchrone : process (clk, ce) is
begin
	if clk'event and clk='1' then
		if rst = '1' then 
			cnt_q <= (others => '0');
		elsif ce then	
			cnt_q <= cnt_d;
		end if;
	end if;
end process update_synchrone;
update_seq : process (D) is
	variable Dxor : std_logic_vector(7 downto 0);
	variable Dxnor: std_logic_vector(7 downto 0);
	variable n1_D : integer;
begin
	Dxor(0) := D(0);
	Dxnor(0) := D(0);

	for i in 1 to 7 loop
		Dxor(i) := Dxor(i - 1) xor D(i); -- Les signaux Dxor(i) (resp. Dxnor(i)) contiennent les xor (resp. xnor) successifs des bits D(0)...D(i)
		Dxnor(i) := Dxnor(i - 1) xnor D(i);
	end loop;
	
	n1_D := N_1(D);
	-- On essaie minimise d'abord le nombre de transitions.
	-- Pour cela, on utilise des xnor/xor successifs (pourquoi ça marche ? je ne sais pas)
	-- On stocke le résultat dans q_m, qui est un signal intermédiaire.
	-- Le 8ème bit de q_m vaut 0 si on a choisit xnor et 1 si on a choisit xor.
	-- Cela permet le décodage.
	if n1_D > 4 or (n1_D = 4 and D(0) = '0') then 
	    q_m(7 downto 0) <= Dxnor;
	    q_m(8) <= '0';
	else
	    q_m(7 downto 0) <= Dxor;
	    q_m(8) <= '1';
	end if;
end process update_seq;

n1_q_m <= N_1(q_m(7 downto 0));

update_comb : process (q_m, n1_q_m, cnt_q) is
begin
	-- La deuxième étape consiste à  décider si l'on doit inverser ou non
	-- la chaîne intermédiaire, pour être DC-balanced i.e avoir autant
	-- de 0 que de 1 en moyenne dans le signal
	
	-- Le signal CNT_q contient la différence actuelle entre le nombre de 1
	-- et de 0 émis. Il s'avère que ce signal est toujours pair, donc on effectue
	-- tout les calculs en les divisant par 2.
	   
	--- Si il y a autant de 1 que de 0, dans ce mot ou bien dans le compte.
	-- Alors inverser ne change rien et on décide d'inverser seulement pour
	-- garder l'équilibre.
	
	
	if cnt_q = 0 or n1_q_m = 4 then
		q_out(9) <= not q_m(8); -- le 9 ème bit vaut l'inverse du 8 ème
		q_out(8) <= q_m(8);  -- pour garder l'équilibre.
		if(q_m(8) = '0') then
	    		cnt_d <= cnt_q + to_signed(4 - n1_q_m, cnt_diff'length); -- 4 - n1 = (n0 - n1) / 2
	    		q_out(7 downto 0) <= not q_m(7 downto 0);
		else
	    		cnt_d <= cnt_q + to_signed(n1_q_m - 4, cnt_diff'length); -- n1 - 4 = (n1 - n0) / 2
	    		q_out(7 downto 0) <= q_m(7 downto 0);
		end if;
	else
		-- Si on va augmenter le compte alors qu'il est positif
		-- Ou diminuer le compte alors qu'il est négatif
		-- On inverse les bits.
		-- Les comparaisons entre n1 et 4 sont équivalentes à des comp avec n0.
		if((cnt_q > 0 and n1_q_m > 4)
	    	or (cnt_q < 0 and n1_q_m < 4)) then
	    		q_out(9) <= '1';
	    		q_out(8) <= q_m(8);
	    		q_out(7 downto 0) <= not q_m(7 downto 0);
	    
	    		-- On rajoute 2 * q_m(8) au compteur car si q_m(8) == 0, il y a
	    		-- q_out(9) et q_out(8) sont différents et on doit
	    		-- simplement rajouter la différence sur q_out(0...7)
	    		-- Si q_m(8) == 1, q_out(8) == q_out(9) == 1 : on rajoute 2
	    		-- on fait n0 - n1 = 8 - 2 n1 car q_out est l'inverse de q_m.
			
			-- On divise par deux ensuite car le signal est toujours pair,
			-- On ajoute finalement q_m.
	    		cnt_d <= cnt_q + ('0' & q_m(8)) + to_signed(4 - n1_q_m, cnt_diff'length);
		else
	    		q_out(9) <= '0';
	    		q_out(8) <= q_m(8);
	    		q_out(7 downto 0) <= q_m(7 downto 0);

	    		-- Même astuce qu'au-dessus.
	    		cnt_d <= cnt_q  - ('0' & (not q_m(8))) + to_signed(n1_q_m - 4, cnt_diff'length);
		end if;
	end if;
end process update_comb;
end architecture behavior;  
