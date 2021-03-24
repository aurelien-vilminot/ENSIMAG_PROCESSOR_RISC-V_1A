# TAG = sll
	.text

	lui x30, 0       #Test chargement d'une valeur nulle
    addi x30, x30, 0x001
    lui x31, 0
    lui x31, 0xfffff
    sll x31, x31, x30

	# max_cycle 100
	# pout_start
    # 00000000
    # fffff000
    # ffffe000
	# pout_end
