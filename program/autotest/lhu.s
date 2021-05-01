# TAG = lhu
    .text

    lui x31, 11
	lui x31, 0

    lui x28, 0x00001
	
    lhu x31, 4(x28)	# Test de non extension de signe à 0

	add x31, x0, x0
	lhu x31, 0(x28)	# Test de non extension de signe à 1

	# max_cycle 100
	# pout_start
	# 0000b000
    # 00000000
	# 00000fb7
	# 00000000
	# 0000bfb7
	# pout_end