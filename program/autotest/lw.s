# TAG = lw
	.text
    lui x31, 0			# 1000
	lui x31, 0xF16FE	# 1004

    lui x28, 0x00001
    lw x31, 0(x28)
	lw x31, 4(x28)

	# max_cycle 100
	# pout_start
    # 00000000
	# F16FE000
	# 00000FB7
	# F16FEFB7
	# pout_end