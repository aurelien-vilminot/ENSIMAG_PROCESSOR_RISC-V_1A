# TAG = lb
	.text
    lui x31, 0	# 1000
	lui x30, 0	# 1004

    lui x28, 0x00001

    lb x31, 0(x28)	# Test extension de signe à 1

	add x31, x0, x0
	lb x31, 4(x28)	# Test extension de signe à 0

	# max_cycle 100
	# pout_start
    # 00000000
	# ffffffb7
	# 00000000
	# 00000037
	# pout_end