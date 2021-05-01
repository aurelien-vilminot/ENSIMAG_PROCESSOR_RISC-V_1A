# TAG = sub
	.text
	
	# Parameters
	lui x5, 0
	addi x5, x5, 0x007
	lui x6, 0
	addi x6, x6, 0x002

	# Classic tests
    sub x31, x5, x6

	lui x5, 0xf1001
	lui x6, 0xd1001
	sub x31, x5, x6

	# Test overflow
	lui x5, 0xf1000
	sub x31, x6, x5

	# max_cycle 50
	# pout_start
    # 00000005
	# 20000000
	# e0001000
	# pout_end