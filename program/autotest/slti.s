# TAG = slti
	.text

    lui x29, 0
    slti x31, x29, 0x001
    lui x29, 0x11000
    slti x31, x29, 0x001

	# max_cycle 100
	# pout_start
    # 00000001
	# 00000000
	# pout_end