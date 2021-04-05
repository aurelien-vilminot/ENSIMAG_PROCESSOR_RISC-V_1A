# TAG = slt
	.text

    lui x29, 0
    lui x30, 0x00001
    slt x31, x29, x30
    slt x31, x30, x29
    lui x30, 0

	# max_cycle 100
	# pout_start
    # 00000001
	# 00000000
	# pout_end