# TAG = and
	.text

    # Parameters
	lui x5, 0xfffff
    lui x6, 0xfffff

    # Classic tests
    and x31, x5, x6
    and x31, x31, x0

    # More 
    lui x5, 0x10200
    lui x6, 0x10300
    and x31, x5, x6

	# max_cycle 100
	# pout_start
	# fffff000
	# 00000000
    # 10200000
	# pout_end