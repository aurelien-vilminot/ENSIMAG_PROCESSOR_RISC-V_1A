# TAG = srl
	.text

	lui x30, 0       #Test chargement d'une valeur nulle
    addi x30, x30, 0x001
    lui x31, 0
    lui x31, 0xfffff
    srl x31, x31, x30

    lui x30, 0       
    addi x30, x30, 0x00a
    srl x31, x31, x30

	# max_cycle 100
	# pout_start
    # 00000000
    # fffff000
    # 7ffff800
    # 001ffffe
	# pout_end
