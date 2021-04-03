# TAG = slli
	.text

    lui x31, 0
    lui x31, 0xfffff
    slli x31, x31, 0x001
    slli x31, x31, 0x00c

	# max_cycle 100
	# pout_start
    # 00000000
    # fffff000
    # ffffe000
    # fe000000
	# pout_end
