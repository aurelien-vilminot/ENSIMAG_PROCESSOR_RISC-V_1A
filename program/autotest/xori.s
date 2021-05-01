# TAG = xori
	.text

    # Parameter
    lui x5, 0xfffff
    addi x5, x5, 0x123

    # Tests
    xori x31, x5, 0x103
    xori x31, x31, 0x000

	# max_cycle 100
	# pout_start
	# fffff020
    # fffff020
	# pout_end