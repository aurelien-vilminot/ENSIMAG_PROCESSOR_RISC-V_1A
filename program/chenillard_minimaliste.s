.text
# On place un index dans x1
ori  x1, x0, 21
# On place un masque dans x2 correspondant à la valeur 2^index
ori  x2, x0, 1
sll  x2, x2, x1
# On place un compteur dans x3 qu'on incrémente (on se fiche de la valeur initiale)
addi x3, x3, 1
# On regarde si le compteur active le masque.
# Le résultat est placé dans x4 : 0 ou 1
and  x4, x3, x2
srl  x4, x4, x1
# Si la valeur (x4) change par rapport à celle de l'itération précédente (x6),  on détecte un évènement de période 2^index*durée_itérations
# Le changement est mis dans x5
xor  x5, x4, x6
# On conserve la valeur courante dans x6
or   x6, x0, x4
# Le motif à afficher est dans x7.
# On le décale de x5 (0 ou 1) position vers la gauche
sll  x7, x7, x5
# On allume le bit de poids faible
ori x7, x7, 1
# On envoie sur les LED pour MMIPS simple
or  x31, x0, x7
# Via l'instruction de garde que rajoute l'assembleur,  on réinitialise PC.
# Donc on reboucle sur la première instruction.
