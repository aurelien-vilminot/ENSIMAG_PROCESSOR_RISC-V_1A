# TAG = ori
	.text

    lui x29, 0xfffff
    addi x29, x29, 0x00f
    lui x31, 0
    ori x31, x29, 0x00f

	# max_cycle 100
	# pout_start
    # 00000000
	# fffff00f
	# pout_end