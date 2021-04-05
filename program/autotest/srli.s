# TAG = srli
	.text

    lui x31, 0
    lui x31, 0xfffff
    srli x31, x31, 0x001
    srli x31, x31, 0x00a

	# max_cycle 100
	# pout_start
    # 00000000
    # fffff000
    # 7ffff800
    # 001ffffe
	# pout_end
