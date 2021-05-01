# TAG = xor
	.text

    # Parameters
	lui x5, 0xfffff
    lui x6, 0x00000

    # Classic tests
    xor x31, x5, x6
    xor x31, x31, x5

    # More
    lui x7, 0x00101
    xor x31, x31, x7
    xor x31, x31, x31
    

	# max_cycle 100
	# pout_start
	# fffff000
	# 00000000
    # 00101000
    # 00000000
	# pout_end