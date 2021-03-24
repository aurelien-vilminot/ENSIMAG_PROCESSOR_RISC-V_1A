# TAG = or
	.text

    lui x29, 0xfffff
    lui x30, 0x00000
    or x31, x30, x29
    addi x30, x30, 0x001
    or x31, x31, x30

	# max_cycle 100
	# pout_start
	# fffff000
    # fffff001
	# pout_end