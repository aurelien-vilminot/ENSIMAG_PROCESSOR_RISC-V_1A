# TAG = srai
	.text

    lui x31, 0
    lui x31, 0xfffff
    srai x31, x31, 0x001

    srai x31, x31, 0x00a

    lui x31, 0
    lui x31, 0x0ffff
    srai x31, x31, 0x00a

	# max_cycle 100
	# pout_start
    # 00000000
    # fffff000
    # fffff800
    # fffffffe
    # 00000000
    # 0ffff000
    # 0003fffc
	# pout_end
