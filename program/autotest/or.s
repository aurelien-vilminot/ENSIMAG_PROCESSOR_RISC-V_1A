# TAG = or
	.text

    # Parameters
    lui x5, 0xfffff
    lui x6, 0x00000

    # Classic tests
    or x31, x5, x6
    addi x6, x6, 0x001
    or x31, x31, x6

	# max_cycle 100
	# pout_start
	# fffff000
    # fffff001
	# pout_end