# TAG = xor
	.text

	lui x29, 0xfffff
    lui x30, 0x00000
    xor x31, x29, x30
    xor x31, x31, x29
    lui x28, 0x00101
    xor x31, x31, x28
    xor x31, x31, x31
    

	# max_cycle 100
	# pout_start
	# fffff000
	# 00000000
    # 00101000
    # 00000000
	# pout_end