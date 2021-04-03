# TAG = xori
	.text

    lui x2, 0xfffff
    addi x2, x2, 0x123
    lui x31, 0
    xori x31, x2, 0x103
    xori x31, x31, 0x000

	# max_cycle 100
	# pout_start
	# 00000000
    # FFFFF020
    # FFFFF020
	# pout_end