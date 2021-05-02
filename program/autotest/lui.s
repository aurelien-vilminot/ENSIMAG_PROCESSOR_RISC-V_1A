# TAG = lui
	.text

	lui x31, 0       	# Test chargement d'une valeur nulle
	lui x31, 0xfffff 	# Test chargement d'une valeur maximale sur 20 bits
	lui x31, 0x12345	# Test chargement d'une valeur quelconque

	addi x31, x31, 0x25
	lui x31, 0x891e1	# Vérification de remise à zéro des bits de poids faibles

	# max_cycle 50
	# pout_start
	# 00000000
	# FFFFF000
	# 12345000
	# 12345025
	# 891E1000
	# pout_end
