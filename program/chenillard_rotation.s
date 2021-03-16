.text
# Le motif du chenillard (2 bits consécutifs) est mis dans x1
# Le chenillard est sur 4 LED
	ori  x1, x0, 0x3

boucle_infinie:
	# Durée d'attente dépend de la fréquence
	li   x2, 10000000

boucle_attente:
	addi x2, x2, -1
	bne  x2, x0, boucle_attente
	# On affiche le motif
	ori  x31, x1, 0
	# On décale le motif
	sll  x1, x1, 1
	# On cherche un dépassement en dehors des 4 LED
	andi x2, x1, 0x10
	beq  x2, x0, boucle_infinie
	# En cas de changement, on ramène la LED qui sort sur la première LED
	andi x1, x1, 0xf
	ori  x1, x1, 0x1
	j    boucle_infinie
