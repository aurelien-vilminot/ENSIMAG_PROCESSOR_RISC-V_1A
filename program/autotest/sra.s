# TAG = sra
	.text

	lui x30, 0       #Test chargement d'une valeur nulle
    addi x30, x30, 0x001
    lui x31, 0
    lui x31, 0xfffff
    sra x31, x31, x30

    lui x30, 0       
    addi x30, x30, 0x00a
    sra x31, x31, x30

    lui x31, 0
    lui x31, 0x0ffff
    sra x31, x31, x30

	# max_cycle 100
	# pout_start
    # 00000000
    # fffff000
    # fffff800
    # fffffffe
    # 00000000
    # 0ffff000
    # 0003fffc
	# pout_end
