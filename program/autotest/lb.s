# TAG = lb
    .data
    p:.byte 55

	.text
    lui x31, 0
    lb x31, p

	# max_cycle 100
	# pout_start
    # 00000000
	# 00000037
	# pout_end