# TAG = lb
	.text
    lui x31, 0

    lui x28, 0x00001
    lb x31, 0(x28)
	# max_cycle 100
	# pout_start
    # 00000000
	# ffffffb7
	# pout_end