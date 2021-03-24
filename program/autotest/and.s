# TAG = and
	.text

	lui x1, 0xfffff
    lui x2, 0xfffff
    lui x31, 0
    and x31, x1, x2
    and x31, x31, x0
    lui x3, 0x10200
    lui x4, 0x10300
    and x31, x3, x4

	# max_cycle 100
	# pout_start
	# 00000000
	# fffff000
	# 00000000
    # 10200000
	# pout_end