# TAG = andi
	.text

	# Parameter
	lui x6, 0xf0f0f
	addi x6, x6, 0x103

	# Classic tests
    andi x31, x0, 0x123
	andi x31, x6, 0x123

	# max_cycle 100
	# pout_start
	# 00000000
	# 00000103
	# pout_end