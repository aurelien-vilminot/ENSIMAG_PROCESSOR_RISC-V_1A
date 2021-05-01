# TAG = lbu
	.text
    lui x31, 0	# 1000
	lui x30, 0	# 1004

    lui x28, 0x00001

    lbu x31, 0(x28)	# Test de non extension de signe à 1

	add x31, x0, x0
	lbu x31, 4(x28)	# Test de non extension de signe à 0

	# max_cycle 100
	# pout_start
    # 00000000
	# 000000b7
	# 00000000
	# 00000037
	# pout_end