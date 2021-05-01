# TAG = lh
    .text

    lui x31, 11
	lui x31, 0

    lui x28, 0x00001
	
    lh x31, 4(x28)	# Test extension de signe à 0

	add x31, x0, x0
	lh x31, 0(x28)	# Test extension de signe à 1

	# max_cycle 100
	# pout_start
	# 0000b000
    # 00000000
	# 00000fb7
	# 00000000
	# ffffbfb7
	# pout_end