BEGIN {
    # Variables globales à usage général
    address_base = 0x00000000; # TODO On veut 0x1000 ici
	besoin_balise = 0; # Détermine si on a besoin d'une balise de fin de section. C'est toujours le cas sauf avant la première section.
	ad_prev = -1;
    balise = "FFFFFFFF" # Balise de fin de section (constante)

    # Variables pour gérer les demi-mots
	incomplete = 0; # Indique si un premier demi-mot à été détecté
    half = 0; # Stocke la valeur du premier demi-mot
}

# Détection des sections
/^[0-9a-f]+ /{
    ad  = (strtonum("0x" $1) - address_base) / 4; # Normalisation par rapport à l'adresse de base et adressage en mot de 32 bit pour le format .mem
    formated_ad = sprintf("%08x", ad); # Adresse formatée
    if (ad != ad_prev) {
        # Affichage d'une sentinelle de fin de section
	    if (besoin_balise) print balise;
        # Affichage de début de section
	    print "@" formated_ad; 
    }
    besoin_balise = 1;
    # MAJ de l'adresse precedente
    ad_prev = ad;
}


# Détection des instructions/données
/^\s*[0-9a-f]+:\s/{
	#Strip du :
	ad=$1
	gsub(":", "", ad);
	ad  = int((strtonum("0x" ad) - address_base) / 4); # Contient l'adresse normalisée de la donnée
    formated_ad = sprintf("%08x", ad); # Adresse formatée
	
    if(length($2)==4){ # Cas où la valeur est sous la forme d'un demi mot (format du .data)

	    if (ad == ad_prev) {
		    # Test pour savoir si on a deja vu un demi mot 
	        if (incomplete == 0) {
		    #On stock le demi mot de l'adresse courante
	            half = $2
		    # Incomplete == 1 indique qu'on a recuperer la premiere partie du mot
	            incomplete = 1;
	        } 
            else {
		    # On affiche un mot composé des deux demi mots
               print $2 half ;
		    # Initialisation de incomplete
               incomplete = 0;
		       ad_prev += 1;
            }
	    } 
        else {
		    if (besoin_balise) print balise;
		    print "@" formated_ad;
	        if (incomplete == 0) {
		        half = $2
		        incomplete = 1;
	            } 
            else {
	            print $2 half " " ;
	            incomplete = 0;
	        }   
		    ad_prev=ad;
	    }
	    besoin_balise = 1;
	}
	else { # Cas ou la valeur est sous la forme d'un mot complet
	    if (ad != ad_prev) {
		    if (besoin_balise) {
                print balise;
            }
		    print "@" formated_ad;
		    ad_prev=ad;
	    }
		print $2
	    # Incrementation de l'adresse precedente
	    ad_prev += 1;
	    besoin_balise = 1;
    }
}

END {
	if (incomplete == 1)
        print "0000" half; # Cas ou la derniere ligne de code est un .int
	if (ad_prev < 0x2000/4)
		print balise;
}

