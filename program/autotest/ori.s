# TAG = ori
	.text

    # Parameter
    lui x5, 0xfffff
    addi x5, x5, 0x123

    # Tests
    ori x31, x0, 0x103
    ori x31, x5, 0x120
    ori x31, x31, 0x5ff

	# max_cycle 100
	# pout_start
    # 00000103
	# fffff123
    # fffff5ff
	# pout_end