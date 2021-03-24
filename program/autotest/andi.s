# TAG = andi
	.text

    lui x2, 0xfffff
    addi x2, x2, 0x123
    lui x31, 0
    andi x31, x2, 0x103

	# max_cycle 100
	# pout_start
	# 00000000
	# 00000103
	# pout_end